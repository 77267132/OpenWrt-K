#!/bin/bash
config=$1
openwrt_tag_branch=$(sed -n '/openwrt_tag\/branch/p' $GITHUB_WORKSPACE/config/"$config"/OpenWrt-Z/compile.config | sed -e 's/.*=//')
sed -i 's/^  DEPENDS:= +kmod-crypto-manager +kmod-crypto-pcbc +kmod-crypto-fcrypt$/  DEPENDS:= +kmod-crypto-manager +kmod-crypto-pcbc +kmod-crypto-fcrypt +kmod-udptunnel4 +kmod-udptunnel6/' package/kernel/linux/modules/netsupport.mk #https://github.com/openwrt/openwrt/commit/ecc53240945c95bc77663b79ccae6e2bd046c9c8
sed -i 's/^	dnsmasq \\$/	dnsmasq-full \\/g' ./include/target.mk
sed -i 's/^	b43-fwsquash.py "$(CONFIG_B43_FW_SQUASH_PHYTYPES)" "$(CONFIG_B43_FW_SQUASH_COREREVS)"/	$(TOPDIR)\/tools\/b43-tools\/files\/b43-fwsquash.py "$(CONFIG_B43_FW_SQUASH_PHYTYPES)" "$(CONFIG_B43_FW_SQUASH_COREREVS)"/' ./package/kernel/mac80211/broadcom.mk
# https://github.com/openwrt/packages/pull/22251
if [[ "$openwrt_tag_branch" == "v23.05.0-rc4" ]] ; then
  if grep -q "^define Package/prometheus-node-exporter-lua-bmx6$" "feeds/packages/utils/prometheus-node-exporter-lua/Makefile"; then
    echo "修复https://github.com/openwrt/packages/pull/22251"
    curl -s -L --retry 6 https://github.com/openwrt/packages/commit/361b360d2bbf7abe93241f6eaa12320d8d83475a.patch  | patch -p1 -d feeds/packages 2>/dev/null
  fi
fi
if [[ "$openwrt_tag_branch" == "v23.05.2" ]] ; then
  if grep -q "^GO_VERSION_MAJOR_MINOR:=1.21$" "feeds/packages/lang/golang/golang/Makefile" && grep -q "^GO_VERSION_PATCH:=3$" "feeds/packages/lang/golang/golang/Makefile"; then
    echo "更新golang"
    curl -s -L --retry 6 https://github.com/openwrt/packages/commit/413260559e7b830dedb47919f2b9e428cf11eb78.patch  | patch -p1 -d feeds/packages 2>/dev/null
  fi
fi
