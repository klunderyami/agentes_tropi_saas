'use client';

import { useEffect, useState, type FormEvent } from 'react';
import { getSupabaseClient, isSupabaseConfigured } from '@/lib/supabase';

export default function LoginPage() {
  const [mode, setMode] = useState<'login' | 'signup'>('login');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  const [setupRequired, setSetupRequired] = useState(false);

  useEffect(() => {
    setSetupRequired(new URLSearchParams(window.location.search).get('setup') === 'supabase');
  }, []);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setBusy(true);
    setMessage('');
    const supabase = getSupabaseClient();
    if (!supabase) {
      setMessage('Configura NEXT_PUBLIC_SUPABASE_URL y NEXT_PUBLIC_SUPABASE_ANON_KEY para habilitar el acceso.');
      setBusy(false);
      return;
    }
    try {
      if (mode === 'signup') {
        const { data, error } = await supabase.auth.signUp({
          email,
          password,
          options: { emailRedirectTo: window.location.origin + '/auth/callback' },
        });
        if (error) throw error;
        setMessage(data.session
          ? 'Cuenta creada. Tu espacio de trabajo se está preparando.'
          : 'Registro recibido. Confirma tu correo para activar tu espacio de trabajo.');
      } else {
        const { error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) throw error;
        const requested = new URLSearchParams(window.location.search).get('next') || '/admin';
        window.location.assign(requested.startsWith('/') && !requested.startsWith('//') ? requested : '/admin');
      }
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'No fue posible completar el acceso.');
    } finally {
      setBusy(false);
    }
  }

  return (
    <main className="flex min-h-dvh items-center justify-center bg-brand-cream px-5 py-12">
      <section className="w-full max-w-md rounded-2xl border border-black/10 bg-white p-8 shadow-xl">
        <div className="mb-8 text-center">
          <div className="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-brand-green text-2xl font-black text-brand-cream">A</div>
          <p className="text-xs font-bold uppercase tracking-[0.2em] text-brand-green">Agentes Tropi SaaS</p>
          <h1 className="mt-2 text-2xl font-bold text-brand-tierra">{mode === 'login' ? 'Bienvenido de nuevo' : 'Crea tu espacio de trabajo'}</h1>
          <p className="mt-2 text-sm text-stone-600">Inteligencia y automatización para tu negocio.</p>
        </div>
        {setupRequired && <p className="mb-4 rounded-lg bg-amber-50 p-3 text-sm text-amber-900">La autenticación requiere configurar primero el proyecto Supabase del SaaS.</p>}
        <form onSubmit={submit} className="space-y-4">
          <label className="block text-sm font-medium text-stone-700">Correo electrónico
            <input type="email" required autoComplete="email" value={email} onChange={e => setEmail(e.target.value)} className="mt-1 w-full rounded-lg border border-stone-300 px-3 py-2.5 outline-none focus:border-brand-green" />
          </label>
          <label className="block text-sm font-medium text-stone-700">Contraseña
            <input type="password" required minLength={8} autoComplete={mode === 'login' ? 'current-password' : 'new-password'} value={password} onChange={e => setPassword(e.target.value)} className="mt-1 w-full rounded-lg border border-stone-300 px-3 py-2.5 outline-none focus:border-brand-green" />
          </label>
          <button disabled={busy || !isSupabaseConfigured} className="w-full rounded-lg bg-brand-green px-4 py-3 font-semibold text-white hover:bg-brand-greenDarker disabled:opacity-50">
            {busy ? 'Procesando…' : mode === 'login' ? 'Iniciar sesión' : 'Crear cuenta'}
          </button>
        </form>
        {message && <p role="status" className="mt-4 rounded-lg bg-stone-100 p-3 text-sm text-stone-700">{message}</p>}
        <p className="mt-6 text-center text-sm text-stone-600">
          {mode === 'login' ? '¿No tienes cuenta?' : '¿Ya tienes cuenta?'}{' '}
          <button type="button" onClick={() => { setMode(mode === 'login' ? 'signup' : 'login'); setMessage(''); }} className="font-semibold text-brand-green underline underline-offset-4">
            {mode === 'login' ? 'Regístrate' : 'Inicia sesión'}
          </button>
        </p>
      </section>
    </main>
  );
}
