import { Injectable, inject, signal } from '@angular/core';
import { forkJoin, map, Observable, of, tap } from 'rxjs';

import { ApiClient } from '../api/api-client.service';
import { Customer, Lookup, Paginated } from '../api/models';

export interface SelectOption {
  value: number;
  label: string;
}

/** Catalogos que usan los filtros y los formularios: clientes, estados y criticidades. */
@Injectable({ providedIn: 'root' })
export class LookupsService {
  private readonly api = inject(ApiClient);

  readonly customers = signal<SelectOption[]>([]);
  readonly states = signal<SelectOption[]>([]);
  readonly severities = signal<SelectOption[]>([]);
  private loaded = false;

  /** Carga (una vez) los tres catalogos. */
  ensureLoaded(): Observable<void> {
    if (this.loaded) {
      return of(undefined);
    }
    return forkJoin({
      customers: this.api.list<Customer>('Clients/', { page_size: 100, ordering: 'name' }),
      states: this.api.list<Lookup>('AlertStatus/', { page_size: 100 }),
      severities: this.api.list<Lookup>('AlertCriticity/', { page_size: 100 }),
    }).pipe(
      tap(({ customers, states, severities }) => {
        this.customers.set(customers.results.map((c) => ({ value: c.id, label: c.name })));
        this.states.set(states.results.map((s) => ({ value: s.id, label: s.name })));
        this.severities.set(severities.results.map((s) => ({ value: s.id, label: s.name })));
        this.loaded = true;
      }),
      map(() => undefined),
    );
  }

  /** Vuelve a cargar los clientes (tras crear, editar o eliminar uno). */
  refreshCustomers(): void {
    this.api.list<Customer>('Clients/', { page_size: 100, ordering: 'name' }).subscribe((page) => {
      this.customers.set(page.results.map((c) => ({ value: c.id, label: c.name })));
    });
  }

  /** Opciones para un select de formulario a partir de cualquier listado. */
  options<T extends { id?: number }>(path: string, labelOf: (row: T) => string, valueOf?: (row: T) => number) {
    return this.api
      .list<T>(path, { page_size: 100 })
      .pipe(map((page: Paginated<T>) => page.results.map((row) => ({ value: valueOf ? valueOf(row) : (row.id as number), label: labelOf(row) }))));
  }
}
