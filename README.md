# HF Hidden Code Space Shell

这个仓库是一个 Hugging Face Space 的“壳”项目，用于在运行时拉取真实业务源码并启动服务。构建阶段不会包含任何业务代码，保持仓库公开而代码私有。

## 运行流程
1. 使用 `python:3.11-slim` 构建最小镜像，只安装基础依赖。
2. 镜像启动时运行 `entrypoint.sh`，检查 `APP_ARCHIVE_URL` 环境变量。
3. 通过运行时提供的 URL 下载真实业务代码压缩包（支持 zip 与 tar.gz），自动解压到 `/opt/app`。
4. 进入解压后的目录，执行 `uvicorn app:app --host 0.0.0.0 --port 7860` 启动 FastAPI 应用。

## 配置方法
在 Hugging Face Space → **Settings** → **Variables** 中新增：

```
APP_ARCHIVE_URL = https://example.com/your-real-app.zip
```

> 注意：不要在 Dockerfile 或构建阶段尝试读取该变量，HF secrets 仅在运行时可用。

## 部署步骤示例
1. 将本仓库推送到 Hugging Face，创建为 **Public** Space（Docker 模式）。
2. 在 Space 设置里添加环境变量 `APP_ARCHIVE_URL`，指向你的私有业务代码归档包（zip 或 tar.gz）。
3. 点击 **Restart this Space**，容器启动时会自动下载、解压并运行你的应用。

## 重要提示
- 这是一个空壳仓库，不包含真实业务源码，Fork 后直接运行会失败，因为缺少 `APP_ARCHIVE_URL`。
- `entrypoint.sh` 不会打印下载 URL，避免泄露敏感信息。
- 仅包含基础依赖，如需额外依赖，请在真实业务代码的环境中自行处理。
