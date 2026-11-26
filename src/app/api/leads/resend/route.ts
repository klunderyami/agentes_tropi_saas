import { NextResponse } from 'next/server';

// Esta integración pertenece al panel monocliente anterior.
// Se desactiva en el SaaS hasta implementar credenciales y leads aislados
// por organización; no se deben reutilizar tokens globales de Tropicaña.
export async function POST() {
  return NextResponse.json(
    { ok: false, error: 'La integración de WhatsApp por organización aún no está habilitada.' },
    { status: 501 },
  );
}
