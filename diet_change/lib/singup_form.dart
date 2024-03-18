import 'package:diet_change/singup_second_page.dart';
import 'package:flutter/material.dart';

class SignupForm extends StatefulWidget {
  final double scaleFactor;
  final TextEditingController firstnameController;
  final TextEditingController lastnameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmController;

  // Constructor: initializes scaleFactor and an optional key
  const SignupForm(
      {super.key,
      required this.scaleFactor,
      required this.firstnameController,
      required this.lastnameController,
      required this.emailController,
      required this.passwordController,
      required this.passwordConfirmController});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  // Key used to access the row widget's dimensions

  void _SignupLogic() {
    String firstname = widget.firstnameController.text;
    String lastname = widget.lastnameController.text;
    String email = widget.emailController.text;
    String password = widget.passwordController.text;
    String passwordconfirmed = widget.passwordConfirmController.text;
    if (firstname.isEmpty) {
      _showDialog("First name cannot be empty");
      return;
    }
    if (lastname.isEmpty) {
      _showDialog("Last name cannot be empty");
      return;
    }
    if (email.isEmpty) {
      _showDialog("Email cannot be empty");
      return;
    }
    if (password.isEmpty) {
      _showDialog("Password cannot be empty");
      return;
    }
    if (passwordconfirmed.isEmpty) {
      _showDialog("Password confirmation cannot be empty");
      return;
    }
    RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
      caseSensitive: false,
      multiLine: false,
    );
    bool emailValid = emailRegex.hasMatch(email);

    RegExp passwordRegexp = RegExp(r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,16}$");
    bool passwordValid = passwordRegexp.hasMatch(password);
    bool passwordsMatch = password == passwordconfirmed;

    if (!emailValid) {
      _showDialog("Invalid email format");
    } else if (!passwordValid) {
      _showDialog(
          "Password must be 8-16 characters long and include letters and numbers.");
    } else if (!passwordsMatch) {
      _showDialog("Passwords do not match.");
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SecondSignup(
                  firstname: firstname,
                  lastname: lastname,
                  email: email,
                  password: password,
                )),
      );
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("verification error"),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(left: 15 * widget.scaleFactor),
        child: Column(
          children: [
            // Providing a top spacing for the form elements
            SizedBox(height: 20 * widget.scaleFactor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // This row contains steps for account creation
                SizedBox(
                  width: 402 * widget.scaleFactor,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Button indicating step 1: Account creation
                      SizedBox(
                        width: 24 * widget.scaleFactor,
                        height: 24 * widget.scaleFactor,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: const Color(0xFF059669),
                          ),
                          child: Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15 * widget.scaleFactor,
                            ),
                          ),
                        ),
                      ),
                      // Spacer to maintain a consistent spacing between elements
                      SizedBox(width: 5 * widget.scaleFactor),

                      // Option to navigate to account creation step
                      GestureDetector(
                        onTap: () {},
                        child: const Text('Create account'),
                      ),
                      const Text(' ----- '),

                      // Button indicating step 2: Fitness Goals
                      SizedBox(
                        width: 24 * widget.scaleFactor,
                        height: 24 * widget.scaleFactor,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                  color:
                                      const Color(0xFF059669).withOpacity(0.7),
                                  width: 1)),
                          child: Text(
                            '2',
                            style: TextStyle(
                              color: const Color(0xFF059669).withOpacity(0.7),
                              fontSize: 15 * widget.scaleFactor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5 * widget.scaleFactor),

                      // Option to navigate to fitness goals step
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Fitness Goals',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const Text(' ----- '),

                      // Button indicating step 3: Start
                      SizedBox(
                        width: 24 * widget.scaleFactor,
                        height: 24 * widget.scaleFactor,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.white,
                            side: BorderSide(
                                color: const Color(0xFF059669).withOpacity(0.7),
                                width: 1),
                          ),
                          child: Text(
                            '3',
                            style: TextStyle(
                              color: const Color(0xFF059669).withOpacity(0.7),
                              fontSize: 15 * widget.scaleFactor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5 * widget.scaleFactor),

                      // Option to navigate to start step
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Start',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                // Spacer to maintain a consistent spacing between elements
                SizedBox(height: 40 * widget.scaleFactor),

                // Heading for the account information section
                Text(
                  'Account Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22 * widget.scaleFactor,
                  ),
                ),

                // Spacer to maintain a consistent spacing between elements
                SizedBox(height: 10 * widget.scaleFactor),

                // This section displays additional information about the signup process.
                SizedBox(
                  width: 402 * widget.scaleFactor,
                  child: Text(
                    'We’ll get you up and running so you can verify your personal information and customize your account.',
                    style: TextStyle(
                      fontSize: 14 * widget.scaleFactor,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),

                // Spacer to maintain a consistent spacing between elements
                SizedBox(height: 40 * widget.scaleFactor),

                Row(
                  children: [
                    SizedBox(
                      width: 187 * widget.scaleFactor,
                      height: 40 * widget.scaleFactor,
                      child: TextFormField(
                        controller: widget.firstnameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                10.0 * widget.scaleFactor),
                          ),
                          labelText: 'First Name',
                        ),
                      ),
                    ),
                    SizedBox(width: 20 * widget.scaleFactor),
                    SizedBox(
                      width: 187 * widget.scaleFactor,
                      height: 40 * widget.scaleFactor,
                      child: TextFormField(
                        controller: widget.lastnameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                10.0 * widget.scaleFactor),
                          ),
                          labelText: 'Last Name',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20 * widget.scaleFactor),

                SizedBox(
                  width: 394 * widget.scaleFactor,
                  height: 40 * widget.scaleFactor,
                  child: TextFormField(
                    controller: widget.emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10.0 * widget.scaleFactor),
                      ),
                      labelText: 'Email address',
                    ),
                  ),
                ),

                SizedBox(height: 20 * widget.scaleFactor),

                SizedBox(
                  width: 394 * widget.scaleFactor,
                  height: 40 * widget.scaleFactor,
                  child: TextFormField(
                    controller: widget.passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10.0 * widget.scaleFactor),
                      ),
                      labelText: 'Create Your Password',
                    ),
                  ),
                ),

                SizedBox(height: 20 * widget.scaleFactor),

                SizedBox(
                  width: 394 * widget.scaleFactor,
                  height: 40 * widget.scaleFactor,
                  child: TextFormField(
                    controller: widget.passwordConfirmController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10.0 * widget.scaleFactor),
                      ),
                      labelText: 'Confirm Your Password',
                    ),
                  ),
                ),

                SizedBox(height: 40 * widget.scaleFactor),

                SizedBox(
                  width: 394 * widget.scaleFactor,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                          fontSize: 12 * widget.scaleFactor,
                          color: Colors.black),
                      children: const [
                        TextSpan(
                            text:
                                'By registering, you agree to our collection and use of your personal information as described in our '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(color: Colors.red),
                        ),
                        TextSpan(
                          text:
                              '. Please ensure you\'ve read and understood our terms before proceeding.',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20 * widget.scaleFactor),
                SizedBox(
                  width: 394 * widget.scaleFactor,
                  height: 48 * widget.scaleFactor,
                  child: ElevatedButton(
                    onPressed: () {
                      _SignupLogic();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20 * widget.scaleFactor),
                      ),
                      backgroundColor: const Color(0xFF059669),
                    ),
                    child: const Text('Next Step'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
