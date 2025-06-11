import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_viewmodel.dart';

class AuthPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Column(
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: () =>
                vm.signIn(emailController.text, passwordController.text),
            child: Text('Login'),
          ),
          if (vm.error != null)
            Text(vm.error!, style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
