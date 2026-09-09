#!/usr/bin/env bash
set -euo pipefail

IMMORTALWRT_COMMIT="3a0f609352e0b582fc670af865ad449a65b18e62"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
BUILD_ROOT="${BUILD_ROOT:-/root/immortalwrt-hlk7628}"
SOURCE_DIR="${SOURCE_DIR:-$BUILD_ROOT/source}"
CUSTOM_DIR="${CUSTOM_DIR:-$SCRIPT_DIR}"
OUTPUT_DIR="${OUTPUT_DIR:-$PROJECT_ROOT/output}"

mkdir -p "$BUILD_ROOT" "$OUTPUT_DIR"

if [ ! -d "$SOURCE_DIR/.git" ]; then
	git clone --branch openwrt-25.12 --filter=blob:none \
		https://github.com/immortalwrt/immortalwrt.git "$SOURCE_DIR"
	git -C "$SOURCE_DIR" checkout --detach "$IMMORTALWRT_COMMIT"
fi

if [ "$(git -C "$SOURCE_DIR" rev-parse HEAD)" != "$IMMORTALWRT_COMMIT" ]; then
	echo "ImmortalWrt checkout does not match $IMMORTALWRT_COMMIT" >&2
	exit 1
fi

if [ -n "${DL_CACHE_DIR:-}" ] && [ ! -e "$SOURCE_DIR/dl" ]; then
	mkdir -p "$DL_CACHE_DIR"
	ln -s "$DL_CACHE_DIR" "$SOURCE_DIR/dl"
fi

cd "$SOURCE_DIR"

if [ ! -e .feeds-hlk7628-done ]; then
	./scripts/feeds update -a
	./scripts/feeds install -a
	touch .feeds-hlk7628-done
fi

if [ ! -e .custom-hlk7628-prepared ]; then
	for patch_file in "$CUSTOM_DIR"/patches/*.patch; do
		patch --batch --forward -p1 < "$patch_file"
	done
	mkdir -p files
	cp -a "$CUSTOM_DIR/files/." files/
	chmod 0755 files/etc/init.d/board-hardware files/usr/sbin/fanctl
	touch .custom-hlk7628-prepared
fi

cp "$CUSTOM_DIR/custom.config" .config
make defconfig > "$BUILD_ROOT/defconfig.log" 2>&1

grep -q '^CONFIG_TARGET_ramips_mt76x8_DEVICE_hilink_hlk-7628n=y$' .config
grep -q '^CONFIG_PACKAGE_kmod-sdhci-mt7620=y$' .config
grep -q '^CONFIG_PACKAGE_kmod-i2c-mt7628=y$' .config
grep -q '^CONFIG_PACKAGE_kmod-gpio-pwm=y$' .config
grep -q '^CONFIG_PACKAGE_kmod-hwmon-pwmfan=y$' .config
grep -q '^CONFIG_VERSION_DIST="YANG-RouterOS"$' .config
grep -q '^CONFIG_VERSION_NUMBER="1.0.0"$' .config
grep -q '^CONFIG_VERSION_NICK="MT7628-4G-CPE"$' .config
grep -q '^CONFIG_VERSION_MANUFACTURER="YANG"$' .config
grep -q '^CONFIG_VERSION_PRODUCT="YANG-OS"$' .config
grep -q '^CONFIG_VERSION_HWREV="v1"$' .config
grep -q '^LINUX_VERSION-6.12 = .103$' target/linux/generic/kernel-6.12
grep -q 'model = "MiniLinux-CPE";' target/linux/ramips/dts/mt7628an_hilink_hlk-7628n.dts
grep -q "DISTRIB_DESCRIPTION='%D'" package/base-files/files/etc/openwrt_release
grep -q 'PRETTY_NAME="%D"' package/base-files/files/usr/lib/os-release
grep -q "hostname='YANG-RouterOS'" files/etc/uci-defaults/98-hlk7628-system

make download -j"$(nproc)" > "$BUILD_ROOT/download.log" 2>&1
BUILD_JOBS="${BUILD_JOBS:-$(nproc)}"
if ! make -j"$BUILD_JOBS" > "$BUILD_ROOT/build.log" 2>&1; then
	echo "Parallel build failed; retrying serially with verbose logging." >&2
	if ! make -j1 V=s > "$BUILD_ROOT/build-verbose.log" 2>&1; then
		tail -n 200 "$BUILD_ROOT/build-verbose.log" >&2
		exit 1
	fi
fi

TARGET_DIR="$SOURCE_DIR/bin/targets/ramips/mt76x8"
test -d "$TARGET_DIR"
cp -a "$TARGET_DIR"/. "$OUTPUT_DIR"/
cp .config "$OUTPUT_DIR/hlk7628-custom.config"
(
	cd "$OUTPUT_DIR"
	: > SHA256SUMS
	for artifact in *; do
		[ "$artifact" = SHA256SUMS ] && continue
		[ -f "$artifact" ] && sha256sum "$artifact" >> SHA256SUMS
	done
)

echo "Build complete: $OUTPUT_DIR"
