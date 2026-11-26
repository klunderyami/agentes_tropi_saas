'use client';
import { useCallback, useState } from 'react';
import type { MediaAsset } from '@/lib/types';

/** Activos legacy desconectados hasta migrar sus registros y políticas RLS por organización. */
export function useMediaAssets() {
  const [assets, setAssets] = useState<MediaAsset[]>([]);
  const reload = useCallback(async () => {}, []);
  return { assets, setAssets, fuente: 'demo' as const, loading: false, reload };
}
