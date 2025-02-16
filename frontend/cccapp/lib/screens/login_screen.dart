import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static String routeName = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  String? _errorMessage;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  static const Color backgroundStart = Color(0xFF1A1A1A);
  static const Color backgroundMid = Color(0xFF252525);
  static const Color backgroundEnd = Color(0xFF2D2D2D);

  void _handleLoginPress() {
    if (_usernameController.text.isEmpty) {
      setState(() => _errorMessage = "Username cannot be empty");
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = "Password too short");
      return;
    }
    setState(() => _errorMessage = null);
    // TODO: Proceed with login
  }

  void _handleSignupPress() {
    if (_usernameController.text.isEmpty) {
      setState(() => _errorMessage = "Username cannot be empty");
      return;
    }
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
    // TODO: Proceed with signup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundStart, backgroundMid, backgroundEnd],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
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
      ),
    );
  }

  Widget _buildLogin() {
    return _AuthCard(
      title: "Login",
      fields: [
        _buildTextField(_usernameController, "Username"),
        _buildTextField(_passwordController, "Password", obscureText: true),
      ],
      buttonText: "Login",
      switchText: "No account? Sign up",
      onActionPressed: _handleLoginPress,
      onSwitchPressed: () => setState(() => isLogin = false),
    );
  }

  Widget _buildSignup() {
    return _AuthCard(
      title: "Signup",
      fields: [
        _buildTextField(_usernameController, "Username"),
        _buildTextField(_emailController, "Email"),
        _buildTextField(_passwordController, "Password", obscureText: true),
        _buildTextField(_confirmController, "Confirm Password",
            obscureText: true),
      ],
      buttonText: "Sign Up",
      switchText: "Have an account? Login",
      onActionPressed: _handleSignupPress,
      onSwitchPressed: () => setState(() => isLogin = true),
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
