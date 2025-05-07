# Flutter 生物识别模块

这是一个 Flutter 生物识别插件，提供指纹识别、人脸识别和管理功能。该插件封装了原生 Android 的生物识别 API，使得 Flutter 应用可以轻松实现指纹和人脸识别与管理功能。

## 功能特性

- 生物识别验证（指纹/面部）
- 指纹数据管理（添加/删除/验证）
- 原生指纹管理界面
- 测试功能支持
- **指纹验证成功后自动播放烟花动画（纯 Flutter 绘制，无需外部资源）**
- **人脸采集与验证，采集由 Android 原生完成，Flutter 侧统一圆形识别区样式，保证多机一致**

## 人脸采集功能说明

- **采集流程**：
  - Flutter 通过 Manager 层调用 `startFaceCapture()`，原生 Android 启动摄像头采集并返回 TextureId。
  - Flutter UI 通过 `Texture` 组件渲染原生采集到的图像。
  - Flutter 层用 `CustomPaint` 绘制圆形识别区，保证所有设备样式一致。
  - 采集完成后可调用 `stopFaceCapture()` 关闭摄像头。

- **分层结构**：
  - Service 层：`lib/src/face/face_service.dart`，负责与原生通信。
  - Manager 层：`lib/src/face/face_manager.dart`，负责业务流程。
  - UI 层：`lib/src/ui/face_capture_page.dart`、`lib/src/ui/face_circle_painter.dart`，负责界面与统一识别区绘制。

- **原生实现**：
  - Android 侧建议用 CameraX 输出到 SurfaceTexture，通过 Platform Channel 提供 TextureId。
  - 支持后续扩展人脸检测、采集回调等。

## 示例代码

```dart
// 启动人脸采集并显示页面
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const FaceCapturePage()),
);
```

## 统一圆形识别区效果

- Flutter 层自绘，所有设备样式一致：

```dart
class FaceCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = min(size.width, size.height) * 0.4;
    canvas.drawCircle(center, radius, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

## 其他功能与架构请参考原有文档
