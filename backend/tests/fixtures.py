"""Datos minimos para las pruebas de contrato de la API."""
from datetime import timedelta

from django.conf import settings
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Group
from django.utils.timezone import now

from apps.accounts.models import UserProfile
from apps.alerts.models import (
    AlertSeverity,
    AlertState,
    CertificateAlert,
    GithubCommitAlert,
    LeakedSecretAlert,
    ShodanHostAlert,
    ShodanPortAlert,
)
from apps.assets.models import MonitoredDomain, MonitoredIpAddress
from apps.customers.models import Customer, CustomerServiceSubscription


def create_lookups():
    states = {name: AlertState.objects.create(name=name) for name in
              ["open", "in_progress", "resolved", "false_positive", "duplicated"]}
    severities = {name: AlertSeverity.objects.create(name=name) for name in
                  ["critical", "high", "medium", "low", "informative", "unknown"]}
    return states, severities


def create_customers():
    alpha = Customer.objects.create(name="Alpha Corp", is_active=True, registered_at=now())
    beta = Customer.objects.create(name="Beta Ltd", is_active=True, registered_at=now())
    for customer in (alpha, beta):
        CustomerServiceSubscription.objects.create(
            customer=customer, defacement_enabled=True, github_enabled=True, gitlab_enabled=True,
            google_enabled=True, intelx_enabled=True, shodan_enabled=True, telegram_enabled=True,
            twitter_enabled=True, typosquatting_enabled=True, certificates_enabled=True, blocklist_enabled=False,
        )
    return alpha, beta


def create_alerts(customer, states, severities, when=None, tag="a"):
    when = when or now()
    domain = MonitoredDomain.objects.create(domain_name=f"{tag}.example.com", customer=customer, is_active=True, added_at=when)
    MonitoredIpAddress.objects.create(ip_address=f"10.0.0.{len(tag)}", customer=customer, is_active=False, added_at=when)
    github = GithubCommitAlert.objects.create(
        monitored_domain=domain, repository=f"repo-{tag}", author_name="dev", author_email="dev@example.com",
        commit_hash=f"hash-{tag}", url="https://example.com", detected_at=when, committed_at=when,
        is_analyzed=False, customer=customer, state=states["open"], severity=severities["high"],
    )
    LeakedSecretAlert.objects.create(
        github_alert=github, line_start=1, line_end=1, column_start=1, column_end=5, matched_text="k=v",
        secret_value="v", file_path="settings.py", entropy_score=3.5, author_name="dev", author_email="dev@example.com",
        committed_at=when.date(), commit_message="init", detection_rule="generic", fingerprint_hash=f"fp-{tag}",
        commit_hash=f"hash-{tag}", detected_at=when.date(), state=states["open"], severity=severities["critical"],
    )
    CertificateAlert.objects.create(
        monitored_domain=domain, certificate_summary=f"cert-{tag}", detected_at=when - timedelta(days=45),
        customer=customer, state=states["resolved"], severity=severities["low"],
    )
    host = ShodanHostAlert.objects.create(
        ip_address=f"198.51.100.{len(tag)}", asn_number="AS1", country_name="ES", customer=customer,
        detected_at=when, state=states["open"], severity=severities["medium"],
    )
    ShodanPortAlert.objects.create(host_alert=host, port_number=22, detected_at=when,
                                   state=states["resolved"], severity=severities["informative"])
    return domain, github, host


def create_users(customer):
    user_model = get_user_model()
    analyst_group, _ = Group.objects.get_or_create(name=settings.ANALYST_GROUP)
    client_group, _ = Group.objects.get_or_create(name=settings.CLIENT_GROUP)
    analyst = user_model.objects.create_user("ana", password="analyst-pass-123")
    analyst.groups.add(analyst_group)
    client = user_model.objects.create_user("cli", password="client-pass-123")
    client.groups.add(client_group)
    UserProfile.objects.create(user=client, customer=customer)
    nobody = user_model.objects.create_user("nobody", password="nobody-pass-123")
    return analyst, client, nobody
