"""
Desplaza todas las fechas de 02_seed.sql a un mes objetivo para que los dashboards
(ventanas de 30 y 365 dias desde hoy) muestren los datos de ejemplo.

Uso:
    python compose/db/tools/shift_seed_dates.py 2026-09-17

Regla (determinista e idempotente):
  * La fecha mas reciente del fichero pasa al dia indicado; las fechas del mismo periodo
    (las que, desplazadas igual, caen dentro del mes objetivo) conservan su separacion en dias.
  * Las fechas anteriores a ese periodo (altas, commits, ejecuciones previas...) se reparten en
    orden entre el dia 1 del mes y el dia anterior al primer dia del periodo reciente.
  * La hora del dia no cambia. Solo se tocan literales SQL con forma de fecha o timestamp.

Volver a ejecutarlo con otro dia desplaza el conjunto entero (ya cabe en un mes), por lo que
sirve para "refrescar" los datos de ejemplo mas adelante.
"""
from __future__ import annotations

import re
import sys
from datetime import date, datetime, timedelta
from pathlib import Path

SEED = Path(__file__).resolve().parents[1] / "02_seed.sql"
LITERAL = re.compile(r"'(\d{4}-\d{2}-\d{2})((?:[ T]\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}(?::?\d{2})?)?)?)'")
HEADER_MARK = "-- Fechas desplazadas a "


def build_mapping(dates: set[date], target_end: date) -> dict[date, date]:
    latest = max(dates)
    shift = target_end - latest
    month_start = target_end.replace(day=1)
    recent = {d for d in dates if d + shift >= month_start}
    older = sorted(dates - recent)
    mapping = {d: d + shift for d in recent}
    if older:
        first_recent = min(mapping.values())
        slots = (first_recent - month_start).days
        if slots <= 0:
            raise SystemExit("No queda hueco en el mes para las fechas anteriores; elige un dia mas tardio.")
        for rank, d in enumerate(older):
            mapping[d] = month_start + timedelta(days=rank * slots // len(older))
    return mapping


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    target_end = datetime.strptime(sys.argv[1], "%Y-%m-%d").date()
    text = SEED.read_text(encoding="utf-8")

    dates = {datetime.strptime(m.group(1), "%Y-%m-%d").date() for m in LITERAL.finditer(text)}
    if not dates:
        raise SystemExit("No se han encontrado fechas en el seed.")
    mapping = build_mapping(dates, target_end)

    def replace(match: re.Match) -> str:
        original = datetime.strptime(match.group(1), "%Y-%m-%d").date()
        return f"'{mapping[original].isoformat()}{match.group(2)}'"

    new_text, count = LITERAL.subn(replace, text)

    # Nota en la cabecera del fichero (se sustituye si ya existe).
    note = f"{HEADER_MARK}{target_end.strftime('%Y-%m')} con tools/shift_seed_dates.py para que los dashboards muestren datos."
    lines = new_text.splitlines()
    idx = next((i for i, line in enumerate(lines) if line.startswith(HEADER_MARK)), None)
    if idx is None:
        idx = next(i for i, line in enumerate(lines) if line.startswith("-- Los valores")) + 1
        lines.insert(idx, note)
    else:
        lines[idx] = note
    SEED.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")

    print(f"{count} literales de fecha reescritos; {len(mapping)} fechas distintas.")
    for old, new in sorted(mapping.items()):
        print(f"  {old} -> {new}")


if __name__ == "__main__":
    main()
