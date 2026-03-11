#!/bin/bash

# ================= 配置区 =================
INSTALL_DIR="/opt/youtube"
# ==========================================

# 确保目录存在
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || exit

echo "开始部署/更新 ip_check.sh..."

# 使用 Cat 写入主脚本内容
# 注意：使用 'EOF' (带引号) 可以防止变量在写入时被当前 Shell 解析
cat << 'EOF' > ip_check.sh
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

# 2. 获取 IP 函数 (优先使用 ip.sb)
get_public_ip() {
    local ip_ver=$1
    local ip=$(curl -$ip_ver -s --max-time 5 https://api.ip.sb/ip 2>/dev/null)
    [ -z "$ip" ] && ip=$(curl -$ip_ver -s --max-time 5 https://icanhazip.com 2>/dev/null)
    echo "${ip:-未获取到}" | tr -d '\r\n'
}

# 终端输出颜色
Font_Red="\033[31m"
Font_Green="\033[32m"
Font_Yellow="\033[33m"
Font_Suffix="\033[0m"

# 3. 初始化数据
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
IP4_ADDR=$(get_public_ip 4)
IP6_ADDR=$(get_public_ip 6)

# 构建消息头部
echo " 服务器: ${SERVER_NAME:-未命名}"
echo " IPv4: ${IP4_ADDR}"
echo " IPv6: ${IP6_ADDR}"
echo "----------"

PUSH_MESSAGE="🚀 YouTube 监测报告\n"
PUSH_MESSAGE="${PUSH_MESSAGE}服务器: ${SERVER_NAME:-未命名}\n"
PUSH_MESSAGE="${PUSH_MESSAGE}IPv4: ${IP4_ADDR}\n"
PUSH_MESSAGE="${PUSH_MESSAGE}IPv6: ${IP6_ADDR}\n"
PUSH_MESSAGE="${PUSH_MESSAGE}----------\n"

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
    echo -e "${type}: ${res_color}"
    PUSH_MESSAGE="${PUSH_MESSAGE}${type}: ${res_plain}\n"
}

check_region "4"
check_region "6"
echo "----------"

# 4. 推送逻辑
if [ -n "$TG_BOT_TOKEN" ] && [ -n "$TG_CHAT_ID" ]; then
    curl -s -o /dev/null -X POST "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TG_CHAT_ID}" \
        -d "text=$(echo -e "$PUSH_MESSAGE")"
fi

if [ -n "$WECHAT_WEBHOOK" ]; then
    curl -s -o /dev/null -X POST "$WECHAT_WEBHOOK" \
        -H 'Content-Type: application/json' \
        -d "{ \"msgtype\": \"text\", \"text\": { \"content\": \"$(echo -e "$PUSH_MESSAGE")\" } }"
fi

echo "监测完成，已尝试发送报告。"
EOF

# 2. 设置权限
chmod +x ip_check.sh

# 3. 初始化空白 .env (如果不存在)
if [ ! -f .env ]; then
    cat << EOF > .env
SERVER_NAME="未命名服务器"
TG_BOT_TOKEN=""
TG_CHAT_ID=""
WECHAT_WEBHOOK=""
EOF
    echo -e "\033[33m[!] 已生成空白 .env，请编辑配置。\033[0m"
else
    echo -e "\033[32m[*] 检测到已有 .env，保持原配置。\033[0m"
fi

echo -e "\033[32m[+] ip_check.sh 部署/更新成功！\033[0m"
