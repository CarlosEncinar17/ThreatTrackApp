#!/usr/bin/env python
"""Utilidad de linea de comandos de Django para ThreatTrackApp."""
import os
import sys


def main() -> None:
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:  # pragma: no cover - solo ocurre si Django no esta instalado
        raise ImportError(
            "No se ha podido importar Django. Comprueba que esta instalado y que el "
            "entorno virtual esta activado."
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == "__main__":
    main()
