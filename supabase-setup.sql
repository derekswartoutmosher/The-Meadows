-- The Meadows: database setup
-- Run this once in Supabase: SQL Editor > New query > paste > Run.
-- BEFORE running, change 'CHANGE-ME-PIN' below to your own admin PIN (6+ digits recommended).

create extension if not exists pgcrypto with schema extensions;

-- Rounds: one row per player per round
create table if not exists rounds (
  id text primary key,
  round_id text,
  name text not null,
  date date not null,
  club text,
  scores int[] not null,
  par int not null,
  to_par int not null,
  created_at timestamptz default now()
);

alter table rounds enable row level security;

-- Anyone with the link can read and add rounds.
-- There is deliberately NO delete or update policy: deletes go through the PIN function below.
create policy "anyone can read" on rounds for select using (true);
create policy "anyone can add"  on rounds for insert with check (true);

-- Admin PIN (stored hashed; not readable from the app)
create table if not exists admin_settings (
  id int primary key default 1,
  pin_hash text not null
);
alter table admin_settings enable row level security;  -- no policies = not readable from the app

insert into admin_settings (id, pin_hash)
values (1, extensions.crypt('CHANGE-ME-PIN', extensions.gen_salt('bf')))
on conflict (id) do nothing;

-- PIN-protected delete
create or replace function delete_round(p_id text, p_pin text)
returns boolean
language plpgsql
security definer
set search_path = public, extensions
as $$
declare ok boolean;
begin
  select pin_hash = crypt(p_pin, pin_hash) into ok from admin_settings where id = 1;
  if not coalesce(ok, false) then
    return false;
  end if;
  delete from rounds where id = p_id;
  return true;
end;
$$;

revoke all on function delete_round(text, text) from public;
grant execute on function delete_round(text, text) to anon, authenticated;

-- To change the PIN later, run:
--   update admin_settings set pin_hash = extensions.crypt('NEW-PIN', extensions.gen_salt('bf')) where id = 1;
