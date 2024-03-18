import 'package:flutter/material.dart';
import 'singup_second_form.dart'; // Importing the SignupForm widget from a separate file.

// This widget represents the sign-up page.
class SecondSignup extends StatefulWidget {
  final String firstname;
  final String lastname;
  final String email;
  final String password;
  const SecondSignup({
    super.key,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
  });

  @override
  State<SecondSignup> createState() => _SecondSignupState();
}

class _SecondSignupState extends State<SecondSignup> {
  @override
  Widget build(BuildContext context) {
    // Determine the screen width to calculate an appropriate scaling factor.
    double currentWidth = MediaQuery.of(context).size.width;
    double scaleFactor = currentWidth / 430; // Base width of 430 for scaling.
    const pageTitle = 'Goal'; // Page title constant.
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
      // Using the SignupForm widget as the body of the scaffold.
      body: SecondSignupForm(
        scaleFactor: scaleFactor,
        firstname: widget.firstname,
        lastname: widget.lastname,
        email: widget.email,
        password: widget.password,
      ),
    );
  }
}
