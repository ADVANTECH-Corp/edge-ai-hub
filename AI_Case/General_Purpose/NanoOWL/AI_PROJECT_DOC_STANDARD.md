# AI Project Documentation Standard (README-Aligned)

> 適用範圍：所有對外發布的 AI 專案 README。  
> 本標準已對齊 `NanoOWL/README.md` 章節骨架。

---

## A. 核心原則

1. **README 骨架一致**：必須使用本文件定義的固定章節順序。
2. **可重現**：所有成功宣告需有可執行指令與可驗證輸出。
3. **自包含交付**：不可依賴 build/runtime 臨時 clone 核心程式碼。
4. **對外語氣**：使用公開文件語氣，避免內部備註與模糊措辭。

---

## B. 固定章節順序（必須）

# `<PROJECT_NAME>`

## 專案資訊
### 1) 專案定位
### 2) 模型介紹
### 3) 相依來源與封裝策略
### 4) 為什麼先用 InferenceKit
### 5) 已驗證硬體平台
### 6) 執行結果示意

---

## 開發者資訊
### 0) 前置條件
### 1) 建置
### 2) 第一次啟動
### 3) 驗證

---

## 最低驗收門檻
- Build 成功
- Compose 服務為 Up
- 視覺化結果可驗證

---

## 文件規範
本文件遵循 `AI_PROJECT_DOC_STANDARD.md`。

---

## C. 各章節最低內容要求

### 專案資訊
- 專案定位：一句話價值 + 適用場景
- 模型介紹：核心模型、推論流程、加速方式、技術來源連結
- 相依來源與封裝策略：
  - vendor 進 repo 的核心檔案
  - 外部依賴（pip/apt）
  - 說明不依賴 runtime/build-time clone
- InferenceKit：提供連結與導入理由
- 已驗證硬體平台：平台/規格/OS/連結
- 執行結果示意：至少 1 張 repo 內有效圖片（建議 2 張）

### 開發者資訊
- 前置條件：環境與裝置要求
- 建置：完整 command（含工作目錄）
- 第一次啟動：線上準備流程與預期訊號
- 驗證：至少含 URL、`docker compose ps -a` 或等價健康檢查

### 最低驗收門檻
必須提供可複製指令並驗證：
```bash
cd <PROJECT_DIR>
docker build -t <IMAGE_TAG> -f <DOCKERFILE_PATH> .
docker compose up -d
docker compose ps -a
```
期望結果：
- Build exit code = 0
- 目標服務狀態 = `Up`
- 可視化結果可被檢視（Web UI / 截圖 / demo）

---

## D. 格式規範

1. 指令可直接複製執行。
2. 版本資訊需明確（JetPack / CUDA / TensorRT / image tag）。
3. 連結使用完整 URL。
4. 圖片使用 repo 內有效路徑（優先 `assets/`）。
5. 禁用模糊字眼（如「應該可以」）。
