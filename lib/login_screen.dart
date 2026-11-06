import 'package:flutter/material.dart';
import 'api_service.dart';
import 'sms_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '+380');
  bool _isLoading = false;

  void _sendCode() async {
    setState(() => _isLoading = true);
    final res = await ApiService.sendCode(_phoneController.text.trim());
    setState(() => _isLoading = false);

    if (res['status'] == 'success') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SmsScreen(phone: _phoneController.text.trim())));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Помилка')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('DERMASAFE', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2d6f65))),
              const SizedBox(height: 10),
              const Text('ВВЕДІТЬ НОМЕР ТЕЛЕФОНУ', style: TextStyle(color: Color(0xFF5f6f6c))),
              const SizedBox(height: 30),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Телефон',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF42947b), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: _isLoading ? null : _sendCode,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('ОТРИМАТИ КОД', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}