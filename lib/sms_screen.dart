import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'card_screen.dart';

class SmsScreen extends StatefulWidget {
  final String phone;
  SmsScreen({required this.phone});

  @override
  _SmsScreenState createState() => _SmsScreenState();
}

class _SmsScreenState extends State<SmsScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  void _verify() async {
    if (_codeController.text.length != 3) return;

    setState(() => _isLoading = true);
    final res = await ApiService.verifyCode(widget.phone, _codeController.text);
    setState(() => _isLoading = false);

    if (res['status'] == 'success') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_token', res['token']);

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => CardScreen(token: res['token'])), (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Невірний код')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('ПІДТВЕРДЖЕННЯ ВХОДУ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2d6f65))),
            const SizedBox(height: 10),
            Text('Код надіслано на ${widget.phone}', style: const TextStyle(color: Color(0xFF5f6f6c))),
            const SizedBox(height: 30),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 3,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, letterSpacing: 20, fontWeight: FontWeight.bold, color: Color(0xFF2d6f65)),
              decoration: InputDecoration(counterText: '', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF42947b), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _isLoading ? null : _verify,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('УВІЙТИ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}