#!/bin/bash
set -e

# ===================== 核心配置 =====================
REPO_URL="https://github.com/duheng-ai/complaint-order.git"
SKILL_DIR="$HOME/.openclaw/skills/complaint-order"
# ====================================================

green() { echo -e "\033[32m$1\033[0m"; }
yellow() { echo -e "\033[33m$1\033[0m"; }
red() { echo -e "\033[31m$1\033[0m"; }

check_deps() {
    green "=== 检查依赖 ==="
    if ! command -v git &> /dev/null; then red "请安装 git"; exit 1; fi
    if ! command -v node &> /dev/null; then red "请安装 Node.js"; exit 1; fi
    green "✅ 依赖检查通过"
}

pull_code() {
    green "=== 拉取代码 ==="
    mkdir -p "$SKILL_DIR"
    cd "$SKILL_DIR"
    if [ -d .git ]; then
        git pull
    else
        git clone "$REPO_URL" .
    fi
    green "✅ 代码拉取完成"
}

config_account() {
    green "=== 配置账号 ==="
    cd "$SKILL_DIR/complaint-order v2.3.0"

    npm i --silent

    echo ""
    read -p "手机号： " phone
    read -s -p "密码： " password
    echo ""

    # 兼容 Windows + Linux sed
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OS" == "Windows_NT" ]]; then
        sed -i "s|phone:.*|phone: \"$phone\",|g" index.js
        sed -i "s|password:.*|password: \"$password\",|g" index.js
    else
        sed -i.bak "s|phone:.*|phone: \"$phone\",|g" index.js
        sed -i.bak "s|password:.*|password: \"$password\",|g" index.js
        rm -f index.js.bak
    fi

    green "✅ 配置成功！"
    yellow "🔁 重启网关中..."
    openclaw gateway restart 2>/dev/null || true
}

main() {
    echo ""
    echo "====================================="
    echo "    投诉订单技能 - 一键安装"
    echo "        支持 Windows / Linux / Mac"
    echo "====================================="
    echo ""
    check_deps
    pull_code
    config_account
    green "🎉 安装完成！"
}

main
