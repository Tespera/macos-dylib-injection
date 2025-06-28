# MacOS 动态库注入项目

本项目演示如何在 MacOS 应用程序中注入自定义动态库，显示弹窗消息。

## 文件结构

- `Lib.Tips.h` - 动态库头文件
- `Lib.Tips.m` - 动态库实现文件
- `build_lib_tips.sh` - 编译动态库脚本（支持通用二进制）
- `inject_lib_tips.sh` - **推荐的注入脚本（自动检测动态库文件）**
- `README.md` - 项目说明文档

## 快速开始

### 1. 编译动态库

```bash
./build_lib_tips.sh
```

脚本会自动：
- 检测当前目录中的 `.m` 源文件
- 同时编译 **x86_64** 和 **arm64** 架构
- 合并为通用二进制文件（Universal Binary）
- 根据源文件名生成对应的动态库文件名（转换为小写）
- 编译并输出到 `build/` 目录

### 2. 注入动态库（推荐方法）

```bash
# 使用环境变量方式注入（最安全）
./inject_lib_tips.sh /path/to/App.app

# 示例：注入到桌面的应用程序
./inject_lib_tips.sh /Applications/test.app
```

脚本会自动：
- 检测 `build/` 目录中的动态库文件
- 使用检测到的动态库进行注入
- 无需手动指定文件名

### 3. 测试应用程序

打开注入后的应用程序，应该会看到弹窗消息，显示实际的动态库文件名。

## 特性

### 🤖 自动化功能
- **自动源文件检测**：构建脚本自动找到 `.m` 源文件
- **自动文件命名**：根据源文件名生成动态库名
- **自动库文件检测**：注入脚本自动找到编译好的动态库
- **动态文件名显示**：弹窗显示实际的动态库文件名

### 🔧 灵活性
- 支持任意名称的源文件
- 不需要修改脚本中的硬编码文件名
- 便于项目重命名和复用

### 🏗️ 架构支持
- **通用二进制**：同时支持 Intel (x86_64) 和 Apple Silicon (arm64)
- **自动合并**：构建脚本自动创建包含两个架构的单一文件
- **兼容性强**：在任何 Mac 设备上都能正常运行

## 注入方法对比

### 🟢 环境变量注入（推荐）
**脚本：** `inject_lib_tips.sh`

**优点：**
- 最安全，不破坏原始可执行文件
- 兼容性好
- 容易恢复
- 自动检测动态库文件
- 支持所有架构（Intel + Apple Silicon）

**原理：**
通过修改应用程序的 `Info.plist` 文件，设置 `LSEnvironment` 环境变量 `DYLD_TIPS`，使系统在启动应用程序时自动加载指定的动态库。

## 故障排除

### 应用程序崩溃

如果注入后应用程序崩溃，请：

1. **恢复备份文件：**
   ```bash
   # 恢复 Info.plist（环境变量方式）
   cp "/path/to/App.app/Contents/Info.plist.backup" "/path/to/App.app/Contents/Info.plist"
   ```

2. **查看崩溃日志：**
   ```bash
   # 查看系统日志
   log show --predicate 'process == "AppName"' --last 5m
   
   # 查看崩溃报告
   ls ~/Library/Logs/DiagnosticReports/
   ```

## 调试技巧

### 1. 查看系统日志

```bash
# 实时查看日志
log stream --predicate 'category == "LibTipsLibrary"'

# 查看最近的日志
log show --predicate 'category == "LibTipsLibrary"' --last 1h
```

### 2. 环境变量调试

```bash
# 手动设置环境变量运行应用程序（使用实际的动态库文件名）
DYLD_TIPS="./build/实际文件名.dylib" /path/to/App.app/Contents/MacOS/AppName
```

## 安全注意事项

1. **仅在开发和测试环境使用**
2. **不要注入到系统关键应用程序**
3. **始终备份原始文件**
4. **注意签名和权限问题**
5. **遵守软件许可协议**

## 常见应用场景

- 应用程序功能扩展
- 调试和分析
- 安全研究（合法范围内）
- 开发工具集成
- 多项目复用
- 跨架构部署

## 系统兼容性

- **macOS 版本**：10.15+
- **处理器架构**：Intel x86_64 + Apple Silicon arm64（通用二进制）
- **开发工具**：Xcode 命令行工具
- **自动适配**：在任何 Mac 设备上都能正常编译和运行

## 许可证

本项目仅用于教育和研究目的。使用时请遵守相关法律法规和软件许可协议。
