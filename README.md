
---

# 🚀 IP Check & YouTube Region Monitor

**一个轻量级的 Linux 服务器工具，实时监控公网 IP 变动并深度检测 YouTube 区域（送中判定），支持多端同步告警。**

---

## ✨ 核心特性

* **🌐 双栈监测**：集成 `ip.sb` 高速 API，精准获取 IPv4 & IPv6 地址。
* **📺 送中判定**：通过模拟 YouTube 请求，深度检测 IP 是否被 Google 映射至中国大陆 (CN)。
* **📢 多维推送**：内置 Telegram Bot 与 企业微信 (WeChat Work) 机器人联动，异动实时掌控。
* **🏗️ 易于管理**：支持 `SERVER_NAME` 自定义标识，多台 VPS 部署不再混淆。
* **⚡ 极简安装**：一行命令完成部署，自动处理权限、目录与环境依赖。

---

## 📦 快速开始

### 1. 一键安装

在终端执行以下命令，脚本将自动安装至 `/opt/youtube/`：

```bash
curl -sSL https://raw.githubusercontent.com/xia-66/ip_check/main/install.sh | bash

```

### 2. 配置环境

安装完成后，请编辑 `.env` 文件配置您的机器人 Token：

```bash
cd /opt/youtube && nano .env

```

| 配置项 | 说明 | 示例 |
| --- | --- | --- |
| `SERVER_NAME` | 服务器备注名称 | `美西-CN2GIA-01` |
| `TG_BOT_TOKEN` | Telegram 机器人 Token | `123456:ABC-DEF...` |
| `TG_CHAT_ID` | 接收消息的 Chat ID | `987654321` |
| `WECHAT_WEBHOOK` | 企业微信 Webhook 地址 | `https://qyapi.weixin...` |
| `NOTIFY_ON_CHANGE_ONLY` | IP区域发生改变时推送 | `true` |

---

## 🛠️ 自动化运维

### 计划任务 (Crontab)
设置上海时区
```
sudo timedatectl set-timezone Asia/Shanghai
```

每天上午 8 点自动执行一次检测：
```
crontab -e
```

```bash
0 8 * * * /bin/bash /opt/youtube/ip_check.sh >> /opt/youtube/ip_check.log 2>&1
```

### 常见问题 (Troubleshooting)

**Windows 用户注意：** 若在 Windows 编辑过脚本，执行时可能会遇到 `$'\r': command not found` 错误（换行符格式问题）。
**修复方案：**

```bash
sed -i 's/\r$//' /opt/youtube/ip_check.sh
sed -i 's/\r$//' /opt/youtube/.env

```

---

## 📂 文件结构

```text
/opt/youtube/
├── install.sh     # 自动安装与初始化脚本
├── ip_check.sh    # 核心检测逻辑脚本
└── .env           # 环境变量配置文件 (敏感信息)

```

---

## 📜 开源协议

本项目基于 [MIT License](https://www.google.com/search?q=LICENSE) 协议开源。

---
