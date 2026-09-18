import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';

import { UserRole } from '../api/models';
import { AuthService } from './auth.service';

/** Exige sesion iniciada. */
export const authGuard: CanActivateFn = (_route, state) => {
  const auth = inject(AuthService);
  const router = inject(Router);
  if (auth.isAuthenticated()) {
    return true;
  }
  return router.createUrlTree(['/login'], { queryParams: { next: state.url } });
};

/** Exige un rol concreto (los analistas pueden entrar en todas las secciones). */
export function roleGuard(role: UserRole): CanActivateFn {
  return () => {
    const auth = inject(AuthService);
    const router = inject(Router);
    if (!auth.isAuthenticated()) {
      return router.createUrlTree(['/login']);
    }
    if (auth.isAnalyst() || auth.role() === role) {
      return true;
    }
    return router.createUrlTree([auth.homeFor(auth.role())]);
  };
}

/** Si ya hay sesion, salta el login y va a la pagina de inicio del rol. */
export const guestGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);
  return auth.isAuthenticated() ? router.createUrlTree([auth.homeFor(auth.role())]) : true;
};
