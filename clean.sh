#!/bin/bash

# 清理Flutter项目脚本
echo "🧹 开始清理Flutter项目..."

# 清理Flutter构建文件
echo "📱 清理Flutter构建文件..."
flutter clean

# 清理Dart工具缓存
echo "🛠️ 清理Dart工具缓存..."
rm -rf .dart_tool/
rm -rf example/.dart_tool/

# 清理pub缓存
echo "📦 清理pub缓存..."
rm -rf .pub/
rm -rf example/.pub/

# 清理Flutter插件文件
echo "🔌 清理Flutter插件文件..."
rm -f .flutter-plugins
rm -f .flutter-plugins-dependencies
rm -f example/.flutter-plugins
rm -f example/.flutter-plugins-dependencies

# 清理IDE文件
echo "💻 清理IDE文件..."
rm -rf .idea/
rm -rf example/.idea/
rm -rf .vscode/
rm -rf example/.vscode/

# 清理构建目录
echo "🏗️ 清理构建目录..."
rm -rf build/
rm -rf example/build/
rm -rf android/build/
rm -rf ios/build/

# 清理Android特定文件
echo "🤖 清理Android文件..."
rm -rf android/.gradle/
rm -rf android/app/build/
rm -rf example/android/.gradle/
rm -rf example/android/app/build/

# 清理iOS特定文件
echo "🍎 清理iOS文件..."
rm -rf ios/Pods/
rm -rf ios/.symlinks/
rm -rf ios/Flutter/App.framework/
rm -rf ios/Flutter/Flutter.framework/
rm -rf ios/Flutter/Flutter.podspec
rm -rf ios/Flutter/Generated.xcconfig
rm -rf ios/Flutter/flutter_assets/
rm -rf ios/Flutter/flutter_export_environment.sh
rm -rf example/ios/Pods/
rm -rf example/ios/.symlinks/
rm -rf example/ios/Flutter/App.framework/
rm -rf example/ios/Flutter/Flutter.framework/
rm -rf example/ios/Flutter/Flutter.podspec
rm -rf example/ios/Flutter/Generated.xcconfig
rm -rf example/ios/Flutter/flutter_assets/
rm -rf example/ios/Flutter/flutter_export_environment.sh

# 清理系统文件
echo "🖥️ 清理系统文件..."
find . -name ".DS_Store" -delete
find . -name "Thumbs.db" -delete
find . -name "*.log" -delete
find . -name "*.tmp" -delete
find . -name "*.temp" -delete

# 重新获取依赖
echo "📥 重新获取依赖..."
flutter pub get
cd example && flutter pub get && cd ..

echo "✅ 清理完成！"
echo "💡 提示：如果遇到问题，可以运行 'flutter doctor' 检查环境" 