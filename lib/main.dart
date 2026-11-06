import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'card_screen.dart';

void main() {
  runApp(const DermaSafeApp());
}

class DermaSafeApp extends StatelessWidget {
  const DermaSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DERMASAFE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'Roboto'),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  void _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');
    
    await Future.delayed(const Duration(seconds: 1));
    
    if (token != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CardScreen(token: token)));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF42947b),
      body: Center(child: Text('DERMASAFE', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2))),
    );
  }
}