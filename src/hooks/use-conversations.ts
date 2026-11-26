'use client';
import { useCallback, useState } from 'react';
import type { Conversacion } from '@/lib/types';

/** Conversaciones legacy desactivadas hasta incorporar aislamiento por organización. */
export function useConversations() {
  const [conversations, setConversations] = useState<Conversacion[]>([]);
  const reload = useCallback(async () => {}, []);
  return { conversations, setConversations, fuente: 'demo' as const, loading: false, reload };
}
