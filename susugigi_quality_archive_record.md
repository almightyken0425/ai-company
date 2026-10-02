# susugigi 舊品質資料封存紀錄

2026-10-02 已完成[重做計劃](susugigi_quality_rebuild_plan.md)的步驟一。計劃與封存先在隔離工作區完成。使用者後續以 `game stop` 授權本階段提交、推送、合併及清理。

本紀錄驗收封存與停用狀態。新版 Quality 定義、測試方法及平台交接尚待重建。

## 封存結果

共同分支為 `feat/susugigi-quality-rebuild`。

| 來源 | 封存檔案 | 原位置處理 | 封存位置 |
| --- | --- | --- | --- |
| susugigi Quality | 108 份 | 104 份移出，1 份改為重建指令，3 份必要設定保留 | Quality 工作區的 `no99_archive/quality_before_rebuild_20261002/` |
| Agent-Control-Plane | 45 份 | 13 份改為停用告示，32 份共用原件保留 | Control 工作區的 `no99_archive/test_workflow_before_rebuild_20261002/` |

封存施工工作區如下。收尾清理後，從各 Git 的最新 main 接續新主題。

- 公司：`~/Doc/ai-company-worktrees/susugigi-quality-rebuild/company`。
- Quality：`~/Doc/ai-company-worktrees/susugigi-quality-rebuild/quality-no2-accounting-app`。
- Control：`~/Doc/agent-control-plane-worktrees/susugigi-quality-rebuild`。

每個封存目錄均有 `README.md`、`manifest.json` 與 `verify_archive.py`。清單記錄來源版本、原路徑、目的地、大小、模式及 SHA-256。

合併後的保存位置如下。

- 計劃與本紀錄：`~/Doc/ai-company/`。
- Quality 封存：`~/Doc/ai-company/product/susugigi/no6_product_quality/no2_accounting_app/no99_archive/quality_before_rebuild_20261002/`。
- Control 封存：`~/Doc/agent-control-plane/no99_archive/test_workflow_before_rebuild_20261002/`。

封存清單中的來源版本、候選狀態與 `main_or_installed_changed` 保留封存當時的事實，不代表後續 Git 收尾狀態。

原始指令檔與 Git 設定改用 `.snapshot` 副檔名。內容保留不變，原檔名由清單還原。這些檔案不作為有效指令或封存目錄的 Git 設定。

## 封存範圍

Quality 封存所有已追蹤檔案，包括能力側寫、回歸計劃、場次腳本、測試資料、產品適配程式與原檢查工具。封存保留十個原始目錄位置的對照。

Control 封存兩個 skill、十二份品質政策及相關共用資料。兩個 skill 與十一份方法文件的原位置改為停用告示。

共用程式、測試、契約、能力台帳、`test-ios` 入口與 iOS 政策保留原位，另存快照。保留是為避免修改其他控制能力，不代表新版接受舊方法。

未追蹤的 Quality 服務憑證仍留在主目錄。不讀取其內容，不複製進封存或 Git。`.git` 資料也不搬移。

## 驗證結果

| 核對項目 | 結果 |
| --- | --- |
| 複製前後逐檔核對 | 153 份內容、大小、模式與雜湊相符 |
| 封存清單 | 沒有缺檔或額外的原始檔案 |
| 暫存目錄還原 | 108 份 Quality 與 45 份 Control 均還原到原相對路徑 |
| 還原後比對 | 內容與模式均與未修改的主 checkout 相符 |
| 保留原件 | 35 份保留檔案與封存前相符 |
| 舊工件移出 | 104 份 Quality 舊工件已離開原位置 |
| skill 格式 | 兩個停用入口通過官方 `quick_validate.py` |
| 指令漂移檢查 | 公司檢查器通過 33 組入口與 34 個掃描根目錄 |
| 候選指令 | 已讀回 Quality 重建指令，Claude 相容入口維持原樣 |
| Control 台帳與薄入口 | 21 個能力及候選相容入口的一致性檢查通過 |
| 候選安裝 | 新建暫存家目錄的安裝與稽核通過，外掛檢查依候選模式略過 |
| Git 差異 | 三個候選的 `diff --check` 通過 |
| 文件審查 | 計劃與新增說明依 `writing_policy.md` 審讀，20 份 Markdown 通過路徑檢查 |
| 正式來源 | 公司、Quality、Control 的 main 工作目錄均乾淨 |

指令漂移檢查的全域結果涵蓋正式目錄。候選 Quality 的新指令另以讀回與相容入口比對核對，不將全域檢查冒充候選內容驗收。

本輪未執行封存的 `check_plan.sh` 或其自測。它們驗證舊格式，且已隨舊資料封存。本輪驗收對象是資料完整性與停用入口，不是新版測試系統。

本輪未啟動 Metro、build、simulator 或產品測試。官方 skill 檢查所用的暫時 Python 環境已移除。候選安裝只驗證停用入口及控制接線，不宣稱 QA 能力可執行。

## 接續位置

下一步為計劃中的完整來源盤點與最小契約。封存內容在新版完成驗收前維持封閉，只允許完整性核對。

Control 仍有待重建的共用引用。`test-ios` 及舊契約產生器仍指向已停用的方法文件。這些缺口已記在 `references/quality/rebuild_status.md`，新版啟用前必須處理並驗證。

本機 `~/.agents/skills` 與 `~/.codex/references` 直接連到 Control 正式來源。合併後停用告示即生效，不另執行安裝器。`test-define`、`test-run` 與相依的 QA 場次保持停用，不能把來源合併當成新版測試系統完成。
