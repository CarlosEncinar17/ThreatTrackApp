import { ChangeDetectionStrategy, Component, computed, effect, inject, signal, untracked } from '@angular/core';
import { ChartData, ChartOptions } from 'chart.js';
import { forkJoin } from 'rxjs';

import {
  DailyByModule,
  DailyOpenResolved,
  OpenResolvedByModule,
  OpenResolvedBySeverity,
  OpenResolvedTotals,
  QueryParams,
  ServiceModuleKey,
  SeverityCounts,
} from '../../../core/api/models';
import { GlobalFiltersStore } from '../../../core/filters/global-filters.store';
import { StatisticsService } from '../../../core/services/statistics.service';
import { ChartCardComponent } from '../../../shared/chart-card/chart-card.component';
import { SEVERITY_HEX } from '../../../shared/format';

type RangeDays = 30 | 90 | 365;

export const MODULE_META: Record<ServiceModuleKey, { label: string; color: string }> = {
  information_leaks: { label: 'Fugas de información', color: 'rgba(244, 114, 208, 1)' },
  credential_exposure: { label: 'Exposición de credenciales', color: 'rgba(255, 224, 130, 1)' },
  defacement: { label: 'Defacement', color: 'rgba(150, 150, 150, 1)' },
  domain_monitoring: { label: 'Monitorización de dominios', color: 'rgba(102, 187, 106, 1)' },
  system_vulnerabilities_monitoring: { label: 'Monitorización de sistemas y vulnerabilidades', color: 'rgba(255, 99, 132, 1)' },
  phishing_and_fraudulent_domains: { label: 'Phishing y dominios fraudulentos', color: 'rgba(102, 178, 255, 1)' },
};

const MODULE_KEYS = Object.keys(MODULE_META) as ServiceModuleKey[];
const SEVERITY_KEYS = ['critical', 'high', 'medium', 'low', 'informative'] as const;
const SEVERITY_LABELS = ['Crítica', 'Alta', 'Media', 'Baja', 'Informativa'];
const OPEN_COLOR = '#ffcd56';
const RESOLVED_COLOR = '#90ee90';

const doughnutOptions: ChartOptions<'doughnut'> = {
  cutout: '58%',
  plugins: {
    legend: { position: 'bottom', labels: { usePointStyle: true, pointStyle: 'circle', padding: 14 } },
    datalabels: {
      color: '#ffffff',
      font: { weight: 'bold', size: 13 },
      textShadowColor: 'rgba(0,0,0,0.6)',
      textShadowBlur: 4,
      formatter: (value: number) => (value > 0 ? value : ''),
    },
  },
};

const barOptions = (stacked: boolean): ChartOptions<'bar'> => ({
  interaction: { mode: 'index', intersect: false },
  scales: {
    x: { stacked, title: { display: true, text: 'Fecha' }, ticks: { maxRotation: 0, autoSkip: true, maxTicksLimit: 12 } },
    y: { stacked, beginAtZero: true, title: { display: true, text: 'Número de casos' }, ticks: { precision: 0 } },
  },
  plugins: { legend: { position: 'bottom', labels: { usePointStyle: true, pointStyle: 'circle', padding: 14 } } },
});

/** Dashboards del cliente: distribucion de casos por estado, criticidad, modulo y dia. */
@Component({
  selector: 'app-dashboard',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ChartCardComponent],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
})
export class DashboardComponent {
  private readonly stats = inject(StatisticsService);
  private readonly filters = inject(GlobalFiltersStore);

  readonly totals = signal<OpenResolvedTotals | null>(null);
  readonly severity = signal<SeverityCounts | null>(null);
  readonly split = signal<OpenResolvedBySeverity | null>(null);
  readonly modules = signal<OpenResolvedByModule | null>(null);
  readonly daily = signal<DailyOpenResolved | null>(null);
  readonly dailyModules = signal<DailyByModule | null>(null);
  readonly loading = signal(true);
  readonly range = signal<RangeDays>(30);
  readonly ranges: RangeDays[] = [30, 90, 365];
  readonly moduleKeys = MODULE_KEYS;
  readonly moduleMeta = MODULE_META;

  readonly doughnutOptions = doughnutOptions;
  readonly stackedOptions = barOptions(true);
  readonly groupedOptions = barOptions(false);

  readonly totalsData = computed<ChartData<'doughnut'>>(() => ({
    labels: ['Resueltos', 'Abiertos'],
    datasets: [{ data: [this.totals()?.resolved ?? 0, this.totals()?.open ?? 0], backgroundColor: [RESOLVED_COLOR, OPEN_COLOR], borderWidth: 0 }],
  }));
  readonly totalsCenter = computed(() => `Total: ${(this.totals()?.resolved ?? 0) + (this.totals()?.open ?? 0)}`);

  readonly severityData = computed(() => severityDoughnut(this.severity()));
  readonly severityCenter = computed(() => `Total: ${sumSeverity(this.severity())}`);
  readonly openBySeverityData = computed(() => severityDoughnut(this.split()?.open_by_severity ?? null));
  readonly openBySeverityCenter = computed(() => `Total: ${sumSeverity(this.split()?.open_by_severity ?? null)}`);
  readonly resolvedBySeverityData = computed(() => severityDoughnut(this.split()?.resolved_by_severity ?? null));
  readonly resolvedBySeverityCenter = computed(() => `Total: ${sumSeverity(this.split()?.resolved_by_severity ?? null)}`);

  readonly dailyData = computed<ChartData<'bar'>>(() => {
    const data = this.daily();
    const keep = withinRange(data?.days ?? [], this.range());
    return {
      labels: keep.map((i) => data!.days[i]),
      datasets: [
        { label: 'Resueltos', data: keep.map((i) => data!.resolved[i]), backgroundColor: RESOLVED_COLOR, borderRadius: 3 },
        { label: 'Abiertos', data: keep.map((i) => data!.open[i]), backgroundColor: OPEN_COLOR, borderRadius: 3 },
      ],
    };
  });
  readonly dailyEmpty = computed(() => (this.dailyData().labels?.length ?? 0) === 0);

  readonly dailyModulesData = computed<ChartData<'bar'>>(() => {
    const data = this.dailyModules();
    const keep = withinRange(data?.days ?? [], this.range());
    return {
      labels: keep.map((i) => data!.days[i]),
      datasets: MODULE_KEYS.map((key) => ({
        label: MODULE_META[key].label,
        data: keep.map((i) => data!.by_module[key]?.[i] ?? 0),
        backgroundColor: MODULE_META[key].color,
        borderRadius: 3,
      })),
    };
  });
  readonly dailyModulesEmpty = computed(() => (this.dailyModulesData().labels?.length ?? 0) === 0);

  constructor() {
    effect(() => {
      const params = this.filters.statsParams();
      untracked(() => this.load(params));
    });
  }

  reload(): void {
    this.load(this.filters.statsParams());
  }

  private load(params: QueryParams): void {
    this.loading.set(true);
    forkJoin({
      totals: this.stats.openResolvedTotals(params),
      severity: this.stats.severityCounts(params),
      split: this.stats.openResolvedBySeverity(params),
      modules: this.stats.openResolvedByModule(params),
      daily: this.stats.dailyOpenResolved(params),
      dailyModules: this.stats.dailyByModule(params),
    }).subscribe({
      next: (result) => {
        this.totals.set(result.totals);
        this.severity.set(result.severity);
        this.split.set(result.split);
        this.modules.set(result.modules);
        this.daily.set(result.daily);
        this.dailyModules.set(result.dailyModules);
        this.loading.set(false);
      },
      error: () => this.loading.set(false),
    });
  }
}

function severityDoughnut(counts: SeverityCounts | null): ChartData<'doughnut'> {
  return {
    labels: [...SEVERITY_LABELS],
    datasets: [
      {
        data: SEVERITY_KEYS.map((key) => counts?.[key] ?? 0),
        backgroundColor: SEVERITY_KEYS.map((key) => SEVERITY_HEX[key]),
        borderWidth: 0,
      },
    ],
  };
}

function sumSeverity(counts: SeverityCounts | null): number {
  return SEVERITY_KEYS.reduce((acc, key) => acc + (counts?.[key] ?? 0), 0);
}

/** Indices de los dias que caen dentro de los ultimos `days` dias (incluido hoy). */
function withinRange(days: string[], range: RangeDays): number[] {
  const limit = new Date();
  limit.setHours(0, 0, 0, 0);
  limit.setDate(limit.getDate() - (range - 1));
  const out: number[] = [];
  days.forEach((day, index) => {
    if (new Date(`${day}T00:00:00`) >= limit) {
      out.push(index);
    }
  });
  return out;
}
