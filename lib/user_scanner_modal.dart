import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserScannerModal extends StatefulWidget {
  const UserScannerModal({Key? key}) : super(key: key);

  @override
  State<UserScannerModal> createState() => _UserScannerModalState();
}

class _UserScannerModalState extends State<UserScannerModal> {
  String? _scanResult;
  bool _scanning = true;
  final _storage = const FlutterSecureStorage();
  final MobileScannerController _scannerController = MobileScannerController();
  @override
  void initState() {
    super.initState();
    _scannerController.start();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan User ID')),
      body:
          _scanning
              ? MobileScanner(
                key: const Key('scanner'),
                controller: _scannerController,
                onDetect: (capture) async {
                  final String? code = capture.barcodes.first.rawValue;
                  if (code != null) {
                    setState(() {
                      _scanResult = code;
                      _scanning = false;
                    });
                    await _storage.write(key: 'user_id', value: code);
                  }
                },
              )
              : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Scanned User ID: $_scanResult'),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
    );
  }
}
