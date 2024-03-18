import 'package:flutter/material.dart';
import 'login_page.dart'; // Import the login page module.
import 'singup_page.dart'; // Import the sign-up page module.
import 'package:flutter/material.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// Entry point for the application.
void main() => runApp(const MainPage());

// This widget serves as the main landing page, where users can either log in or sign up.
class MainPage extends StatelessWidget {
  // Constructor for the MainPage widget.
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Capture the current screen width.
    double currentWidth = MediaQuery.of(context).size.width;
    // Calculate a scale factor based on a reference width.
    double scaleFactor = currentWidth / 430;

    return MaterialApp(
      navigatorObservers: [routeObserver],
      home: Scaffold(
        body: Stack(
          children: [
            // Apply a gradient background.
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Color(0xFFFCE4EC)],
                ),
              ),
            ),
            // Centre the UI elements.
            Builder(
              builder: (innerContext) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Display the logo.
                      Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                            width: 100.0 * scaleFactor,
                            height: 100.0 * scaleFactor,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'LOGO',
                            style: TextStyle(
                                fontSize: 15 * scaleFactor,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      // Provide some spacing.
                      SizedBox(
                        height: 100.0 * scaleFactor,
                      ),
                      // Display promotional texts.
                      SizedBox(
                        child: Text(
                          "Use EatEvolve,",
                          style: TextStyle(
                              fontSize: 30.0 * scaleFactor,
                              color: const Color(0xFF880E4F)),
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      SizedBox(
                        child: Text(
                          "Unlock a Healthier You",
                          style: TextStyle(
                              fontSize: 30.0 * scaleFactor,
                              color: const Color(0xFF880E4F)),
                        ),
                      ),
                      // Provide some spacing.
                      SizedBox(
                        height: 100.0 * scaleFactor,
                      ),
                      // Display the "Sign up for free" button.
                      SizedBox(
                        width: 200.0 * scaleFactor,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              innerContext,
                              MaterialPageRoute(
                                  builder: (context) => const Signup()),
                            );
                          },
                          style: ButtonStyle(backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return const Color(0xFFE91E63);
                            }
                            return const Color(0xFFE91E63).withOpacity(0.7);
                          })),
                          child: const Text('Sign up for free'),
                        ),
                      ),
                      // Provide some spacing.
                      SizedBox(
                        height: 10.0 * scaleFactor,
                      ),
                      // Display the "Log in" button.
                      SizedBox(
                        width: 200.0 * scaleFactor,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              innerContext,
                              MaterialPageRoute(
                                  builder: (context) => const Login()),
                            );
                          },
                          style: ButtonStyle(backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return const Color(0xFFFFC107);
                            }
                            return const Color(0xFFFFC107).withOpacity(0.7);
                          })),
                          child: const Text('Log in'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
