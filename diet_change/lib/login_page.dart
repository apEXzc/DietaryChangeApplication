import 'package:diet_change/feature_page.dart';
import 'package:flutter/material.dart';
import 'login_form.dart'; // Importing the LoginForm widget from another file.
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// This widget represents the entire login page.
class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Controllers for capturing input values from the text fields.
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  void _showDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  // Logic when the login button is pressed.
  void _loginLogic() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    var url = Uri.parse('http://3.10.233.31:3000/login');
    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        if (!mounted) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Feature()));
      } else {
        final message = jsonDecode(response.body)['message'];
        if (!mounted) return;
        _showDialog(context, message);
      }
    } catch (e) {
      if (!mounted) return;
      _showDialog(context, 'Network error');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Capturing the screen width to determine a scaling factor for UI.
    double currentWidth = MediaQuery.of(context).size.width;
    double scaleFactor = currentWidth / 430;
    const pageTitle = 'Log In';

    return Scaffold(
      appBar: AppBar(
        // Disabling the default back button for customisation.
        automaticallyImplyLeading: false,
        title: Stack(
          alignment: Alignment.center, // Center items on the stack.
          children: <Widget>[
            // Center the page title.
            Align(
              alignment: Alignment.center,
              child: Text(
                pageTitle,
                style: TextStyle(
                  fontSize: scaleFactor * 20, // Scaling the font size.
                  color: const Color.fromRGBO(
                      0, 0, 0, 1), // Setting text color to black.
                ),
              ),
            ),

            // Align the back button to the left side.
            Positioned(
              left: 0,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black, // Setting the icon color to black.
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromRGBO(
            255, 255, 255, 1), // Setting the app bar color to white.
      ),
      // Rendering the LoginForm widget in the body of the Scaffold.
      body: LoginForm(
        scaleFactor: scaleFactor,
        usernameController: _usernameController,
        passwordController: _passwordController,
        onLoginPressed:
            _loginLogic, // Assigning the login logic to the LoginForm widget.
      ),
    );
  }
}
