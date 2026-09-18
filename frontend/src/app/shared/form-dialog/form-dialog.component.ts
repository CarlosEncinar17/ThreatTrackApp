import {
  ChangeDetectionStrategy,
  Component,
  ElementRef,
  computed,
  effect,
  inject,
  input,
  output,
  signal,
  untracked,
  viewChild,
} from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, ValidatorFn, Validators } from '@angular/forms';

import { FieldDef, OptionSource } from '../../core/resources/resource-definitions';
import { LookupsService, SelectOption } from '../../core/services/lookups.service';

export type FormValues = Record<string, unknown>;

/**
 * Dialogo con un formulario reactivo generado a partir de una lista de campos.
 * Sustituye a los formularios HTML incrustados en SweetAlert de la version original.
 */
@Component({
  selector: 'app-form-dialog',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ReactiveFormsModule],
  templateUrl: './form-dialog.component.html',
  styleUrl: './form-dialog.component.scss',
})
export class FormDialogComponent {
  private readonly lookups = inject(LookupsService);

  readonly title = input.required<string>();
  readonly fields = input.required<FieldDef[]>();
  /** Valores iniciales (edicion). `null` = alta. */
  readonly initial = input<FormValues | null>(null);
  readonly open = input<boolean>(false);
  readonly busy = input<boolean>(false);
  readonly submitted = output<FormValues>();
  readonly closed = output<void>();

  /** El formulario se reconstruye cuando cambian los campos o los valores iniciales. */
  readonly form = computed<FormGroup>(() => buildForm(this.fields(), this.initial()));
  readonly options = signal<Partial<Record<OptionSource, SelectOption[]>>>({});
  readonly isEdit = computed(() => this.initial() !== null);

  private readonly dialog = viewChild.required<ElementRef<HTMLDialogElement>>('dialog');

  constructor() {
    effect(() => {
      const open = this.open();
      const fields = this.fields();
      const dialog = this.dialog().nativeElement;
      untracked(() => {
        if (open) {
          this.loadOptions(fields);
          if (!dialog.open) {
            dialog.showModal();
          }
        } else if (dialog.open) {
          dialog.close();
        }
      });
    });
  }

  control(key: string): FormControl {
    return this.form().get(key) as FormControl;
  }

  invalid(key: string): boolean {
    const control = this.control(key);
    return !!control && control.invalid && (control.touched || control.dirty);
  }

  submit(): void {
    const form = this.form();
    form.markAllAsTouched();
    if (form.invalid) {
      return;
    }
    this.submitted.emit(serialize(this.fields(), form.getRawValue()));
  }

  cancel(): void {
    this.closed.emit();
  }

  /** Tecla Escape: se cierra a traves del estado `open` del padre. */
  onCancelEvent(event: Event): void {
    event.preventDefault();
    this.cancel();
  }

  /** Clic fuera del panel (sobre el fondo del dialogo). */
  onBackdropClick(event: MouseEvent): void {
    if (event.target === this.dialog().nativeElement) {
      this.cancel();
    }
  }

  private loadOptions(fields: FieldDef[]): void {
    const sources = new Set(fields.map((f) => f.options).filter((s): s is OptionSource => !!s));
    if (sources.size === 0) {
      return;
    }
    this.lookups.ensureLoaded().subscribe(() => {
      this.options.update((current) => ({
        ...current,
        ...(sources.has('customers') ? { customers: this.lookups.customers() } : {}),
        ...(sources.has('states') ? { states: this.lookups.states() } : {}),
        ...(sources.has('severities') ? { severities: this.lookups.severities() } : {}),
      }));
    });
    if (sources.has('domains')) {
      this.lookups
        .options<{ id: number; domain_name: string; customer_name: string }>('Domains/', (d) => `${d.domain_name} · ${d.customer_name}`)
        .subscribe((domains) => this.options.update((current) => ({ ...current, domains })));
    }
    if (sources.has('keywords')) {
      this.lookups
        .options<{ id: number; term: string; customer_name: string }>('Keywords/', (k) => `${k.term} · ${k.customer_name}`)
        .subscribe((keywords) => this.options.update((current) => ({ ...current, keywords })));
    }
  }
}

function buildForm(fields: FieldDef[], initial: FormValues | null): FormGroup {
  const controls: Record<string, FormControl> = {};
  for (const field of fields) {
    const validators: ValidatorFn[] = [];
    if (field.required) {
      validators.push(field.type === 'checkbox' ? Validators.nullValidator : Validators.required);
    }
    if (field.type === 'email') {
      validators.push(Validators.email);
    }
    const raw = initial ? initial[field.key] : undefined;
    controls[field.key] = new FormControl(
      { value: initialValue(field, raw), disabled: !!initial && !!field.lockOnEdit },
      validators,
    );
  }
  return new FormGroup(controls);
}

function initialValue(field: FieldDef, raw: unknown): unknown {
  if (field.type === 'checkbox') {
    return raw === true;
  }
  if (raw === null || raw === undefined) {
    return field.type === 'select' ? null : '';
  }
  if (field.type === 'date') {
    return String(raw).slice(0, 10);
  }
  if (field.type === 'datetime') {
    return String(raw).slice(0, 16);
  }
  return raw;
}

function serialize(fields: FieldDef[], values: FormValues): FormValues {
  const out: FormValues = {};
  for (const field of fields) {
    const value = values[field.key];
    if (field.type === 'checkbox') {
      out[field.key] = value === true;
      continue;
    }
    if (field.type === 'select') {
      out[field.key] = value === null || value === '' || value === undefined ? null : Number(value);
      continue;
    }
    if (field.type === 'number') {
      out[field.key] = value === '' || value === null || value === undefined ? null : Number(value);
      continue;
    }
    out[field.key] = value === '' || value === undefined ? null : value;
  }
  return out;
}
