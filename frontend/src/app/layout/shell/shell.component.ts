import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { ActivatedRouteSnapshot, NavigationEnd, Router, RouterOutlet } from '@angular/router';
import { filter, map, startWith } from 'rxjs';

import { AuthService } from '../../core/auth/auth.service';
import { FilterKind } from '../../core/filters/global-filters.store';
import { GlobalFiltersComponent } from '../global-filters/global-filters.component';
import { SidebarComponent } from '../sidebar/sidebar.component';

interface RouteInfo {
  title: string;
  filters: FilterKind[];
}

const SIDEBAR_KEY = 'tta.sidebar-collapsed';

/** Marco de la aplicacion: barra lateral, barra superior con filtros y contenido. */
@Component({
  selector: 'app-shell',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [RouterOutlet, SidebarComponent, GlobalFiltersComponent],
  templateUrl: './shell.component.html',
  styleUrl: './shell.component.scss',
})
export class ShellComponent {
  private readonly router = inject(Router);
  protected readonly auth = inject(AuthService);

  readonly collapsed = signal<boolean>(readCollapsed());
  readonly mobileOpen = signal(false);
  readonly userMenuOpen = signal(false);

  readonly routeInfo = toSignal(
    this.router.events.pipe(
      filter((event) => event instanceof NavigationEnd),
      startWith(null),
      map(() => deepestData(this.router.routerState.snapshot.root)),
    ),
    { initialValue: { title: '', filters: [] } as RouteInfo },
  );

  readonly roleLabel = computed(() => (this.auth.isAnalyst() ? 'Analista' : 'Cliente'));

  toggleSidebar(): void {
    if (window.matchMedia('(max-width: 992px)').matches) {
      this.mobileOpen.update((open) => !open);
      return;
    }
    this.collapsed.update((value) => {
      const next = !value;
      try {
        localStorage.setItem(SIDEBAR_KEY, String(next));
      } catch {
        // sin almacenamiento
      }
      return next;
    });
  }

  closeMobile(): void {
    this.mobileOpen.set(false);
  }

  logout(): void {
    this.userMenuOpen.set(false);
    this.auth.logout();
  }
}

function deepestData(snapshot: ActivatedRouteSnapshot): RouteInfo {
  let node = snapshot;
  while (node.firstChild) {
    node = node.firstChild;
  }
  return {
    title: (node.data['title'] as string) ?? '',
    filters: (node.data['filters'] as FilterKind[]) ?? [],
  };
}

function readCollapsed(): boolean {
  try {
    return localStorage.getItem(SIDEBAR_KEY) === 'true';
  } catch {
    return false;
  }
}
