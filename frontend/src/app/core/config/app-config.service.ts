import { HttpClient } from '@angular/common/http';
import { Injectable, inject, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';

export interface AppConfig {
  /** Base de la API REST. Por defecto `/api`, que nginx redirige al backend. */
  apiBaseUrl: string;
}

const DEFAULT_CONFIG: AppConfig = { apiBaseUrl: '/api' };

/**
 * Configuracion en tiempo de ejecucion (assets/config.json). Se carga antes de
 * arrancar la aplicacion, asi el mismo build sirve para cualquier despliegue.
 */
@Injectable({ providedIn: 'root' })
export class AppConfigService {
  private readonly http = inject(HttpClient);
  private readonly config = signal<AppConfig>(DEFAULT_CONFIG);

  get apiBaseUrl(): string {
    return this.config().apiBaseUrl.replace(/\/+$/, '');
  }

  async load(): Promise<void> {
    try {
      const loaded = await firstValueFrom(this.http.get<Partial<AppConfig>>('assets/config.json'));
      this.config.set({ ...DEFAULT_CONFIG, ...loaded });
    } catch {
      this.config.set(DEFAULT_CONFIG);
    }
  }
}
