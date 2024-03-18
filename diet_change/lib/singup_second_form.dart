import 'package:diet_change/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum QuestionType { text, multipleChoice, singleChoice }

class Question {
  String questionText;
  QuestionType type;
  List<String>? options;

  Question({
    required this.questionText,
    required this.type,
    this.options,
  });
}

class SecondSignupForm extends StatefulWidget {
  final double scaleFactor;
  final String firstname;
  final String lastname;
  final String email;
  final String password;

  // Constructor: initializes scaleFactor and an optional key
  const SecondSignupForm({
    super.key,
    required this.scaleFactor,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
  });

  @override
  State<SecondSignupForm> createState() => _SecondSignupFormState();
}

class _SecondSignupFormState extends State<SecondSignupForm> {
  int currentQuestionIndex = 0;
  int failedIndex = -1;
  Map<int, dynamic> answers = {};
  Map<int, TextEditingController> textControllers = {};
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < questions.length; i++) {
      if (questions[i].type == QuestionType.text) {
        textControllers[i] = TextEditingController();
      }
    }
  }

  List<Question> questions = [
    Question(questionText: 'Your Age (9-100)', type: QuestionType.text),
    Question(
      questionText: 'Your Sex',
      type: QuestionType.singleChoice,
      options: ['Male', 'Female'],
    ),
    Question(questionText: 'Height (50-255 cm)', type: QuestionType.text),
    Question(questionText: 'Weight (5-400 kg)', type: QuestionType.text),
    Question(
      questionText: 'Do you have any of the following diseases?',
      type: QuestionType.multipleChoice,
      options: [
        'diabetes',
        'Cardiovascular disease',
        'Gastrointestinal problems',
        'Bone and joint health',
        'Respiratory diseases',
        'None of the above'
      ],
    ),
    Question(
      questionText: 'What is your diet type?',
      type: QuestionType.multipleChoice,
      options: [
        'vegetarian',
        'gluten-free',
        'Ketogenic',
        'Paleo',
        'Omnivores',
        'None of the above'
      ],
    ),
    Question(
      questionText: 'How many days do you exercise?',
      type: QuestionType.singleChoice,
      options: [
        '5 days or more',
        '1-3 days',
        '3-5 days',
        'Everyday / heavy physical exercise',
      ],
    ),
    Question(
      questionText: 'What is the purpose of your use of the Software?',
      type: QuestionType.singleChoice,
      options: [
        'Weight Loss',
        'Nutritional Balance',
        'Managing Speclfic Health Conditions',
        'None of the above'
      ],
    ),
  ];
  void goToNextQuestion(BuildContext context) {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        textControllers[currentQuestionIndex]?.clear();
        currentQuestionIndex++;
      });
    } else {
      if (validateAnswers()) {
        submitAnswers(context);
      }
    }
  }

  void goToPreviousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        textControllers[currentQuestionIndex]?.clear();
        currentQuestionIndex--;
      });
    }
  }

  bool validateAnswers() {
    for (int i = 0; i < questions.length; i++) {
      dynamic answer = answers[i];
      switch (questions[i].type) {
        case QuestionType.text:
          if (i == 0) {
            // Age and Height questions
            if (answer == null ||
                answer.isEmpty ||
                !isNumeric(answer) ||
                int.parse(answer) < 9 ||
                int.parse(answer) > 100) {
              setState(() {
                currentQuestionIndex = i;
                failedIndex = i;
              });
              return false;
            }
          } else if (i == 2) {
            if (answer == null ||
                answer.isEmpty ||
                !isNumeric(answer) ||
                int.parse(answer) > 255 ||
                int.parse(answer) < 100) {
              setState(() {
                currentQuestionIndex = i;
                failedIndex = i;
              });
              return false;
            }
          } else if (i == 3) {
            // Question with numeric answer
            if (answer == null ||
                answer.isEmpty ||
                !isNumeric(answer) ||
                int.parse(answer) < 5 ||
                int.parse(answer) > 400) {
              setState(() {
                currentQuestionIndex = i;
                failedIndex = i;
              });
              return false;
            }
          } else {
            // Other text questions
            if (answer == null || answer.isEmpty) {
              setState(() {
                currentQuestionIndex = i;
                failedIndex = i;
              });
              return false;
            }
          }
          break;
        case QuestionType.singleChoice:
          if (i == 1 || i == 4) {
            // Sex and food allergy questions
            if (answer == null || answer.isEmpty) {
              setState(() {
                currentQuestionIndex = i;
                failedIndex = i;
              });
              return false;
            }
          }
          break;
        case QuestionType.multipleChoice:
          if (i == 8 || i == 9) {
            // Diet type and software purpose questions
            if (answer == null || answer.isEmpty || answer.length < 1) {
              setState(() {
                currentQuestionIndex = i;
                failedIndex = i;
              });
              return false;
            }
          }
          break;
        default:
          break;
      }
    }
    failedIndex = -1;
    return true;
  }

  bool isNumeric(String str) {
    if (str.isEmpty) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  Map<String, dynamic> convertMapForJson(Map<int, dynamic> originalMap) {
    final Map<String, dynamic> jsonMap = {};
    originalMap.forEach((key, value) {
      jsonMap[key.toString()] = value;
      if (value is List) {
        jsonMap[key.toString()] = value.map((item) => item.toString()).toList();
      }
    });
    return jsonMap;
  }

  void submitAnswers(BuildContext context) async {
    if (validateAnswers()) {
      var url = Uri.parse('http://10.114.74.46:3000/submitreginfo');
      try {
        var response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'firstname': widget.firstname,
            'lastname': widget.lastname,
            'email': widget.email,
            'password': widget.password,
            'answers': convertMapForJson(answers)
          }),
        );
        if (!mounted) return;
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        if (response.statusCode == 200) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const Login()));
        } else if (response.statusCode == 400) {
          _showEmailInUseDialog(context);
        } else {
          print('Failed to submit data: ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void _showEmailInUseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Email Already in Use'),
          content: const Text(
              'The provided email address is already in use. Please use a different email.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentQuestion = questions[currentQuestionIndex];

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
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                  color:
                                      const Color(0xFF059669).withOpacity(0.7),
                                  width: 1)),
                          child: Text(
                            '1',
                            style: TextStyle(
                              color: const Color(0xFF059669),
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
                        child: const Text(
                          'Create account',
                          style: TextStyle(color: Colors.grey),
                        ),
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
                            backgroundColor: const Color(0xFF059669),
                          ),
                          child: Text(
                            '2',
                            style: TextStyle(
                              color: Colors.white,
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
                  'Your personal infomation',
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
                    ' We\'ll provide the services based on your personal information.',
                    style: TextStyle(
                      fontSize: 14 * widget.scaleFactor,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),

                // Spacer to maintain a consistent spacing between elements
                SizedBox(height: 40 * widget.scaleFactor),

                Text(
                  currentQuestion.questionText,
                  style: TextStyle(
                    color: currentQuestionIndex == failedIndex
                        ? Colors.red
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 22 * widget.scaleFactor,
                  ),
                ),
                SizedBox(height: 20 * widget.scaleFactor),
                if (currentQuestion.type == QuestionType.text)
                  Container(
                    margin: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextField(
                      controller: textControllers[currentQuestionIndex],
                      onChanged: (value) =>
                          answers[currentQuestionIndex] = value,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      ),
                    ),
                  ),

                if (currentQuestion.type == QuestionType.singleChoice)
                  Column(
                    children: currentQuestion.options!.map((option) {
                      return RadioListTile(
                        title: Text(option),
                        value: option,
                        groupValue: answers[currentQuestionIndex],
                        onChanged: (value) {
                          setState(() {
                            answers[currentQuestionIndex] = value;
                          });
                        },
                      );
                    }).toList(),
                  ),
                if (currentQuestion.type == QuestionType.multipleChoice)
                  Column(
                    children: currentQuestion.options!.map((option) {
                      bool isNoneOfTheAboveSelected =
                          answers[currentQuestionIndex]
                                  ?.contains('None of the above') ??
                              false;
                      bool isCurrentOptionSelected =
                          answers[currentQuestionIndex]?.contains(option) ??
                              false;

                      return CheckboxListTile(
                        title: Text(option),
                        value: isCurrentOptionSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (option == 'None of the above') {
                              if (value == true) {
                                answers[currentQuestionIndex] = [
                                  'None of the above'
                                ];
                              } else {
                                answers[currentQuestionIndex] = [];
                              }
                            } else {
                              if (value == true) {
                                if (isNoneOfTheAboveSelected) {
                                  answers[currentQuestionIndex] = [option];
                                } else {
                                  answers[currentQuestionIndex] =
                                      (answers[currentQuestionIndex] ?? [])
                                        ..add(option);
                                }
                              } else {
                                answers[currentQuestionIndex]?.remove(option);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 20, bottom: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (currentQuestionIndex > 0)
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 35,
                          child: ElevatedButton(
                            onPressed: goToPreviousQuestion,
                            child: const Text('Previous'),
                          ),
                        ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 35,
                        child: ElevatedButton(
                          onPressed: () => goToNextQuestion(context),
                          child: Text(
                              currentQuestionIndex < questions.length - 1
                                  ? 'Next'
                                  : 'Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    textControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}
