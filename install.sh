#!/bin/bash

# complaint-order 技能自动安装脚本
# 支持终端输入账号密码 + 自动配置 + 自动装依赖

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}=== complaint-order 技能 自动安装 ===${NC}"
echo ""

# 路径定义
HOME_DIR="$HOME"
OPENCLAW_DIR="$HOME_DIR/.openclaw"
SKILLS_DIR="$OPENCLAW_DIR/workspace/skills"
TARGET_DIR="$SKILLS_DIR/complaint-order"
TEMP_DIR="/tmp/complaint-order"

# [1/5] 检查 OpenClaw
echo -e "${YELLOW}[1/5] 检查 OpenClaw...${NC}"
if [ ! -d "$SKILLS_DIR" ]; then
    echo -e "${RED}错误：未找到 OpenClaw，请先安装主程序！${NC}"
    exit 1
fi
echo -e "${GREEN}[OK]${NC}"
echo ""

# [2/5] 备份旧版本
if [ -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}[2/5] 备份旧版本...${NC}"
    BACKUP="$TARGET_DIR-backup-$(date +%Y%m%d-%H%M%S)"
    mv "$TARGET_DIR" "$BACKUP"
    echo -e "${GREEN}[OK] $BACKUP${NC}"
    echo ""
fi

# [3/5] 下载技能
echo -e "${YELLOW}[3/5] 下载技能中...${NC}"
rm -rf "$TEMP_DIR"
curl -fsSL "https://github.com/duheng-ai/complaint-order/archive/refs/heads/main.zip" -o "$TEMP_DIR.zip"
if [ $? -ne 0 ]; then
    echo -e "${RED}下载失败，请检查网络连接${NC}"
    exit 1
fi

# 解压
unzip -q "$TEMP_DIR.zip" -d "$TEMP_DIR"
mv "$TEMP_DIR/complaint-order-main"/* "$TEMP_DIR/"
rm -rf "$TEMP_DIR/complaint-order-main"
rm "$TEMP_DIR.zip"
echo -e "${GREEN}[OK]${NC}"
echo ""

# [4/5] 配置账号密码
echo -e "${YELLOW}[4/5] 配置账号密码${NC}"
echo ""
read -p "请输入登录手机号：" PHONE
read -sp "请输入登录密码：" PASSWORD
echo ""
echo ""

# 修改 index.js
INDEX_FILE="$TEMP_DIR/index.js"
if [ -f "$INDEX_FILE" ]; then
    # 使用 sed 替换账号密码
    sed -i.bak "s/phone: \".*\"/phone: \"$PHONE\"/" "$INDEX_FILE"
    sed -i.bak "s/password: \".*\"/password: \"$PASSWORD\"/" "$INDEX_FILE"
    rm "$INDEX_FILE.bak"
    echo -e "${GREEN}✅ 账号已自动配置完成${NC}"
    echo ""
else
    echo -e "${RED}⚠️  未找到 index.js，跳过配置${NC}"
    echo ""
fi

# [5/5] 移动到目标目录并安装依赖
echo -e "${YELLOW}[5/5] 安装技能到 OpenClaw...${NC}"
mkdir -p "$SKILLS_DIR"
mv "$TEMP_DIR" "$TARGET_DIR"
echo -e "${GREEN}[OK] $TARGET_DIR${NC}"
echo ""

# 安装依赖
echo -e "${YELLOW}正在安装 npm 依赖...${NC}"
cd "$TARGET_DIR"
npm install
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  npm install 失败，请手动执行：cd '$TARGET_DIR' && npm install${NC}"
else
    echo -e "${GREEN}[OK]${NC}"
fi
echo ""

# 完成
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  安装完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${CYAN}📁 路径：$TARGET_DIR${NC}"
echo -e "${CYAN}📱 手机号：$PHONE${NC}"
echo ""
echo -e "${YELLOW}请重启 OpenClaw 网关：${NC}"
echo -e "${NC}  openclaw gateway restart${NC}"
echo ""
