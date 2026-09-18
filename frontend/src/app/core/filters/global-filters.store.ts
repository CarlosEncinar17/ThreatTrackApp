import { Injectable, computed, signal } from '@angular/core';

import { QueryParams } from '../api/models';

export type FilterKind = 'dates' | 'customer' | 'state' | 'severity';

export interface DateRange {
  from: string; // YYYY-MM-DD
  to: string;
}

/**
 * Filtros globales de la barra superior (fecha, cliente, estado, criticidad).
 * Sustituye a las tres copias de `updateTableFilters` de la version original:
 * las tablas leen `alertParams()` / `assetParams()` y se recargan solas.
 */
@Injectable({ providedIn: 'root' })
export class GlobalFiltersStore {
  readonly dateRange = signal<DateRange | null>(null);
  readonly customerId = signal<number | null>(null);
  readonly stateId = signal<number | null>(null);
  readonly severityId = signal<number | null>(null);

  /** Parametros para los listados de alertas. */
  readonly alertParams = computed<QueryParams>(() => ({
    customer: this.customerId(),
    state: this.stateId(),
    severity: this.severityId(),
    date_from: this.dateRange()?.from,
    date_to: this.dateRange()?.to,
  }));

  /** Parametros para activos y consultas (sin estado ni criticidad). */
  readonly assetParams = computed<QueryParams>(() => ({
    customer: this.customerId(),
    date_from: this.dateRange()?.from,
    date_to: this.dateRange()?.to,
  }));

  /** Parametros para las estadisticas (solo cliente). */
  readonly statsParams = computed<QueryParams>(() => ({ customer: this.customerId() }));

  readonly activeCount = computed(
    () => [this.dateRange(), this.customerId(), this.stateId(), this.severityId()].filter((v) => v !== null).length,
  );

  clear(): void {
    this.dateRange.set(null);
    this.customerId.set(null);
    this.stateId.set(null);
    this.severityId.set(null);
  }
}
