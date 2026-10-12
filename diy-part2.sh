#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

rm -rf feeds/packages/net/adguardhome

rm -rf feeds/luci/applications/luci-app-passwall

rm -rf feeds/packages/lang/golang
git clone -b 26.x --single-branch --depth 1 https://github.com/GruntFish/packages_lang_golang feeds/packages/lang/golang


if [ -n "$ROOT_PASSWORD" ]; then
    echo "Modifying root password..."
    NEW_PASSWORD_HASH=$(openssl passwd -1 "$ROOT_PASSWORD")
    if sed -i "s|root::0:0:99999:7:::|root:${NEW_PASSWORD_HASH}:0:0:99999:7:::|" package/base-files/files/etc/shadow; then
        echo "✓ Root password modified successfully"
    else
        echo "✗ Failed to modify root password"
    fi
else
    echo "⚠ No root password provided, using default"
fi

if [ -n "$ORIGINAL_IP" ] && [ -n "$NEW_IP" ]; then
    echo "Modifying IP address from $ORIGINAL_IP to $NEW_IP..."
    if sed -i "s|$ORIGINAL_IP|$NEW_IP|g" package/base-files/files/bin/config_generate; then
        echo "✓ IP address modified successfully"
    else
        echo "✗ Failed to modify IP address"
    fi
else
    echo "⚠ IP addresses not provided, using defaults"
fi

sed -i 's|set luci.main.mediaurlbase=/luci-static/bootstrap|set luci.main.mediaurlbase=/luci-static/infinityfreedom|' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap


PATCH_FILE="target/linux/ramips/patches-5.10/322-mt7621-fix-cpu-clk-add-clkdev.patch"
if [ -f "$PATCH_FILE" ]; then
    echo "Modifying mt7621 patch file: $PATCH_FILE"
    if sed -i 's|0x2B2|0x312|' "$PATCH_FILE"; then
        echo "✓ mt7621 patch modified successfully"
    else
        echo "✗ Failed to modify mt7621 patch"
    fi
else
    echo "⚠ Patch file not found: $PATCH_FILE"
    echo "Available patch files in target/linux/ramips/patches-5.10/:"
    ls -la target/linux/ramips/patches-5.10/ 2>/dev/null || echo "Directory does not exist"
fi
