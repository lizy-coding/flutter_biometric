import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_biometric/flutter_biometric.dart';
import 'package:flutter_biometric_example/face_image_demo_page.dart'
    show FaceImageDemoPage;
import 'package:flutter_biometric_example/fireworks_dialog.dart'
    show FireworksDialog;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final BiometricManager _biometricManager = BiometricManager();
  bool _isSupported = false;
  List<BiometricType> _availableBiometrics = [];
  BiometricStatus _biometricStatus = BiometricStatus.unsupported;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // 初始化平台状态
  Future<void> initPlatformState() async {
    String platformVersion;
    bool isSupported = false;
    BiometricStatus biometricStatus = BiometricStatus.unsupported;
    List<BiometricType> availableBiometrics = [];

    try {
      final flutterBiometricPlugin = FlutterBiometric();
      platformVersion =
          await flutterBiometricPlugin.getPlatformVersion() ??
          'Unknown platform version';

      // 检查生物识别状态
      biometricStatus = await _biometricManager.checkBiometricStatus();
      isSupported = biometricStatus != BiometricStatus.unsupported;

      // 获取可用的生物识别类型
      if (isSupported) {
        availableBiometrics = await _biometricManager.getAvailableBiometrics();
      }
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _isSupported = isSupported;
      _biometricStatus = biometricStatus;
      _availableBiometrics = availableBiometrics;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomePage(
        platformVersion: _platformVersion,
        isSupported: _isSupported,
        biometricStatus: _biometricStatus,
        availableBiometrics: _availableBiometrics,
        biometricManager: _biometricManager,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String platformVersion;
  final bool isSupported;
  final BiometricStatus biometricStatus;
  final List<BiometricType> availableBiometrics;
  final BiometricManager biometricManager;

  const HomePage({
    super.key,
    required this.platformVersion,
    required this.isSupported,
    required this.biometricStatus,
    required this.availableBiometrics,
    required this.biometricManager,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('指纹/人脸生物识别示例'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.face),
        label: const Text('人脸图像输出演示'),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const FaceImageDemoPage()));
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 设备信息卡片
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '设备信息',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('平台版本: $platformVersion'),
                  Text('生物识别支持: ${isSupported ? "支持" : "不支持"}'),
                  Text('生物识别状态: ${_getBiometricStatusText()}'),
                  const SizedBox(height: 8),
                  if (availableBiometrics.isNotEmpty) ...[
                    const Text('可用生物识别类型:'),
                    const SizedBox(height: 4),
                    ...availableBiometrics.map(
                      (type) => Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              BiometricUtils.getBiometricTypeIcon(type),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(BiometricUtils.getBiometricTypeName(type)),
                          ],
                        ),
                      ),
                    ),
                  ] else if (isSupported)
                    const Text('未设置任何生物识别'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 操作按钮
          ElevatedButton.icon(
            onPressed: () => _authenticate(context),
            icon: const Icon(Icons.fingerprint),
            label: const Text('测试生物识别验证'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(12)),
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: () => _navigateToFingerprintManagement(context),
            icon: const Icon(Icons.settings),
            label: const Text('指纹管理界面'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(12)),
          ),

          const SizedBox(height: 24),

          if (biometricStatus == BiometricStatus.notEnrolled)
            const Card(
              color: Colors.amber,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 36),
                    SizedBox(height: 8),
                    Text(
                      '您尚未设置生物识别',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('请在指纹管理界面添加生物识别'),
                  ],
                ),
              ),
            ),

          if (biometricStatus == BiometricStatus.unsupported)
            const Card(
              color: Colors.red,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 36),
                    SizedBox(height: 8),
                    Text(
                      '您的设备不支持生物识别',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '请使用其他方式进行身份验证',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getBiometricStatusText() {
    switch (biometricStatus) {
      case BiometricStatus.available:
        return '可用';
      case BiometricStatus.notEnrolled:
        return '未设置';
      case BiometricStatus.unsupported:
        return '不支持';
      default:
        return '未知';
    }
  }

  Future<void> _authenticate(BuildContext context) async {
    try {
      final result = await biometricManager.authenticate(reason: '请验证您的身份以继续');
      if (context.mounted) {
        if (result) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const FireworksDialog(),
          );
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('验证${result ? '成功' : '失败'}')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('验证过程出错: $e')));
      }
    }
  }

  void _navigateToFingerprintManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FingerprintManagementPage(),
      ),
    );
  }
}
