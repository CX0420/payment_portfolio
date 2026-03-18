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
  Map<String, dynamic>? _cardData;

  @override
  void initState() {
    super.initState();
    _startProcess();
  }

  Future<void> _startProcess() async {
    // 开始扫描
    await _scanCard();

    // 如果失败，等待 10 秒后自动跳转
    if (!success) {
      await Future.delayed(const Duration(seconds: 10));
    }

    if (!_isNavigating && mounted) {
      _navigateToResultPage();
    }
  }

  Future<void> _scanCard() async {
    try {
      // First try to read as EMV card
      final emvData = await _nfcService.readEMVCard();
      if (emvData != null && emvData.isNotEmpty) {
        if (!mounted) return;

        setState(() {
          _status = 'EMV 卡片扫描成功！正在跳转...';
          _cardData = emvData;
          success = true;
        });

        // 等待 5 秒后跳转
        await Future.delayed(const Duration(seconds: 5));

        if (mounted) _navigateToResultPage();
        return;
      }

      // If not EMV or EMV reading failed, try regular NFC tag reading
      final result = await _nfcService.readNFCTag();
      if (!mounted) return;

      setState(() {
        _status = 'NFC 标签扫描成功！正在跳转...';
        success = true;
        _cardData = {'tagData': result};
      });

      // 等待 5 秒后跳转
      await Future.delayed(const Duration(seconds: 5));

      if (mounted) _navigateToResultPage();
    } catch (e) {
      if (!mounted) return;

      // Show more detailed error message
      String errorMessage = '扫描失败';
      if (e.toString().contains('NFC is not available')) {
        errorMessage = 'NFC 不可用，请检查设备设置';
      } else if (e.toString().contains('Not an EMV card')) {
        errorMessage = '未检测到 EMV 卡片，请重试';
      } else {
        errorMessage = '扫描失败: ${e.toString()}';
      }

      setState(() {
        _status = '$errorMessage，10秒后自动跳转...';
        success = false;
      });
    }
  }

  void _navigateToResultPage() {
    _isNavigating = true;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaymentResult(
                  success: success,
                  cardData: _cardData,
                )));
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
