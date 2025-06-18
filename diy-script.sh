#!/bin/bash






### ========== 1. 添加 feed 源 ==========
echo 'src-git kiddin9 https://github.com/kiddin9/kwrt-packages.git' >>feeds.conf.default
# echo 'src-git smpackage https://github.com/kenzok8/small-package.git' >>feeds.conf.default

# echo 'src-git package https://github.com/yufanpin/package.git' >>feeds.conf.default





# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}



### ========== 2. 添加额外插件 ==========
# git clone --depth=1 https://github.com/lwb1978/openwrt-gecoosac.git package/openwrt-gecoosac                          #集客ac控制器
git clone --depth=1 https://github.com/selfcan/luci-app-onliner.git package/luci-app-onliner                          #显示上线用户
# git clone --depth=1 https://github.com/sirpdboy/luci-app-partexp.git package/luci-app-partexp                         #格式化分区
# git clone --depth=1 https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter                               #应用过滤，防沉迷插件
git clone --depth=1 https://github.com/sirpdboy/luci-app-advancedplus.git package/luci-app-advancedplus               #kucat主题设置
git clone --depth=1 https://github.com/ending7495/luci-theme-kucat.git package/luci-theme-kucat                       #kucat主题
# git clone --depth=1 https://github.com/sirpdboy/luci-app-lucky.git package/lucky                                      #lucky大吉，内网穿透插件
# git clone --depth=1 https://github.com/sirpdboy/luci-app-watchdog package/watchdog                                    #监控登录次数，超过次数就拉黑IP
# git clone --depth=1 https://github.com/sirpdboy/luci-app-wizard package/luci-app-wizard                               #设置向导，可以一键修改IP地址等
git clone --depth=1 https://github.com/sirpdboy/luci-app-taskplan package/luci-app-taskplan                           #定时清理内存、重启、关机等操作等，还有多wan短线重连等


# 修复golang工具不存在问题，这里直接用helloword的golang
echo 'src-git helloworld https://github.com/fw876/helloworld.git' >>feeds.conf.default
./scripts/feeds update helloworld
./scripts/feeds install golang




# # #添加一个turboacc，仅支持fw4
# # ### ========== 额外：拉取 turboacc（不启用 SFE） ==========
# echo "[INFO] 拉取 luci-app-turboacc (禁用 SFE)"
# curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh
# bash add_turboacc.sh --no-sfe





### ========== 3. 修改默认 IP、主机名、界面信息等 ==========
# 修改默认 IP 地址
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 修改默认主机名
sed -i "s/hostname='.*'/hostname='HOMR'/g" package/base-files/files/bin/config_generate

# 添加 LuCI 状态页的构建信息  这行代码有问题，版本号会跟固件内核版本号对应不上
# sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ Build by Superman')/g" feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js

# TTYD 免登录
# sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 修改本地时间格式显示
# sed -i 's/os.date()/os.date("%a %Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/*/index.htm

# 修改版本号为编译日期 + 自定义名
# date_version=$(date +"%y.%m.%d")
# orig_version=$(grep "DISTRIB_REVISION=" package/lean/default-settings/files/zzz-default-settings | awk -F "'" '{print $2}')
# sed -i "s/${orig_version}/R${date_version} by Superman/g" package/lean/default-settings/files/zzz-default-settings


### ========== 4. 修复兼容问题 ==========
# 修复 hostapd 报错
# cp -f $GITHUB_WORKSPACE/scripts/011-fix-mbo-modules-build.patch package/network/services/hostapd/patches/011-fix-mbo-modules-build.patch

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





