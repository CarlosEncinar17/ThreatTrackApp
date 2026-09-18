import { formatDate } from '@angular/common';

import { AlertSeverityName, AlertStateName } from '../core/api/models';
import { ColumnDef } from '../core/resources/resource-definitions';

export const STATE_META: Record<AlertStateName, { label: string; icon: string; color: string }> = {
  open: { label: 'Abierta', icon: 'fa-regular fa-folder-open', color: 'var(--tta-state-open)' },
  in_progress: { label: 'En progreso', icon: 'fa-solid fa-spinner', color: 'var(--tta-state-in-progress)' },
  resolved: { label: 'Resuelta', icon: 'fa-solid fa-check', color: 'var(--tta-state-resolved)' },
  false_positive: { label: 'Falso positivo', icon: 'fa-solid fa-circle-xmark', color: 'var(--tta-state-false-positive)' },
  duplicated: { label: 'Duplicada', icon: 'fa-solid fa-copy', color: 'var(--tta-state-duplicated)' },
};

export const SEVERITY_META: Record<AlertSeverityName, { label: string; color: string }> = {
  critical: { label: 'Crítica', color: 'var(--tta-sev-critical)' },
  high: { label: 'Alta', color: 'var(--tta-sev-high)' },
  medium: { label: 'Media', color: 'var(--tta-sev-medium)' },
  low: { label: 'Baja', color: 'var(--tta-sev-low)' },
  informative: { label: 'Informativa', color: 'var(--tta-sev-informative)' },
  unknown: { label: 'Desconocida', color: 'var(--tta-sev-unknown)' },
};

export const SEVERITY_HEX: Record<string, string> = {
  critical: '#7a26c0',
  high: '#e22222',
  medium: '#ffd43b',
  low: '#63e6be',
  informative: '#74c0fc',
  unknown: '#ffffff',
};

/** Texto plano de una celda (para copiar, exportar e imprimir). */
export function cellText(row: Record<string, unknown>, column: ColumnDef): string {
  const value = row[column.key];
  if (value === null || value === undefined || value === '') {
    return '';
  }
  switch (column.type) {
    case 'date':
      return safeDate(String(value), 'dd/MM/yyyy');
    case 'datetime':
      return safeDate(String(value), 'dd/MM/yyyy HH:mm');
    case 'bool':
      return value ? 'Sí' : 'No';
    case 'state':
      return STATE_META[value as AlertStateName]?.label ?? String(value);
    case 'severity':
      return SEVERITY_META[value as AlertSeverityName]?.label ?? String(value);
    default:
      return String(value);
  }
}

function safeDate(value: string, pattern: string): string {
  try {
    return formatDate(value, pattern, 'es');
  } catch {
    return value;
  }
}

export function toCsv(rows: string[][]): string {
  return rows
    .map((cells) => cells.map((cell) => `"${cell.replace(/"/g, '""')}"`).join(';'))
    .join('\r\n');
}

export function downloadText(filename: string, content: string, mime = 'text/csv;charset=utf-8'): void {
  const blob = new Blob(['﻿', content], { type: mime });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement('a');
  anchor.href = url;
  anchor.download = filename;
  anchor.click();
  URL.revokeObjectURL(url);
}

export function escapeHtml(text: string): string {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}
