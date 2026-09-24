# ghidra-chinese flatpak 打包

参考 [flathub/org.ghidra_sre.Ghidra](https://github.com/flathub/org.ghidra_sre.Ghidra) 简化而来。

## 结构

```
.github/workflows/flatpak-build.yml   # GitHub Actions: push 到 chinese 分支自动构建+发Release
flatpak/io.github.TC999.ghidra_chinese.yaml    # Flatpak manifest
flatpak/io.github.TC999.ghidra_chinese.desktop # 桌面入口
build-flatpak.sh                      # 本地构建（与 CI 完全一致入口）
```

## 顶层 manifest 引用的 patch/模板文件

如 manifest 里引用的外部 patch 文件（`icoutils-gcc15.patch`）需随仓库携带，请到 flathub 对应 repo 仓库下载同 patch 文件放 `flatpak/` 目录。当前 manifest 把该 patch path 设为 `flatpak/icoutils-gcc15.patch`；提交时需要一并添加。

## 本地构建

```bash
./build-flatpak.sh              # 仅构建
./build-flatpak.sh --install   # 构建并本地装 + 试运行
```

## CI 自动化

push 到 `chinese` 分支或手动触发。`workflow_dispatch.inputs.publish_release=true` 会在 Release 附加 `io.github.TC999.ghidra_chinese-<sha>.flatpak`。

## 与 flathub 官方 manifest 的差异

1. **App ID**：`io.github.TC999.ghidra_chinese`（GitHub 反向域名；`org.ghidra_sre.Ghidra` 已被原版占用）
2. **主源**：`type: git · branch: chinese`，直接使用本仓库（汉化版）源码
3. **依赖策略**：两阶段：
   - 阶段 1（宿主联网）：`gradle -I gradle/support/fetchDependencies.gradle` 拉好 `dependencies/`、`flatRepo/`
   - 阶段 2（沙盒离线）：flatpak-builder 只做编译
   - 上游 fetchDependencies.gradle 更新版本号时无需像 flathub 那样手工重新生成钉死 sha256 的 gradle-*.json
4. **icoutils** / **z3** / **dex2jar** / **dbgmodel.tlb**：照搬 flathub 官方做法与 sha256 锁版本
5. **省略** 了 flathub 的 `remove-maven-repo.patch`（fork 阶段保持联网拉依赖灵活；若构建报漏依赖再补）

## 已知风险（首次跑 CI 必调一次正常）

- `launch.properties` mv/ln 与 `ghidraRun` 的 `sed 's,bg,fg,'` 需与汉化分支现状复核
- `build/dist/ghidra_*_linux_*.zip` 的命名通配
- flatpak 版本要求 ⩾ 1.4（25.08 runtime + openjdk21 extension）
