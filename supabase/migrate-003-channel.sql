-- 升級：加上「購入渠道」欄位（淘寶、鹹魚、FB、小紅書、拼多多…）
-- 用法：Supabase → SQL Editor → New query → 貼上 → Run（可重複執行）
alter table public.items add column if not exists channel text;
