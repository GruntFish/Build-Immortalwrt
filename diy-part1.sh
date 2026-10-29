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
