#!/bin/bash

# 清理之前的编译文件
rm -rf build
mkdir -p build

# 自动获取源文件名和生成动态库名
SOURCE_FILE=$(find . -maxdepth 1 -name "*.m" -type f | head -n 1)
if [ -z "$SOURCE_FILE" ]; then
    echo "❌ 错误：找不到 .m 源文件"
    exit 1
fi

# 从源文件名生成动态库名（转换为小写并添加扩展名）
SOURCE_BASENAME=$(basename "$SOURCE_FILE" .m)
DYLIB_NAME=$(echo "$SOURCE_BASENAME" | tr '[:upper:]' '[:lower:]').dylib

echo "编译通用动态库 (x86_64 + arm64)..."
echo "源文件: $SOURCE_FILE"
echo "输出文件: build/$DYLIB_NAME"

# 编译 x86_64 架构
echo "正在编译 x86_64 架构..."
clang -arch x86_64 -dynamiclib -framework Foundation -framework AppKit -framework Cocoa \
    -compatibility_version 1.0 \
    -current_version 1.0 \
    -install_name "@executable_path/../Frameworks/$DYLIB_NAME" \
    -o "build/${DYLIB_NAME%.dylib}_x86_64.dylib" \
    "$SOURCE_FILE"

if [ $? -ne 0 ]; then
    echo "❌ x86_64 架构编译失败"
    exit 1
fi

# 编译 arm64 架构
echo "正在编译 arm64 架构..."
clang -arch arm64 -dynamiclib -framework Foundation -framework AppKit -framework Cocoa \
    -compatibility_version 1.0 \
    -current_version 1.0 \
    -install_name "@executable_path/../Frameworks/$DYLIB_NAME" \
    -o "build/${DYLIB_NAME%.dylib}_arm64.dylib" \
    "$SOURCE_FILE"

if [ $? -ne 0 ]; then
    echo "❌ arm64 架构编译失败"
    exit 1
fi

# 合并为通用二进制文件
echo "正在合并为通用二进制文件..."
lipo -create \
    "build/${DYLIB_NAME%.dylib}_x86_64.dylib" \
    "build/${DYLIB_NAME%.dylib}_arm64.dylib" \
    -output "build/$DYLIB_NAME"

if [ $? -eq 0 ]; then
    echo "✅ 编译成功: build/$DYLIB_NAME"
    
    # 清理临时文件
    rm -f "build/${DYLIB_NAME%.dylib}_x86_64.dylib"
    rm -f "build/${DYLIB_NAME%.dylib}_arm64.dylib"
    
    echo ""
    echo "📋 支持的架构:"
    lipo -info "build/$DYLIB_NAME"
    echo ""
    echo "📋 动态库大小:"
    ls -lh "build/$DYLIB_NAME"
    echo ""
else
    echo "❌ 合并失败"
    exit 1
fi