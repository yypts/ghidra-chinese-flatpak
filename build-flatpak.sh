#!/usr/bin/env bash
# build-flatpak.sh — ghidra-chinese 本地 Flatpak 构建脚本
# 用法: ./build-flatpak.sh [--install]
# 依赖: flatpak, flatpak-builder, git
set -euo pipefail

APP_ID=io.github.TC999.ghidra_chinese
MANIFEST=flatpak/${APP_ID}.yaml
REPO_DIR=_repo
BUILD_DIR=_build

# 1) 一次性准备运行时与 SDK（已装可跳过）
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install --if-not-exists --user flathub \
    org.freedesktop.Sdk//25.08 \
    org.freedesktop.Platform//25.08 \
    org.freedesktop.Sdk.Extension.openjdk21//25.08

# 2) 构建
rm -rf "${BUILD_DIR}" ; mkdir -p "${BUILD_DIR}"
rm -rf "${REPO_DIR}"  ; mkdir -p "${REPO_DIR}"
flatpak-builder --force-clean --ccache --default-branch=stable \
    "${BUILD_DIR}" "${MANIFEST}" --repo="${REPO_DIR}"

# 3) 生成单文件 .flatpak 包
flatpak build-bundle "${REPO_DIR}" "${APP_ID}.flatpak" "${APP_ID}" stable
echo "产物: ${APP_ID}.flatpak"

# 4) 可选: 本地安装测试
if [[ "${1:-}" == "--install" ]]; then
    flatpak install --user --relocal ./ "${APP_ID}" || \
    flatpak install --user "${REPO_DIR}" "${APP_ID}"
    flatpak run "${APP_ID}"
fi
