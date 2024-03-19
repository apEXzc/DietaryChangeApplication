import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecomPage extends StatefulWidget {
  final Map<String, double> nutritionData;

  const RecomPage({Key? key, required this.nutritionData}) : super(key: key);

  @override
  _RecomPageState createState() => _RecomPageState();
}

class _RecomPageState extends State<RecomPage> {
  final TextEditingController _foodNameController = TextEditingController();
  final Map<String, TextEditingController> _nutrientControllers = {
    'Energy(Kcal = mg*4)': TextEditingController(),
    'Fat(g)': TextEditingController(),
    'Protein(g)': TextEditingController(),
    'Carbohydrate(g)': TextEditingController(),
    'Potassium(mg)': TextEditingController(),
    'Cholesterol(mg)': TextEditingController(),
    'vitaminA(IU = 1000*mg)': TextEditingController(),
    'vitaminC(mg)': TextEditingController(),
    'Calcium(mg)': TextEditingController(),
    'Iron(mg)': TextEditingController(),
    'Sodium(mg)': TextEditingController(),
  };
  String? _selectedMealType;
  final List<String> _mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
    'Beverages'
  ];

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
        );
      },
    );
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop(); //
    });
  }

  Future<void> submitData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      print('No token found');
      return;
    }
    Map<String, dynamic> nutrientData = {};
    _nutrientControllers.forEach((key, controller) {
      nutrientData[key] = double.tryParse(controller.text) ?? 0.0;
    });
    try {
      final response = await http.post(
        Uri.parse('http://3.10.233.31:3000/updatedata'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          'foodName': _foodNameController.text,
          'mealType': _selectedMealType,
          'nutrients': nutrientData,
        }),
      );

      if (response.statusCode == 200) {
        _showDialog('Success', 'Data submitted successfully');
      } else {
        _showDialog('Error', 'Failed to submit data');
      }
    } catch (e) {
      _showDialog('Error', 'Error sending request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add food Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextField(_foodNameController, 'Food Name'),
            const SizedBox(height: 20),
            buildDropdown(),
            const SizedBox(height: 20),
            ..._nutrientControllers.entries.map((entry) {
              return buildTextField(entry.value, entry.key,
                  keyboardType: TextInputType.number);
            }).toList(),
            Center(
              child: ElevatedButton(
                onPressed: submitData,
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget buildDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Meal Type',
        border: OutlineInputBorder(),
      ),
      value: _selectedMealType,
      items: _mealTypes.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedMealType = newValue;
        });
      },
    );
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _nutrientControllers.values.forEach((controller) {
      controller.dispose();
    });
    super.dispose();
  }
}
