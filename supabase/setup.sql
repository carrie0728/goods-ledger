-- 我的谷子帳：Supabase 資料庫設定
-- 用法：Supabase 專案 → SQL Editor → New query → 貼上全部內容 → Run
-- 可以重複執行，不會刪掉資料。

-- 1. 周邊資料表 --------------------------------------------------------
create table if not exists public.items (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  legacy_id   text,                 -- 從舊版匯入時的編號，用來避免重複匯入
  work        text not null default '網球王子',  -- 作品
  series      text not null,        -- 系列
  chara       text not null,        -- 角色
  type        text not null,        -- 周邊類型
  qty         integer not null default 1 check (qty > 0),
  cny         numeric not null default 0,   -- 人民幣單價
  twd         numeric not null default 0,   -- 台幣單價
  status      text not null default '已到貨',
  note        text,
  image_path  text,                 -- 圖片在 storage「goods」bucket 裡的路徑
  created     bigint not null default (extract(epoch from now()) * 1000)::bigint,
  updated_at  timestamptz not null default now(),
  constraint items_user_legacy unique (user_id, legacy_id)
);

-- 舊資料表升級：加上「作品」欄位（已存在就略過）
alter table public.items add column if not exists work text not null default '網球王子';

create index if not exists items_user_created on public.items (user_id, created);

-- 每次修改自動更新 updated_at
create or replace function public.items_touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

drop trigger if exists items_touch on public.items;
create trigger items_touch before update on public.items
  for each row execute function public.items_touch_updated_at();

-- 2. 權限：每個人只能看、改自己的資料 -------------------------------------
alter table public.items enable row level security;

drop policy if exists "items_select_own" on public.items;
create policy "items_select_own" on public.items
  for select to authenticated using (user_id = auth.uid());

drop policy if exists "items_insert_own" on public.items;
create policy "items_insert_own" on public.items
  for insert to authenticated with check (user_id = auth.uid());

drop policy if exists "items_update_own" on public.items;
create policy "items_update_own" on public.items
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "items_delete_own" on public.items;
create policy "items_delete_own" on public.items
  for delete to authenticated using (user_id = auth.uid());

-- 3. 即時同步（手機改了，電腦馬上看到） --------------------------------
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'items'
  ) then
    alter publication supabase_realtime add table public.items;
  end if;
end $$;

-- 4. 圖片空間：私人 bucket，每個人只能存取自己資料夾 -------------------
insert into storage.buckets (id, name, public)
values ('goods', 'goods', false)
on conflict (id) do nothing;

drop policy if exists "goods_select_own" on storage.objects;
create policy "goods_select_own" on storage.objects
  for select to authenticated
  using (bucket_id = 'goods' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "goods_insert_own" on storage.objects;
create policy "goods_insert_own" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'goods' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "goods_update_own" on storage.objects;
create policy "goods_update_own" on storage.objects
  for update to authenticated
  using (bucket_id = 'goods' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "goods_delete_own" on storage.objects;
create policy "goods_delete_own" on storage.objects
  for delete to authenticated
  using (bucket_id = 'goods' and (storage.foldername(name))[1] = auth.uid()::text);
