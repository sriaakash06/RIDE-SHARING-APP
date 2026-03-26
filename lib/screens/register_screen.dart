import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.onSurface),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Account',
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join the fleet and ride with us.',
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.primary),
                  ),
                  const SizedBox(height: 48),

                  // Name Field
                  Text('Full Name', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: 'John Doe',
                      hintStyle: TextStyle(color: Colors.white30),
                    ),
                  ),
                  const SizedBox(height: 24),

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

                  const SizedBox(height: 48),

                  // Register Button
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
                              String? error = await authProvider.register(
                                _emailController.text.trim(),
                                _passwordController.text,
                                _nameController.text.trim(),
                              );
                              if (error == null) {
                                Navigator.of(context).pushReplacementNamed('/home');
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error), backgroundColor: Colors.red),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                            ),
                            child: Text(
                              'Sign Up',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.background, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                  const SizedBox(height: 40),

                  // Back to Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primary)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text('Sign in', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondary, fontWeight: FontWeight.bold)),
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
