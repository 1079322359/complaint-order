#!/bin/bash
set -e

# 颜色输出
green() { echo -e "\033[32m$1\033[0m"; }
yellow() { echo -e "\033[33m$1\033[0m"; }
blue() { echo -e "\033[34m$1\033[0m"; }
red() { echo -e "\033[31m$1\033[0m"; }

# 技能固定安装目录
SKILL_DIR="$HOME/.openclaw/skills/complaint-order"
REPO_URL="https://github.com/你的用户名/你的仓库名.git"

# 欢迎信息
green "========================================"
green "   通道投诉订单查询技能 - 一键安装"
green "========================================"

# 1. 检查依赖
blue "\n[1/5] 检查依赖..."
if ! command -v git &> /dev/null; then
    red "错误：请先安装 git"
    exit 1
fi
if ! command -v node &> /dev/null; then
    red "错误：请先安装 Node.js 14+"
    exit 1
fi
green "✅ 依赖检查通过"

# 2. 克隆/更新代码
blue "\n[2/5] 拉取技能代码..."
if [ -d "$SKILL_DIR" ]; then
    yellow "目录已存在，执行更新..."
    cd "$SKILL_DIR"
    git pull
else
    git clone "$REPO_URL" "$SKILL_DIR"
fi
green "✅ 代码拉取完成"

# 3. 安装依赖
blue "\n[3/5] 安装依赖包..."
cd "$SKILL_DIR"
npm install --production
green "✅ 依赖安装完成"

# 4. 交互式配置引导（核心！）
blue "\n[4/5] 配置账号信息（火脸运营后台）..."
read -p "请输入您的火脸后台手机号: " PHONE
read -s -p "请输入您的火脸后台密码: " PWD
echo -e ""

# 自动写入配置到 index.js
sed -i "s/phone: \".*\"/phone: \"$PHONE\"/" "$SKILL_DIR/index.js"
sed -i "s/password: \".*\"/password: \"$PWD\"/" "$SKILL_DIR/index.js"

green "✅ 配置已自动写入"

# 5. 完成
blue "\n[5/5] 安装完成！"
yellow "\n使用方法：在 OpenClaw 发送投诉内容即可自动查询"
yellow "测试命令：cd $SKILL_DIR && node run.js"
green "\n🎉 技能安装成功！"
