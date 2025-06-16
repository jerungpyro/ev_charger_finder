// File: lib/screens/login_or_register_screen.dart

import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class LoginOrRegisterScreen extends StatefulWidget {
  const LoginOrRegisterScreen({super.key});

  @override
  State<LoginOrRegisterScreen> createState() => _LoginOrRegisterScreenState();
}

class _LoginOrRegisterScreenState extends State<LoginOrRegisterScreen> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginScreen(onSwitchToRegister: togglePages);
    } else {
      return RegisterScreen(onSwitchToLogin: togglePages);
    }
  }
}