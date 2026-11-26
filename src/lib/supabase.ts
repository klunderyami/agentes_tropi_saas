import { createBrowserClient, type SupabaseClient } from '@supabase/ssr';

const url = process.env.NEXT_PUBLIC_SUPABASE_URL ?? '';
const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? '';
export const isSupabaseConfigured = Boolean(url && key);
let browserClient: SupabaseClient | undefined;

/** Cliente de navegador con sesión persistida en cookies compatibles con SSR. */
export function getSupabaseClient(): SupabaseClient | null {
  if (!isSupabaseConfigured) return null;
  browserClient ??= createBrowserClient(url, key);
  return browserClient;
}
