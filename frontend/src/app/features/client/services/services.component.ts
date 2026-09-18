import { ChangeDetectionStrategy, Component, computed, effect, inject, signal, untracked } from '@angular/core';
import { RouterLink } from '@angular/router';

import { ApiClient } from '../../../core/api/api-client.service';
import { CustomerServiceSubscription } from '../../../core/api/models';
import { AuthService } from '../../../core/auth/auth.service';
import { GlobalFiltersStore } from '../../../core/filters/global-filters.store';

type Flag = keyof Omit<CustomerServiceSubscription, 'customer' | 'customer_name' | 'notes'>;

interface ServiceCard {
  title: string;
  image: string;
  description: string;
  /** Seccion del tablero de alertas a la que enlaza. */
  anchor: string;
  /** Servicios contratados (columnas de la suscripcion) que activan este servicio. Vacio = en desarrollo. */
  flags: Flag[];
}

/** Catalogo de servicios de cibervigilancia (textos de la version original). */
const SERVICES: ServiceCard[] = [
  {
    title: 'Fugas de información',
    image: 'inf.png',
    anchor: 'inf',
    flags: ['github_enabled', 'gitlab_enabled', 'google_enabled'],
    description:
      'Búsqueda de información en RRSS, Surface Web y Deep Web sobre posibles filtraciones de información que puedan dañar la imagen pública de la compañía y, por tanto, impactar negativamente en el negocio, generando desconfianza e inseguridad en clientes.',
  },
  {
    title: 'Exposición de credenciales',
    image: 'cre.png',
    anchor: 'cre',
    flags: ['intelx_enabled', 'telegram_enabled', 'twitter_enabled'],
    description: 'Identificación de filtraciones de credenciales corporativas de la compañía, así como de las cuentas que las utilizan.',
  },
  {
    title: 'Alertas de defacement',
    image: 'def.png',
    anchor: 'defa',
    flags: ['defacement_enabled'],
    description: 'Monitorización de los sitios web para detectar ataques mediante los que se cambia el aspecto visual de una página web.',
  },
  {
    title: 'Alertas de phishing',
    image: 'phi.png',
    anchor: 'phi',
    flags: ['typosquatting_enabled'],
    description:
      'Monitorización de los dominios de la compañía y de aquellos tan similares (typosquatting) que puedan dar pie a un atacante a utilizarlos como phishing.',
  },
  {
    title: 'Monitorización de dominios',
    image: 'mon.png',
    anchor: 'mon',
    flags: ['certificates_enabled'],
    description:
      'Monitorización de los aspectos relacionados con los dominios: suplantaciones de identidad, cambios de registrador, mala configuración o ausencia de un certificado digital, entre otros.',
  },
  {
    title: 'Listas de categorización',
    image: 'list.png',
    anchor: 'lists',
    flags: ['blocklist_enabled'],
    description:
      'Identificación de los dominios, IPs, direcciones de correo electrónico y hashes de la compañía en listas de categorización públicas, con afectación a la reputación y la operatividad de los mismos.',
  },
  {
    title: 'Carding',
    image: 'card.png',
    anchor: 'card',
    flags: [],
    description: 'Monitorización de foros, mercados y sitios donde prolifera la comercialización de tarjetas bancarias y/o datos relativos a estas.',
  },
  {
    title: 'Monitorización de sistemas, vulnerabilidades y apps',
    image: 'def.png',
    anchor: 'mons',
    flags: ['shodan_enabled'],
    description:
      'Identificación de la exposición de sistemas con vulnerabilidades públicas que un atacante podría explotar para comprometer su integridad, disponibilidad o confidencialidad, así como del uso no autorizado de aplicaciones legítimas con fines malintencionados.',
  },
  {
    title: 'Fraude de app',
    image: 'fraude.png',
    anchor: 'fraude',
    flags: [],
    description:
      'Identificación de aplicaciones no autorizadas para Android o iOS distribuidas en markets no oficiales, con el fin de detectar posibles distribuciones de adware, malware, abusos de marca o fraude.',
  },
  {
    title: 'Hacktivismo',
    image: 'hack.png',
    anchor: 'hack',
    flags: [],
    description:
      'Identificación de posibles movimientos que se gestan y organizan a través de foros privados y redes sociales, tanto en la Surface Web como en la Dark Web, en forma de campañas de ataques globales contra entidades y estatutos locales.',
  },
  {
    title: 'VIP y VAP',
    image: 'vip.png',
    anchor: 'vip',
    flags: [],
    description:
      'Monitorización para detectar una posible suplantación de la identidad de estas personas y evitar engaños o estafas que puedan causar perjuicios económicos, daños de imagen, divulgación de información confidencial o abuso de los sistemas.',
  },
];

/**
 * Servicios de defensa: el estado activo/inactivo de cada servicio se toma de los servicios
 * contratados por el cliente (tabla de suscripciones), en vez de los iconos fijos de la
 * version original.
 */
@Component({
  selector: 'app-services',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [RouterLink],
  templateUrl: './services.component.html',
  styleUrl: './services.component.scss',
})
export class ServicesComponent {
  private readonly api = inject(ApiClient);
  protected readonly auth = inject(AuthService);
  protected readonly filters = inject(GlobalFiltersStore);

  readonly services = SERVICES;
  readonly subscription = signal<CustomerServiceSubscription | null>(null);
  readonly loaded = signal(false);
  readonly customerId = computed(() => this.filters.customerId());
  readonly alertsRoute = computed(() => (this.auth.isAnalyst() ? '/analyst/alerts' : '/client/alerts'));

  constructor() {
    effect(() => {
      const customerId = this.customerId();
      untracked(() => this.load(customerId));
    });
  }

  status(service: ServiceCard): 'active' | 'inactive' | 'soon' | 'pending' | 'none' {
    if (service.flags.length === 0) {
      return 'soon';
    }
    if (this.customerId() === null) {
      return 'none';
    }
    const subscription = this.subscription();
    if (!subscription) {
      return this.loaded() ? 'inactive' : 'pending';
    }
    return service.flags.some((flag) => subscription[flag]) ? 'active' : 'inactive';
  }

  private load(customerId: number | null): void {
    this.loaded.set(false);
    this.subscription.set(null);
    if (customerId === null) {
      this.loaded.set(true);
      return;
    }
    this.api.list<CustomerServiceSubscription>('Apps/', { customer: customerId, page_size: 1 }).subscribe({
      next: (page) => {
        this.subscription.set(page.results[0] ?? null);
        this.loaded.set(true);
      },
      error: () => this.loaded.set(true),
    });
  }
}
