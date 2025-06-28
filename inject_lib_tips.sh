#!/bin/bash

# 使用 install_name_tool 的动态库注入脚本

if [ $# -eq 0 ]; then
    echo "使用方法: $0 /path/to/App.app"
    exit 1
fi

APP_PATH="$1"

# 自动检测动态库文件
DYLIB_FILE=$(find "$(pwd)/build" -name "*.dylib" -type f | head -n 1)
if [ -z "$DYLIB_FILE" ]; then
    echo "错误：在 build 目录中找不到动态库文件"
    echo "请先运行 ./build_lib_tips.sh 编译动态库"
    exit 1
fi

DYLIB_NAME=$(basename "$DYLIB_FILE")
DYLIB_PATH="$DYLIB_FILE"

echo "检测到动态库: $DYLIB_NAME"

# 检查应用程序是否存在
if [ ! -d "$APP_PATH" ]; then
    echo "错误：应用程序不存在：$APP_PATH"
    exit 1
fi

echo "开始注入动态库..."

# 获取应用程序包信息
INFO_PLIST="$APP_PATH/Contents/Info.plist"
if [ -f "$INFO_PLIST" ]; then
    EXECUTABLE_NAME=$(plutil -extract CFBundleExecutable raw -o - "$INFO_PLIST" 2>/dev/null)
    if [ -z "$EXECUTABLE_NAME" ]; then
        EXECUTABLE_NAME=$(basename "$APP_PATH" .app)
    fi
else
    EXECUTABLE_NAME=$(basename "$APP_PATH" .app)
fi

EXECUTABLE_PATH="$APP_PATH/Contents/MacOS/$EXECUTABLE_NAME"
FRAMEWORKS_DIR="$APP_PATH/Contents/Frameworks"

# 检查可执行文件是否存在
if [ ! -f "$EXECUTABLE_PATH" ]; then
    echo "错误：找不到可执行文件：$EXECUTABLE_PATH"
    exit 1
fi

# 检查写入权限
if [ ! -w "$APP_PATH" ]; then
    echo "错误：没有写入权限"
    exit 1
fi

# 创建 Frameworks 目录
mkdir -p "$FRAMEWORKS_DIR"

# 复制动态库到应用程序包
cp "$DYLIB_PATH" "$FRAMEWORKS_DIR/"

# 备份 Info.plist
cp "$INFO_PLIST" "$INFO_PLIST.backup"

# 使用 PlistBuddy 添加环境变量
/usr/libexec/PlistBuddy -c "Add :LSEnvironment dict" "$INFO_PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :LSEnvironment:DYLD_TIPS string '@executable_path/../Frameworks/$DYLIB_NAME'" "$INFO_PLIST" 2>/dev/null || true

# 如果上面的命令失败，说明 LSEnvironment 已经存在，我们更新它
if [ $? -ne 0 ]; then
    /usr/libexec/PlistBuddy -c "Set :LSEnvironment:DYLD_TIPS '@executable_path/../Frameworks/$DYLIB_NAME'" "$INFO_PLIST" 2>/dev/null || {
        # 创建一个包装脚本作为备用方案
        WRAPPER_SCRIPT="$APP_PATH/Contents/MacOS/${EXECUTABLE_NAME}_original"
        mv "$EXECUTABLE_PATH" "$WRAPPER_SCRIPT"
        
        cat > "$EXECUTABLE_PATH" << EOF
#!/bin/bash
export DYLD_TIPS="@executable_path/../Frameworks/$DYLIB_NAME"
exec "\$(dirname "\$0")/${EXECUTABLE_NAME}_original" "\$@"
EOF
        chmod +x "$EXECUTABLE_PATH"
    }
fi

# 重新签名应用程序
codesign --force --deep --sign - "$APP_PATH" 2>/dev/null

echo "✅ 注入完成"
echo "动态库: $DYLIB_NAME"