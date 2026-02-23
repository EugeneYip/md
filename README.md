# HedgeDoc 1.x 新手部署指南（VPS + Docker Compose + PostgreSQL + Caddy）

> 目標：讓你從零開始，把 `https://notes.<你的網域>/` 成功部署起來，並可建立與保存筆記。

> 這個 repo 現在**不只有教學**，也已經幫你把可直接部署的檔案架好（`deploy/` 與 `scripts/`）。

## 這份 repo 已經幫你架好的內容

## 先釐清兩件事（你剛好問到的）

### 1) 你有多個網域，該用哪一個？

**先選一個你最常用、最短最好記的主網域**，再切一個子網域給 HedgeDoc。

- 例如你有：
  - `myblog.com`
  - `company.net`
  - `notes.tw`
- 建議先選其中一個，例如 `myblog.com`
- 然後 HedgeDoc 用：`notes.myblog.com`

> 重點：你不需要把「所有網域」都設定。**先挑一個網域成功上線就好**。

### 2) 什麼是「建一台 Ubuntu 22.04 VPS」？

把它想成：**你在雲端租一台 24 小時開機的小電腦**。

- `VPS` = Virtual Private Server（虛擬私人伺服器）
- `Ubuntu 22.04` = 這台雲端電腦使用的作業系統版本
- 你之後做的事（安裝 Docker、啟動 HedgeDoc）都在這台雲端電腦上完成

超簡單比喻：
- 你的 Mac：你自己的本機電腦（可能會關機）
- VPS：放在機房的遠端電腦（持續開機，網站才會一直可用）

---

## 你現在要先決定的 3 個值（直接照填）

1. **主網域**：例如 `myblog.com`
2. **HedgeDoc 網址（子網域）**：例如 `notes.myblog.com`
3. **憑證通知 Email**：例如 `you@gmail.com`

只要這 3 個值決定好，就可以往下照步驟部署。

---

- `deploy/docker-compose.yml`：HedgeDoc + PostgreSQL + Caddy 的完整 compose（含 `restart: unless-stopped`）
- `deploy/Caddyfile`：Caddy 自動 HTTPS 反向代理設定
- `deploy/.env.example`：你只要填 `DOMAIN`、`EMAIL`，其餘可沿用
- `scripts/init-env.sh`：自動產生 `.env` 與隨機密碼/secret
- `scripts/up.sh`：一鍵 `pull + up -d + ps`

### 最快啟動（在你的 VPS）

```bash
# 1) 進專案根目錄
cd /opt/hedgedoc

# 2) 產生 deploy/.env（含隨機密碼）
./scripts/init-env.sh

# 3) 編輯 deploy/.env 只改兩個欄位
nano deploy/.env
# DOMAIN=notes.你的網域
# EMAIL=你的Email

# 4) 啟動
./scripts/up.sh
```

---

## DigitalOcean 是最合適、最實惠嗎？（給你一句結論）

**結論（以你現在的目標）**：  
- **最合適（新手）**：是，DigitalOcean 很合適。  
- **最實惠（純價格）**：不一定，通常不是最低價。  

為什麼我仍先帶你用 DigitalOcean：
1. 介面簡單，對超新手比較不容易迷路。  
2. 教學資源多，遇到問題比較好排除。  
3. 用你現在這個需求（HedgeDoc + 1GB VPS）可快速成功上線。  

如果你之後想省錢，可以再搬家到其他供應商（例如較便宜方案），
但**第一階段先求成功上線**，不要同時增加平台學習成本。

### 最小決策建議（現在就照做）
- 你如果重視「最少卡關」：先用 DigitalOcean `$6/mo`。  
- 你如果重視「最低月費」：可之後再比價搬遷，不建議現在就換平台。  

---

## 超新手版：如何在雲端租一台 24 小時開機的小電腦（VPS）

下面用 **DigitalOcean**（介面最直覺）示範，你只要照點就好。

### 目標
成功租到一台可遠端登入的 Ubuntu 22.04 VPS，並拿到 Public IP。

### 看到「Select the product...」這頁，你要選哪個？

**你現在只要選：`Droplet`。**

原因（超精簡）：
- 你要的是一台可自己安裝 Docker 的 Linux 主機 → 這就是 Droplet。
- 我們本教學的所有指令（SSH、Docker、Compose、Caddy）都假設你有 Droplet。

先不要選（目前階段都不需要）：
- App Platform（它是 PaaS，流程不同，會和本教學不一致）
- Managed Database（我們已在 Docker 內跑 PostgreSQL）
- Kubernetes / GPU / Functions（都屬進階或不同場景）

如果頁面有 **"Don't worry, this is just to get you started"**：
- 選錯也不用怕，之後仍可從 Dashboard 建立 Droplet。

---

### 選完 Droplet 後，下一個畫面立刻這樣點

1. **Choose an image → Ubuntu → 22.04 (LTS)**
2. **Choose size → Basic（Regular）→ 建議選 `$6/mo`（1 GB RAM / 1 CPU）**
   - 這是我給超新手的**最低不易踩雷**規格。
   - `512MB / $4` 也能開機，但在拉映像、初始化或更新時更容易記憶體不足。
   - 暫時**不要選 Premium Intel / Premium AMD**（比較貴，對這個用途不是必要）。
3. **Authentication → SSH Key（貼上你的 `id_ed25519.pub`）**
4. **Create Droplet**

拿到 Public IP 後就做：
```bash
ssh root@你的PublicIP
```

---

### 你在網頁要點哪裡
1. **DigitalOcean 首頁 → Sign Up → 建立帳號並完成付款方式驗證**
2. **Dashboard → Create（右上角）→ Droplets**
3. **Choose Region → 選離你最近（例如 Singapore）**
4. **Choose an image → Ubuntu → 22.04 (LTS) x64**
5. **Choose size → Basic → Regular → 選 `$6/mo`（1 GB / 1 CPU）**
6. **Authentication → SSH keys → New SSH Key（先把你的公鑰貼上）**
7. **Finalize details → Hostname 輸入 `hedgedoc-vps`（可改）**
8. **按 Create Droplet**
9. 建立完成後，在清單點進該 Droplet，找到 **Public IPv4**
   - 你會在主機詳情頁看到 `IPv4` 區塊，裡面有一個像 `203.0.113.10` 的數字。
   - 通常在 `Networking` 或 `Access` 區域會有 **Copy** 按鈕可直接複製。

### Public IP 看不到時，照這 4 步找

1. **Dashboard → Droplets**
2. 點你的主機名稱（例如 `hedgedoc-vps`）
3. 進入主機詳情頁後，找 **IPv4** 或 **Public network**
4. 複製那串 IP（格式像 `203.0.113.10`）

驗證你抄的 IP 是對的：
```bash
ping -c 1 你的PublicIP
```
若有回應（`1 packets transmitted, 1 received`）通常就抄對了。

---

### 終端機要貼上的指令（先在 macOS / GitHub Terminal 產生 SSH key）
```bash
# 1) 產生 SSH 金鑰（若已存在可略過）
ssh-keygen -t ed25519 -C "vps-login" -f ~/.ssh/id_ed25519 -N ""

# 2) 印出公鑰，貼到 DigitalOcean 的 New SSH Key
cat ~/.ssh/id_ed25519.pub
```

### 你應該看到的結果
- DigitalOcean 清單中有一台 `Running` 的 Droplet。
- 頁面顯示一組 Public IP（例如 `203.0.113.10`）。
- 你可用下面指令登入（把 IP 換成你的）：
  ```bash
  ssh root@203.0.113.10
  ```

### CPU / 方案你現在就照這個選（不用比較太多）

- ✅ **直接選：Regular `$6/mo`（1 GB RAM / 1 CPU）**
- ❌ 先不要選：`$4/mo 512MB`（太小，初期容易卡）
- ❌ 先不要選：Premium Intel / Premium AMD（你目前用不到）

你若只想「先上線成功」，這是成本與穩定度最平衡的起點。

### 常見失敗原因與排除
1. **卡在付款驗證**：先完成信用卡/扣款驗證，才可建立 Droplet。  
2. **SSH 登入失敗（Permission denied publickey）**：通常是建機時沒綁對 SSH 公鑰，刪除重建最省時間。  
3. **找不到 Public IP**：到 `Droplets → 點主機名稱` 的詳情頁看 `Public IPv4`。  
4. **建立按鈕灰色不能按**：通常有欄位未選（Region / Image / Size / Auth）。

---

## 你現在「下一步」就照這個順序做（不要跳步）

1. **先買網域 + 開一台 VPS（Ubuntu 22.04）**。
2. **把 DNS A 記錄設到 VPS IP**（`notes.你的網域 -> VPS_IP`，Cloudflare 先灰雲）。
3. **SSH 登入 VPS**，安裝 Docker 與 Compose。
4. **把這個 repo 放到 VPS**（例如放到 `/opt/hedgedoc`）。
5. 執行：
   ```bash
   cd /opt/hedgedoc
   ./scripts/init-env.sh
   nano deploy/.env
   ```
   只改 `DOMAIN` 和 `EMAIL`。
6. 啟動服務：
   ```bash
   ./scripts/up.sh
   ```
7. 檢查：
   ```bash
   cd /opt/hedgedoc/deploy
   docker compose --env-file .env ps
   docker compose --env-file .env logs --tail=80 caddy
   ```
8. 用瀏覽器開 `https://notes.你的網域/`，建立一篇筆記並重新整理確認有保存。
9. 最後測試重開機：
   ```bash
   reboot
   ```
   1–2 分鐘後再 `docker compose ps`，確認服務自動起來。

---

## A. 一頁式總覽（12 個大步驟）

1. 準備你要填的基本資訊（網域、Email、密碼、SSH Key）
2. 在 VPS 供應商（DigitalOcean）建立伺服器
3. 取得 VPS 公網 IP，確認可以連線
4. 在網域 DNS 新增 `A` 記錄指向 VPS
5. 用 SSH 登入伺服器（以 GitHub Codespaces Terminal / macOS Terminal）
6. 更新系統並安裝 Docker + Docker Compose 插件
7. 建立部署目錄與 `.env` 參數檔
8. 建立 `docker-compose.yml`（HedgeDoc + PostgreSQL + Caddy）
9. 建立 `Caddyfile`（自動 HTTPS）
10. 啟動服務並檢查容器、日誌、連接埠
11. 在瀏覽器驗證 HedgeDoc 可開啟、可建立並保存筆記
12. 驗證重開機後自動啟動（restart policy）

---

## 先準備好這些資訊（含範例）

請先把以下資料整理在一個筆記中，部署時直接複製貼上。

- 子網域（要用來放 HedgeDoc）：`notes.example.com`
- 主網域：`example.com`
- VPS 公網 IP：`203.0.113.10`（建立機器後取得）
- Caddy 憑證通知用 Email：`you@example.com`
- PostgreSQL 資料庫名稱：`hedgedoc`
- PostgreSQL 使用者：`hedgedoc`
- PostgreSQL 強密碼（範例生成指令）：
  ```bash
  openssl rand -base64 32
  ```
- HedgeDoc Session secret（範例生成指令）：
  ```bash
  openssl rand -hex 32
  ```
- SSH 公鑰（若你還沒有，下面步驟會教你產生）

---

## B. 超詳細逐步教學

## 步驟 1：準備本機 SSH Key（登入 VPS 用）

### 目標
建立 SSH 金鑰，之後可以安全登入 VPS（避免用密碼登入）。

### 你要點哪裡
- **GitHub → 右上角頭像 → Your codespaces → 任一 Codespace → Open in browser**
- 然後在 Codespace 裡開啟 **Terminal**（若你用 macOS Terminal 也可）

### 要貼上的指令
```bash
# 1) 建立 SSH key（如果你已經有 ~/.ssh/id_ed25519.pub 可跳過）
ssh-keygen -t ed25519 -C "vps-login" -f ~/.ssh/id_ed25519 -N ""

# 2) 印出公鑰，等等貼到 DigitalOcean
cat ~/.ssh/id_ed25519.pub
```

### 你應該看到的結果
- `ssh-keygen` 完成後會顯示 `Your public key has been saved in ...`。
- `cat` 會印出一整行以 `ssh-ed25519` 開頭的字串。

### 常見失敗原因與排除
1. **顯示 Permission denied 寫不進 ~/.ssh**  
   - 改用有權限的 shell 使用者，或確認你不在只讀環境。
2. **你其實已經有 key，不想覆蓋**  
   - 把 `-f ~/.ssh/id_ed25519` 改成其他檔名，例如 `id_ed25519_do`。
3. **複製時漏掉字串尾巴**  
   - 公鑰必須整行完整複製，不能換行、不能少字。

---

## 步驟 2：建立 VPS（DigitalOcean，最少步驟）

### 目標
建立一台 Ubuntu VPS，並綁定你的 SSH 公鑰。

### 你要點哪裡
1. **DigitalOcean 控制台 → Create → Droplets**
2. **Choose an image → Distributions → Ubuntu → 22.04 LTS**
3. **Choose Size → Basic → Regular Intel/AMD（最低階即可，例如 1GB RAM）**
4. **Choose a datacenter region → 選離你近的（例如 Singapore）**
5. **Authentication → SSH keys → New SSH Key → 貼上剛剛公鑰 → Add SSH Key**
6. **Hostname → 輸入 `hedgedoc-vps`（可自訂）**
7. **Create Droplet**

### 要貼上的指令
（這一步主要是網頁操作，不需終端指令）

### 你應該看到的結果
- Droplet 建立完成後，在列表看到一台 Running 機器。
- 可看到 Public IPv4，例如 `203.0.113.10`。

### 常見失敗原因與排除
1. **區域缺貨/建立卡住**  
   - 換另一個 region 或稍高一級規格再建立。
2. **SSH key 貼錯（少字、換行）**  
   - 刪除重加 SSH key，重新建立 Droplet。
3. **帳號付款未驗證**  
   - 先完成信用卡或付款方式驗證。

---

## 步驟 3：設定 DNS（通用流程 + Cloudflare 注意）

### 目標
讓 `notes.example.com` 指到你的 VPS IP。

### 你要點哪裡
通用概念（Namecheap/Cloudflare/其他 DNS 託管都類似）：
1. **網域管理後台 → Domain List / My Domains → Manage**
2. **DNS / Advanced DNS / DNS Management**
3. **Add Record → Type: A**
4. 填寫：
   - **Host/Name**: `notes`
   - **Value/Content**: `你的 VPS IP`（例 `203.0.113.10`）
   - **TTL**: Auto 或 5 min
5. 儲存

Cloudflare 額外提醒（很重要）：
- 若你把此紀錄設成 **Proxied（橘雲）**，初期可能造成你排錯變複雜。  
- **先設為 DNS only（灰雲）**，等網站穩定後再決定要不要開 Proxy。

### 要貼上的指令
```bash
# 在任一終端驗證 DNS 是否生效（把網域換成你的）
nslookup notes.example.com
```

### 你應該看到的結果
- `nslookup` 回應中，`notes.example.com` 解析到你的 VPS 公網 IP。

### 常見失敗原因與排除
1. **你改錯 DNS 區（改到註冊商，不是實際 DNS 託管商）**  
   - 先查 Nameserver 指向哪家，再到那家管理 DNS。
2. **A 記錄打錯主機名**  
   - `notes`（子網域）不是 `@`（根網域）。
3. **DNS 還沒傳播**  
   - 等 5–30 分鐘再查，最長可能幾小時。
4. **Cloudflare 橘雲干擾**  
   - 先切回灰雲（DNS only）。

---

## 步驟 4：SSH 登入 VPS

### 目標
成功用 SSH 進入伺服器。

### 你要點哪裡
- **DigitalOcean 控制台 → Droplets → 點你的主機 → 複製 Public IP**
- 回到 **GitHub Codespaces Terminal**（或 macOS Terminal）

### 要貼上的指令
```bash
# 把 IP 換成你的
ssh root@203.0.113.10
```

第一次連線會問 yes/no：
```text
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```
輸入 `yes`。

### 你應該看到的結果
- 進入主機後提示符會變成類似 `root@hedgedoc-vps:~#`。

### 常見失敗原因與排除
1. **Connection timed out**  
   - IP 錯、機器尚未啟動完成、網路暫時阻擋。
2. **Permission denied (publickey)**  
   - 建機時沒加正確 SSH key，或你用錯本機 key。
3. **連到舊主機出現 host key changed**  
   - 先刪除 `~/.ssh/known_hosts` 對應舊 IP 記錄再重連。

---

## 步驟 5：安裝 Docker 與 Compose 插件

### 目標
讓 VPS 能跑容器化服務。

### 你要點哪裡
- 只需要在 SSH 終端機操作。

### 要貼上的指令
```bash
set -e
apt update
apt install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

. /etc/os-release
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $VERSION_CODENAME stable" \
  > /etc/apt/sources.list.d/docker.list

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable docker
systemctl start docker

# 驗證版本
docker --version
docker compose version
```

### 你應該看到的結果
- 顯示類似 `Docker version 26.x.x`。
- 顯示類似 `Docker Compose version v2.x.x`。

### 常見失敗原因與排除
1. **apt update 出現 GPG / repo 錯誤**  
   - 重新執行 key 檔下載與來源列表建立步驟。
2. **compose 指令不存在**  
   - 你可能裝到舊版 `docker-compose`，請確認有安裝 `docker-compose-plugin`。
3. **Docker 服務沒啟動**  
   - 執行 `systemctl status docker` 看錯誤，再 `systemctl restart docker`。

---

## 步驟 6：建立部署目錄與 .env

### 目標
把所有設定集中到 `/opt/hedgedoc`。

### 你要點哪裡
- 只需 SSH 終端機操作。

### 要貼上的指令
```bash
mkdir -p /opt/hedgedoc
cd /opt/hedgedoc

# 請先產生兩個值並先記下：
DB_PASSWORD=$(openssl rand -base64 32)
SESSION_SECRET=$(openssl rand -hex 32)

echo "DB_PASSWORD=$DB_PASSWORD"
echo "SESSION_SECRET=$SESSION_SECRET"
```

接著建立 `.env`（把網域與 email 換成你的）：
```bash
cat > /opt/hedgedoc/.env <<'EOF'
DOMAIN=notes.example.com
EMAIL=you@example.com
DB_NAME=hedgedoc
DB_USER=hedgedoc
DB_PASSWORD=請改成你剛剛產生的DB密碼
SESSION_SECRET=請改成你剛剛產生的SESSION_SECRET
TZ=Asia/Taipei
EOF
```

把 placeholder 改成實際值：
```bash
nano /opt/hedgedoc/.env
```

### 你應該看到的結果
- `/opt/hedgedoc/.env` 成功建立。
- `cat /opt/hedgedoc/.env` 可看到你填入的正確參數。

### 常見失敗原因與排除
1. **忘記把 placeholder 改掉**  
   - HedgeDoc 會啟動失敗或 session 不穩定，務必改成真值。
2. **DOMAIN 打錯**  
   - HTTPS 申請會失敗（憑證對不到網域）。
3. **檔案放錯目錄**  
   - 必須在 `/opt/hedgedoc`，以便 compose 自動讀取。

---

## 步驟 7：建立 docker-compose.yml

### 目標
定義三個服務：`db`、`hedgedoc`、`caddy`。

### 你要點哪裡
- 只需 SSH 終端機操作。

### 要貼上的指令
```bash
cat > /opt/hedgedoc/docker-compose.yml <<'EOF'
services:
  db:
    image: postgres:16-alpine
    container_name: hedgedoc-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      TZ: ${TZ}
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - hedgedoc_net

  hedgedoc:
    image: quay.io/hedgedoc/hedgedoc:1.10.0
    container_name: hedgedoc-app
    restart: unless-stopped
    depends_on:
      - db
    env_file:
      - .env
    environment:
      CMD_DB_URL: postgres://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}
      CMD_DOMAIN: ${DOMAIN}
      CMD_URL_ADDPORT: "false"
      CMD_PROTOCOL_USESSL: "true"
      CMD_ALLOW_ANONYMOUS: "true"
      CMD_ALLOW_ANONYMOUS_EDITS: "true"
      CMD_SESSION_SECRET: ${SESSION_SECRET}
      TZ: ${TZ}
    expose:
      - "3000"
    networks:
      - hedgedoc_net

  caddy:
    image: caddy:2.8-alpine
    container_name: hedgedoc-caddy
    restart: unless-stopped
    depends_on:
      - hedgedoc
    ports:
      - "80:80"
      - "443:443"
    env_file:
      - .env
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
    networks:
      - hedgedoc_net

volumes:
  db_data:
  caddy_data:
  caddy_config:

networks:
  hedgedoc_net:
    driver: bridge
EOF
```

### 你應該看到的結果
- `/opt/hedgedoc/docker-compose.yml` 建立成功。

### 常見失敗原因與排除
1. **YAML 縮排錯**  
   - 空白數量錯誤會導致 compose 解析失敗。
2. **image tag 打錯**  
   - `docker compose pull` 會報找不到映像。
3. **把 expose 寫成 ports 給 hedgedoc**  
   - 會直接暴露 3000，不符合最低暴露原則。

---

## 步驟 8：建立 Caddyfile（HTTPS 反向代理）

### 目標
讓 Caddy 自動簽發 HTTPS，並把流量轉發到 HedgeDoc。

### 你要點哪裡
- 只需 SSH 終端機操作。

### 要貼上的指令
```bash
cat > /opt/hedgedoc/Caddyfile <<'EOF'
{$DOMAIN} {
    tls {$EMAIL}

    encode gzip

    reverse_proxy hedgedoc:3000
}
EOF
```

### 你應該看到的結果
- `/opt/hedgedoc/Caddyfile` 建立成功。

### 常見失敗原因與排除
1. **DOMAIN 與 DNS 不一致**  
   - Caddy 申請憑證會失敗。
2. **443/80 被防火牆擋住**  
   - ACME HTTP challenge 會失敗。
3. **Caddyfile 括號漏掉**  
   - Caddy container 會啟動失敗。

---

## 步驟 9：啟動服務

### 目標
拉映像並啟動三個容器。

### 你要點哪裡
- 只需 SSH 終端機操作。

### 要貼上的指令
```bash
cd /opt/hedgedoc
docker compose pull
docker compose up -d

docker compose ps
```

### 你應該看到的結果
- `db`、`hedgedoc`、`caddy` 都是 `Up` / `running` 狀態。

### 常見失敗原因與排除
1. **pull 失敗（tag 不存在或暫時網路問題）**  
   - 重新執行，或把 `quay.io/hedgedoc/hedgedoc:1.10.0` 改成同系列可用 1.x tag。
2. **db 啟動後又退出**  
   - 常見是 `DB_PASSWORD` 空值或非法字元。
3. **caddy 不起來**  
   - 檢查 Caddyfile 語法與 domain/DNS 是否一致。

---

## 步驟 10：最少量安全設定（只開 22/80/443）

### 目標
用 UFW 將外部流量限制到必要連接埠。

### 你要點哪裡
- 只需 SSH 終端機操作。

### 要貼上的指令
```bash
apt install -y ufw
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable
ufw status
```

### 你應該看到的結果
- `Status: active`
- 規則中有 `OpenSSH`, `80/tcp`, `443/tcp`。

### 常見失敗原因與排除
1. **先啟用防火牆但沒開 SSH**  
   - 會把自己鎖在外面；務必先 `allow OpenSSH`。
2. **雲端平台另有 Cloud Firewall**  
   - 若平台層擋掉 80/443，UFW 開了也沒用。
3. **UFW 指令可用但狀態異常**  
   - `ufw disable && ufw --force enable` 重套一次規則。

---

## 步驟 11：檢查日誌與服務健康

### 目標
確認 DB、App、TLS 都正常。

### 你要點哪裡
- 只需 SSH 終端機操作。

### 要貼上的指令
```bash
cd /opt/hedgedoc

# 看整體狀態
docker compose ps

# 看 app 日誌（最近 100 行）
docker compose logs --tail=100 hedgedoc

# 看 caddy 日誌（最近 100 行）
docker compose logs --tail=100 caddy
```

### 你應該看到的結果
- hedgedoc 日誌有連到 postgres 成功訊息。
- caddy 日誌出現取得憑證成功（首次可能需 1~2 分鐘）。

### 常見失敗原因與排除
1. **hedgedoc 顯示 DB 連線拒絕**  
   - 檢查 `CMD_DB_URL` 與 DB 帳密。
2. **caddy 憑證失敗（timeout）**  
   - DNS 未生效、80/443 未開、網域不指向本機。
3. **容器反覆重啟**  
   - 用 `docker compose logs -f <service>` 持續看錯誤。

---

## 步驟 12：瀏覽器驗證 + 自動重啟驗證

### 目標
確認你真的達成最終成果：可用、可寫、重開機後仍自動起來。

### 你要點哪裡
1. **瀏覽器網址列 → 輸入 `https://notes.example.com/`**
2. HedgeDoc 首頁中：
   - 點 **New note**（或首頁輸入後建立）
   - 輸入一些文字
   - 等待自動儲存（URL 會帶筆記識別碼）
3. 重新整理頁面確認內容仍在

### 要貼上的指令
```bash
# 在 VPS 上測試重開機後自動恢復
reboot
```

約 1–2 分鐘後在本機執行：
```bash
ssh root@你的VPS_IP "cd /opt/hedgedoc && docker compose ps"
```

### 你應該看到的結果
- `https://notes.example.com/` 可正常開啟且有鎖頭。
- 筆記可建立、刷新後內容仍存在。
- reboot 後三個容器都自動恢復 `Up`。

### 常見失敗原因與排除
1. **HTTPS 打不開但 HTTP 可開**  
   - Caddy 還在簽證，等 1–2 分鐘再試。
2. **刷新後筆記不見**  
   - DB 未正常寫入，先檢查 db container 與 volume。
3. **重開機後服務沒起來**  
   - 檢查 compose 是否 `restart: unless-stopped`，以及 Docker 服務有 `enable`。

---

## C. 驗收清單（至少 8 項）

1. `nslookup notes.example.com` 解析到正確 VPS IP。
2. `ssh root@VPS_IP` 可登入且非密碼登入（public key）。
3. `docker --version` 與 `docker compose version` 都有版本資訊。
4. `docker compose ps` 顯示 `db`、`hedgedoc`、`caddy` 皆為 `Up`。
5. `https://notes.example.com/` 可開啟且瀏覽器顯示 HTTPS 鎖頭。
6. HedgeDoc 可以建立新筆記並看到內容。
7. 重新整理或重開瀏覽器，筆記仍存在。
8. `reboot` 後服務會自動恢復，網站仍可開啟。
9. `ufw status` 只開 `OpenSSH`、`80/tcp`、`443/tcp`。

---

## D. 最常見錯誤排除

## 1) DNS 類

1. **網域解析不到 IP**  
   - 先查 nameserver 是哪家，再去正確 DNS 控制台修改。
2. **A 記錄設成 @ 而不是 notes**  
   - 你要的是子網域 `notes`。
3. **剛改完立刻測就說失敗**  
   - 先等 5–30 分鐘。
4. **Cloudflare 橘雲造成判斷複雜**  
   - 先改灰雲 DNS only，成功後再考慮開 Proxy。

## 2) 憑證（HTTPS）類

1. **Caddy log 顯示 ACME challenge failed**  
   - 檢查 80/443 是否真的對外開放。
2. **網域不是指到這台機器**  
   - 憑證簽不下來，先修 DNS。
3. **Caddyfile 網域打錯**  
   - 改正後 `docker compose up -d` 套用。
4. **第一次簽證需要時間**  
   - 等 1–2 分鐘再刷新頁面。

## 3) 連線類（SSH / 網站無法連）

1. **SSH timeout**  
   - IP 錯、機器未就緒、平台網路防火牆阻擋 22。
2. **網站 timeout**  
   - 80/443 沒開、Caddy 容器未啟動。
3. **Connection refused**  
   - 服務沒起來；用 `docker compose ps` + logs 排查。
4. **重開機後偶發連不上**  
   - 等 30–90 秒讓 Docker 與容器完成啟動。

## 4) 容器啟動失敗類

1. **`docker compose up -d` 後某服務 Exit**  
   - `docker compose logs <service>` 看第一個錯誤。
2. **YAML 格式錯誤**  
   - 確認縮排只用空白，且層級正確。
3. **映像拉不到**  
   - 重試 `docker compose pull`，確認 tag 拼字。
4. **系統時間錯誤導致 TLS 異常**  
   - `timedatectl` 檢查時間，必要時校時。

## 5) 資料庫連線失敗類

1. **`password authentication failed`**  
   - `.env` 的 `DB_PASSWORD` 與 DB 初始化密碼不一致。
2. **`database does not exist`**  
   - `DB_NAME` 寫錯或資料庫初始化沒成功。
3. **`ECONNREFUSED db:5432`**  
   - db 容器未 ready，等 10–30 秒再看。
4. **改過密碼但沿用舊 volume**  
   - 開發期可清空 volume 重建（正式環境勿隨意刪資料）。

---

如果你要，我下一步可以直接給你一份「你只要替換 4 個欄位就能貼上」的最終版檔案（`.env`、`docker-compose.yml`、`Caddyfile`）單頁整理版，讓你部署時不必上下捲動。
