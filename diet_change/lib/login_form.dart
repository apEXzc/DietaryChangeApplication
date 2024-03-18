import 'package:flutter/material.dart';

// This widget represents the login form UI.
class LoginForm extends StatelessWidget {
  // Define instance variables to hold input form details and actions.
  final double scaleFactor;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onLoginPressed;

  // Constructor to initialise instance variables.
  const LoginForm({
    super.key,
    required this.scaleFactor,
    required this.usernameController,
    required this.passwordController,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Wrapping the form in a scroll view for better responsiveness.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Input field for Username/Email.
          Container(
            margin: EdgeInsets.only(top: 50 * scaleFactor),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 60 * scaleFactor, vertical: 24 * scaleFactor),
              child: TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0 * scaleFactor),
                  ),
                  labelText: 'Username/Email',
                ),
              ),
            ),
          ),
          // Input field for Password.
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 60 * scaleFactor, vertical: 24 * scaleFactor),
            child: TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0 * scaleFactor),
                ),
                labelText: 'Password',
              ),
              obscureText: true, // Ensuring characters are hidden for password.
            ),
          ),
          SizedBox(height: 100.0 * scaleFactor),
          // 'Forgot password?' link.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 60 * scaleFactor),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: const Text('Forgot password?'),
                onPressed: () {
                  // TODO: Implement forgot password functionality here.
                },
              ),
            ),
          ),
          SizedBox(height: 50.0 * scaleFactor),
          // Link to 'Terms of Service' and 'Privacy Policy'.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 60 * scaleFactor),
            child: Align(
              alignment: Alignment.center,
              child: TextButton(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                        fontSize: 12 * scaleFactor, color: Colors.black),
                    children: const [
                      TextSpan(text: 'By continuing, you agree to our '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(color: Colors.red),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(color: Colors.red),
                      ),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),
                onPressed: () {
                  // TODO: Navigate user to the relevant pages or display information.
                },
              ),
            ),
          ),
          // Login button.
          Center(
            child: SizedBox(
              width: 307 * scaleFactor,
              height: 48 * scaleFactor,
              child: ElevatedButton(
                onPressed: onLoginPressed,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20 * scaleFactor),
                  ),
                  backgroundColor: const Color(0xFF059669),
                ),
                child: const Text('Log in'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
