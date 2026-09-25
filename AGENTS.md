# AI Company — Codex 全局設定

## 動作前 5 秒自檢

先確認本次目標、工作目錄與已獲授權的操作。
授權判準共用 `~/.codex/references/workflow_safety.md`。
已確認的提交、合併或收尾授權不因跨回合失效。
Skill 自動啟動與單純肯定 review 結果不構成合併授權。

- **產品修改：** 先完成動工前置。在本次涉及層的 worktree 修改，主 Git 保持乾淨 main。
- **使用者既有成果：** 不 stash 或丟棄既有未提交修改。工作位置錯誤依共同政策保全並移轉。
- **控制工具維護：** 依控制 repo 的 README 建立隔離審閱環境。不套用產品流程，不直接寫入正式設定。原生安全核准仍有效。
- **依賴與執行環境：** node_modules 與 Metro、build、simulator 分別依「Worktree 使用慣例」及「Port 協作規範」。不因完成修改自行啟動。
- **Impl UI：** 修改前讀取同模組對應 design 檔。範圍見「Design-Impl 對齊」。
- **跨 Git 盤點與清理：** 依「盤點任務協作節奏」一次收齊本次範圍。`--keep-remote` 等限制持續有效。

## 頂層目錄結構

```
ai-company/
├── company/     公司層級定位與產品索引
├── product/     所有產品（App 程式碼 + Spec 文件）
├── project/     各產品專案管理文件
└── finance/     公司層級股權與財務管理
```

## 命名規則

共同命名只由 `~/.codex/references/naming_policy.md` 維護。
本公司增加下列路徑對應。

- remote repo slug 與主要 checkout 根目錄名稱一致。
- module id 使用 `noN_snake_case`。
- worktree 的 module 末層使用 kebab-case，例如 `design-no2-accounting-app`。
- `project/` 下的 Design stage 沿用兩位數 `NN_snake_case`。

## 公司文件路徑
- 公司 context：`company/context.md`
- 產品索引：`company/products.md`

## 產品路徑

- 產品決策流程僅用於任務實際指向的 ai-company 產品。
- 目前目錄與需求、設計、規格等一般用語不單獨構成啟動條件。
- 公司文件、財務維護、外部專案與控制工具維護不因位於 ai-company 目錄就套用產品流程。
- 位於其他目錄或 worktree 的任務仍可指定 ai-company 產品為目標。
- 明確屬於 ai-company 的新產品規劃可先使用 `product-plan` 分析。
- 尚未登錄不阻擋前期討論。
- 只有任務包含建立產品或模組時才依註冊流程新增。

| 查詢內容 | 資料來源 |
| --- | --- |
| 產品與模組身分、repo、形態引用與覆寫、Product Map 對應、品質責任 | `~/.codex/data/products/products_registry.md` |
| 層定義、目錄、Git 邊界與形態定義 | `~/.codex/data/products/layer_manifest.yaml` |

- 從註冊表的 `repo.path` 定位產品主 Git。
- 依產品與模組的形態及覆寫取得有效層。
- 模組層路徑由產品主 Git、層目錄與模組識別推導。
- worktree 透過所屬主 Git 的 `git worktree list --porcelain` 核對。
- 不依 worktree 目錄名或同名模組推定產品身分。
- 確認產品目標後依 `product-scope` 分流討論、唯讀檢查與修改前置。
- 本節不保存產品名單、模組配置或開發進度。

## 財務路徑
- 股權原則：`finance/no1_principles/`
- 各產品貢獻帳本：`finance/no2_ledgers/<product-slug>/`
- 公司股權操作管理：`finance/no3_operation/`

## 多產品多層 git 協作規範

跨層同名分支、配對提交及涉及範圍由 `~/.codex/references/git_policy.md` 維護。本節只保留產品工作區差異。

- **git 拆分結構：** 每產品拆為頂層 Product git 與依 module 拆分的各層 git。層的編號、目錄名、git 邊界只在 `layer_manifest.yaml` 宣告。實例配對在 `products_registry.md`。兩者與衍生物的一致性由 `~/.codex/hooks/tests/layer-manifest-test.sh` 檢核
- **頂層 Product git 承載：** 提案層、需求層、整合層 Product Map、Roadmap。專案管理文件在 ai-company 根 git 的 `project/<product-slug>/`。另追蹤 `no99_archive/` 歸檔層，收納工作追蹤筆記、規格衝突報告、已廢案 spec 等非決策框架核心層檔案
- **新增產品 / 新增 module SOP：** 依 `products_registry.md` 末段變更 SOP 走檢核器迴圈——改宣告、跑 `layer-manifest-test.sh`、照 FAIL 清單補實體與文件、再檢核至全綠
- **Spec 層職責邊界：** spec 文件的 MVC 分層政策與跨層禁止項由 `~/.codex/references/spec/` 承載，寫作及唯讀審查使用 `code-spec`。各 spec module git 的 AGENTS.md 為入口
- **已知邊界：** 本機 hook 僅提示層，無法保證遠端 merge 真的配對發生。要硬保證走 CI 或遠端 pre-merge 檢查
- **測試責任分工：** Quality git 維護測試定義、能力需求與核心標記。執行證據只留目前 session。Release git 維護候選版本 manifest
- **規則漂移檢查：** 修改任何 `AGENTS.md` 或 `CLAUDE.md` 後，執行 `scripts/check-instruction-drift.sh`。檢查器核對 33 組 Claude 薄入口及同目錄 AGENTS.md 是否存在，並掃描宣告的 instruction roots 與實際 Git roots，確認沒有專案層 Hook 設定或執行檔

## 動工前置

已確認目標屬於 ai-company 產品時，首次修改前完成四步。
其他任務不因位置或一般關鍵字套用這套產品前置。

1. **確認產品決策：** 依 `product-scope` 確認產品、層、模組，以及需求根因與 Product Map 對應。
2. **列出影響範圍：** 確認實際修改的 Git、Quality owner、Quality 影響與 Debug 能力影響。沿用本任務已完成且仍適用的判斷。
3. **建立隔離工作環境：** 完成全域同步要求後，對實際修改的層建立同名 `feat/<topic>` worktree。名稱沿用 plan。未涉及的層不建立。
4. **核對工作位置：** 確認 cwd、Git 根目錄及目前分支。再以主 Git 的 `git worktree list --porcelain` 核對歸屬，不只看目錄名稱。

發現漏了前置或改錯位置時，停止該位置的新寫入。
依共同安全政策保全 staged、unstaged、untracked 及二進位差異，再把本次修改移入正確 worktree。
驗證完整承接前保留來源。
無法區分其他人的改動時不整檔還原。
流程錯誤不得以 `git reset --hard` 或廣域清理補救。

## Worktree 使用慣例

公司 Git 與產品各層 Git 的主題修改使用 worktree 隔離。
主 Git 保持乾淨 main，供同步與已授權的合併使用。
小改、hot-fix 與歷史檔案整理也遵守同一規則，避免並行任務互相切換分支。

### 目錄與命名

- worktree 集中在 `~/Doc/ai-company-worktrees/<topic>/`，topic 使用 kebab-case
- module 層 git 的末層目錄使用 `<layer>-<module-kebab>`，例如 `spec-no2-accounting-app`
- 頂層 Product git 的末層目錄使用 `product-<product-slug>`，例如 `product-susugigi`
- ai-company 根 Git 的末層目錄使用 `company`
- 末層目錄名是人類閱讀與 launch entry 的慣例，不是 Hook 的產品身分依據。
- Hook 執行檔只由全域控制層維護。專案不另存 `.codex` 或 `.claude` Hook。
- 產品、module 與 layer 由 registry、layer manifest、Git remote 及 common dir 解析。需要區分 main 與 worktree instance 時再核對實體 repo root。
- 公司、Product 與 module 主 checkout 的 Edit、Write、apply patch 及可辨識命令寫入會被阻擋。linked worktree 正常放行。產品歸屬不唯一時不猜測產品，已確認的正式主 checkout 仍受保護。
- 工具診斷檔清理有有限例外。單一直接 `rm` 可刪除主 checkout 根目錄未被 index 或 HEAD 追蹤的 `firepit-log.txt`，須為目前使用者持有的一般檔案。完整條件由 `~/.codex/references/hook_decision_engine.md` 持有。放行仍保留原生授權審查。
- worktree 改名不需修改 Hook 正則。新增產品、module 或 layer 時只更新對應註冊來源與一致性測試。
- 同主題跨多層 git 用完全相同的 branch 名稱
- 開新 worktree 後、啟一般 server 前，為它 append launch.json entry（見「Port 協作規範」）。test-ios 的 QA Metro 使用下述場次私有登記。

### node_modules 一律 symlink

需要 node_modules 的 worktree 強制 symlink 主 git 那份（`ln -s <主 git node_modules 絕對路徑> ./node_modules`），禁止各自 `npm ci` / `npm install`——單份約 1.9 GB，多 worktree 各一份會爆硬碟。worktree 與主 git 本來就是共用精神。**唯一例外：** 主題本身要動 `package.json` / lock 檔——動工前先說明、獨立 npm ci、收工立刻刪那份 node_modules 並 recreate symlink。

### 修改與收尾

對本次涉及的 Git 建立同名主題分支。
公司根 Git 與 Product Git 的末層目錄沿用前節命名。

```bash
git -C <該層主 git> worktree add ~/Doc/ai-company-worktrees/<topic>/<layer>-<module-kebab> -b feat/<topic> main
```

修改與相關檢查都在 worktree 內完成。
預設保留未提交差異供 review。
驗證只修復本次相關問題，不以專案所有既存錯誤歸零為條件。

提交、推送、合併與刪除依共同授權政策判斷。
`game-stop` 的執行順序由其 workflow 持有，支援單一 Git 與配對多層 Git。
單獨提交或合併時也保留相同安全條件。

- 各層提交 subject 與 body 完全相同。未推送成功的主題不進入合併。
- 主 Git 必須乾淨且對齊遠端。各層使用 `--no-ff` 合併並推送 main。
- 只清理已完成且屬於本次授權範圍的 worktree、分支與 launch 設定。
- 備份、推送或合併失敗時停止依賴它的刪除。不丟棄尚未保全的成果。

## Design-Impl 對齊

凡有 design git 的產品，impl 寫 UI 時 token、component、screen layout 必須對齊 design——不擅自設值，先查 design 對應 token 與 component 結構再對應到 impl。適用範圍以產品註冊表內的 design repo 為準。

- **範圍：** impl 的 `src/screens/**`、`src/components/**`、`src/theme/**`、`src/constants/theme.ts`（任何產品都套）。對應同 module design 的 `project/10_foundations/`（tokens）、`20_components/`（元件）、`30_screens/`（layout）。仲裁配對權威在 `products_registry.md`：design 仲裁、impl 跟進
- **動作層面：** 動 impl UI 前必須先以支援的唯讀命令，成功讀取同 module 對應 design 範圍任一檔。PreToolUse、原命令與 PostToolUse 共同建立成功證據。只有同 session、同產品、同 module 的證據可放行。命令失敗、只在文字或 transcript 提到路徑、不同 session 的讀取都不算。design repo 未註冊或不存在時不啟動本規則
- **例外（極窄）：** 純邏輯修補不動視覺（useEffect、data fetching、handler 邏輯），設 `export CODEX_SKIP_DESIGN_GUARD=1` 繞過。Claude 相容 alias 為 `export CLAUDE_SKIP_DESIGN_GUARD=1`。該 session 後續全放行。判斷由執行者擔責、濫用會回到沒對齊的爆氣循環
- **介面方法入口：** `product-scope` 確認產品與模組後，`ui-*` 直接使用同模組 Design。共同方法不另建一份產品設計真相。已有且仍有效的方向、行為與 token 直接沿用，缺口回交 Design 主人。只有瀏覽器工具必須讀固定檔名時才建立有來源雜湊的自動投影。

## Port 協作規範

多 worktree 並行跑 server 會撞 port。一般 server 使用集中註冊表 `~/Doc/ai-company/.codex/launch.json`，啟動前必查表、不自選 port。test-ios 的 QA Metro 使用場次私有登記，規則見下述重量資源小節。

### 註冊表與硬規則

每個 worktree 一條 entry，欄位：`name`（人類可讀標籤）、`directory`（相對 ai-company 根目錄。`directory` 與 `runtimeArgs` 內任何路徑都**禁止絕對路徑**——launch.json 跨機共享，絕對路徑只對單機有效，混入會讓另一台機看到無法解析的路徑）、`port`（design canvas 用，base 8765 遞增）、`metroPort`（base 8081 遞增。純佔位防手動 hardcode 衝突，`/test-ios` 不讀它、統一跑 8081——app 嵌入的 bundler URL 即 8081，切 worktree = 換 Metro 來源、不換 port）。

- `git worktree add` 完成後、啟一般 server 前，**必須** append entry。未加不許啟 server。分配 port = 現有最大 +1。只供 test-ios 取用候選的 worktree 不建立持久 server entry。
- `git worktree remove` 後**同步移除** entry。`/game-stop` 自動處理，手動 remove 自己記得
- 回報訊息「驗證位置」的 server URL 必須對齊 entry port（銜接`~/.codex/references/reporting_policy.md`），不允許報無對應的 port
- server guard 以 registry 與 Git 身分確認產品範圍，再比對同一實體 repo instance 及其相對子目錄。HTTP server 只使用該 entry 的 `port`，Metro 只使用 `metroPort`。同類 port 重複登記、instance 不符或 port 不符都不放行

### 輕量 server（design canvas）

每 instance 約 10 MB，可多 instance 並行。每個 worktree 用自己 entry 的 port 跑 `python3 -m http.server <port>`。

### 重量資源（Metro / iOS Simulator）：一律走 /test-ios

原獨立節「iOS 自驗策略」已併入本節，hook 訊息引該名時指的就是這裡。

- simulator 驗證由 `/test-ios` 一鍵執行。另一入口是 `test-run` 確認範圍後委派 `test-ios`。切 Metro、build、還原與排隊規則見 `~/.agents/skills/test-ios/SKILL.md`
- QA Metro 由鎖定的 Control helper 在本場次私有暫存目錄建立 `launch.json`。先核對主 checkout 的候選 commit、tree、乾淨狀態與 `8081` 空閒，再核對相對路徑登記及 server policy。不修改公司主目錄的持久登記，也不放寬一般主目錄寫入保護。
- 場次正常結束或失敗時清除私有登記，回到 Metro 未啟動的狀態。既有 owner 尚未結束時停止啟動，不終止其他程序。完整契約由 `~/.codex/references/quality/ios_execution.md` 與鎖定 Quality runbook 持有。
- 上述兩種入口以外，Codex 不主動啟、不主動切 Metro、不動 simulator。Metro 維持單一 8081。低 RAM 環境依序執行
- **禁止 worktree 內 build**（`npm run ios`、`xcodebuild`、`pod install`）——各自 build 會在 DerivedData 累積 cache 爆磁碟。build 集中主 git、由 `/test-ios` 觸發。全域 iOS worktree build guard 在 PreToolUse 機械攔截
- 完成改動、預期使用者想上 simulator 看時，回報「驗證位置」段引導打 `/test-ios`，依 `~/.codex/references/reporting_policy.md` 回報

## 盤點任務協作節奏

- 沿用任務已確認的產品、模組、Git 與 worktree 範圍。
- 一般跨 Git 盤點與多 worktree 清理不預設擴大到其他產品。
- 範圍不明時先查本次任務與註冊資料。
- 仍有缺口時先釐清範圍。
- 第一輪一次收齊已確認範圍的訊號。
- 不分批回報或用全公司掃描代替範圍確認。
- `/game-over`、`/game-start` 與使用者明確要求的全區盤點保留完整覆蓋。
- 全區盤點在 ai-company 的最低範圍包含下列項目。
    - ai-company 根 Git 與所有產品主 Git。
    - 所有已註冊模組的有效層 Git。
    - 搜尋範圍內實際存在但未登錄的 Git。
    - 納入 Git 的所有 worktree。
- 未登錄的 Git 列為待辨識項目。
- 不依目錄位置推定為已註冊產品。
- worktree 依各 Git 的 `git worktree list --porcelain` 列舉。
- 活躍 worktree 根為 `~/Doc/ai-company-worktrees/`。
- 目錄命名沿用本檔 Worktree 使用慣例。
- 遺留根 `~/Doc/.worktrees/` 與 `~/Doc/_worktrees/` 存在時納入檢查。
- 搜尋到的 worktree 仍須核對 Git 歸屬與本次範圍。
- dirty 偵測不依賴 worktree 所在目錄。
- 空殼目錄清理仍只認活躍 worktree 根。

**請示節奏：** 先收齊範圍內的訊號與具體動作清單。已有相同範圍的授權時沿用，不重設確認關卡。範圍改變、發現新損失或缺少授權時，完成不受影響的準備後集中請示。單純盤點不構成刪除或合併授權。判準依共同安全政策。

回報結構——三件套、禁止降級指代、精簡可掃描——沿用 `~/.codex/references/reporting_policy.md`，不在此重述。唯逐欄比對更清楚時可用表格。
