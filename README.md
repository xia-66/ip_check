由于你目前是在本地或特定服务器上维护脚本，生成 `curl | bash` 命令的前提是需要将 `install.sh` 上传到一个可以通过 HTTP 公开访问的地方（如 **GitHub Gist** 或 **GitHub Repo**）。

假设你将脚本上传到了 GitHub，以下是配套的一键安装命令及完善后的 `README.md`。

---

### 1. 一键安装命令模板

请将下方链接替换为你实际存放 `install.sh` 的 Raw 链接：

```bash
curl -sSL https://raw.githubusercontent.com/你的用户名/你的仓库名/main/install.sh | bash

```

> **提示**：如果是在国内服务器运行，建议使用代理下载或将链接替换为加速镜像（如 `fastly.jsdelivr.net`）。

---

### 2. 完善后的 `README.md`

```markdown
# 🚀 IP Check & YouTube Region Monitor

这是一个自动化的 Linux 服务器工具，用于实时检测公网 IP 并在控制台/社交软件同步 YouTube 地区（送中）报告。

## 🌟 核心功能
* **双栈支持**：通过 `ip.sb` 高速获取公网 IPv4 & IPv6。
* **送中判定**：深度检测 IP 是否被 Google 判定为中国大陆（CN）。
* **多端推送**：支持 Telegram Bot 和 企业微信机器人告警。
* **服务器标识**：支持 `SERVER_NAME` 变量，多机管理不混淆。
* **一键部署**：支持 `curl | bash` 快速安装，自动处理权限与目录。

## 📦 快速安装

在终端执行以下命令即可完成安装：

```bash
# 替换为你的真实安装脚本链接
curl -sSL [https://raw.githubusercontent.com/你的用户名/项目名/main/install.sh](https://raw.githubusercontent.com/你的用户名/项目名/main/install.sh) | bash

```

## ⚙️ 配置说明

安装完成后，脚本会存放在 `/opt/youtube/` 目录下。请编辑 `.env` 文件填入你的配置：

```bash
cd /opt/youtube
vi .env

```

**配置项参考：**

* `SERVER_NAME`: 你的服务器备注（如：美西-dedirock）。
* `TG_BOT_TOKEN`: 从 @BotFather 获取的机器人 Token。
* `TG_CHAT_ID`: 你的用户 ID 或频道 ID。
* `WECHAT_WEBHOOK`: 企业微信群机器人的 Webhook 地址。

## ⚠️ 避坑指南 (Windows 用户必看)

如果你是在 Windows 上手动创建或编辑过脚本，Linux 执行时会报 `$'\r': command not found` 错误。这是由于 **CRLF (Windows)** 与 **LF (Linux)** 换行符不一致导致的。

**修复方法：**

```bash
sed -i 's/\r$//' ip_check.sh
sed -i 's/\r$//' .env

```

## ⏰ 自动化监控 (Crontab)

执行以下命令，让脚本每 6 小时自动运行并推送报告：

```bash
(crontab -l ; echo "0 */6 * * * /bin/bash /opt/youtube/ip_check.sh > /dev/null 2>&1") | crontab -

```

## 📂 文件清单

* `install.sh`: 部署脚本，负责写入 `ip_check.sh` 并初始化 `.env`。
* `ip_check.sh`: 主检测脚本，包含 IP 获取与 YouTube 检测逻辑。
* `.env`: 敏感配置文件（不建议上传至 GitHub）。

## 📜 许可证

MIT License

```


**既然一键命令也做好了，需要我帮你测试一下你的 Telegram Token 在 Linux 命令行下是否能通过代理发送消息吗？**

```
