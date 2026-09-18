import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';

import { AlertSeverityName } from '../../core/api/models';
import { SEVERITY_META } from '../format';

@Component({
  selector: 'app-severity-badge',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <span class="badge badge--soft" [style.--badge-color]="meta().color" [title]="meta().label">
      <span class="dot" [style.--dot-color]="meta().color"></span>{{ meta().label }}
    </span>
  `,
})
export class SeverityBadgeComponent {
  readonly severity = input.required<AlertSeverityName | string>();
  readonly meta = computed(() => SEVERITY_META[this.severity() as AlertSeverityName] ?? { label: this.severity(), color: 'var(--tta-gray)' });
}
