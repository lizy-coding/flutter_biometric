import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_biometric/flutter_biometric.dart';

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
  final _flutterBiometricPlugin = FlutterBiometric();
  int _fingerprintCount = 0;
  List<String> _fingerprints = [];
  bool _isSupported = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    int fingerprintCount = 0;
    List<String> fingerprints = [];
    bool isSupported = false;
    
    try {
      platformVersion =
          await _flutterBiometricPlugin.getPlatformVersion() ?? 'Unknown platform version';
      fingerprintCount = await _flutterBiometricPlugin.getFingerprintCount();
      fingerprints = await _flutterBiometricPlugin.getAllFingerprints();
      isSupported = await _flutterBiometricPlugin.isBiometricSupported();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _fingerprintCount = fingerprintCount;
      _fingerprints = fingerprints;
      _isSupported = isSupported;
    });
  }

  Future<void> _refreshData() async {
    try {
      final fingerprintCount = await _flutterBiometricPlugin.getFingerprintCount();
      final fingerprints = await _flutterBiometricPlugin.getAllFingerprints();
      
      setState(() {
        _fingerprintCount = fingerprintCount;
        _fingerprints = fingerprints;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('数据已刷新')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('刷新数据失败: $e')),
      );
    }
  }

  Future<void> _authenticate() async {
    try {
      final result = await _flutterBiometricPlugin.authenticate(
        title: '生物识别验证',
        subtitle: '请验证您的身份',
        description: '使用您的指纹或面部进行身份验证',
        negativeButtonText: '取消',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('验证结果: ${result ? "成功" : "失败"}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('验证过程出错: $e')),
      );
    }
  }

  Future<void> _addFingerprint() async {
    try {
      final result = await _flutterBiometricPlugin.addFingerprint();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('添加指纹: ${result ? "成功" : "失败"}')),
      );
      
      _refreshData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('添加指纹失败: $e')),
      );
    }
  }

  Future<void> _deleteFingerprint(int index) async {
    try {
      final result = await _flutterBiometricPlugin.deleteFingerprint(index);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除指纹: ${result ? "成功" : "失败"}')),
      );
      
      _refreshData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除指纹失败: $e')),
      );
    }
  }

  Future<void> _clearAllFingerprints() async {
    try {
      final result = await _flutterBiometricPlugin.clearAllFingerprints();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('清除所有指纹: ${result ? "成功" : "失败"}')),
      );
      
      _refreshData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('清除指纹失败: $e')),
      );
    }
  }

  Future<void> _setupTestFingerprint() async {
    try {
      final result = await _flutterBiometricPlugin.setupTestFingerprint();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('设置测试指纹: ${result ? "成功" : "失败"}')),
      );
      
      _refreshData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('设置测试指纹失败: $e')),
      );
    }
  }

  Future<void> _testVerify() async {
    try {
      final result = await _flutterBiometricPlugin.testFingerprintVerification();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('测试验证结果: ${result ? "成功" : "失败"}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('测试验证失败: $e')),
      );
    }
  }

  Future<void> _showNativeManager() async {
    try {
      await _flutterBiometricPlugin.showFingerprintManager();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('打开原生指纹管理界面失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('指纹管理'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('平台版本: $_platformVersion'),
                      const SizedBox(height: 8),
                      Text('支持生物识别: ${_isSupported ? "是" : "否"}'),
                      const SizedBox(height: 8),
                      Text('指纹数量: $_fingerprintCount'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '指纹列表',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_fingerprints.isEmpty)
                        const Text('没有存储的指纹')
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _fingerprints.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text('指纹 ${index + 1}'),
                              subtitle: Text(_fingerprints[index]),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteFingerprint(index),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '指纹操作',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _authenticate,
                        child: const Text('生物识别验证'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _addFingerprint,
                        child: const Text('添加测试指纹'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _clearAllFingerprints,
                        child: const Text('清除所有指纹'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _setupTestFingerprint,
                        child: const Text('设置测试指纹'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _testVerify,
                        child: const Text('测试指纹验证'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _showNativeManager,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('打开原生指纹管理界面'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
