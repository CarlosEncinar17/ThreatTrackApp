import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { RouterLink } from '@angular/router';

import { NotifyService } from '../../../core/ui/notify.service';
import { AuthCardComponent } from '../../../shared/auth-card/auth-card.component';

/** Recuperacion de acceso (sin servicio de correo en el servidor, como en la version original). */
@Component({
  selector: 'app-forgot-password',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ReactiveFormsModule, RouterLink, AuthCardComponent],
  styleUrl: '../auth.scss',
  template: `
    <app-auth-card message="¿Has olvidado tu contraseña? Indica tu correo y el administrador se pondrá en contacto contigo.">
      <form [formGroup]="form" (ngSubmit)="submit()" novalidate class="auth-form">
        <div class="field">
          <label for="email">Correo electrónico</label>
          <input id="email" class="input" type="email" formControlName="email" autocomplete="email" />
        </div>
        <button type="submit" class="btn btn--primary btn--block" [disabled]="form.invalid">Solicitar nueva contraseña</button>
      </form>
      <div class="auth-links">
        <a routerLink="/login">Volver al inicio de sesión</a>
        <a routerLink="/register">Crear cuenta</a>
      </div>
    </app-auth-card>
  `,
})
export class ForgotPasswordComponent {
  private readonly notify = inject(NotifyService);
  readonly form = new FormGroup({
    email: new FormControl('', { nonNullable: true, validators: [Validators.required, Validators.email] }),
  });

  submit(): void {
    this.notify.info('Solicitud enviada al administrador de la plataforma.');
    this.form.reset();
  }
}
