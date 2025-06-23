import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  Future<void> _signUp() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final username = _usernameController.text.trim();

    try {
      await Provider.of<AuthService>(context, listen: false).signUp(
        email,
        password,
        username,
      );
      if (mounted) context.go('/');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign up: ${e.toString()}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loading ? null : _signUp,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
