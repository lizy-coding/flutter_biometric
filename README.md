# Flutter 生物识别模块

## 快速开始

1. 在 pubspec.yaml 添加依赖：
```yaml
flutter_biometric:
```
2. 导入包：
```dart
import 'package:flutter_biometric/flutter_biometric.dart';
```

## API 调用示例

### 检查生物识别支持
```dart
final status = await BiometricManager().checkBiometricStatus();
if (status == BiometricStatus.available) {
  // 支持生物识别
}
```

### 发起生物识别认证（指纹/人脸）
```dart
final result = await BiometricManager().authenticate(reason: '请验证身份');
if (result) {
  // 验证成功
}
```

### 指纹数据管理
```dart
// 获取指纹数量
final count = await BiometricManager().getFingerprintCount();
// 添加指纹
final ok = await BiometricManager().addFingerprint(fingerprintHash: 'your_hash');
// 删除指纹
await BiometricManager().deleteFingerprint(0);
// 清空所有指纹
await BiometricManager().clearAllFingerprints();
```

### 启动/停止人脸预览
```dart
final textureId = await FacePreviewManager().startFacePreview();
// 渲染预览：Texture(textureId: textureId)
await FacePreviewManager().stopFacePreview();
```

### 人脸预览页面
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => FacePreviewPage(
    onResult: (success) { /* 验证结果处理 */ },
    onCancel: () { /* 取消回调 */ },
  )),
);
```

## 架构分层说明

- **Service 层**：如 `face_service.dart`，负责与原生通信（MethodChannel）。
- **Manager 层**：如 `biometric_manager.dart`、`face_manager.dart`，负责业务流程、状态管理。
- **UI 层**：如 `face_preview_page.dart`、`face_mask_overlay.dart`，负责 Flutter 页面与组件。
- **原生实现**：Android 端如 `FacePreviewHandler.kt`，负责 CameraX 采集、指纹/人脸原生 API 封装。

---

## 功能特性

- 生物识别验证（指纹/面部）
- 指纹数据管理（添加/删除/验证）
- 原生指纹管理界面
- 测试功能支持
- **指纹验证成功后自动播放烟花动画（纯 Flutter 绘制，无需外部资源）**
- **人脸预览与验证（原生采集，Flutter 渲染圆形遮罩）**

## 人脸识别/预览功能说明

- **启动与停止**：
  - Flutter 调用 `FacePreviewManager.startFacePreview()` 或通过 UI 页面 `FacePreviewPage` 自动调用，原生 Android 启动摄像头采集并返回 `TextureId`。
  - Flutter 通过 `Texture(textureId: ...)` 组件渲染预览画面。
  - 调用 `FacePreviewManager.stopFacePreview()` 或页面退出时自动释放资源。

- **验证流程**：
  - 用户点击页面"开始验证"按钮时，Flutter 调用 `FlutterBiometricPlugin` 插件方法 `verifyFace()`，目前默认返回 `true`，可集成实际人脸检测逻辑。

- **分层结构**：
  - Service 层：`lib/src/face/face_service.dart`，负责与原生通信。
  - Manager 层：`lib/src/face/face_manager.dart`、`lib/src/face/face_preview_manager.dart`，管理业务流程。
  - UI 层：`lib/src/face/face_preview_page.dart` 页面与 `lib/src/face/face_mask_overlay.dart` 遮罩组件。

- **原生实现**：
  - Android 端：`android/src/main/kotlin/com/example/flutter_biometric/FacePreviewHandler.kt`，使用 CameraX 输出 `SurfaceTexture`，通过 `face_channel` 返回 `TextureId`。

## 示例代码

```dart
// 使用 FacePreviewPage 页面
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => FacePreviewPage(
    onResult: (success) { /* 验证结果处理 */ },
    onCancel: () { /* 取消回调 */ },
  )),
);
```

## 遮罩组件示例

```dart
FaceMaskOverlay(
  size: 280,
  borderColor: Colors.white,
  borderWidth: 3,
  maskColor: Colors.black54,
  hintText: '请将脸部放在框内',
),
```

## 其他功能与架构请参考原有文档
