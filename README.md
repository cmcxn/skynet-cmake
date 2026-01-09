# 使用 CMake 编译 skynet

[skynet-cmake](https://github.com/hanxi/skynet-cmake) 是 [skynet](https://github.com/cloudwu/skynet) 的使用 CMake 的多平台的实现。

## 特点

- 支持在 Visual Studio 2022 中编译运行。
- skynet 以 submodule 的方式链接，方便升级，确保不改。

## 在 Windows 下

基于 [Visual Studio 2022](https://visualstudio.microsoft.com/zh-hans/downloads/) ，需要安装 CMake 和 Clang 模块。

- [安装CMake](https://learn.microsoft.com/en-us/cpp/build/cmake-projects-in-visual-studio?view=msvc-170)
- [安装Clang](https://learn.microsoft.com/en-us/cpp/build/clang-support-cmake?view=msvc-170)

### 下载工程和更新 submodule

```bash
git checkout https://github.com/hanxi/skynet-cmake.git
cd skynet-cmake
git submodule update --init --recursive
```

使用 vs2022 打开此工程目录 skynet-cmake (即CMakeLists.txt 文件所在目录）。
- 点击 [生成] -> [全部重新生成]
- 选择 skynet.exe -> 点击 [调试]

也可以执行 `build.bat` 脚本生成 `out/build/x64-debug/skynet.exe` 文件。

## 在 Linux MacOSX 下

没多大必要，直接用 make 可能更方便。

```bash
mkdir build
cd build
    Makefile:
        cmake ../
    Xcode:
        cmake -G Xcode ../
```

## 参考

- [cloudfreexiao/skynet/tree/windows](https://github.com/cloudfreexiao/skynet/tree/windows)
- [dpull/skynet-mingw](https://github.com/dpull/skynet-mingw)
- [cloudfreexiao/pluto](https://github.com/cloudfreexiao/pluto)

## GitHub Actions 自动构建和发布

本项目已配置 GitHub Actions 工作流，可以自动编译和发布多平台版本。

### 自动构建

每次推送代码或创建 Pull Request 时，会自动触发构建流程：

- **build.yml**: 在 Linux、macOS 和 Windows 三个平台上自动编译，并上传构建产物
- **msvc.yml**: 专门用于 Windows MSVC 编译测试

构建产物会作为 Artifacts 上传，可以在 GitHub Actions 页面下载。

### 发布版本

当推送标签时（如 `v1.0.0`），会自动触发发布流程：

```bash
# 创建并推送标签
git tag v1.0.0
git push origin v1.0.0
```

发布流程会：
1. 在三个平台上编译项目
2. 打包构建产物：
   - Linux 和 macOS: `.tar.gz` 格式
   - Windows: `.zip` 格式
3. 自动创建 GitHub Release 并上传打包文件

### 子模块自动拉取

所有工作流都配置了自动拉取 git 子模块：
- `skynet` - 核心框架
- `3rd/pthread-win32` - Windows 下的 pthread 实现

使用 `submodules: recursive` 选项确保所有子模块都被正确初始化和更新。


