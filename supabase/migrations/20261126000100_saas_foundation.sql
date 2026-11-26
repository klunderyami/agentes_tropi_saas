-- Agentes Tropi SaaS: base multiempresa y permisos por organización.
-- Aplicar SOLO en un proyecto Supabase nuevo e independiente del CRM original.
begin;
create extension if not exists pgcrypto;
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create table if not exists public.organizations (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 slug text not null unique,
 plan_code text not null default 'starter' check (plan_code in ('starter','professional','business')),
 billing_status text not null default 'trialing' check (billing_status in ('trialing','active','past_due','canceled','incomplete')),
 stripe_customer_id text unique,
 stripe_subscription_id text unique,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 full_name text,
 avatar_url text,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table if not exists public.organization_members (
 id uuid primary key default gen_random_uuid(),
 organization_id uuid not null references public.organizations(id) on delete cascade,
 user_id uuid not null references auth.users(id) on delete cascade,
 role text not null default 'owner' check (role in ('owner','admin','member')),
 created_at timestamptz not null default now(),
 unique (organization_id,user_id)
);
create index if not exists organization_members_user_idx on public.organization_members(user_id);
create index if not exists organization_members_org_idx on public.organization_members(organization_id);

create table if not exists public.business_profiles (
 id uuid primary key default gen_random_uuid(),
 organization_id uuid not null unique references public.organizations(id) on delete cascade,
 business_name text not null,
 industry text,
 description text,
 website_url text,
 country_code text not null default 'MX',
 timezone text not null default 'America/Mexico_City',
 brand_voice text,
 target_audience text,
 products_services jsonb not null default '[]'::jsonb,
 goals jsonb not null default '[]'::jsonb,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table if not exists public.agent_catalog (
 id text primary key,
 name text not null,
 module text not null,
 description text not null default '',
 tier text not null check (tier in ('included','premium')),
 active boolean not null default true,
 created_at timestamptz not null default now()
);
create table if not exists public.organization_agent_entitlements (
 id uuid primary key default gen_random_uuid(),
 organization_id uuid not null references public.organizations(id) on delete cascade,
 agent_id text not null references public.agent_catalog(id),
 source text not null check (source in ('included','subscription','one_time_purchase','admin_grant')),
 starts_at timestamptz not null default now(),
 expires_at timestamptz,
 created_at timestamptz not null default now(),
 unique (organization_id,agent_id)
);
create table if not exists public.agent_runs (
 id uuid primary key default gen_random_uuid(),
 organization_id uuid not null references public.organizations(id) on delete cascade,
 user_id uuid not null references auth.users(id),
 agent_id text not null references public.agent_catalog(id),
 status text not null default 'queued' check (status in ('queued','running','succeeded','failed','canceled')),
 input jsonb not null default '{}'::jsonb,
 output jsonb,
 provider text,
 model text,
 input_tokens integer not null default 0 check (input_tokens >= 0),
 output_tokens integer not null default 0 check (output_tokens >= 0),
 cost_usd numeric(12,6) not null default 0 check (cost_usd >= 0),
 error_code text,
 created_at timestamptz not null default now(),
 completed_at timestamptz
);
create index if not exists agent_runs_org_created_idx on public.agent_runs(organization_id,created_at desc);
create table if not exists public.usage_ledger (
 id uuid primary key default gen_random_uuid(),
 organization_id uuid not null references public.organizations(id) on delete cascade,
 agent_run_id uuid references public.agent_runs(id) on delete set null,
 event_type text not null check (event_type in ('agent_run','premium_purchase','subscription_credit','manual_adjustment')),
 quantity integer not null default 1,
 amount_usd numeric(12,6) not null default 0,
 metadata jsonb not null default '{}'::jsonb,
 created_at timestamptz not null default now()
);
create index if not exists usage_ledger_org_created_idx on public.usage_ledger(organization_id,created_at desc);

insert into public.agent_catalog(id,name,module,description,tier) values
('AGT-NEG-CP','Copy Principal de Conversión','Negocio','Mensajes y textos orientados a conversión.','premium'),
('AGT-NEG-LP','Arquitecto de Landing Page','Negocio','Estructura y contenido de páginas de aterrizaje.','premium'),
('AGT-NEG-CA','Comercial / CRM de Leads','Negocio','Prospección, clasificación y seguimiento comercial.','premium'),
('AGT-NEG-WT','Asistente de Ventas por WhatsApp','Negocio','Asistencia comercial y conversaciones de cierre.','included'),
('AGT-NEG-PC','Estratega de Negocio y Plan Comercial','Negocio','Planificación comercial, promociones y estrategia.','included'),
('AGT-NEG-FG','Funnel Growth / Embudos','Negocio','Diseño y optimización de embudos.','premium'),
('AGT-SOC-VH','Video Hooks','Social','Hooks para TikTok, Reels y video corto.','premium'),
('AGT-SOC-IR','Estratega de Instagram Reels','Social','Estrategia y guiones para Reels.','premium'),
('AGT-SOC-SC','Creador de Stories','Social','Historias y secuencias para redes.','premium'),
('AGT-SOC-SW','Redactor Social','Social','Redacción de publicaciones sociales.','premium'),
('AGT-SOC-PS','Planificador de Redes Sociales','Social','Calendario y cadencia de publicaciones.','included'),
('AGT-SOC-MD','Community Manager','Social','Moderación y respuestas de comunidad.','included'),
('AGT-ADS-MA','Estratega de Marketing y Meta Ads','Ads','Estrategia de marketing y campañas Meta.','included'),
('AGT-ADS-GA','Generador de Anuncios','Ads','Estructura y copy de anuncios.','included'),
('AGT-ADS-AL','Analista de Resultados y ROAS','Ads','Análisis de leads, conversiones y retorno.','included'),
('AGT-ADS-CA','Diseñador Creativo Publicitario','Ads','Conceptos y briefs creativos.','included'),
('AGT-ADS-MZ','Segmentación por Zonas','Ads','Segmentación geográfica y audiencias locales.','premium'),
('AGT-ENG-TC','Especialista en Configuración Técnica','Ingeniería','Configuración de herramientas y automatizaciones.','premium'),
('AGT-ENG-AS','Especialista en Automatización','Ingeniería','Diseño de automatizaciones e integraciones.','premium'),
('AGT-ENG-WA','Desarrollador WhatsApp Cloud API','Ingeniería','Integraciones WhatsApp.','premium'),
('AGT-ENG-FM','Especialista en Formularios y Scripts','Ingeniería','Formularios, validación y scripts.','premium'),
('AGT-ENG-CO','Diseñador Conversacional','Ingeniería','Flujos y experiencias conversacionales.','premium'),
('AGT-ENG-WD','Desarrollador Web / Landing','Ingeniería','Arquitectura y desarrollo web.','premium'),
('AGT-CON-CC','Creador de Contenido','Contenido','Ideas y piezas de contenido para marca.','included'),
('AGT-CON-CV','Guionista de Video','Contenido','Guiones audiovisuales y videos cortos.','included'),
('AGT-CON-HA','Historias y Storytelling','Contenido','Narrativa de marca y storytelling.','premium'),
('AGT-CON-RP','Especialista de Producto y Recetas','Contenido','Fichas y contenidos de producto.','premium'),
('AGT-CON-CK','Diseñador de Campañas y Kits','Contenido','Campañas promocionales y paquetes.','premium'),
('AGT-CON-VM','Estratega de Distribución de Video','Contenido','Distribución y adaptación de video marketing.','premium'),
('AGT-SEO-SA','Auditor SEO Técnico','SEO','Auditoría SEO y detección de problemas técnicos.','premium'),
('AGT-SEO-CS','Estratega de Contenido SEO','SEO','Planificación de contenidos orgánicos.','premium'),
('AGT-SEO-PS','Especialista en Page Speed','SEO','Rendimiento y Core Web Vitals.','premium'),
('AGT-SEO-CP','Especialista en Google Business Profile','SEO','Optimización de presencia local.','premium'),
('AGT-SEO-FQ','Especialista en FAQ y Schema','SEO','Datos estructurados y respuestas frecuentes.','premium'),
('AGT-SEO-GG','Especialista en SEO Local y Mapas','SEO','SEO geográfico y presencia en mapas.','premium')
on conflict(id) do update set name=excluded.name,module=excluded.module,description=excluded.description,tier=excluded.tier;

create or replace function private.is_org_member(target_org uuid)
returns boolean language sql stable security definer set search_path=''
as $$ select exists(select 1 from public.organization_members m where m.organization_id=target_org and m.user_id=(select auth.uid())); $$;
create or replace function private.has_org_role(target_org uuid, allowed_roles text[])
returns boolean language sql stable security definer set search_path=''
as $$ select exists(select 1 from public.organization_members m where m.organization_id=target_org and m.user_id=(select auth.uid()) and m.role=any(allowed_roles)); $$;
revoke all on function private.is_org_member(uuid) from public,anon;
revoke all on function private.has_org_role(uuid,text[]) from public,anon;
grant usage on schema private to authenticated;
grant execute on function private.is_org_member(uuid) to authenticated;
grant execute on function private.has_org_role(uuid,text[]) to authenticated;

create or replace function private.handle_new_user()
returns trigger language plpgsql security definer set search_path=''
as $$
declare new_org_id uuid; display_name text; base_slug text;
begin
 display_name:=coalesce(nullif(new.raw_user_meta_data->>'full_name',''),split_part(new.email,'@',1),'Mi espacio');
 base_slug:=lower(regexp_replace(display_name,'[^a-zA-Z0-9]+','-','g'));
 insert into public.profiles(id,full_name) values(new.id,display_name) on conflict(id) do nothing;
 insert into public.organizations(name,slug)
 values(display_name||' Workspace',left(coalesce(nullif(base_slug,''),'workspace'),35)||'-'||substr(new.id::text,1,8))
 returning id into new_org_id;
 insert into public.organization_members(organization_id,user_id,role) values(new_org_id,new.id,'owner');
 insert into public.organization_agent_entitlements(organization_id,agent_id,source)
 select new_org_id,id,'included' from public.agent_catalog where tier='included' and active=true
 on conflict(organization_id,agent_id) do nothing;
 insert into public.business_profiles(organization_id,business_name) values(new_org_id,display_name);
 return new;
end;
$$;
revoke all on function private.handle_new_user() from public,anon,authenticated;
drop trigger if exists on_auth_user_created_saas on auth.users;
create trigger on_auth_user_created_saas after insert on auth.users for each row execute function private.handle_new_user();

alter table public.organizations enable row level security;
alter table public.profiles enable row level security;
alter table public.organization_members enable row level security;
alter table public.business_profiles enable row level security;
alter table public.agent_catalog enable row level security;
alter table public.organization_agent_entitlements enable row level security;
alter table public.agent_runs enable row level security;
alter table public.usage_ledger enable row level security;

create policy "members read organizations" on public.organizations for select to authenticated using(private.is_org_member(id));
create policy "admins update organizations" on public.organizations for update to authenticated using(private.has_org_role(id,array['owner','admin'])) with check(private.has_org_role(id,array['owner','admin']));
create policy "read own profile" on public.profiles for select to authenticated using(id=(select auth.uid()));
create policy "update own profile" on public.profiles for update to authenticated using(id=(select auth.uid())) with check(id=(select auth.uid()));
create policy "members read memberships" on public.organization_members for select to authenticated using(private.is_org_member(organization_id));
create policy "members read business profile" on public.business_profiles for select to authenticated using(private.is_org_member(organization_id));
create policy "admins insert business profile" on public.business_profiles for insert to authenticated with check(private.has_org_role(organization_id,array['owner','admin']));
create policy "admins update business profile" on public.business_profiles for update to authenticated using(private.has_org_role(organization_id,array['owner','admin'])) with check(private.has_org_role(organization_id,array['owner','admin']));
create policy "read active agent catalog" on public.agent_catalog for select to authenticated using(active=true);
create policy "members read entitlements" on public.organization_agent_entitlements for select to authenticated using(private.is_org_member(organization_id));
create policy "members read runs" on public.agent_runs for select to authenticated using(private.is_org_member(organization_id));
create policy "members create own runs" on public.agent_runs for insert to authenticated with check(user_id=(select auth.uid()) and private.is_org_member(organization_id));
create policy "members read usage" on public.usage_ledger for select to authenticated using(private.is_org_member(organization_id));

grant select,update on public.organizations to authenticated;
grant select,update on public.profiles to authenticated;
grant select on public.organization_members to authenticated;
grant select,insert,update on public.business_profiles to authenticated;
grant select on public.agent_catalog to authenticated;
grant select on public.organization_agent_entitlements to authenticated;
grant select,insert on public.agent_runs to authenticated;
grant select on public.usage_ledger to authenticated;
commit;
