import { ChangeDetectionStrategy, Component } from '@angular/core';
import { ChartData, ChartOptions } from 'chart.js';

import { ChartCardComponent } from '../../../shared/chart-card/chart-card.component';
import { StatCardComponent } from '../../../shared/stat-card/stat-card.component';

interface SeriesTable {
  title: string;
  unit: string;
  columns: string[];
  rows: Array<{ label: string; color: string; values: string[] }>;
  data: ChartData<'line'>;
}

const labels = lastHourLabels();

const line = (label: string, color: string, values: number[]) => ({
  label,
  data: values,
  fill: true,
  tension: 0.35,
  borderColor: color,
  backgroundColor: color.replace('1)', '0.18)'),
  pointRadius: 2,
});

const lineOptions: ChartOptions<'line'> = {
  interaction: { mode: 'index', intersect: false },
  scales: {
    x: { ticks: { maxTicksLimit: 8 } },
    y: { beginAtZero: true },
  },
  plugins: { legend: { position: 'bottom', labels: { usePointStyle: true, pointStyle: 'circle', padding: 14 } } },
};

const gaugeOptions: ChartOptions<'doughnut'> = {
  cutout: '72%',
  rotation: -125,
  circumference: 250,
  plugins: { legend: { display: false }, tooltip: { enabled: false } },
};

/**
 * Estado de los servidores. Como en la version original, muestra datos de ejemplo:
 * la conexion con la telemetria real de los contenedores queda como trabajo futuro.
 */
@Component({
  selector: 'app-server-status',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ChartCardComponent, StatCardComponent],
  templateUrl: './server-status.component.html',
  styleUrl: './server-status.component.scss',
})
export class ServerStatusComponent {
  readonly lineOptions = lineOptions;
  readonly gaugeOptions = gaugeOptions;

  readonly gauges = [
    { label: 'CPU', value: 25 },
    { label: 'RAM', value: 75 },
    { label: 'DISK', value: 95 },
  ].map((gauge) => ({ ...gauge, data: gaugeData(gauge.value) }));

  readonly charts: SeriesTable[] = [
    {
      title: 'Estado CPU',
      unit: '%',
      columns: ['Last', 'Mean', 'Min', 'Max'],
      rows: [
        { label: 'Total', color: '#ff6384', values: ['76,8 %', '79,1 %', '74,5 %', '99,9 %'] },
        { label: 'System', color: '#ffcd56', values: ['30,0 %', '32,2 %', '29,2 %', '47,6 %'] },
        { label: 'User', color: '#36a2eb', values: ['46,2 %', '46,7 %', '43,6 %', '52,4 %'] },
      ],
      data: {
        labels,
        datasets: [
          line('Total', 'rgba(255, 99, 132, 1)', [65, 59, 80, 81, 56, 55, 72, 78, 74, 81, 77, 76]),
          line('System', 'rgba(255, 205, 86, 1)', [28, 48, 40, 19, 46, 27, 31, 34, 30, 33, 29, 30]),
          line('User', 'rgba(54, 162, 235, 1)', [18, 48, 47, 39, 50, 27, 41, 44, 44, 48, 48, 46]),
        ],
      },
    },
    {
      title: 'Estado Memoria',
      unit: 'GB',
      columns: ['Last', 'Mean', 'Min', 'Max'],
      rows: [
        { label: 'Total', color: '#ff6384', values: ['4,12 GB', '4,12 GB', '4,12 GB', '4,12 GB'] },
        { label: 'Used', color: '#ffcd56', values: ['1,17 GB', '1,15 GB', '1,19 GB', '1,14 GB'] },
        { label: 'Cached', color: '#36a2eb', values: ['2,67 GB', '2,65 GB', '2,69 GB', '2,64 GB'] },
      ],
      data: {
        labels,
        datasets: [
          line('Total', 'rgba(255, 99, 132, 1)', Array(12).fill(4.12)),
          line('Used', 'rgba(255, 205, 86, 1)', [1.1, 1.14, 1.19, 1.12, 1.15, 1.18, 1.16, 1.13, 1.17, 1.19, 1.15, 1.17]),
          line('Cached', 'rgba(54, 162, 235, 1)', [2.6, 2.64, 2.69, 2.62, 2.65, 2.68, 2.66, 2.63, 2.67, 2.69, 2.65, 2.67]),
        ],
      },
    },
    {
      title: 'Estado Procesadores',
      unit: '',
      columns: ['Last', 'Mean', 'Max'],
      rows: [
        { label: 'Total', color: '#ff6384', values: ['173', '172', '174'] },
        { label: 'Running', color: '#ffcd56', values: ['3', '1,87', '4'] },
        { label: 'Blocked', color: '#36a2eb', values: ['0', '0', '0'] },
      ],
      data: {
        labels,
        datasets: [
          line('Total', 'rgba(255, 99, 132, 1)', [172, 173, 174, 172, 171, 173, 172, 174, 173, 172, 173, 173]),
          line('Running', 'rgba(255, 205, 86, 1)', [2, 1, 3, 2, 1, 2, 4, 2, 1, 2, 3, 3]),
          line('Blocked', 'rgba(54, 162, 235, 1)', Array(12).fill(0)),
        ],
      },
    },
    {
      title: 'Estado Problemas',
      unit: '',
      columns: ['Last', 'Mean', 'Min', 'Max'],
      rows: [
        { label: 'Threads', color: '#90ee90', values: ['520', '520', '517', '523'] },
        { label: 'Processes', color: '#ffcd56', values: ['173', '172', '170', '174'] },
      ],
      data: {
        labels,
        datasets: [
          line('Threads', 'rgba(144, 238, 144, 1)', [518, 520, 523, 519, 517, 521, 520, 522, 519, 520, 521, 520]),
          line('Processes', 'rgba(255, 205, 86, 1)', [172, 173, 174, 171, 170, 173, 172, 174, 173, 172, 173, 173]),
        ],
      },
    },
    {
      title: 'Estado Disco',
      unit: 'GB',
      columns: ['Last', 'Mean', 'Min', 'Max'],
      rows: [
        { label: 'Total', color: '#ff6384', values: ['120 GB', '120 GB', '120 GB', '120 GB'] },
        { label: 'Used', color: '#ffcd56', values: ['114 GB', '113 GB', '112 GB', '114 GB'] },
      ],
      data: {
        labels,
        datasets: [
          line('Total', 'rgba(255, 99, 132, 1)', Array(12).fill(120)),
          line('Used', 'rgba(255, 205, 86, 1)', [112, 112, 113, 113, 113, 113, 114, 114, 114, 114, 114, 114]),
        ],
      },
    },
  ];
}

function lastHourLabels(): string[] {
  const now = new Date();
  const out: string[] = [];
  for (let i = 11; i >= 0; i--) {
    const d = new Date(now.getTime() - i * 5 * 60 * 1000);
    out.push(`${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`);
  }
  return out;
}

function gaugeData(value: number): ChartData<'doughnut'> {
  return {
    labels: ['Uso', 'Libre'],
    datasets: [{ data: [value, 100 - value], backgroundColor: ['#00c0ef', 'rgba(255,255,255,0.08)'], borderWidth: 0 }],
  };
}
