#!/bin/bash
# ==========================================
# Universal DNS Changer for Linux
# Support: Debian/Ubuntu/CentOS/Alpine/Fedora
# DNS: 8.8.8.8, 1.1.1.1
# ==========================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
SKYBLUE='\033[0;36m'
PLAIN='\033[0m'

# 1. 检查 Root 权限
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}Error: You must be root to run this script.${PLAIN}"
   exit 1
fi

echo -e "${SKYBLUE}Checking current DNS configuration...${PLAIN}"

# ==========================================
# 2. [新增功能] 检测是否已经配置过 8.8.8.8
# ==========================================
IS_RESOLVED_ACTIVE=false
if systemctl is-active --quiet systemd-resolved; then
    IS_RESOLVED_ACTIVE=true
fi

# 如果是 systemd-resolved 系统，检查它的主配置文件
if [ "$IS_RESOLVED_ACTIVE" = true ]; then
    if grep -q "DNS=8.8.8.8" /etc/systemd/resolved.conf; then
        echo -e "${GREEN}Detected: systemd-resolved is already configured with 8.8.8.8.${PLAIN}"
        echo -e "${GREEN}Skipping DNS modification.${PLAIN}"
        exit 0
    fi
# 如果是传统系统，检查 resolv.conf
else
    # 检查 resolv.conf 是否包含 8.8.8.8 (忽略注释行)
    if grep -v '^#' /etc/resolv.conf | grep -q "8.8.8.8"; then
        echo -e "${GREEN}Detected: /etc/resolv.conf already contains 8.8.8.8.${PLAIN}"
        echo -e "${GREEN}Skipping DNS modification.${PLAIN}"
        exit 0
    fi
fi

# ==========================================
# 3. 开始修改 DNS
# ==========================================
echo -e "${YELLOW}Starting DNS configuration...${PLAIN}"

if [ "$IS_RESOLVED_ACTIVE" = true ]; then
    echo -e "${GREEN}System type: systemd-resolved${PLAIN}"
    
    # 备份
    cp /etc/systemd/resolved.conf /etc/systemd/resolved.conf.bak.$(date +%s) 2>/dev/null
    
    # 写入配置 (使用 Global 模式 + 强制优先级)
    cat > /etc/systemd/resolved.conf <<EOF
[Resolve]
DNS=8.8.8.8 1.1.1.1
Domains=~.
#FallbackDNS=
#MulticastDNS=yes
#DNSSEC=no
#DNSOverTLS=no
EOF
    # 重启服务
    systemctl restart systemd-resolved
    echo -e "${GREEN}DNS updated via systemd-resolved.${PLAIN}"

else
    echo -e "${GREEN}System type: Legacy /etc/resolv.conf${PLAIN}"
    
    RESOLV_CONF="/etc/resolv.conf"
    
    # 解锁文件 (如果之前被锁定了)
    if lsattr "$RESOLV_CONF" 2>/dev/null | grep -q "i"; then
        chattr -i "$RESOLV_CONF"
    fi
    
    # 备份
    cp "$RESOLV_CONF" "${RESOLV_CONF}.bak.$(date +%s)" 2>/dev/null
    
    # 写入文件
    rm -f "$RESOLV_CONF"
    cat > "$RESOLV_CONF" <<EOF
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

    # 锁定文件 (防止 DHCP 自动覆盖)
    if command -v chattr >/dev/null 2>&1; then
        chattr +i "$RESOLV_CONF"
        echo -e "${GREEN}File /etc/resolv.conf is now immutable (locked).${PLAIN}"
    else
        echo -e "${YELLOW}Warning: chattr command not found.${PLAIN}"
    fi
fi

# 4. 验证结果
echo -e "${YELLOW}Verifying connectivity...${PLAIN}"
if ping -c 1 -W 2 google.com >/dev/null 2>&1; then
    echo -e "${GREEN}Success! Network is reachable.${PLAIN}"
else
    echo -e "${RED}Warning: Network check failed, but DNS settings are applied.${PLAIN}"
fi

echo -e "-------------------------------------"
cat /etc/resolv.conf
echo -e "-------------------------------------"