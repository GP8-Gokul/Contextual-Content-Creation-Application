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

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  String? _errorMessage;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  void _handleLoginPress() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      setState(() => _errorMessage = "Enter a valid email");
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = "Password too short");
      return;
    }

    setState(() => _errorMessage = null);

    String? error =
        await loginUser(_emailController.text, _passwordController.text);
    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      Navigator.pushNamed(context, MainScreen.routeName);
    }
  }

  void _handleSignupPress() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      setState(() => _errorMessage = "Enter a valid email");
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = "Password too short");
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      setState(() => _errorMessage = "Passwords do not match");
      return;
    }

    setState(() => _errorMessage = null);

    String? error =
        await signUpUser(_emailController.text, _passwordController.text);
    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Now you can login.')),
      );
      logoutUser();
    }
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
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 500),
                  firstChild: _buildLogin(),
                  secondChild: _buildSignup(),
                  crossFadeState: isLogin
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogin() {
    return _AuthCard(
      title: "Login",
      fields: [
        _buildTextField(_emailController, "Email"),
        _buildTextField(_passwordController, "Password", obscureText: true),
      ],
      buttonText: "Login",
      switchText: "No account? Sign up",
      onActionPressed: _handleLoginPress,
      onSwitchPressed: () {
        setState(() => isLogin = false);
        _emailController.clear();
        _passwordController.clear();
      },
    );
  }

  Widget _buildSignup() {
    return _AuthCard(
      title: "Signup",
      fields: [
        _buildTextField(_emailController, "Email"),
        _buildTextField(_passwordController, "Password", obscureText: true),
        _buildTextField(_confirmController, "Confirm Password",
            obscureText: true),
      ],
      buttonText: "Sign Up",
      switchText: "Have an account? Login",
      onActionPressed: () async {
        _handleSignupPress();
        if (_errorMessage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('A verification link has been sent to your email')),
          );
        }
      },
      onSwitchPressed: () {
        setState(() => isLogin = true);
        _emailController.clear();
        _passwordController.clear();
        _confirmController.clear();
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(hintText: hint),
    );
  }
}

class _AuthCard extends StatelessWidget {
  final String title;
  final List<Widget> fields;
  final String buttonText;
  final String switchText;
  final VoidCallback onActionPressed;
  final VoidCallback onSwitchPressed;

  const _AuthCard({
    required this.title,
    required this.fields,
    required this.buttonText,
    required this.switchText,
    required this.onActionPressed,
    required this.onSwitchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      margin: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            ...fields,
            const SizedBox(height: 16),
            _buildGradientButton(buttonText, onActionPressed),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onSwitchPressed,
              child: Text(
                switchText,
                style: const TextStyle(color: Colors.purple),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
