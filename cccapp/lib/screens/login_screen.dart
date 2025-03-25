import 'package:cccapp/screens/main_screen.dart';
import 'package:cccapp/service/auth/logout.dart';
import 'package:flutter/material.dart';
import 'package:cccapp/widgets/bg.dart';
import 'package:cccapp/service/auth/login.dart';
import 'package:cccapp/service/auth/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static String routeName = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  String? _errorMessage;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleLoginPress() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      setState(() => _errorMessage = "Enter a valid email");
      _shakeError();
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = "Password too short");
      _shakeError();
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Simulate a small delay for animation purposes
    await Future.delayed(const Duration(milliseconds: 300));

    String? error =
        await loginUser(_emailController.text, _passwordController.text);

    if (error != null) {
      setState(() {
        _errorMessage = error;
        _isLoading = false; // Reset loading state on error
      });
      _shakeError();
    } else {
      // Success animation before navigation
      _animationController.forward().then((_) {
        // Reset loading state before navigation
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacementNamed(context, MainScreen.routeName);
      });
    }
  }

  void _handleSignupPress() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      setState(() => _errorMessage = "Enter a valid email");
      _shakeError();
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = "Password too short");
      _shakeError();
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      setState(() => _errorMessage = "Passwords do not match");
      _shakeError();
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Simulate a small delay for animation purposes
    await Future.delayed(const Duration(milliseconds: 300));

    String? error =
        await signUpUser(_emailController.text, _passwordController.text);

    setState(() => _isLoading = false); // Always reset loading state

    if (error != null) {
      setState(() => _errorMessage = error);
      _shakeError();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Now you can login.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.deepPurple,
        ),
      );
      logoutUser();
      setState(() => isLogin = true);
    }
  }

  void _shakeError() {
    // Simple animation for error feedback
    AnimationController controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Repeat once
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        ).forward();
      }
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'appLogo',
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 70,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                if (_errorMessage != null)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: isLogin
                        ? _buildLogin(key: const ValueKey('login'))
                        : _buildSignup(key: const ValueKey('signup')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogin({Key? key}) {
    return _AuthCard(
      key: key,
      title: "Welcome Back",
      subtitle: "Log in to your account",
      fields: [
        _buildTextField(_emailController, "Email", Icons.email_outlined),
        const SizedBox(height: 16),
        _buildTextField(_passwordController, "Password", Icons.lock_outline,
            obscureText: true),
      ],
      buttonText: "Login",
      switchText: "Don't have an account? Sign up",
      onActionPressed: _handleLoginPress,
      onSwitchPressed: () {
        setState(() {
          isLogin = false;
          _isLoading = false; // Reset loading state when switching forms
          _errorMessage = null; // Clear any error messages
        });
        _emailController.clear();
        _passwordController.clear();
      },
      isLoading: _isLoading,
    );
  }

  Widget _buildSignup({Key? key}) {
    return _AuthCard(
      key: key,
      title: "Create Account",
      subtitle: "Sign up to get started",
      fields: [
        _buildTextField(_emailController, "Email", Icons.email_outlined),
        const SizedBox(height: 16),
        _buildTextField(_passwordController, "Password", Icons.lock_outline,
            obscureText: true),
        const SizedBox(height: 16),
        _buildTextField(
            _confirmController, "Confirm Password", Icons.lock_outline,
            obscureText: true),
      ],
      buttonText: "Sign Up",
      switchText: "Already have an account? Login",
      onActionPressed: _handleSignupPress,
      onSwitchPressed: () {
        setState(() {
          isLogin = true;
          _isLoading = false; // Reset loading state when switching forms
          _errorMessage = null; // Clear any error messages
        });
        _emailController.clear();
        _passwordController.clear();
        _confirmController.clear();
      },
      isLoading: _isLoading,
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset loading state when screen is shown (including after returning from logout)
    setState(() {
      _isLoading = false;
    });
  }
}

class _AuthCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> fields;
  final String buttonText;
  final String switchText;
  final VoidCallback onActionPressed;
  final VoidCallback onSwitchPressed;
  final bool isLoading;

  const _AuthCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.buttonText,
    required this.switchText,
    required this.onActionPressed,
    required this.onSwitchPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white.withOpacity(0.95),
      margin: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ...fields,
            const SizedBox(height: 24),
            _buildGradientButton(buttonText, onActionPressed, isLoading),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onSwitchPressed,
              child: Text(
                switchText,
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton(
      String text, VoidCallback onPressed, bool isLoading) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.4),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.0,
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
