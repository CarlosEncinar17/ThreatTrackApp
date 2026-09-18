import { Injectable, computed, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import { Observable, tap } from 'rxjs';

import { ApiClient } from '../api/api-client.service';
import { LoginResponse, SessionInfo, UserRole } from '../api/models';

const TOKEN_KEY = 'tta.token';
const SESSION_KEY = 'tta.session';

/**
 * Sesion del usuario: token de la API y datos de rol/cliente.
 * "Mantener sesion iniciada" guarda en localStorage; si no, en sessionStorage.
 */
@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly api = inject(ApiClient);
  private readonly router = inject(Router);

  private readonly tokenSignal = signal<string | null>(readStorage(TOKEN_KEY));
  private readonly sessionSignal = signal<SessionInfo | null>(readSession());

  readonly token = this.tokenSignal.asReadonly();
  readonly session = this.sessionSignal.asReadonly();
  readonly isAuthenticated = computed(() => this.tokenSignal() !== null);
  readonly role = computed<UserRole | null>(() => this.sessionSignal()?.role ?? null);
  readonly isAnalyst = computed(() => this.role() === 'analyst');
  readonly customer = computed(() => this.sessionSignal()?.customer ?? null);
  readonly username = computed(() => this.sessionSignal()?.username ?? '');

  login(username: string, password: string, remember: boolean): Observable<LoginResponse> {
    return this.api.post<LoginResponse>('auth/login/', { username, password }).pipe(
      tap((response) => {
        const storage = remember ? localStorage : sessionStorage;
        clearStorage();
        writeStorage(storage, TOKEN_KEY, response.token);
        const session: SessionInfo = { username: response.username, role: response.role, customer: response.customer };
        writeStorage(storage, SESSION_KEY, JSON.stringify(session));
        this.tokenSignal.set(response.token);
        this.sessionSignal.set(session);
      }),
    );
  }

  /** Cierra la sesion en el servidor (si es posible) y limpia el estado local. */
  logout(): void {
    const finish = () => {
      clearStorage();
      this.tokenSignal.set(null);
      this.sessionSignal.set(null);
      void this.router.navigate(['/login']);
    };
    if (!this.tokenSignal()) {
      finish();
      return;
    }
    this.api.post<void>('auth/logout/', {}).subscribe({ next: finish, error: finish });
  }

  /** Invalida la sesion local cuando el servidor rechaza el token. */
  expire(): void {
    clearStorage();
    this.tokenSignal.set(null);
    this.sessionSignal.set(null);
  }

  /** Ruta de inicio segun el rol (los analistas entran en la gestion de alertas, como en la version original). */
  homeFor(role: UserRole | null): string {
    return role === 'analyst' ? '/analyst/alerts' : '/client/dashboard';
  }
}

function readStorage(key: string): string | null {
  try {
    return localStorage.getItem(key) ?? sessionStorage.getItem(key);
  } catch {
    return null;
  }
}

function readSession(): SessionInfo | null {
  const raw = readStorage(SESSION_KEY);
  if (!raw) {
    return null;
  }
  try {
    return JSON.parse(raw) as SessionInfo;
  } catch {
    return null;
  }
}

function writeStorage(storage: Storage, key: string, value: string): void {
  try {
    storage.setItem(key, value);
  } catch {
    // almacenamiento no disponible (modo privado): la sesion dura lo que dure la pagina
  }
}

function clearStorage(): void {
  try {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(SESSION_KEY);
    sessionStorage.removeItem(TOKEN_KEY);
    sessionStorage.removeItem(SESSION_KEY);
  } catch {
    // ignorar
  }
}
