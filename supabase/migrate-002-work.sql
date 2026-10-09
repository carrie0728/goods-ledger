-- 升級：加上「作品」欄位。現有資料會自動歸到「網球王子」。
-- 用法：Supabase → SQL Editor → New query → 貼上 → Run（可重複執行）
alter table public.items add column if not exists work text not null default '網球王子';
