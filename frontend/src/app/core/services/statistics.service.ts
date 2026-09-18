import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { ApiClient } from '../api/api-client.service';
import {
  ActiveInactiveCount,
  DailyByModule,
  DailyOpenResolved,
  OpenResolvedByModule,
  OpenResolvedBySeverity,
  OpenResolvedTotals,
  QueryParams,
  SeverityCounts,
  StatusCounts,
} from '../api/models';

/** Endpoints de estadisticas de los dashboards. */
@Injectable({ providedIn: 'root' })
export class StatisticsService {
  private readonly api = inject(ApiClient);

  statusCounts(params?: QueryParams): Observable<StatusCounts> {
    return this.api.get<StatusCounts>('status-counts/', params);
  }

  openResolvedTotals(params?: QueryParams): Observable<OpenResolvedTotals> {
    return this.api.get<OpenResolvedTotals>('total-count-open-resolved/', params);
  }

  severityCounts(params?: QueryParams): Observable<SeverityCounts> {
    return this.api.get<SeverityCounts>('criticity-counts/', params);
  }

  openResolvedBySeverity(params?: QueryParams): Observable<OpenResolvedBySeverity> {
    return this.api.get<OpenResolvedBySeverity>('cases-by-status-and-criticity/', params);
  }

  openResolvedByModule(params?: QueryParams): Observable<OpenResolvedByModule> {
    return this.api.get<OpenResolvedByModule>('case-counts-by-module/', params);
  }

  dailyOpenResolved(params?: QueryParams): Observable<DailyOpenResolved> {
    return this.api.get<DailyOpenResolved>('stacked-bar-chart/', params);
  }

  dailyByModule(params?: QueryParams): Observable<DailyByModule> {
    return this.api.get<DailyByModule>('daily-counts-services/', params);
  }

  ipCount(params?: QueryParams): Observable<ActiveInactiveCount> {
    return this.api.get<ActiveInactiveCount>('ips-count/', params);
  }

  domainCount(params?: QueryParams): Observable<ActiveInactiveCount> {
    return this.api.get<ActiveInactiveCount>('domains-count/', params);
  }

  keywordCount(params?: QueryParams): Observable<ActiveInactiveCount> {
    return this.api.get<ActiveInactiveCount>('keywords-count/', params);
  }
}
