import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your details to ride.',
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.primary),
                  ),
                  const SizedBox(height: 48),

                  // Email Field
                  Text('Email', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: 'you@example.com',
                      hintStyle: TextStyle(color: Colors.white30),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Password Field
                  Text('Password', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: '••••••••',
                      hintStyle: TextStyle(color: Colors.white30),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text('Forgot Password?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Sign In Button
                  authProvider.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.secondary))
                      : Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.secondary, AppTheme.secondaryContainer],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(48),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.secondary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              String? error = await authProvider.login(
                                _emailController.text.trim(),
                                _passwordController.text,
                              );
                              if (error == null) {
                                Navigator.of(context).pushReplacementNamed('/home');
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                            ),
                            child: Text(
                              'Sign In',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.background, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                  const SizedBox(height: 40),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primary)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/register'),
                        child: Text('Sign up', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
