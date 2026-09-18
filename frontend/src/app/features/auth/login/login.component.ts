import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, inject, input, signal } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';

import { AuthService } from '../../../core/auth/auth.service';
import { AuthCardComponent } from '../../../shared/auth-card/auth-card.component';

@Component({
  selector: 'app-login',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ReactiveFormsModule, RouterLink, AuthCardComponent],
  templateUrl: './login.component.html',
  styleUrl: '../auth.scss',
})
export class LoginComponent {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  /** Ruta a la que volver tras iniciar sesion (?next=). */
  readonly next = input<string>('');
  /** Aviso de sesion caducada (?expired=1). */
  readonly expired = input<string>('');

  readonly form = new FormGroup({
    username: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
    password: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
    remember: new FormControl(false, { nonNullable: true }),
  });
  readonly busy = signal(false);
  readonly error = signal<string | null>(null);

  submit(): void {
    this.form.markAllAsTouched();
    if (this.form.invalid || this.busy()) {
      return;
    }
    const { username, password, remember } = this.form.getRawValue();
    this.busy.set(true);
    this.error.set(null);
    this.auth.login(username, password, remember).subscribe({
      next: (session) => {
        this.busy.set(false);
        const target = this.next() && this.next().startsWith('/') ? this.next() : this.auth.homeFor(session.role);
        void this.router.navigateByUrl(target);
      },
      error: (err: unknown) => {
        this.busy.set(false);
        if (err instanceof HttpErrorResponse && (err.status === 400 || err.status === 401)) {
          this.error.set('Usuario o contraseña incorrectos.');
        } else if (err instanceof HttpErrorResponse && err.status === 429) {
          this.error.set('Demasiados intentos. Espera un minuto y vuelve a intentarlo.');
        } else {
          this.error.set('No se ha podido contactar con el servidor.');
        }
      },
    });
  }
}
