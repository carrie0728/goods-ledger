# 我的谷子帳

動漫周邊收藏帳本。可以按系列分組、記錄狀態（未付款／已付款／待包貨／已到貨／待售）、加圖片、匯出 CSV。
手機和電腦會同步同一份資料。

- 網頁放在 **GitHub Pages**（免費）
- 資料和圖片存在你自己的 **Supabase** 專案（免費方案：資料庫 500 MB、圖片 1 GB）
- 可以「加到主畫面」當成 app 使用

---

## 第一次設定（約 15 分鐘）

### 1. 建立 Supabase 專案
1. 到 <https://supabase.com> 用 GitHub 帳號登入，按 **New project**。
2. 名稱隨意（例如 `goods-ledger`），設一組資料庫密碼（記下來，平常用不到），Region 選 **Northeast Asia (Tokyo)** 或 **Southeast Asia (Singapore)**。
3. 等一兩分鐘建立完成。

### 2. 建立資料表
1. 左側選單點 **SQL Editor** → **New query**。
2. 打開這個 repo 的 [`supabase/setup.sql`](supabase/setup.sql)，全部複製貼上，按 **Run**。
3. 看到 `Success. No rows returned` 就完成了。

### 3. 把連線設定填進 `config.js`
1. Supabase 左側點 **Project Settings** → **API**（或 **Data API**／**API Keys**）。
2. 複製 **Project URL** 和 **anon public** key。
3. 在 GitHub 打開 [`config.js`](config.js)，按鉛筆圖示編輯，把 `YOUR_SUPABASE_URL` 和 `YOUR_SUPABASE_ANON_KEY` 換掉，按 **Commit changes**。

> anon key 本來就是設計給網頁用的公開金鑰，放在公開 repo 沒問題；資料由 `setup.sql` 裡的權限規則保護，只有登入的你看得到自己的資料。

### 4. 打開 GitHub Pages
1. repo 的 **Settings** → **Pages**。
2. **Source** 選 **Deploy from a branch**，Branch 選 `main`、資料夾 `/ (root)`，按 **Save**。
3. 一兩分鐘後網址會出現在同一頁，通常是 `https://你的帳號.github.io/goods-ledger/`。

### 5. 設定登入
1. Supabase → **Authentication** → **URL Configuration**，把 **Site URL** 改成上一步的網址。
2. 打開 app，按「第一次使用？建立帳號」，用 Email + 密碼註冊。
3. 去信箱點確認信的連結，再回 app 登入。
4. **建議**：登入成功後，到 Supabase → **Authentication** → **Sign In / Providers**（或 **Settings**），把 **Allow new users to sign up** 關掉，這樣別人就不能在你的專案註冊帳號。

### 6. 匯入舊資料
1. 在 app 右上角按 **⋯** → **匯入備份**。
2. 選 `goods-backup-20261008.json`（Claude 另外傳給你的檔案，**不要**放進這個 repo）。
3. 等進度條跑完。重複匯入不會產生重複資料，所以中途斷掉再匯一次就好。

### 7. 加到手機主畫面
- **iPhone（Safari）**：分享 → 加入主畫面
- **Android（Chrome）**：⋮ → 安裝應用程式／加到主畫面

---

## 日常注意

- **Supabase 免費專案一週沒有使用會暫停。** repo 裡的 `.github/workflows/keepalive.yml` 每 3 天會自動碰一下資料庫，讓它保持清醒。如果哪天 app 打不開，到 Supabase 後台按 **Restore project** 即可，資料不會消失。
- GitHub 的排程工作在 repo 60 天沒有任何更新時會自動停用；收到 GitHub 通知時到 **Actions** 頁面按啟用就好。
- 定期按 **匯出 → 完整備份（.json）** 留一份在自己電腦，最安心。

## 檔案說明

| 檔案 | 用途 |
|---|---|
| `index.html` | app 本體 |
| `config.js` | Supabase 連線設定 |
| `supabase/setup.sql` | 建立資料表、權限、圖片空間 |
| `sw.js`、`manifest.webmanifest`、`icon-*.png` | 加到主畫面、離線開啟用 |
| `.github/workflows/keepalive.yml` | 防止 Supabase 專案被暫停 |
