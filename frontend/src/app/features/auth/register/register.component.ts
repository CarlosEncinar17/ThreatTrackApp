import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { RouterLink } from '@angular/router';

import { NotifyService } from '../../../core/ui/notify.service';
import { AuthCardComponent } from '../../../shared/auth-card/auth-card.component';

/**
 * Formulario de registro. Como en la version original no existe alta de usuarios en el
 * servidor: las cuentas las crea el administrador (panel de administracion o bootstrap_roles).
 */
@Component({
  selector: 'app-register',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ReactiveFormsModule, RouterLink, AuthCardComponent],
  styleUrl: '../auth.scss',
  template: `
    <app-auth-card message="Registrarse como nuevo usuario.">
      <p class="auth-note">
        <i class="fa-solid fa-circle-info" aria-hidden="true"></i>
        El alta de cuentas la gestiona el administrador de la plataforma. Envía la solicitud y te asignará el rol y el cliente correspondientes.
      </p>
      <form [formGroup]="form" (ngSubmit)="submit()" novalidate class="auth-form">
        <div class="field">
          <label for="fullName">Nombre completo</label>
          <input id="fullName" class="input" type="text" formControlName="fullName" autocomplete="name" />
        </div>
        <div class="field">
          <label for="email">Correo electrónico</label>
          <input id="email" class="input" type="email" formControlName="email" autocomplete="email" />
        </div>
        <div class="field">
          <label for="password">Contraseña</label>
          <input id="password" class="input" type="password" formControlName="password" autocomplete="new-password" />
        </div>
        <div class="field">
          <label for="confirm">Confirmar contraseña</label>
          <input id="confirm" class="input" type="password" formControlName="confirm" autocomplete="new-password" />
        </div>
        <div class="auth-row">
          <label class="checkbox">
            <input type="checkbox" formControlName="terms" />
            <span>Acepto los términos y condiciones</span>
          </label>
          <button type="submit" class="btn btn--primary" [disabled]="form.invalid">Registrar</button>
        </div>
      </form>
      <div class="auth-links">
        <a routerLink="/login">Ya tengo cuenta</a>
      </div>
    </app-auth-card>
  `,
})
export class RegisterComponent {
  private readonly notify = inject(NotifyService);

  readonly form = new FormGroup({
    fullName: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
    email: new FormControl('', { nonNullable: true, validators: [Validators.required, Validators.email] }),
    password: new FormControl('', { nonNullable: true, validators: [Validators.required, Validators.minLength(10)] }),
    confirm: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
    terms: new FormControl(false, { nonNullable: true, validators: [Validators.requiredTrue] }),
  });

  submit(): void {
    if (this.form.getRawValue().password !== this.form.getRawValue().confirm) {
      this.notify.error('Las contraseñas no coinciden');
      return;
    }
    this.notify.info('Solicitud registrada: el administrador activará tu cuenta.');
    this.form.reset();
  }
}
