import { ChangeDetectionStrategy, Component, OnInit, computed, effect, inject, input, signal, untracked } from '@angular/core';

import { AuthService } from '../../core/auth/auth.service';
import { DateRange, FilterKind, GlobalFiltersStore } from '../../core/filters/global-filters.store';
import { LookupsService } from '../../core/services/lookups.service';
import { NotifyService } from '../../core/ui/notify.service';

type PresetKey = 'today' | 'yesterday' | 'last7' | 'last15' | 'last30' | 'thisMonth' | 'lastMonth' | 'year' | 'custom';

const PRESETS: Array<{ key: PresetKey; label: string }> = [
  { key: 'today', label: 'Hoy' },
  { key: 'yesterday', label: 'Ayer' },
  { key: 'last7', label: 'Últimos 7 días' },
  { key: 'last15', label: 'Últimos 15 días' },
  { key: 'last30', label: 'Últimos 30 días' },
  { key: 'thisMonth', label: 'Este mes' },
  { key: 'lastMonth', label: 'Mes pasado' },
  { key: 'year', label: 'Todo el año' },
  { key: 'custom', label: 'Personalizado' },
];

/** Filtros globales de la barra superior (fecha de deteccion, cliente, estado y criticidad). */
@Component({
  selector: 'app-global-filters',
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './global-filters.component.html',
  styleUrl: './global-filters.component.scss',
})
export class GlobalFiltersComponent implements OnInit {
  protected readonly store = inject(GlobalFiltersStore);
  protected readonly lookups = inject(LookupsService);
  protected readonly auth = inject(AuthService);
  private readonly notify = inject(NotifyService);

  readonly kinds = input<FilterKind[]>([]);
  readonly presets = PRESETS;
  readonly preset = signal<PresetKey | ''>('');

  readonly showDates = computed(() => this.kinds().includes('dates'));
  readonly showCustomer = computed(() => this.kinds().includes('customer'));
  readonly showState = computed(() => this.kinds().includes('state'));
  readonly showSeverity = computed(() => this.kinds().includes('severity'));
  readonly hasAny = computed(() => this.kinds().length > 0);
  /** Filtros que el usuario puede quitar (el cliente fijo del rol cliente no cuenta). */
  readonly clearableCount = computed(() => {
    const forcedCustomer = !this.auth.isAnalyst() && this.auth.customer() !== null && this.store.customerId() !== null;
    return this.store.activeCount() - (forcedCustomer ? 1 : 0);
  });

  constructor() {
    // Un usuario con rol cliente siempre trabaja sobre su propio cliente.
    effect(() => {
      const customer = this.auth.customer();
      if (!this.auth.isAnalyst() && customer) {
        untracked(() => this.store.customerId.set(customer.id));
      }
    });
  }

  ngOnInit(): void {
    this.lookups.ensureLoaded().subscribe();
  }

  applyPreset(key: string): void {
    this.preset.set(key as PresetKey | '');
    if (!key) {
      this.store.dateRange.set(null);
      this.notify.info('Filtro de fechas eliminado.');
      return;
    }
    if (key === 'custom') {
      return;
    }
    this.store.dateRange.set(presetRange(key as PresetKey));
    this.notify.success('Filtro aplicado correctamente.');
  }

  setFrom(value: string): void {
    this.preset.set('custom');
    const current = this.store.dateRange();
    this.store.dateRange.set(value || current?.to ? { from: value, to: current?.to ?? '' } : null);
    this.notify.success('Filtro aplicado correctamente.');
  }

  setTo(value: string): void {
    this.preset.set('custom');
    const current = this.store.dateRange();
    this.store.dateRange.set(value || current?.from ? { from: current?.from ?? '', to: value } : null);
    this.notify.success('Filtro aplicado correctamente.');
  }

  setCustomer(value: string): void {
    this.store.customerId.set(value ? Number(value) : null);
    this.notify.success('Filtro aplicado correctamente.');
  }

  setState(value: string): void {
    this.store.stateId.set(value ? Number(value) : null);
    this.notify.success('Filtro aplicado correctamente.');
  }

  setSeverity(value: string): void {
    this.store.severityId.set(value ? Number(value) : null);
    this.notify.success('Filtro aplicado correctamente.');
  }

  clear(): void {
    this.store.clear();
    this.preset.set('');
    const customer = this.auth.customer();
    if (!this.auth.isAnalyst() && customer) {
      this.store.customerId.set(customer.id);
    }
    this.notify.info('Todos los filtros han sido eliminados.');
  }
}

function iso(date: Date): string {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

function presetRange(key: PresetKey): DateRange | null {
  const today = new Date();
  const from = new Date(today);
  const to = new Date(today);
  switch (key) {
    case 'today':
      break;
    case 'yesterday':
      from.setDate(today.getDate() - 1);
      to.setDate(today.getDate() - 1);
      break;
    case 'last7':
      from.setDate(today.getDate() - 6);
      break;
    case 'last15':
      from.setDate(today.getDate() - 14);
      break;
    case 'last30':
      from.setDate(today.getDate() - 29);
      break;
    case 'thisMonth':
      from.setDate(1);
      to.setMonth(today.getMonth() + 1, 0);
      break;
    case 'lastMonth':
      from.setMonth(today.getMonth() - 1, 1);
      to.setDate(0);
      break;
    case 'year':
      // Como en la version original: del inicio del ano anterior al final del ano siguiente.
      from.setFullYear(today.getFullYear() - 1, 0, 1);
      to.setFullYear(today.getFullYear() + 1, 11, 31);
      break;
    default:
      return null;
  }
  return { from: iso(from), to: iso(to) };
}
