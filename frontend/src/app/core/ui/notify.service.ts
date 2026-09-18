import { Injectable } from '@angular/core';
import Swal, { SweetAlertIcon } from 'sweetalert2';

/** Avisos y confirmaciones (SweetAlert2, como en la version original). */
@Injectable({ providedIn: 'root' })
export class NotifyService {
  private readonly toast = Swal.mixin({
    toast: true,
    position: 'top-end',
    showConfirmButton: false,
    timer: 3000,
    timerProgressBar: true,
    didOpen: (el) => {
      el.addEventListener('mouseenter', Swal.stopTimer);
      el.addEventListener('mouseleave', Swal.resumeTimer);
    },
  });

  info(title: string): void {
    void this.toast.fire({ title, icon: 'info' });
  }

  success(title: string): void {
    void this.toast.fire({ title, icon: 'success' });
  }

  error(title: string, text?: string): void {
    void Swal.fire({ title, text, icon: 'error', confirmButtonText: 'Cerrar' });
  }

  async confirm(title: string, text: string, confirmText = 'Sí, eliminar', icon: SweetAlertIcon = 'warning'): Promise<boolean> {
    const result = await Swal.fire({
      title,
      text,
      icon,
      showCancelButton: true,
      confirmButtonText: confirmText,
      cancelButtonText: 'Cancelar',
      confirmButtonColor: '#dc3545',
      reverseButtons: true,
      focusCancel: true,
    });
    return result.isConfirmed;
  }

  /** Mensaje de error a partir de la respuesta de la API. */
  describeError(error: unknown): string {
    const body = (error as { error?: unknown })?.error;
    if (!body) {
      return 'No se ha podido completar la operación.';
    }
    if (typeof body === 'string') {
      return body;
    }
    if (typeof body === 'object') {
      const record = body as Record<string, unknown>;
      if (typeof record['detail'] === 'string') {
        return record['detail'];
      }
      return Object.entries(record)
        .map(([field, messages]) => `${field}: ${Array.isArray(messages) ? messages.join(' ') : String(messages)}`)
        .join('\n');
    }
    return 'No se ha podido completar la operación.';
  }
}
