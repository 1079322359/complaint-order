#!/bin/bash
cd "$(dirname "$0")"

echo ""
echo "====================================="
echo "    投诉订单技能 安装配置向导"
echo "====================================="
echo ""

# 安装依赖
echo "🔧 安装依赖中..."
npm i --silent

echo ""
echo "请输入你的平台账号信息"
read -p "手机号： " phone
read -s -p "密码： " password
echo ""

# 自动写入配置
sed -i.bak "s|phone:.*|phone: \"$phone\",|g" index.js
sed -i.bak "s|password:.*|password: \"$password\",|g" index.js
rm -f index.js.bak

echo "✅ 账号配置完成！"
echo "🔁 正在重启 OpenClaw 网关..."
openclaw gateway restart

echo ""
echo "🎉 技能安装完成，可以正常使用！"
echo ""
