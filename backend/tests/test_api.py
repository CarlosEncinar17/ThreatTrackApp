"""
Pruebas de contrato de la API: forma de las respuestas, filtros, estadisticas,
autenticacion por rol y recorte de datos por cliente.
"""
from django.test import override_settings
from rest_framework.authtoken.models import Token
from rest_framework.test import APIClient, APITestCase

from apps.alerts.models import GithubCommitAlert

from .fixtures import create_alerts, create_customers, create_lookups, create_users


class ApiFixtureMixin:
    @classmethod
    def setUpTestData(cls):
        cls.states, cls.severities = create_lookups()
        cls.alpha, cls.beta = create_customers()
        cls.alpha_domain, cls.alpha_github, cls.alpha_host = create_alerts(cls.alpha, cls.states, cls.severities, tag="alpha")
        cls.beta_domain, cls.beta_github, cls.beta_host = create_alerts(cls.beta, cls.states, cls.severities, tag="be")
        cls.analyst, cls.client_user, cls.nobody = create_users(cls.alpha)

    def as_user(self, user):
        client = APIClient()
        token, _ = Token.objects.get_or_create(user=user)
        client.credentials(HTTP_AUTHORIZATION=f"Token {token.key}")
        return client


@override_settings(API_REQUIRE_AUTH=False)
class PublicContractTests(ApiFixtureMixin, APITestCase):
    """Con API_REQUIRE_AUTH=False la API se comporta como el sistema original (anonima)."""

    def test_list_is_paginated_with_standard_shape(self):
        response = self.client.get("/api/Github/")
        self.assertEqual(response.status_code, 200)
        body = response.json()
        self.assertEqual(set(body), {"count", "next", "previous", "results"})
        self.assertEqual(body["count"], 2)

    def test_page_size_is_capped_at_100(self):
        response = self.client.get("/api/Github/?page_size=500")
        self.assertEqual(response.status_code, 200)

    def test_alert_fields_use_v2_names(self):
        row = self.client.get("/api/Github/").json()["results"][0]
        for key in ("customer", "customer_name", "state", "state_name", "severity", "severity_name",
                    "monitored_domain", "domain_name", "detected_at", "notes", "commit_hash"):
            self.assertIn(key, row)
        for legacy in ("client_id", "criticity", "status", "observations", "created_at", "commit"):
            self.assertNotIn(legacy, row)

    def test_filters_by_customer_state_severity_and_dates(self):
        self.assertEqual(self.client.get(f"/api/Github/?customer={self.alpha.id}").json()["count"], 1)
        self.assertEqual(self.client.get(f"/api/Github/?state={self.states['resolved'].id}").json()["count"], 0)
        self.assertEqual(self.client.get(f"/api/Github/?severity={self.severities['high'].id}").json()["count"], 2)
        self.assertEqual(self.client.get("/api/Certificates/?date_from=2000-01-01&date_to=2000-01-02").json()["count"], 0)

    def test_invalid_date_returns_400_not_500(self):
        self.assertEqual(self.client.get("/api/Github/?date_from=ayer").status_code, 400)

    def test_unknown_ordering_field_is_ignored(self):
        self.assertEqual(self.client.get("/api/Github/?ordering=customer__notes").status_code, 200)

    def test_search(self):
        self.assertEqual(self.client.get("/api/Github/?search=repo-alpha").json()["count"], 1)

    def test_child_alerts_are_filtered_through_their_parent(self):
        self.assertEqual(self.client.get(f"/api/ShodanPorts/?customer={self.alpha.id}").json()["count"], 1)
        self.assertEqual(self.client.get(f"/api/Secrets/?customer={self.beta.id}").json()["count"], 1)

    def test_create_alert_applies_default_state_and_severity(self):
        payload = {
            "customer": self.alpha.id, "monitored_domain": self.alpha_domain.id, "repository": "new-repo",
            "author_name": "x", "author_email": "x@example.com", "commit_hash": "abc", "url": "https://x",
            "committed_at": "2025-01-01T10:00:00Z",
        }
        response = self.client.post("/api/Github/", payload, format="json")
        self.assertEqual(response.status_code, 201, response.content)
        self.assertEqual(response.json()["state_name"], "open")
        self.assertEqual(response.json()["severity_name"], "unknown")

    def test_duplicate_alert_is_rejected_with_400(self):
        payload = {
            "customer": self.alpha.id, "monitored_domain": self.alpha_domain.id, "repository": "repo-alpha",
            "author_name": "dev", "author_email": "dev@example.com", "commit_hash": "hash-alpha", "url": "https://x",
            "committed_at": "2025-01-01T10:00:00Z",
        }
        response = self.client.post("/api/Github/", payload, format="json")
        self.assertEqual(response.status_code, 400)
        self.assertIn("non_field_errors", response.json())

    def test_deleting_referenced_customer_returns_409(self):
        self.assertEqual(self.client.delete(f"/api/Clients/{self.alpha.id}/").status_code, 409)

    def test_deleting_domain_cascades_to_its_alerts(self):
        self.assertEqual(self.client.delete(f"/api/Domains/{self.alpha_domain.id}/").status_code, 204)
        self.assertFalse(GithubCommitAlert.objects.filter(pk=self.alpha_github.id).exists())

    def test_update_and_delete(self):
        url = f"/api/Github/{self.alpha_github.id}/"
        response = self.client.patch(url, {"state": self.states["resolved"].id, "notes": "cerrada"}, format="json")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["state_name"], "resolved")
        self.assertEqual(self.client.delete(url).status_code, 204)
        self.assertFalse(GithubCommitAlert.objects.filter(pk=self.alpha_github.id).exists())

    def test_statistics_shapes(self):
        status_counts = self.client.get("/api/status-counts/").json()
        self.assertEqual(status_counts["window_days"], 30)
        self.assertEqual(status_counts["open"]["github"], 2)
        self.assertEqual(status_counts["resolved"]["certificates"], 0)  # fuera de la ventana de 30 dias

        totals = self.client.get("/api/total-count-open-resolved/").json()
        self.assertEqual(totals, {"open": 4, "resolved": 4})  # github+shodan abiertos; certificados+puertos resueltos

        by_severity = self.client.get("/api/criticity-counts/").json()
        self.assertEqual(list(by_severity), ["critical", "high", "medium", "low", "informative"])
        self.assertEqual(by_severity["high"], 2)

        split = self.client.get("/api/cases-by-status-and-criticity/").json()
        self.assertEqual(split["open_by_severity"]["medium"], 2)
        self.assertEqual(split["resolved_by_severity"]["low"], 2)

        modules = self.client.get("/api/case-counts-by-module/").json()
        self.assertEqual(modules["open_by_module"]["information_leaks"], 2)
        self.assertEqual(modules["resolved_by_module"]["system_vulnerabilities_monitoring"], 2)

        daily = self.client.get("/api/stacked-bar-chart/").json()
        self.assertEqual(set(daily), {"days", "open", "resolved"})
        self.assertEqual(len(daily["days"]), len(daily["open"]))

        per_module = self.client.get("/api/daily-counts-services/").json()
        self.assertEqual(set(per_module["by_module"]), {
            "information_leaks", "credential_exposure", "defacement", "domain_monitoring",
            "system_vulnerabilities_monitoring", "phishing_and_fraudulent_domains",
        })

        self.assertEqual(self.client.get("/api/ips-count/").json(), {"active": 0, "inactive": 2})
        self.assertEqual(self.client.get("/api/domains-count/").json(), {"active": 2, "inactive": 0})

    def test_statistics_can_be_scoped_by_customer(self):
        totals = self.client.get(f"/api/total-count-open-resolved/?customer={self.alpha.id}").json()
        self.assertEqual(totals, {"open": 2, "resolved": 2})

    def test_health(self):
        self.assertEqual(self.client.get("/api/health/").json(), {"status": "ok"})


@override_settings(API_REQUIRE_AUTH=True)
class AuthenticatedContractTests(ApiFixtureMixin, APITestCase):
    def test_anonymous_is_rejected(self):
        self.assertEqual(self.client.get("/api/Github/").status_code, 401)
        self.assertEqual(self.client.get("/api/status-counts/").status_code, 401)

    def test_login_returns_token_role_and_customer(self):
        response = self.client.post("/api/auth/login/", {"username": "cli", "password": "client-pass-123"}, format="json")
        self.assertEqual(response.status_code, 200)
        body = response.json()
        self.assertIn("token", body)
        self.assertEqual(body["role"], "client")
        self.assertEqual(body["customer"], {"id": self.alpha.id, "name": "Alpha Corp"})

    def test_login_with_bad_password_fails(self):
        response = self.client.post("/api/auth/login/", {"username": "cli", "password": "wrong"}, format="json")
        self.assertEqual(response.status_code, 400)

    def test_analyst_has_full_access(self):
        client = self.as_user(self.analyst)
        self.assertEqual(client.get("/api/Github/").json()["count"], 2)
        response = client.patch(f"/api/Github/{self.beta_github.id}/", {"notes": "ok"}, format="json")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(client.get("/api/auth/session/").json()["role"], "analyst")

    def test_client_is_read_only_and_scoped_to_own_customer(self):
        client = self.as_user(self.client_user)
        rows = client.get("/api/Github/").json()
        self.assertEqual(rows["count"], 1)
        self.assertEqual(rows["results"][0]["customer"], self.alpha.id)
        self.assertEqual(client.get(f"/api/Github/{self.beta_github.id}/").status_code, 404)
        self.assertEqual(client.get("/api/Clients/").json()["count"], 1)
        self.assertEqual(client.get(f"/api/ShodanPorts/").json()["count"], 1)
        self.assertEqual(client.get(f"/api/Secrets/").json()["count"], 1)
        self.assertEqual(client.patch(f"/api/Github/{self.alpha_github.id}/", {"notes": "x"}, format="json").status_code, 403)
        self.assertEqual(client.post("/api/Clients/", {"name": "Evil", "is_active": True}, format="json").status_code, 403)

    def test_client_statistics_ignore_customer_parameter(self):
        client = self.as_user(self.client_user)
        totals = client.get(f"/api/total-count-open-resolved/?customer={self.beta.id}").json()
        self.assertEqual(totals, {"open": 2, "resolved": 2})
        self.assertEqual(client.get("/api/domains-count/").json(), {"active": 1, "inactive": 0})

    def test_user_without_role_is_forbidden(self):
        self.assertEqual(self.as_user(self.nobody).get("/api/Github/").status_code, 403)

    def test_logout_invalidates_token(self):
        client = self.as_user(self.analyst)
        self.assertEqual(client.post("/api/auth/logout/").status_code, 204)
        self.assertEqual(client.get("/api/Github/").status_code, 401)
