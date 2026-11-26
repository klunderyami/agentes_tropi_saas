'use client';
import { useCallback } from 'react';
import type { MetricasEjecutivas } from '@/lib/types';

const emptyMetrics: MetricasEjecutivas = {
  periodo: 'Sin datos',
  kpis: [],
  por_zona: [],
  fugas: [],
  agentes: [],
};

/** Métricas legacy desconectadas hasta tener consultas tenant-scoped y verificadas con RLS. */
export function useMetrics() {
  const reload = useCallback(async () => {}, []);
  return { metricas: emptyMetrics, fuente: 'demo' as const, loading: false, reload };
}
