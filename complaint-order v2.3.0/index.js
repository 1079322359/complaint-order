// ===================== OpenClaw 标准技能 =====================
const axios = require('axios');

// ========================
// ⚙️ 配置区域（使用前请修改）
// ========================
const CONFIG = {
  // 火脸运营后台账号配置
  LOGIN: {
    phone: "您的手机号",      // ⚠️ 请修改为您的手机号
    password: "您的密码",     // ⚠️ 请修改为您的密码
    system: "operation",
    type: "password"
  },
  // API 配置
  API: {
    baseUrl: "https://api.lianok.com",
    loginEndpoint: "/common/v1/user/login",
    queryEndpoint: "/operation/v1/flow/selectByPage"
  },
  // 初始 Token（可选，会被自动刷新）
  initialToken: "ca83f4d3812f42688d6052bc4fba5d35"
};

module.exports = {
  meta: {
    id: "channelcomplaint",
    name: "通道投诉订单查询",
    description: "自动解析投诉信息，查询订单并格式化输出（401 自动刷新 token）",
    version: "2.3.0",
    author: "duheng"
  },

  triggers: {
    patterns: [/联系方式/, /投诉内容/, /订单号/]
  },

  // ========================
  // 自动登录获取新 token
  // ========================
  async getNewToken() {
    try {
      const res = await axios.post(`${CONFIG.API.baseUrl}${CONFIG.API.loginEndpoint}`, {
        password: CONFIG.LOGIN.password,
        phone: CONFIG.LOGIN.phone,
        system: CONFIG.LOGIN.system,
        type: CONFIG.LOGIN.type
      });
      return res.data?.data?.accessToken || null;
    } catch (err) {
      console.error("Token 刷新失败:", err.message);
      return null;
    }
  },

  // ========================
  // 获取订单日期（已加新规则）
  // ========================
  getOrderDate(orderNo) {
    if (!orderNo) return null;

    // 规则 1：1026084xxxxxx → 2026 第 84 天
    if (/^1026\d{3}/.test(orderNo)) {
      const year = 2026;
      const dayOfYear = parseInt(orderNo.slice(4, 7), 10);
      const date = new Date(year, 0, 1);
      date.setDate(dayOfYear);
      // 使用本地时间格式化，避免时区问题
      const ymd = date.getFullYear() + '-' + 
                  String(date.getMonth() + 1).padStart(2, '0') + '-' + 
                  String(date.getDate()).padStart(2, '0');
      return {
        queryBeginPayTime: `${ymd} 00:00:00`,
        queryEndPayTime: `${ymd} 23:59:59`
      };
    }

    // 规则 2：420000304620260325xxxx → 第 10 位后 8 位
    if (/^42000/.test(orderNo) && orderNo.length >= 18) {
      const dateStr = orderNo.slice(10, 18);
      if (/^\d{8}$/.test(dateStr)) {
        const y = dateStr.slice(0, 4);
        const m = dateStr.slice(4, 6);
        const d = dateStr.slice(6, 8);
        const ymd = `${y}-${m}-${d}`;
        return {
          queryBeginPayTime: `${ymd} 00:00:00`,
          queryEndPayTime: `${ymd} 23:59:59`
        };
      }
    }

    // 规则 3：2026040223001419901446808099 → 前 8 位是日期
    if (/^20\d{2}/.test(orderNo)) {
      const dateStr = orderNo.slice(0, 8);
      if (/^\d{8}$/.test(dateStr)) {
        const y = dateStr.slice(0, 4);
        const m = dateStr.slice(4, 6);
        const d = dateStr.slice(6, 8);
        const ymd = `${y}-${m}-${d}`;
        return {
          queryBeginPayTime: `${ymd} 00:00:00`,
          queryEndPayTime: `${ymd} 23:59:59`
        };
      }
    }

    return null;
  },

  // ========================
  // 解析消息
  // ========================
  parseMsg(text) {
    const msgList = text.trim().split(/\n\s*\n/);
    const result = [];
    for (const msg of msgList) {
      if (!msg.trim()) continue;
      const lines = msg.split('\n');
      let telephone = '无';
      let complaintContent = '无';
      let OrderNo = '无';
      for (const line of lines) {
        const trimmed = line.trim();
        if (telephone === '无') {
          const phoneMatch = trimmed.match(/用户联系方式\s*[:：]\s*(\d+)/);
          if (phoneMatch) telephone = phoneMatch[1];
        }
        if (complaintContent === '无') {
          const complaintMatch = trimmed.match(/(?:用户)?投诉内容\s*[:：]\s*(.+)/);
          if (complaintMatch) complaintContent = complaintMatch[1].trim();
        }
        if (OrderNo === '无') {
          const orderMatch = trimmed.match(/订单号\s*[:：]\s*(\d+)/);
          if (orderMatch) OrderNo = orderMatch[1];
        }
      }
      result.push({ telephone, complaintContent, OrderNo });
    }
    return result;
  },

  // ========================
  // 格式化输出（按订单号前缀判断）
  // ========================
  formatOutput(data, telephone, orderNo, complaint) {
    const { list = [] } = data || {};

    // ========================
    // 按订单号前缀判断：火脸 / 官方
    // ========================
    let orderLabel = "官方订单号";
    if (orderNo.startsWith("1026")) {
      orderLabel = "火脸订单号";
    } else if (orderNo.startsWith("42000") || /^20\d{2}/.test(orderNo)) {
      orderLabel = "官方订单号";
    }

    if (!list || list.length === 0) {
      return `所属服务商：无
消费者联系方式：${telephone}
${orderLabel}：${orderNo}
查询结果：未查询到订单信息
投诉内容：${complaint}`;
    }

    const outputs = [];
    list.forEach(order => {
      outputs.push(`所属服务商：${order.agentName || '无'}
商户 ID：${order.shopNo || '无'} 商户名称：${order.shopShortName || '无'} 存在${order.payChannelName || '无'}通道投诉
消费者联系方式：${telephone}
${orderLabel}：${orderNo}
订单金额：${order.totalAmount || '无'}
支付时间：${order.payTime || '无'}
投诉内容：${complaint}`);
    });

    return outputs.join('\n\n');
  },

  // ========================
  // 核心执行入口
  // ========================
  async execute(context) {
    const { userMessage } = context;
    const API_URL = `${CONFIG.API.baseUrl}${CONFIG.API.queryEndpoint}`;

    // ========================
    // 初始 token
    // ========================
    let accessToken = CONFIG.initialToken;

    // ========================
    // 统一请求封装 + 401 自动刷新 + 重试
    // ========================
    const request = async (url, data) => {
      try {
        return await axios({
          method: 'post',
          url: url,
          data: data,
          headers: {
            'accessToken': accessToken,
            'Content-Type': 'application/json',
            'client': 'WEB'
          }
        });
      } catch (err) {
        // 401 自动刷新 token
        if (err.response?.status === 401) {
          const newToken = await this.getNewToken();
          if (!newToken) throw new Error('登录已失效，自动刷新 token 失败');

          // 更新全局 token
          accessToken = newToken;

          // 重试请求
          return axios({
            method: 'post',
            url: url,
            data: data,
            headers: {
              'accessToken': accessToken,
              'Content-Type': 'application/json',
              'client': 'WEB'
            }
          });
        }
        throw err;
      }
    };

    // ========================
    // 查询订单（按订单号日期精准查询）
    // ========================
    const queryOrder = async (orderNo) => {
      const timeRange = this.getOrderDate(orderNo);
      if (!timeRange) return { list: [], source: "" };

      let list = [];

      try {
        // 1. orderNo 查询
        const res1 = await request(API_URL, {
          currentPage: 1, pageSize: 100, ...timeRange, orderNo
        });
        if (res1.data.code === 0 && Array.isArray(res1.data.data)) {
          list = res1.data.data;
        }

        // 2. topChannelOrderNo 查询
        if (list.length === 0) {
          const res2 = await request(API_URL, {
            currentPage: 1, pageSize: 100, ...timeRange, topChannelOrderNo: orderNo
          });
          if (res2.data.code === 0 && Array.isArray(res2.data.data)) {
            list = res2.data.data;
          }
        }

        return { list };
      } catch (err) {
        console.error("查询失败:", err.message);
        return { list: [] };
      }
    };

    // ========================
    // 执行解析 & 查询
    // ========================
    try {
      const list = this.parseMsg(userMessage);
      if (!list.length) return { text: '未解析到有效投诉信息' };

      const output = [];
      for (const item of list) {
        const { telephone, complaintContent, OrderNo } = item;
        if (OrderNo === '无') {
          output.push(`订单号为空，跳过处理 | 联系方式：${telephone}`);
          continue;
        }
        const data = await queryOrder(OrderNo);
        output.push(this.formatOutput(data, telephone, OrderNo, complaintContent));
      }

      return { text: output.join('\n') };
    } catch (err) {
      return { text: `❌ 查询失败：${err.message}` };
    }
  }
};
