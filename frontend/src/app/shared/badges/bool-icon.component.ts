import { ChangeDetectionStrategy, Component, input } from '@angular/core';

@Component({
  selector: 'app-bool-icon',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @if (value()) {
      <i class="fa-solid fa-check" style="color: var(--tta-state-resolved)" title="Sí" aria-label="Sí"></i>
    } @else {
      <i class="fa-solid fa-xmark" style="color: var(--tta-state-false-positive)" title="No" aria-label="No"></i>
    }
  `,
})
export class BoolIconComponent {
  readonly value = input<unknown>(false);
}
