"""
Unica tabla de configuracion de las estadisticas: que fuentes de alerta existen, en que
modulo de servicio se agrupan y que fuentes participan en cada endpoint.

Se conserva exactamente la composicion del sistema original (por ejemplo, los puertos y
vulnerabilidades de Shodan cuentan en los totales pero no en el desglose por estado, y las
alertas de Shodan en formato antiguo no pertenecen a ningun modulo).
"""
from .models import (
    CertificateAlert,
    DefacementAlert,
    GithubCommitAlert,
    GitlabProjectAlert,
    GoogleSearchAlert,
    IntelxLeakAlert,
    ShodanHostAlert,
    ShodanLegacyAlert,
    ShodanPortAlert,
    ShodanVulnerabilityAlert,
    TelegramMessageAlert,
    TwitterPostAlert,
    TyposquattingAlert,
)

# Clave publica de cada fuente -> modelo. Las claves son las que devuelve la API.
ALERT_SOURCES = {
    "certificates": CertificateAlert,
    "defacement": DefacementAlert,
    "github": GithubCommitAlert,
    "gitlab": GitlabProjectAlert,
    "google": GoogleSearchAlert,
    "intelx": IntelxLeakAlert,
    "shodan_legacy": ShodanLegacyAlert,
    "shodan": ShodanHostAlert,
    "shodan_ports": ShodanPortAlert,
    "shodan_vulns": ShodanVulnerabilityAlert,
    "telegram": TelegramMessageAlert,
    "twitter": TwitterPostAlert,
    "typosquatting": TyposquattingAlert,
}

# Fuentes que participan en el desglose por estado y fuente (status-counts).
STATUS_COUNT_SOURCES = [
    "certificates", "defacement", "github", "gitlab", "google", "intelx",
    "shodan_legacy", "shodan", "telegram", "twitter", "typosquatting",
]

# Fuentes que participan en los totales de los dashboards.
DASHBOARD_SOURCES = list(ALERT_SOURCES)

# Modulos de servicio -> fuentes que los componen.
SERVICE_MODULES = {
    "information_leaks": ["github", "gitlab", "google"],
    "credential_exposure": ["intelx", "twitter", "telegram"],
    "defacement": ["defacement"],
    "domain_monitoring": ["certificates"],
    "system_vulnerabilities_monitoring": ["shodan", "shodan_ports", "shodan_vulns"],
    "phishing_and_fraudulent_domains": ["typosquatting"],
}

# Criticidades que se desglosan en los dashboards (en este orden). `unknown` no se muestra.
DASHBOARD_SEVERITIES = ["critical", "high", "medium", "low", "informative"]
