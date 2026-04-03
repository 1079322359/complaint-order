#!/bin/bash
set -e

# ======================== 配置项 ========================
PROJECT_NAME="complaint-order"
NODE_VERSION_REQUIRED="14.0.0"
INSTALL_DIR="$HOME/.openclaw/skills/${PROJECT_NAME}"
# ========================================================

# 颜色输出
red() { echo -e "\033[31m$1\033[0m"; }
green() { echo -e "\033[32m$1\033[0m"; }
yellow() { echo -e "\033[33m$1\033[0m"; }
blue() { echo -e "\033[34m$1\033[0m"; }

clear
green "========================================"
green "     ${PROJECT_NAME} 自动安装配置脚本"
green "========================================"
echo ""

# 检查 Node.js
check_node() {
  blue "🔍 检查 Node.js 环境..."
  if ! command -v node &> /dev/null; then
    red "❌ 未安装 Node.js，请安装 v14.0.0 以上版本"
    exit 1
  fi
  green "✅ Node.js 环境正常"
}

# 安装依赖
install_deps() {
  blue "📦 安装项目依赖..."
  cd "$INSTALL_DIR" || exit 1
  npm install axios@^1.6.0 --registry=https://registry.npmmirror.com --silent
  green "✅ 依赖安装完成"
  echo ""
}

# 自动配置账号密码
auto_config() {
  blue "⚙️  自动配置账号密码"
  echo ""

  read -p "请输入运营后台手机号： " PHONE
  read -s -p "请输入运营后台密码： " PASSWORD
  echo ""

  sed -i.bak "s|phone:.*\".*\"|phone: \"$PHONE\"|g" index.js
  sed -i.bak "s|password:.*\".*\"|password: \"$PASSWORD\"|g" index.js
  rm -f index.js.bak

  green "✅ 账号密码已自动写入 index.js"
  echo ""
}

# 重启网关
restart_gateway() {
  blue "🔁 重启 OpenClaw 网关..."
  openclaw gateway restart
  green "✅ 网关重启完成"
  echo ""
}

# 完成提示
finish() {
  green "🎉 安装配置全部完成！"
  yellow "测试命令："
  echo "cd $INSTALL_DIR"
  echo "node run.js \"订单号：1026081200001329\""
  echo ""
}

# 主流程
main() {
  check_node
  install_deps
  auto_config
  restart_gateway
  finish
}

main
