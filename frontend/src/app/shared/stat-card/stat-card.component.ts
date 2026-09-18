import { ChangeDetectionStrategy, Component, input } from '@angular/core';

/** Tarjeta de indicador numerico (abiertas / en progreso / resueltas, activos, etc.). */
@Component({
  selector: 'app-stat-card',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="stat" [style.--stat-color]="color()">
      <div class="stat__label">
        @if (icon()) {
          <i [class]="icon()" aria-hidden="true"></i>
        }
        {{ label() }}
      </div>
      <div class="stat__value">{{ value() ?? '–' }}</div>
      @if (caption()) {
        <div class="stat__caption">{{ caption() }}</div>
      }
    </div>
  `,
  styles: `
    .stat {
      position: relative;
      background: var(--tta-surface);
      border: 1px solid var(--tta-border);
      border-radius: var(--tta-radius);
      padding: 0.85rem 1rem 0.85rem 1.15rem;
      box-shadow: var(--tta-shadow-sm);
      overflow: hidden;
      min-width: 0;
    }
    .stat::before {
      content: '';
      position: absolute;
      inset: 0 auto 0 0;
      width: 5px;
      background: var(--stat-color, var(--tta-primary));
    }
    .stat__label {
      font-size: 0.78rem;
      font-weight: 600;
      letter-spacing: 0.04em;
      text-transform: uppercase;
      color: var(--tta-text-muted);
      display: flex;
      align-items: center;
      gap: 0.4rem;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .stat__label i { color: var(--stat-color, var(--tta-primary)); }
    .stat__value {
      font-size: 1.9rem;
      font-weight: 700;
      line-height: 1.1;
      margin-top: 0.25rem;
      color: var(--stat-color, var(--tta-text));
      font-variant-numeric: tabular-nums;
    }
    .stat__caption { font-size: 0.78rem; color: var(--tta-text-dim); margin-top: 0.2rem; }
  `,
})
export class StatCardComponent {
  readonly label = input.required<string>();
  readonly value = input<number | string | null | undefined>(null);
  readonly color = input<string>('var(--tta-primary)');
  readonly icon = input<string>('');
  readonly caption = input<string>('');
}
