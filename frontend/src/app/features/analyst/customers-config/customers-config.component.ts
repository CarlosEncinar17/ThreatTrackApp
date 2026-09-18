import { ChangeDetectionStrategy, Component, computed, effect, inject, signal, untracked } from '@angular/core';
import { ChartData, ChartOptions } from 'chart.js';
import { forkJoin } from 'rxjs';

import { ActiveInactiveCount, QueryParams } from '../../../core/api/models';
import { GlobalFiltersStore } from '../../../core/filters/global-filters.store';
import {
  CUSTOMERS,
  DOMAINS,
  GOOGLE_DORKS,
  IPS,
  KEYWORDS,
  SHODAN_DORKS,
  SUBSCRIPTIONS,
  TWITTER_DORKS,
} from '../../../core/resources/resource-definitions';
import { LookupsService } from '../../../core/services/lookups.service';
import { StatisticsService } from '../../../core/services/statistics.service';
import { ChartCardComponent } from '../../../shared/chart-card/chart-card.component';
import { DataTableComponent } from '../../../shared/data-table/data-table.component';
import { StatCardComponent } from '../../../shared/stat-card/stat-card.component';

const doughnutOptions: ChartOptions<'doughnut'> = {
  cutout: '60%',
  plugins: {
    legend: { position: 'bottom', labels: { usePointStyle: true, pointStyle: 'circle', padding: 14 } },
    datalabels: { color: '#ffffff', font: { weight: 'bold', size: 13 }, formatter: (value: number) => (value > 0 ? value : '') },
  },
};

/** Configuracion de clientes, servicios contratados, metadatos (IPs, dominios, keywords) y dorks. */
@Component({
  selector: 'app-customers-config',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [DataTableComponent, ChartCardComponent, StatCardComponent],
  templateUrl: './customers-config.component.html',
  styleUrl: './customers-config.component.scss',
})
export class CustomersConfigComponent {
  private readonly stats = inject(StatisticsService);
  private readonly lookups = inject(LookupsService);
  protected readonly filters = inject(GlobalFiltersStore);

  readonly customers = CUSTOMERS;
  readonly subscriptions = SUBSCRIPTIONS;
  readonly ips = IPS;
  readonly domains = DOMAINS;
  readonly keywords = KEYWORDS;
  readonly dorks = [GOOGLE_DORKS, SHODAN_DORKS, TWITTER_DORKS];
  readonly doughnutOptions = doughnutOptions;

  readonly ipCount = signal<ActiveInactiveCount | null>(null);
  readonly domainCount = signal<ActiveInactiveCount | null>(null);
  readonly keywordCount = signal<ActiveInactiveCount | null>(null);

  readonly ipData = computed(() => activeInactive(this.ipCount()));
  readonly domainData = computed(() => activeInactive(this.domainCount()));
  readonly keywordData = computed(() => activeInactive(this.keywordCount()));
  readonly subscriptionParams = computed<QueryParams>(() => ({ customer: this.filters.customerId() }));

  constructor() {
    effect(() => {
      const params = this.filters.statsParams();
      untracked(() => this.loadCounts(params));
    });
  }

  refreshCounts(): void {
    this.loadCounts(this.filters.statsParams());
  }

  customersChanged(): void {
    this.lookups.refreshCustomers();
  }

  total(count: ActiveInactiveCount | null): number {
    return (count?.active ?? 0) + (count?.inactive ?? 0);
  }

  private loadCounts(params: QueryParams): void {
    forkJoin({
      ips: this.stats.ipCount(params),
      domains: this.stats.domainCount(params),
      keywords: this.stats.keywordCount(params),
    }).subscribe(({ ips, domains, keywords }) => {
      this.ipCount.set(ips);
      this.domainCount.set(domains);
      this.keywordCount.set(keywords);
    });
  }
}

function activeInactive(count: ActiveInactiveCount | null): ChartData<'doughnut'> {
  return {
    labels: ['Activos', 'Inactivos'],
    datasets: [{ data: [count?.active ?? 0, count?.inactive ?? 0], backgroundColor: ['#7ed321', '#d33021'], borderWidth: 0 }],
  };
}
