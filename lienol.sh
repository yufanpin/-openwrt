#!/bin/bash

### ========== 1. 添加 feed 源 ==========
echo 'src-git kiddin9 https://github.com/kiddin9/kwrt-packages.git' >>feeds.conf.default

# echo 'src-git smpackage https://github.com/kenzok8/small-package.git' >>feeds.conf.default

# echo 'src-git package https://github.com/yufanpin/package.git' >>feeds.conf.default



### ========== 2. 添加额外插件 ==========
# git clone --depth=1 https://github.com/lwb1978/openwrt-gecoosac.git package/openwrt-gecoosac                          #集客ac控制器
# git clone --depth=1 https://github.com/selfcan/luci-app-onliner.git package/luci-app-onliner                          #显示上线用户
# git clone --depth=1 https://github.com/sirpdboy/luci-app-partexp.git package/luci-app-partexp                         #格式化分区
# git clone --depth=1 https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter                               #应用过滤，防沉迷插件
# git clone --depth=1 https://github.com/sirpdboy/luci-app-advancedplus.git package/luci-app-advancedplus               #kucat主题设置
# git clone --depth=1 https://github.com/ending7495/luci-theme-kucat.git package/luci-theme-kucat                       #kucat主题
# git clone --depth=1 https://github.com/sirpdboy/luci-app-lucky.git package/lucky                                      #lucky大吉，内网穿透插件
# git clone --depth=1 https://github.com/sirpdboy/luci-app-watchdog package/watchdog                                    #监控登录次数，超过次数就拉黑IP
# git clone --depth=1 https://github.com/sirpdboy/luci-app-wizard package/luci-app-wizard                               #设置向导，可以一键修改IP地址等
# git clone --depth=1 https://github.com/sirpdboy/luci-app-taskplan package/luci-app-taskplan                           #定时清理内存、重启、关机等操作等，还有多wan短线重连等
# git clone --depth=1 https://github.com/yufanpin/luci-theme-design.git package/luci-theme-design                       #design主题，js版本
# git clone --depth=1 https://github.com/yufanpin/luci-app-design-config.git package/luci-app-design-config             #design设置界面





### ========== 3. 修改默认 IP、主机名、界面信息等 ==========
# 修改默认 IP 地址
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 修改默认主机名
sed -i "s/hostname='.*'/hostname='HOMR'/g" package/base-files/files/bin/config_generate

### ========== 4. 修复兼容问题 ==========
# 修复 armv8 平台 xfsprogs 报错
sed -i 's/TARGET_CFLAGS.*/TARGET_CFLAGS += -DHAVE_MAP_SYNC -D_LARGEFILE64_SOURCE/g' feeds/packages/utils/xfsprogs/Makefile

### ========== 5. 统一修正 Makefile 引用路径 ==========
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's|\.\./\.\./luci.mk|$(TOPDIR)/feeds/luci/luci.mk|g' {}
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's|\.\./\.\./lang/golang/golang-package.mk|$(TOPDIR)/feeds/packages/lang/golang/golang-package.mk|g' {}
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's|PKG_SOURCE_URL:=@GHREPO|PKG_SOURCE_URL:=https://github.com|g' {}
# find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's|PKG_SOURCE_URL:=@GHCODELOAD|PKG_SOURCE_URL:=https://codeload.github.com|g' {}

### ========== 6. 拉取 feeds ==========
./scripts/feeds update -a
./scripts/feeds install -a

