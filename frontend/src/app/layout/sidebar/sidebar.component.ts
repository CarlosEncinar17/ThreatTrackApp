import { ChangeDetectionStrategy, Component, inject, input, output } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';

import { AuthService } from '../../core/auth/auth.service';

interface NavItem {
  label: string;
  icon: string;
  route?: string;
  /** Sin ruta: entrada prevista pero aun no disponible (como en la version original). */
  soon?: boolean;
}

interface NavSection {
  label: string;
  icon: string;
  analystOnly: boolean;
  items: NavItem[];
}

const SECTIONS: NavSection[] = [
  {
    label: 'Cliente',
    icon: 'fa-solid fa-users',
    analystOnly: false,
    items: [
      { label: 'Dashboards', icon: 'fa-solid fa-chart-pie', route: '/client/dashboard' },
      { label: 'Alertas de los servicios', icon: 'fa-solid fa-triangle-exclamation', route: '/client/alerts' },
      { label: 'Servicios de defensa', icon: 'fa-solid fa-shield', route: '/client/services' },
    ],
  },
  {
    label: 'Analista',
    icon: 'fa-solid fa-user-tie',
    analystOnly: true,
    items: [
      { label: 'Configuración de clientes', icon: 'fa-solid fa-user-gear', route: '/analyst/customers' },
      { label: 'Gestión de alertas', icon: 'fa-solid fa-list-check', route: '/analyst/alerts' },
      { label: 'Estado de servidores', icon: 'fa-solid fa-server', route: '/analyst/servers' },
      { label: 'Estado de scripts', icon: 'fa-brands fa-python', soon: true },
      { label: 'Configuración de roles', icon: 'fa-solid fa-user-tag', soon: true },
    ],
  },
];

@Component({
  selector: 'app-sidebar',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [RouterLink, RouterLinkActive],
  templateUrl: './sidebar.component.html',
  styleUrl: './sidebar.component.scss',
})
export class SidebarComponent {
  protected readonly auth = inject(AuthService);
  readonly collapsed = input<boolean>(false);
  readonly navigated = output<void>();
  readonly sections = SECTIONS;
}
