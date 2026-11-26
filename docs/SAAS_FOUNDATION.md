# Fundación SaaS — Agentes Tropi

## Alcance implementado

Esta fase incorpora autenticación SSR, registro, organizaciones, membresías, perfil empresarial, catálogo de 35 agentes, 10 agentes incluidos y 25 premium, y políticas RLS por organización.

**No conecta ni migra la base de datos anterior de Tropicaña.** Las migraciones están destinadas exclusivamente a un proyecto Supabase nuevo e independiente. No ejecutarlas sobre la base productiva original.

## Variables de entorno

Configurar en local y en el entorno de despliegue:

- `NEXT_PUBLIC_SUPABASE_URL`: URL del proyecto Supabase NUEVO.
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`: publishable/anon key del proyecto nuevo.

No usar claves `service_role` en el navegador ni en variables `NEXT_PUBLIC_*`. Las credenciales de proveedores se configuran como secretos server-side y por organización en una fase posterior.

## Configuración inicial de Supabase

1. Crear un proyecto Supabase independiente para Agentes Tropi SaaS.
2. Aplicar en orden los archivos de `supabase/migrations/` desde el SQL Editor o Supabase CLI.
3. En Authentication > URL Configuration, configurar el Site URL del despliegue y permitir `/auth/callback`.
4. Mantener habilitada la confirmación de correo antes de abrir el registro al público.
5. Configurar las dos variables públicas en Vercel y local.
6. Si el proyecto tiene deshabilitada la exposición automática de tablas nuevas, habilitar explícitamente las tablas SaaS necesarias en Data API y conservar los GRANT/RLS de las migraciones.
7. Probar alta y confirmación con una cuenta de prueba. El trigger crea perfil, organización, membresía owner, perfil empresarial y los diez permisos incluidos.

## Modelo de acceso

- Cada cuenta nueva recibe una organización propia.
- La pertenencia se registra en `organization_members`.
- La pertenencia y los roles se verifican mediante funciones SQL del esquema privado `private`.
- Las tablas SaaS tienen RLS activado.
- Los usuarios no pueden asignarse roles, alterar el plan o concederse agentes premium desde el cliente.
- Los diez agentes incluidos se asignan al crear la organización.
- Los otros 25 agentes requieren una compra individual o una suscripción válida, que se conectará en la fase de billing.

## Pendientes deliberados

- Ejecutar migraciones y pruebas RLS en un proyecto Supabase de staging.
- Completar el aislamiento de los módulos legacy (leads, conversaciones, media y métricas) antes de conectarlos a tablas por organización.
- Implementar API/worker server-side para ejecutar agentes y validar cuotas.
- Implementar Stripe Checkout, webhooks y revocación de entitlement.
- Conectar redes sociales mediante OAuth por organización.
- Implementar publicación programada, aprobaciones y registros de auditoría.
- Generar y versionar el lockfile npm después de instalar dependencias y ejecutar el build en CI.
