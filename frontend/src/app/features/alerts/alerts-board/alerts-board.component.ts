import { ChangeDetectionStrategy, Component, computed, effect, inject, input, signal, untracked } from '@angular/core';

import { AlertSourceKey, QueryParams, StatusCounts } from '../../../core/api/models';
import { GlobalFiltersStore } from '../../../core/filters/global-filters.store';
import {
  CERTIFICATE_ALERTS,
  DEFACEMENT_ALERTS,
  GITHUB_ALERTS,
  GITLAB_ALERTS,
  GOOGLE_ALERTS,
  INTELX_ALERTS,
  ResourceDef,
  SHODAN_ALERTS,
  TYPOSQUATTING_ALERTS,
} from '../../../core/resources/resource-definitions';
import { StatisticsService } from '../../../core/services/statistics.service';
import { DataTableComponent } from '../../../shared/data-table/data-table.component';
import { SEVERITY_META, STATE_META } from '../../../shared/format';
import { StatCardComponent } from '../../../shared/stat-card/stat-card.component';

interface BoardSection {
  id: string;
  title: string;
  image: string;
  resources: ResourceDef[];
  soon?: boolean;
}

/** Mismos modulos y tablas que la version original (incluidos los servicios en desarrollo). */
const SECTIONS: BoardSection[] = [
  { id: 'inf', title: 'Fugas de información', image: 'inf.png', resources: [GOOGLE_ALERTS, GITHUB_ALERTS, GITLAB_ALERTS] },
  { id: 'cre', title: 'Exposición de credenciales', image: 'cre.png', resources: [INTELX_ALERTS] },
  { id: 'defa', title: 'Defacement', image: 'def.png', resources: [DEFACEMENT_ALERTS] },
  { id: 'mon', title: 'Monitorización de dominios', image: 'mon.png', resources: [CERTIFICATE_ALERTS] },
  { id: 'mons', title: 'Monitorización de sistemas y vulnerabilidades', image: 'def.png', resources: [SHODAN_ALERTS] },
  { id: 'phi', title: 'Alertas de phishing', image: 'phi.png', resources: [TYPOSQUATTING_ALERTS] },
  { id: 'lists', title: 'Alertas de listas de categorización', image: 'list.png', resources: [], soon: true },
  { id: 'card', title: 'Alertas de carding', image: 'card.png', resources: [], soon: true },
  { id: 'fraude', title: 'Fraude App', image: 'fraude.png', resources: [], soon: true },
  { id: 'hack', title: 'Alertas de hacktivismo', image: 'hack.png', resources: [], soon: true },
  { id: 'vip', title: 'Alertas de VIP/VAP', image: 'vip.png', resources: [], soon: true },
];

const STATE_LEGEND = [
  { key: 'open', description: 'Indica que la alerta está abierta y aún no se ha resuelto.' },
  { key: 'in_progress', description: 'La alerta está siendo abordada actualmente.' },
  { key: 'resolved', description: 'La alerta ha sido resuelta satisfactoriamente.' },
  { key: 'false_positive', description: 'La alerta fue identificada como un falso positivo.' },
  { key: 'duplicated', description: 'La alerta es una copia de otra ya reportada.' },
] as const;

const SEVERITY_LEGEND = [
  { key: 'critical', description: 'Vulnerabilidad o problema que puede causar daños graves o comprometer la seguridad del sistema. Requiere atención inmediata.' },
  { key: 'high', description: 'Riesgo significativo con impacto considerable en la seguridad u operatividad. Debe abordarse lo antes posible.' },
  { key: 'medium', description: 'Amenaza moderada que puede afectar al rendimiento o la seguridad, pero no de forma crítica. Solucionar en un plazo razonable.' },
  { key: 'low', description: 'Riesgo menor con impacto mínimo. Puede abordarse en el próximo ciclo de mantenimiento.' },
  { key: 'informative', description: 'Información útil que no representa una amenaza directa o inmediata.' },
  { key: 'unknown', description: 'Criticidad aún no determinada. Requiere la evaluación de un analista.' },
] as const;

/**
 * Tablero de alertas por servicio. Con `editable` (ruta de analista) las tablas
 * permiten crear, editar y eliminar registros.
 */
@Component({
  selector: 'app-alerts-board',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [DataTableComponent, StatCardComponent],
  templateUrl: './alerts-board.component.html',
  styleUrl: './alerts-board.component.scss',
})
export class AlertsBoardComponent {
  private readonly stats = inject(StatisticsService);
  protected readonly filters = inject(GlobalFiltersStore);

  /** Enlazado desde `data.editable` de la ruta. */
  readonly editable = input<boolean>(false);

  readonly sections = SECTIONS;
  readonly stateLegend = STATE_LEGEND.map((item) => ({ ...item, ...STATE_META[item.key] }));
  readonly severityLegend = SEVERITY_LEGEND.map((item) => ({ ...item, ...SEVERITY_META[item.key] }));
  readonly counts = signal<StatusCounts | null>(null);
  readonly windowDays = computed(() => this.counts()?.window_days ?? 30);

  constructor() {
    effect(() => {
      const params = this.filters.statsParams();
      untracked(() => this.loadCounts(params));
    });
  }

  count(kind: 'open' | 'in_progress' | 'resolved', source: AlertSourceKey | undefined): number | null {
    const counts = this.counts();
    if (!counts || !source) {
      return null;
    }
    return counts[kind][source] ?? 0;
  }

  refreshCounts(): void {
    this.loadCounts(this.filters.statsParams());
  }

  private loadCounts(params: QueryParams): void {
    this.stats.statusCounts(params).subscribe({
      next: (counts) => this.counts.set(counts),
      error: () => this.counts.set(null),
    });
  }
}
