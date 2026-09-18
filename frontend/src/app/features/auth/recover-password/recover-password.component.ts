import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';

import { NotifyService } from '../../../core/ui/notify.service';
import { AuthCardComponent } from '../../../shared/auth-card/auth-card.component';

/** Establecer una nueva contrasena (pantalla informativa, como en la version original). */
@Component({
  selector: 'app-recover-password',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ReactiveFormsModule, RouterLink, AuthCardComponent],
  styleUrl: '../auth.scss',
  template: `
    <app-auth-card message="Estás a un paso de tu nueva contraseña.">
      <form [formGroup]="form" (ngSubmit)="submit()" novalidate class="auth-form">
        <div class="field">
          <label for="password">Nueva contraseña</label>
          <input id="password" class="input" type="password" formControlName="password" autocomplete="new-password" />
        </div>
        <div class="field">
          <label for="confirm">Confirmar contraseña</label>
          <input id="confirm" class="input" type="password" formControlName="confirm" autocomplete="new-password" />
        </div>
        <button type="submit" class="btn btn--primary btn--block" [disabled]="form.invalid">Cambiar contraseña</button>
      </form>
      <div class="auth-links">
        <a routerLink="/login">Volver al inicio de sesión</a>
      </div>
    </app-auth-card>
  `,
})
export class RecoverPasswordComponent {
  private readonly notify = inject(NotifyService);
  private readonly router = inject(Router);
  readonly form = new FormGroup({
    password: new FormControl('', { nonNullable: true, validators: [Validators.required, Validators.minLength(10)] }),
    confirm: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
  });

  submit(): void {
    const { password, confirm } = this.form.getRawValue();
    if (password !== confirm) {
      this.notify.error('Las contraseñas no coinciden');
      return;
    }
    this.notify.info('El cambio de contraseña lo aplica el administrador de la plataforma.');
    void this.router.navigate(['/login']);
  }
}
