既然脚本名称已由 `check_youtube_region.sh` 改为 `ip_check.sh`，且增加了 IP 检测和 `.env` 配置文件支持，我们需要更新 `README.md` 以反映最新的项目状态。

以下是更新后的 `README.md` 内容，你可以直接替换原文件：

---

```markdown
# IP & YouTube Region 监测工具 (ip_check.sh)

这是一个专为 Linux 服务器设计的轻量级监测脚本，用于获取公网 IP 地址并检测 YouTube 区域设置（判定是否“送中”）。支持通过 Telegram Bot 和企业微信机器人发送自动化报告。

## 🌟 主要功能
* **双栈 IP 获取**：优先使用 `ip.sb` 接口获取公网 IPv4 和 IPv6 地址。
* **YouTube 地区检测**：通过 YouTube Premium 接口判定当前 IP 的内容服务区。
* **送中识别**：自动识别并标记被 Google 判定为中国大陆（CN）的 IP。
* **自定义服务器名**：支持在报告中显示自定义的服务器标识，方便管理多台机器。
* **多平台推送**：支持 Telegram Bot 和企业微信 Webhook 同步推送。
* **环境变量管理**：敏感 Token 存储在 `.env` 文件中，结构清晰且更安全。

## 📂 文件清单
* `ip_check.sh`: 主执行程序。
* `.env`: 环境变量配置文件（需手动创建）。
* `README.md`: 项目使用说明。

## 🛠️ 安装与配置

### 1. 部署脚本
将脚本放置在目标目录（如 `/opt/youtube/`），并赋予执行权限：
```bash
chmod +x ip_check.sh

```

### 2. 配置环境变量

在脚本同级目录下创建 `.env` 文件：

```bash
SERVER_NAME="美西-dedirock"
TG_BOT_TOKEN="8671243464:AAHsak..."
TG_CHAT_ID="6420667502"
WECHAT_WEBHOOK="[https://qyapi.weixin.qq.com/](https://qyapi.weixin.qq.com/)..."

```

### 3. 解决跨平台格式问题 (必做)

如果你在 Windows 下编辑过文件，请务必在 Linux 终端执行以下命令，否则脚本会因隐藏的 `\r` 字符报错：

```bash
sed -i 's/\r$//' ip_check.sh
sed -i 's/\r$//' .env

```

### 4. 手动运行测试

```bash
./ip_check.sh

```

## ⏰ 自动化监控

建议通过 `crontab` 设置定时任务（如每 6 小时运行一次）：

```bash
0 */6 * * * /bin/bash /opt/youtube/ip_check.sh > /dev/null 2>&1

```

## ⚠️ 注意事项

* **权限安全**：建议执行 `chmod 600 .env` 以确保只有当前用户可以读取 Token 信息。
* **网络限制**：Telegram 推送依赖服务器对 `api.telegram.org` 的访问能力。
* **IPv6 缺失**：若显示“未获取到”，请检查服务器是否分配了 IPv6 地址或防火墙是否放行。

## 📜 许可证

MIT License

```
