import 'package:flutter/material.dart';
import '../biometric/biometric_manager.dart';

/// 指纹管理页面
class FingerprintManagementPage extends StatefulWidget {
  const FingerprintManagementPage({super.key});

  @override
  State<FingerprintManagementPage> createState() => _FingerprintManagementPageState();
}

class _FingerprintManagementPageState extends State<FingerprintManagementPage> {
  final BiometricManager _biometricManager = BiometricManager();
  List<String> _fingerprints = [];
  bool _isLoading = true;
  BiometricStatus _biometricStatus = BiometricStatus.unsupported;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // 获取生物识别状态
      final status = await _biometricManager.checkBiometricStatus();
      
      // 如果可用，获取指纹列表
      List<String> fingerprints = [];
      if (status == BiometricStatus.available) {
        fingerprints = await _biometricManager.getAllFingerprints();
      }
      
      if (mounted) {
        setState(() {
          _biometricStatus = status;
          _fingerprints = fingerprints;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('加载数据失败', '无法获取指纹数据: $e');
      }
    }
  }

  Future<void> _addFingerprint() async {
    try {
      final bool result = await _biometricManager.addFingerprint();
      if (!mounted) return;
      
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('指纹添加成功')),
        );
        _loadData(); // 重新加载数据
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('指纹添加失败')),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('添加失败', '添加指纹时发生错误: $e');
      }
    }
  }

  Future<void> _deleteFingerprint(int index) async {
    try {
      final bool result = await _biometricManager.deleteFingerprint(index);
      if (!mounted) return;
      
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('指纹删除成功')),
        );
        _loadData(); // 重新加载数据
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('指纹删除失败')),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('删除失败', '删除指纹时发生错误: $e');
      }
    }
  }

  Future<void> _clearAllFingerprints() async {
    try {
      final bool result = await _biometricManager.clearAllFingerprints();
      if (!mounted) return;
      
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('所有指纹已清除')),
        );
        _loadData(); // 重新加载数据
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('清除失败')),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('清除失败', '清除指纹时发生错误: $e');
      }
    }
  }

  Future<void> _authenticate() async {
    try {
      final bool result = await _biometricManager.authenticate(
        reason: '验证您的身份',
      );
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('验证${result ? '成功' : '失败'}')),
      );
    } catch (e) {
      if (mounted) {
        _showErrorDialog('验证失败', '身份验证时发生错误: $e');
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showNativeSettings() async {
    try {
      // 尝试显示原生指纹管理界面
      await _biometricManager.showFingerprintSettings(context);
    } catch (e) {
      // 如果失败，则显示对话框提示用户
      if (mounted) {
        _showErrorDialog(
          '无法打开指纹管理',
          '无法打开原生指纹管理界面，请前往系统设置手动管理指纹。'
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('指纹管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showNativeSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_biometricStatus == BiometricStatus.unsupported) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_accounts,
              size: 72,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text('您的设备不支持生物识别',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('无法使用指纹识别功能',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_biometricStatus == BiometricStatus.notEnrolled) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fingerprint,
              size: 72,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text('未设置生物识别',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            const Text('请添加指纹以使用生物识别功能',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('添加指纹'),
              onPressed: _addFingerprint,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text('系统设置'),
              onPressed: _showNativeSettings,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('已注册的指纹',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 8),
                  Text('共 ${_fingerprints.length} 个指纹',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _fingerprints.isEmpty
                ? const Center(
                    child: Text('没有已存储的指纹',
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _fingerprints.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.fingerprint),
                          title: Text('指纹 ${index + 1}'),
                          subtitle: Text(_fingerprints[index].length > 20
                              ? '${_fingerprints[index].substring(0, 20)}...'
                              : _fingerprints[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteFingerprint(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('添加指纹'),
                  onPressed: _addFingerprint,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('清除所有'),
                  onPressed: _fingerprints.isEmpty
                      ? null
                      : _clearAllFingerprints,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('测试验证'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: _authenticate,
          ),
        ],
      ),
    );
  }
} 