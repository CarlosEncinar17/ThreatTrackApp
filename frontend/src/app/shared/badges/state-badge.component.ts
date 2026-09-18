import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';

import { AlertStateName } from '../../core/api/models';
import { STATE_META } from '../format';

@Component({
  selector: 'app-state-badge',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <span class="badge badge--soft" [style.--badge-color]="meta().color" [title]="meta().label">
      <i [class]="meta().icon" aria-hidden="true"></i>{{ meta().label }}
    </span>
  `,
})
export class StateBadgeComponent {
  readonly state = input.required<AlertStateName | string>();
  readonly meta = computed(() => STATE_META[this.state() as AlertStateName] ?? { label: this.state(), icon: 'fa-solid fa-circle', color: 'var(--tta-gray)' });
}
