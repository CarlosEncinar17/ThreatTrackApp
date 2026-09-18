import { Routes } from '@angular/router';

import { authGuard, guestGuard, roleGuard } from './core/auth/guards';

export const routes: Routes = [
  { path: '', pathMatch: 'full', redirectTo: 'login' },
  {
    path: 'login',
    canActivate: [guestGuard],
    loadComponent: () => import('./features/auth/login/login.component').then((m) => m.LoginComponent),
    title: 'Iniciar sesión · Threat Track App',
  },
  {
    path: 'register',
    canActivate: [guestGuard],
    loadComponent: () => import('./features/auth/register/register.component').then((m) => m.RegisterComponent),
    title: 'Registro · Threat Track App',
  },
  {
    path: 'forgot-password',
    canActivate: [guestGuard],
    loadComponent: () =>
      import('./features/auth/forgot-password/forgot-password.component').then((m) => m.ForgotPasswordComponent),
    title: 'Recuperar acceso · Threat Track App',
  },
  {
    path: 'recover-password',
    canActivate: [guestGuard],
    loadComponent: () =>
      import('./features/auth/recover-password/recover-password.component').then((m) => m.RecoverPasswordComponent),
    title: 'Nueva contraseña · Threat Track App',
  },
  {
    path: '',
    canActivate: [authGuard],
    loadComponent: () => import('./layout/shell/shell.component').then((m) => m.ShellComponent),
    children: [
      {
        path: 'client/dashboard',
        loadComponent: () => import('./features/client/dashboard/dashboard.component').then((m) => m.DashboardComponent),
        data: { title: 'Dashboards en tiempo real', filters: ['customer'] },
        title: 'Dashboards · Threat Track App',
      },
      {
        path: 'client/alerts',
        loadComponent: () => import('./features/alerts/alerts-board/alerts-board.component').then((m) => m.AlertsBoardComponent),
        data: { title: 'Listado de alertas de cada servicio', filters: ['dates', 'customer', 'state', 'severity'], editable: false },
        title: 'Alertas de los servicios · Threat Track App',
      },
      {
        path: 'client/services',
        loadComponent: () => import('./features/client/services/services.component').then((m) => m.ServicesComponent),
        data: { title: 'Servicios de cibervigilancia digital', filters: ['customer'] },
        title: 'Servicios de defensa · Threat Track App',
      },
      {
        path: 'analyst/customers',
        canActivate: [roleGuard('analyst')],
        loadComponent: () =>
          import('./features/analyst/customers-config/customers-config.component').then((m) => m.CustomersConfigComponent),
        data: { title: 'Configuración de clientes, metadatos y dorks', filters: ['dates', 'customer'] },
        title: 'Configuración de clientes · Threat Track App',
      },
      {
        path: 'analyst/alerts',
        canActivate: [roleGuard('analyst')],
        loadComponent: () => import('./features/alerts/alerts-board/alerts-board.component').then((m) => m.AlertsBoardComponent),
        data: { title: 'Gestión de alertas de cada servicio', filters: ['dates', 'customer', 'state', 'severity'], editable: true },
        title: 'Gestión de alertas · Threat Track App',
      },
      {
        path: 'analyst/servers',
        canActivate: [roleGuard('analyst')],
        loadComponent: () =>
          import('./features/analyst/server-status/server-status.component').then((m) => m.ServerStatusComponent),
        data: { title: 'Estado de los servidores', filters: [] },
        title: 'Estado de servidores · Threat Track App',
      },
    ],
  },
  { path: '**', redirectTo: 'login' },
];
