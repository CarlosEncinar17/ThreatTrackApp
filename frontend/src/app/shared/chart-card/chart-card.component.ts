import {
  ChangeDetectionStrategy,
  Component,
  ElementRef,
  OnDestroy,
  effect,
  input,
  untracked,
  viewChild,
} from '@angular/core';
import { Chart, ChartConfiguration, ChartData, ChartOptions, ChartType, Plugin, registerables } from 'chart.js';
import ChartDataLabels from 'chartjs-plugin-datalabels';

Chart.register(...registerables);
Chart.defaults.color = '#c2c7d0';
Chart.defaults.font.family = "'Source Sans 3', 'Source Sans Pro', system-ui, sans-serif";
Chart.defaults.borderColor = 'rgba(255, 255, 255, 0.08)';

/** Texto en el centro de un donut (total). */
const centerTextPlugin: Plugin = {
  id: 'ttaCenterText',
  afterDraw(chart) {
    const text = (chart.options as { ttaCenterText?: string }).ttaCenterText;
    if (!text) {
      return;
    }
    const { ctx, chartArea } = chart;
    ctx.save();
    ctx.font = "600 15px 'Source Sans 3', system-ui, sans-serif";
    ctx.fillStyle = '#ffffff';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(text, (chartArea.left + chartArea.right) / 2, (chartArea.top + chartArea.bottom) / 2);
    ctx.restore();
  },
};

/**
 * Tarjeta con un grafico de Chart.js. Se redibuja cuando cambian `data` u `options`.
 */
@Component({
  selector: 'app-chart-card',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <section class="card">
      <header class="card__header">
        <i [class]="icon()" aria-hidden="true"></i>
        <h3>{{ title() }}</h3>
        <ng-content select="[actions]" />
      </header>
      <div class="card__body">
        <div class="chart-wrap" [style.height.px]="height()">
          @if (empty()) {
            <div class="chart-empty">Sin datos en el periodo</div>
          }
          <canvas #canvas [class.is-hidden]="empty()"></canvas>
        </div>
      </div>
    </section>
  `,
  styles: `
    :host { display: block; min-width: 0; }
    .chart-wrap { position: relative; width: 100%; }
    canvas.is-hidden { visibility: hidden; }
    .chart-empty {
      position: absolute; inset: 0; display: flex; align-items: center; justify-content: center;
      color: var(--tta-text-dim); font-size: 0.9rem;
    }
  `,
})
export class ChartCardComponent implements OnDestroy {
  readonly title = input.required<string>();
  readonly icon = input<string>('fa-solid fa-chart-pie');
  readonly type = input.required<ChartType>();
  readonly data = input.required<ChartData>();
  readonly options = input<ChartOptions>({});
  readonly height = input<number>(300);
  readonly centerText = input<string | null>(null);
  readonly datalabels = input<boolean>(false);
  readonly empty = input<boolean>(false);

  private readonly canvas = viewChild.required<ElementRef<HTMLCanvasElement>>('canvas');
  private chart: Chart | null = null;
  private chartType: ChartType | null = null;

  constructor() {
    effect(() => {
      const type = this.type();
      const data = this.data();
      const options = this.options();
      const centerText = this.centerText();
      const useLabels = this.datalabels();
      const canvas = this.canvas().nativeElement;
      untracked(() => this.render(canvas, type, data, options, centerText, useLabels));
    });
  }

  ngOnDestroy(): void {
    this.chart?.destroy();
    this.chart = null;
  }

  private render(
    canvas: HTMLCanvasElement,
    type: ChartType,
    data: ChartData,
    options: ChartOptions,
    centerText: string | null,
    useLabels: boolean,
  ): void {
    const config: ChartConfiguration = {
      type,
      data,
      options: {
        responsive: true,
        maintainAspectRatio: false,
        ...options,
        ...(centerText ? { ttaCenterText: centerText } : {}),
      } as ChartOptions,
      plugins: [centerTextPlugin, ...(useLabels ? [ChartDataLabels] : [])],
    };
    if (this.chart && this.chartType === type) {
      this.chart.data = data;
      this.chart.options = config.options as ChartOptions;
      this.chart.update();
      return;
    }
    this.chart?.destroy();
    this.chart = new Chart(canvas, config);
    this.chartType = type;
  }
}
