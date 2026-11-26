import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: {
    default: 'Agentes Tropi SaaS',
    template: '%s · Tropicaña Admin',
  },
  description:
    'Plataforma SaaS multiempresa para agentes de inteligencia artificial y automatización empresarial.',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es">
      <body className="min-h-dvh bg-brand-cream text-brand-tierra antialiased">
        {children}
      </body>
    </html>
  );
}