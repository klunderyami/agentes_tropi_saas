'use client';
import { Radio, LogOut } from 'lucide-react';
import { usePathname } from 'next/navigation';
import { useEffect, useState } from 'react';
import { isSupabaseConfigured } from '@/lib/supabase';
import { cn } from '@/lib/utils';

const TITLES: Record<string, { title: string; subtitle: string }> = {
  '/admin': { title: 'Panel de Control', subtitle: 'Agentes Tropi · visión general de tu espacio de trabajo' },
  '/admin/leads': { title: 'Pipeline de Leads', subtitle: 'Seguimiento comercial y oportunidades' },
  '/admin/chat': { title: 'Mensajes', subtitle: 'Conversaciones y canales conectados' },
  '/admin/media': { title: 'Biblioteca de Contenido', subtitle: 'Activos generados por tus agentes' },
  '/admin/metrics': { title: 'Agentes & Analítica', subtitle: 'Ejecuciones, resultados y rendimiento' },
};

export function Topbar() {
  const pathname = usePathname();
  const meta = TITLES[pathname] ?? TITLES['/admin'];
  const [today, setToday] = useState('');

  useEffect(() => {
    setToday(new Date().toLocaleDateString('es-MX', {
      weekday: 'long', day: 'numeric', month: 'long', year: 'numeric',
    }));
  }, []);

  return (
    <header className="sticky top-0 z-20 border-b border-black/10 bg-brand-green text-white">
      <div className="flex flex-wrap items-center justify-between gap-3 px-6 py-4 md:px-8">
        <div className="min-w-0">
          <h1 className="text-lg font-bold leading-tight">{meta.title}</h1>
          <p className="truncate text-sm text-white/65">{meta.subtitle}</p>
        </div>
        <div className="flex items-center gap-3">
          {today && <span className="hidden text-xs capitalize text-white/65 lg:block">{today}</span>}
          <span className={cn(
            'inline-flex items-center gap-1.5 rounded-full border px-3 py-1 text-xs font-semibold',
            isSupabaseConfigured
              ? 'border-emerald-300/40 bg-emerald-400/10 text-emerald-200'
              : 'border-brand-gold/50 bg-brand-gold/10 text-brand-goldLight',
          )} title={isSupabaseConfigured ? 'Supabase configurado' : 'Falta configurar Supabase'}>
            <Radio className="h-3.5 w-3.5" />
            {isSupabaseConfigured ? 'Conectado' : 'Pendiente'}
          </span>
          <form action="/auth/signout" method="post">
            <button type="submit" className="inline-flex items-center gap-2 rounded-lg border border-white/20 px-3 py-2 text-xs font-semibold text-white/90 hover:bg-white/10">
              <LogOut className="h-3.5 w-3.5" /> Salir
            </button>
          </form>
        </div>
      </div>
    </header>
  );
}
