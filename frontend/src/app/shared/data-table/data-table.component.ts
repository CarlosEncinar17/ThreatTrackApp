import { DatePipe } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  effect,
  inject,
  input,
  linkedSignal,
  output,
  signal,
  untracked,
} from '@angular/core';
import { Subscription } from 'rxjs';

import { ApiClient } from '../../core/api/api-client.service';
import { Paginated, QueryParams } from '../../core/api/models';
import { ColumnDef, ResourceDef } from '../../core/resources/resource-definitions';
import { NotifyService } from '../../core/ui/notify.service';
import { BoolIconComponent } from '../badges/bool-icon.component';
import { SeverityBadgeComponent } from '../badges/severity-badge.component';
import { StateBadgeComponent } from '../badges/state-badge.component';
import { FormDialogComponent, FormValues } from '../form-dialog/form-dialog.component';
import { cellText, downloadText, escapeHtml, toCsv } from '../format';

type Row = Record<string, unknown>;

const PAGE_SIZE = 10;

/**
 * Tabla generica alimentada por la API (paginacion, ordenacion y busqueda en el servidor)
 * con las acciones de la version original: copiar, CSV, imprimir, elegir columnas y,
 * para analistas, crear / editar / eliminar el registro seleccionado.
 */
@Component({
  selector: 'app-data-table',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [DatePipe, StateBadgeComponent, SeverityBadgeComponent, BoolIconComponent, FormDialogComponent],
  templateUrl: './data-table.component.html',
  styleUrl: './data-table.component.scss',
})
export class DataTableComponent {
  private readonly api = inject(ApiClient);
  private readonly notify = inject(NotifyService);

  readonly resource = input.required<ResourceDef>();
  /** Parametros externos (filtros globales). */
  readonly params = input<QueryParams>({});
  readonly editable = input<boolean>(false);
  /** Se emite tras crear, editar o eliminar (para refrescar contadores y graficos). */
  readonly changed = output<void>();

  readonly rows = signal<Row[]>([]);
  readonly count = signal(0);
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);
  readonly search = signal('');
  readonly ordering = linkedSignal<string>(() => this.resource().defaultOrdering ?? '-detected_at');
  readonly selectedId = signal<unknown>(null);
  readonly hidden = linkedSignal<Set<string>>(() => new Set(this.resource().columns.filter((c) => c.hidden).map((c) => c.key)));
  readonly columnsMenuOpen = signal(false);

  /** La pagina vuelve a 1 cuando cambian filtros, busqueda u orden. */
  readonly page = linkedSignal<number>(() => {
    this.params();
    this.search();
    this.ordering();
    this.resource();
    return 1;
  });

  readonly dialogOpen = signal(false);
  readonly dialogInitial = signal<FormValues | null>(null);
  readonly saving = signal(false);

  readonly visibleColumns = computed(() => this.resource().columns.filter((c) => !this.hidden().has(c.key)));
  readonly totalPages = computed(() => Math.max(1, Math.ceil(this.count() / PAGE_SIZE)));
  readonly rangeStart = computed(() => (this.count() === 0 ? 0 : (this.page() - 1) * PAGE_SIZE + 1));
  readonly rangeEnd = computed(() => Math.min(this.count(), this.page() * PAGE_SIZE));
  readonly selectedRow = computed(() => this.rows().find((row) => this.idOf(row) === this.selectedId()) ?? null);
  readonly pageNumbers = computed(() => {
    const total = this.totalPages();
    const current = this.page();
    const from = Math.max(1, Math.min(current - 2, total - 4));
    const to = Math.min(total, from + 4);
    const numbers: number[] = [];
    for (let n = from; n <= to; n++) {
      numbers.push(n);
    }
    return numbers;
  });

  private request: Subscription | null = null;
  private searchTimer: ReturnType<typeof setTimeout> | null = null;

  constructor() {
    effect(() => {
      const resource = this.resource();
      const query: QueryParams = {
        ...this.params(),
        page: this.page(),
        page_size: PAGE_SIZE,
        search: this.search() || undefined,
        ordering: this.ordering() || undefined,
      };
      untracked(() => this.load(resource, query));
    });
  }

  // ---------------------------------------------------------------- datos
  idOf(row: Row): unknown {
    return row[this.resource().idKey ?? 'id'];
  }

  reload(): void {
    const query: QueryParams = {
      ...this.params(),
      page: this.page(),
      page_size: PAGE_SIZE,
      search: this.search() || undefined,
      ordering: this.ordering() || undefined,
    };
    this.load(this.resource(), query);
  }

  private load(resource: ResourceDef, query: QueryParams): void {
    this.request?.unsubscribe();
    this.loading.set(true);
    this.error.set(null);
    this.request = this.api.list<Row>(resource.endpoint, query).subscribe({
      next: (page: Paginated<Row>) => {
        this.rows.set(page.results);
        this.count.set(page.count);
        this.loading.set(false);
        if (!page.results.some((row) => this.idOf(row) === this.selectedId())) {
          this.selectedId.set(null);
        }
      },
      error: (err: unknown) => {
        this.loading.set(false);
        this.rows.set([]);
        this.count.set(0);
        this.error.set(this.notify.describeError(err));
      },
    });
  }

  // ---------------------------------------------------------------- interaccion
  onSearchInput(value: string): void {
    if (this.searchTimer) {
      clearTimeout(this.searchTimer);
    }
    this.searchTimer = setTimeout(() => this.search.set(value.trim()), 350);
  }

  sortBy(column: ColumnDef): void {
    if (column.sortKey === null) {
      return;
    }
    const key = column.sortKey ?? column.key;
    const current = this.ordering();
    this.ordering.set(current === key ? `-${key}` : key);
  }

  sortState(column: ColumnDef): 'asc' | 'desc' | null {
    const key = column.sortKey ?? column.key;
    if (this.ordering() === key) {
      return 'asc';
    }
    if (this.ordering() === `-${key}`) {
      return 'desc';
    }
    return null;
  }

  goTo(page: number): void {
    if (page >= 1 && page <= this.totalPages() && page !== this.page()) {
      this.page.set(page);
    }
  }

  toggleSelect(row: Row): void {
    const id = this.idOf(row);
    this.selectedId.set(this.selectedId() === id ? null : id);
  }

  onRowClick(row: Row): void {
    if (this.editable()) {
      this.toggleSelect(row);
    }
  }

  toggleColumn(key: string): void {
    this.hidden.update((set) => {
      const next = new Set(set);
      if (next.has(key)) {
        next.delete(key);
      } else if (next.size < this.resource().columns.length - 1) {
        next.add(key);
      }
      return next;
    });
  }

  cellValue(row: Row, column: ColumnDef): unknown {
    return row[column.key];
  }

  cellString(row: Row, column: ColumnDef): string {
    return cellText(row, column);
  }

  // ---------------------------------------------------------------- exportar
  private exportMatrix(): string[][] {
    const columns = this.visibleColumns();
    return [columns.map((c) => c.label), ...this.rows().map((row) => columns.map((c) => cellText(row, c)))];
  }

  async copy(): Promise<void> {
    const text = this.exportMatrix()
      .map((cells) => cells.join('\t'))
      .join('\n');
    try {
      await navigator.clipboard.writeText(text);
      this.notify.success(`${this.rows().length} filas copiadas al portapapeles.`);
    } catch {
      this.notify.error('No se ha podido copiar', 'El navegador no permite acceder al portapapeles.');
    }
  }

  exportCsv(): void {
    downloadText(`${this.resource().key}.csv`, toCsv(this.exportMatrix()));
  }

  print(): void {
    const matrix = this.exportMatrix();
    const [header, ...body] = matrix;
    const html = `<!doctype html><html lang="es"><head><meta charset="utf-8"><title>${escapeHtml(this.resource().title)}</title>
      <style>body{font-family:system-ui,sans-serif;padding:24px;color:#111}h1{font-size:18px;margin:0 0 12px}
      table{border-collapse:collapse;width:100%;font-size:12px}th,td{border:1px solid #999;padding:4px 6px;text-align:left;vertical-align:top}
      th{background:#eee}</style></head><body><h1>${escapeHtml(this.resource().title)}</h1><table><thead><tr>${header
        .map((h) => `<th>${escapeHtml(h)}</th>`)
        .join('')}</tr></thead><tbody>${body
        .map((cells) => `<tr>${cells.map((c) => `<td>${escapeHtml(c)}</td>`).join('')}</tr>`)
        .join('')}</tbody></table></body></html>`;
    const win = window.open('', '_blank', 'width=1024,height=768');
    if (!win) {
      this.notify.error('No se ha podido abrir la vista de impresión', 'Permite las ventanas emergentes para este sitio.');
      return;
    }
    win.document.write(html);
    win.document.close();
    win.focus();
    win.print();
  }

  // ---------------------------------------------------------------- CRUD
  openCreate(): void {
    this.dialogInitial.set(null);
    this.dialogOpen.set(true);
  }

  openEdit(): void {
    const row = this.selectedRow();
    if (!row) {
      this.notify.info('Selecciona un registro para editar.');
      return;
    }
    this.dialogInitial.set(row);
    this.dialogOpen.set(true);
  }

  closeDialog(): void {
    this.dialogOpen.set(false);
  }

  save(values: FormValues): void {
    const resource = this.resource();
    const editing = this.dialogInitial();
    this.saving.set(true);
    const request = editing
      ? this.api.patch<Row>(`${resource.endpoint}${this.idOf(editing)}/`, values)
      : this.api.post<Row>(resource.endpoint, values);
    request.subscribe({
      next: () => {
        this.saving.set(false);
        this.dialogOpen.set(false);
        this.notify.success(editing ? 'Registro actualizado correctamente.' : 'Registro creado correctamente.');
        this.reload();
        this.changed.emit();
      },
      error: (err: unknown) => {
        this.saving.set(false);
        this.notify.error(editing ? 'No se ha podido actualizar el registro' : 'No se ha podido crear el registro', this.notify.describeError(err));
      },
    });
  }

  async remove(): Promise<void> {
    const row = this.selectedRow();
    if (!row) {
      this.notify.info('Selecciona un registro para eliminar.');
      return;
    }
    const confirmed = await this.notify.confirm('¿Eliminar el registro?', 'Esta acción no se puede deshacer.');
    if (!confirmed) {
      return;
    }
    this.api.delete(`${this.resource().endpoint}${this.idOf(row)}/`).subscribe({
      next: () => {
        this.notify.success('Registro eliminado.');
        this.selectedId.set(null);
        this.reload();
        this.changed.emit();
      },
      error: (err: unknown) => this.notify.error('No se ha podido eliminar el registro', this.notify.describeError(err)),
    });
  }
}
