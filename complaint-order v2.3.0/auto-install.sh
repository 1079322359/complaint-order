#!/bin/bash
set -e  # 出错立即退出

# ===================== 核心配置=====================
REPO_URL="https://github.com/duheng-ai/complaint-order.git"  # 
TARGET_DIR="/opt/complaint-order"                        # 代码要部署的目录
# ==================================================================

# 颜色输出（优化体验）
green() { echo -e "\033[32m$1\033[0m"; }
yellow() { echo -e "\033[33m$1\033[0m"; }
red() { echo -e "\033[31m$1\033[0m"; }

# 1. 检查依赖（git、npm 必须有）
check_deps() {
    green "=== 检查基础依赖 ==="
    local deps=("git" "npm")
    for dep in "${deps[@]}"; do
        if ! command -v $dep &>/dev/null; then
            red "错误：未安装 $dep，请先安装！"
            exit 1
        fi
    done
    green "✅ 依赖检查通过"
}

# 2. 拉取/更新仓库代码
pull_code() {
    green "=== 拉取投诉订单技能代码 ==="
    if [ -d "$TARGET_DIR" ]; then
        yellow "检测到已有代码目录，执行更新..."
        cd "$TARGET_DIR" && git pull
    else
        yellow "首次安装，克隆代码仓库..."
        git clone "$REPO_URL" "$TARGET_DIR"
    fi
    green "✅ 代码拉取完成"
}

# 3. 执行原有的配置逻辑（复用你原来的 install.sh 逻辑）
config_account() {
    green "=== 配置平台账号信息 ==="
    cd "$TARGET_DIR/complaint-order v2.3.0"  # 进入你原来的 install.sh 所在目录

    # 安装依赖（复用原逻辑）
    echo "🔧 安装依赖中..."
    npm i --silent

    # 读取账号密码（复用原逻辑）
    echo ""
    read -p "手机号： " phone
    read -s -p "密码： " password
    echo ""

    # 写入配置（复用原逻辑）
    sed -i.bak "s|phone:.*|phone: \"$phone\",|g" index.js
    sed -i.bak "s|password:.*|password: \"$password\",|g" index.js
    rm -f index.js.bak

    green "✅ 账号配置完成！"
    yellow "🔁 正在重启 OpenClaw 网关..."
    openclaw gateway restart

    green "🎉 技能安装完成，可以正常使用！"
}

# 主流程
main() {
    echo ""
    echo "====================================="
    echo "    投诉订单技能 一键安装配置向导"
    echo "====================================="
    echo ""
    check_deps
    pull_code
    config_account
}

# 执行主流程
main
