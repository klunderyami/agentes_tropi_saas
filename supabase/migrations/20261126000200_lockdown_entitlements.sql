-- Endurecimiento adicional: el cliente no puede editar su facturación y solo puede iniciar agentes con entitlement.
begin;
drop policy if exists "admins update organizations" on public.organizations;
revoke update on public.organizations from authenticated;

create or replace function private.has_agent_entitlement(target_org uuid, target_agent text)
returns boolean
language sql stable security definer set search_path=''
as $$
  select exists (
    select 1
    from public.organization_agent_entitlements e
    join public.agent_catalog a on a.id=e.agent_id
    where e.organization_id=target_org
      and e.agent_id=target_agent
      and a.active=true
      and e.starts_at <= now()
      and (e.expires_at is null or e.expires_at > now())
  );
$$;
revoke all on function private.has_agent_entitlement(uuid,text) from public,anon;
grant execute on function private.has_agent_entitlement(uuid,text) to authenticated;

drop policy if exists "members create own runs" on public.agent_runs;
create policy "members run entitled agents" on public.agent_runs
for insert to authenticated
with check (
  user_id=(select auth.uid())
  and private.is_org_member(organization_id)
  and private.has_agent_entitlement(organization_id,agent_id)
);
commit;
