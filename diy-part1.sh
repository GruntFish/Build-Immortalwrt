#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# Uncomment a feed source
# echo 'src-git full https://github.com/immortalwrt/packages.git;openwrt-23.05' >> feeds.conf.default
# echo 'src-git luci https://github.com/immortalwrt/luci.git;openwrt-23.05' >> feeds.conf.default

# 添加自定义 feeds（必须在 Update feeds 前）
sed -i '1i src-git GPackages https://github.com/GruntFish/GPackages.git;Packages' feeds.conf.default

echo ">>> diy-part1.sh 开始"

# ============================================================
# 1. dnsmasq 不读运营商解析文件
#    路径: package/network/services/dnsmasq/files/dhcp.conf
#    动作: 删掉 option resolvfile，加上 option noresolv 1
# ============================================================
DNSMASQ_CONF="package/network/services/dnsmasq/files/dhcp.conf"
if [ -f "$DNSMASQ_CONF" ]; then
    echo ">>> 修改 $DNSMASQ_CONF"
    sed -i '/^\s*option resolvfile\s/d' "$DNSMASQ_CONF"
    sed -i '/^\s*option noresolv\s/d' "$DNSMASQ_CONF"
    sed -i '/^config dnsmasq$/a\\toption noresolv\t1' "$DNSMASQ_CONF"
    echo ">>> 修改后关键行："
    grep -E "noresolv|resolvfile" "$DNSMASQ_CONF" || echo "（无 resolvfile，有 noresolv）"
else
    echo ">>> 警告: 未找到 $DNSMASQ_CONF"
fi

# ============================================================
# 2. turboacc：清空 revert_dns，防止它把 noresolv 改回 0
#    路径: package/emortal/luci-app-turboacc-mtk/root/etc/init.d/turboacc
# ============================================================
TC_FILE="package/emortal/luci-app-turboacc-mtk/root/etc/init.d/turboacc"
if [ -f "$TC_FILE" ]; then
    echo ">>> 修改 turboacc: $TC_FILE"
    sed -i '/^revert_dns() {/,/^}/c\
revert_dns() {\
    return 0\
}' "$TC_FILE"
    echo ">>> 修改后 revert_dns 内容："
    sed -n '/^revert_dns() {/,/^}/p' "$TC_FILE"
else
    echo ">>> 警告: 未找到 $TC_FILE"
fi

# ============================================================
# 3. dnsmasq 过滤 IPv6 DNS 解析（不返回 AAAA 记录）
#    路径: package/network/services/dnsmasq/files/dhcp.conf
#    动作: 在 config dnsmasq 下加 option filter_aaaa 1
# ============================================================
if [ -f "$DNSMASQ_CONF" ]; then
    echo ">>> 修改 $DNSMASQ_CONF: 添加 filter_aaaa"
    sed -i '/^\s*option filter_aaaa\s/d' "$DNSMASQ_CONF"
    sed -i '/^config dnsmasq$/a\\toption filter_aaaa\t1' "$DNSMASQ_CONF"
    echo ">>> 修改后关键行："
    grep -E "noresolv|resolvfile|filter_aaaa" "$DNSMASQ_CONF" || echo "（未找到关键行）"
else
    echo ">>> 警告: 未找到 $DNSMASQ_CONF"
fi

echo ">>> diy-part1.sh 完成"
