'use client';
import { useCallback, useState } from 'react';
import type { Lead } from '@/lib/types';

/**
 * Los datos del CRM monocliente anterior quedan desconectados hasta migrar
 * leads a una tabla con organization_id y RLS verificado.
 */
export function useLeads() {
  const [leads, setLeads] = useState<Lead[]>([]);
  const reload = useCallback(async () => {}, []);
  return { leads, setLeads, fuente: 'demo' as const, loading: false, reload };
}
