import { ChangeDetectionStrategy, Component, input } from '@angular/core';

/** Marco de las paginas de acceso (inicio de sesion, registro, recuperacion). */
@Component({
  selector: 'app-auth-card',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="auth">
      <div class="auth__card">
        <div class="auth__brand">
          <img src="assets/img/LogoTTA.png" alt="Threat Track App" />
        </div>
        <p class="auth__message">{{ message() }}</p>
        <ng-content />
      </div>
      <p class="auth__footer">Threat Track App · Gestión de la superficie de ataque</p>
    </div>
  `,
  styles: `
    .auth {
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 1.5rem;
      background:
        radial-gradient(ellipse at 20% 0%, rgba(10, 103, 163, 0.35), transparent 55%),
        radial-gradient(ellipse at 100% 100%, rgba(116, 192, 252, 0.12), transparent 50%),
        var(--tta-bg);
    }
    .auth__card {
      width: 100%;
      max-width: 420px;
      background: var(--tta-surface);
      border: 1px solid var(--tta-border-strong);
      border-top: 4px solid var(--tta-primary);
      border-radius: var(--tta-radius);
      box-shadow: var(--tta-shadow);
      padding: 1.75rem 1.75rem 1.5rem;
    }
    .auth__brand {
      background: #fff;
      border-radius: var(--tta-radius-sm);
      padding: 0.9rem 1.2rem;
      margin-bottom: 1.25rem;
      display: flex;
      justify-content: center;
    }
    .auth__brand img { height: 46px; width: auto; }
    .auth__message { text-align: center; color: var(--tta-text-muted); margin-bottom: 1.25rem; }
    .auth__footer { margin-top: 1.25rem; font-size: 0.8rem; color: var(--tta-text-dim); text-align: center; }
  `,
})
export class AuthCardComponent {
  readonly message = input<string>('');
}
