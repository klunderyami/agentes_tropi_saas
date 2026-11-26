import { NextResponse, type NextRequest } from 'next/server';
import { createServerClient } from '@supabase/ssr';

export async function GET(request: NextRequest) {
  const code = request.nextUrl.searchParams.get('code');
  if (!code) return NextResponse.redirect(new URL('/login?error=missing_code', request.url));
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if (!url || !key) return NextResponse.redirect(new URL('/login?setup=supabase', request.url));

  const response = NextResponse.redirect(new URL('/admin', request.url));
  const supabase = createServerClient(url, key, {
    cookies: {
      getAll: () => request.cookies.getAll(),
      setAll: values => values.forEach(({ name, value, options }) => response.cookies.set(name, value, options)),
    },
  });
  const { error } = await supabase.auth.exchangeCodeForSession(code);
  if (error) return NextResponse.redirect(new URL('/login?error=confirmation_failed', request.url));
  return response;
}
