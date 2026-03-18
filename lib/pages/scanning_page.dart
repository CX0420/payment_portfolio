import 'package:flutter/material.dart';
import 'package:payment_portfolio/pages/payment_result_page.dart';
import 'package:payment_portfolio/services/nfc_service.dart';

class Scanning extends StatefulWidget {
  const Scanning({Key? key}) : super(key: key);

  @override
  State<Scanning> createState() => _ScanningState();
}

class _ScanningState extends State<Scanning> {
  final NFCService _nfcService = NFCService();
  String _status = '准备扫描 NFC 卡片...';
  bool _isNavigating = false;
  bool success = false;

  @override
  void initState() {
    super.initState();
    _startProcess();
  }

  Future<void> _startProcess() async {
    // 开始扫描
    _scanNFCTag();

    // 等待 5 秒后自动跳转
    await Future.delayed(const Duration(seconds: 5));

    if (!_isNavigating && mounted) {
      _navigateToResultPage();
    }
  }

  Future<void> _scanNFCTag() async {
    try {
      final result = await _nfcService.readNFCTag();
      if (!mounted) return;

      setState(() {
        _status = '扫描成功！正在跳转...';
        success = true; // 假设扫描成功
      });

      // 保存结果到共享参数（如果需要）
      // 例如使用 SharedPreferences
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _status = '扫描失败，10秒后自动跳转...';
      });
    }
  }

  void _navigateToResultPage() {
    _isNavigating = true;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaymentResult(success: success)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('正在扫描...'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/loading.gif',
              height: 300,
              width: 300,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text(
              _status,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '请将卡片靠近手机...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
