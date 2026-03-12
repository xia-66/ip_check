#!/bin/bash

# 1. 加载配置
BASE_DIR=$(cd "$(dirname "$0")"; pwd)
ENV_FILE="${BASE_DIR}/.env"

if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
else
    echo -e "\033[31m错误: 找不到配置文件 .env\033[0m"
    exit 1
fi


# 是否仅在归属地变化时推送 (true 为开启，false 为每次都推送)
NOTIFY_ON_CHANGE_ONLY=${NOTIFY_ON_CHANGE_ONLY:-true}
# 用于存储上一次归属地状态的文件
LAST_STATE_FILE="${BASE_DIR}/.last_ip_state"
# 用于收集本次归属地检测结果
CURRENT_REGION_STATE=""


# 2. 获取 IP 函数 (优先使用 ip.sb)
get_public_ip() {
    local ip_ver=$1
    local ip=$(curl -$ip_ver -s --max-time 5 https://api.ip.sb/ip 2>/dev/null)
    [ -z "$ip" ] && ip=$(curl -$ip_ver -s --max-time 5 https://icanhazip.com 2>/dev/null)
    echo "${ip:-未获取到}" | tr -d '\r\n'
}

# 终端输出颜色配置
Font_Red="\033[31m"
Font_Green="\033[32m"
Font_Yellow="\033[33m"
Font_Suffix="\033[0m"

# 3. 初始化基础信息
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
IP4_ADDR=$(get_public_ip 4)
IP6_ADDR=$(get_public_ip 6)

# 构建推送消息头部
PUSH_MESSAGE="🚀 YouTube 监测报告\n"
PUSH_MESSAGE="${PUSH_MESSAGE}服务器: ${SERVER_NAME:-未命名}\n"
PUSH_MESSAGE="${PUSH_MESSAGE}IPv4: ${IP4_ADDR}\n"
PUSH_MESSAGE="${PUSH_MESSAGE}IPv6: ${IP6_ADDR}\n"
PUSH_MESSAGE="${PUSH_MESSAGE}--------------------\n"

# 控制台实时输出头部
echo "服务器: ${SERVER_NAME:-未命名}"
echo "IPv4: ${IP4_ADDR}"
echo "IPv6: ${IP6_ADDR}"
echo "--------------------"

check_region() {
    local ip_ver=$1
    local type=$([ "$ip_ver" == "4" ] && echo "IPv4" || echo "IPv6")
    local tmpresult=$(curl -$ip_ver -sL -H "Accept-Language: en-US,en;q=0.9" --user-agent "$UA_Browser" --max-time 10 "https://www.youtube.com/premium" 2>&1)
    local res_plain=""
    local res_color=""

    if [[ $tmpresult == "curl"* ]] || [ -n "$(echo "$tmpresult" | grep -E "Could not resolve|unreachable|refused")" ]; then
        res_plain="网络不通"
        res_color="${Font_Yellow}${res_plain}${Font_Suffix}"
    elif echo "$tmpresult" | grep -q 'www.google.cn'; then
        res_plain="[CN] (已送中)"
        res_color="${Font_Red}${res_plain}${Font_Suffix}"
    else
        local region=$(echo "$tmpresult" | grep -oP '"(contentRegion|countryCode|gl)"\s*:\s*"\K[A-Za-z]{2}(?=")' | head -n 1)
        if [ -n "$region" ]; then
            res_plain="[$region]"
            res_color="${Font_Green}${res_plain}${Font_Suffix}"
        else
            res_plain="获取失败"
            res_color="${Font_Red}${res_plain}${Font_Suffix}"
        fi
    fi
    # 实时输出到控制台（带颜色）
    echo -e "${type}: ${res_color}"
    # 累加到推送消息（纯文本）
    PUSH_MESSAGE="${PUSH_MESSAGE}${type}: ${res_plain}\n"
    # 收集当前状态
    CURRENT_REGION_STATE="${CURRENT_REGION_STATE}${type}:${res_plain};"
}

# 4. 执行检测并实时显示
check_region "4"
check_region "6"
echo "----------"

# 5. 归属地变化比对逻辑
SHOULD_PUSH=true
LAST_REGION_STATE=""

# 读取上一次的状态
if [ -f "$LAST_STATE_FILE" ]; then
    LAST_REGION_STATE=$(cat "$LAST_STATE_FILE")
fi

# 判断是否需要推送
if [[ "$NOTIFY_ON_CHANGE_ONLY" == "true" ]]; then
    # 如果当前状态等于上一次状态，并且上一次状态不为空，则跳过推送
    if [[ "$CURRENT_REGION_STATE" == "$LAST_REGION_STATE" ]] && [[ -n "$LAST_REGION_STATE" ]]; then
        SHOULD_PUSH=false
        echo "🔕 IP 归属地未发生变化，跳过推送。"
    else
        # 可选：如果是发生了改变（非首次运行），在推送文案里加个高亮提示
        if [[ -n "$LAST_REGION_STATE" ]]; then
             echo "🔔 IP 归属地发生变化！"
             PUSH_MESSAGE="⚠️ 归属地变更通知\n${PUSH_MESSAGE}"
        else
             echo "🔔 首次记录归属地，准备推送..."
        fi
    fi
fi

# 更新当前状态到本地文件，供下次比对使用
echo "$CURRENT_REGION_STATE" > "$LAST_STATE_FILE"

# 6. 推送逻辑
if [[ "$SHOULD_PUSH" == "true" ]]; then
    # Telegram 推送
    if [ -n "$TG_BOT_TOKEN" ] && [ -n "$TG_CHAT_ID" ]; then
        curl -s -o /dev/null -X POST "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
            -d "chat_id=${TG_CHAT_ID}" \
            -d "text=$(echo -e "$PUSH_MESSAGE")"
    fi

    # 企业微信推送
    if [ -n "$WECHAT_WEBHOOK" ]; then
        curl -s -o /dev/null -X POST "$WECHAT_WEBHOOK" \
            -H 'Content-Type: application/json' \
            -d "{ \"msgtype\": \"text\", \"text\": { \"content\": \"$(echo -e "$PUSH_MESSAGE")\" } }"
    fi

    echo "监测完成，已发送报告。"
else
    echo "监测完成，未发送报告（状态无变化）。"
fi
