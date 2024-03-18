import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrueRecom extends StatefulWidget {
  @override
  _TrueRecomState createState() => _TrueRecomState();
}

class _TrueRecomState extends State<TrueRecom> {
  Timer? _timer;
  String? _selectedMealType;
  List<String> _recipes = [];
  String? _selectedRecipe;
  Map<String, Map<String, dynamic>> _recipeDetails = {};
  final Map<String, String> _mealTypes = {
    "": "Select Meal Type",
    "0": "Breakfast/Brunch",
    "1": "Lunch/Dinner",
    "2": "Beverage",
    "3": "Snacks/Dessert",
    "9": "Others",
  };

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildDropdown() {
    return DropdownButton<String>(
      value: _selectedMealType,
      onChanged: (String? newValue) {
        setState(() {
          _selectedMealType = newValue;
          if (newValue != null && newValue.isNotEmpty) {
            _fetchRecommendations(newValue, 'list');
          }
        });
      },
      items: _mealTypes.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
    );
  }

  Widget _buildRecipeDropdown() {
    return DropdownButton<String>(
      value: _selectedRecipe,
      onChanged: (String? newValue) {
        setState(() {
          _selectedRecipe = newValue;
        });
      },
      items: _recipes.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      isExpanded: true,
    );
  }

  void _fetchRecommendations(String param, String returnType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print('No token found');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            'http://10.114.74.46:3000/recomsys?param=$param&returnType=$returnType'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (returnType == 'list') {
          setState(() {
            _recipes.clear();
            _recipeDetails.clear();
            for (var recipe in data) {
              String name = recipe['name'];
              _recipes.add(name);
              _recipeDetails[name] = recipe; // 存储食谱的详细信息
            }
            if (!_recipes.contains(_selectedRecipe)) {
              _selectedRecipe = _recipes.isNotEmpty ? _recipes.first : null;
            }
          });
        } else {
          setState(() {
            _selectedRecipe = data['name'];
            // 确保也更新了 _recipeDetails
            _recipeDetails[_selectedRecipe!] = data;
          });
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _addToTodayData() async {
    if (_selectedRecipe == null) {
      print('No recipe selected');
      return;
    }

    final recipeData = _recipeDetails[_selectedRecipe];
    if (recipeData == null) {
      print('No data for selected recipe');
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print('No token found');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.114.74.46:3000/modifydata'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          'nutritionData': recipeData,
        }),
      );

      if (response.statusCode == 200) {
        _showDialog(context, "Successful", "Data added successfully.");
      } else {
        _showDialog(context, "Error", "Failed to add data.");
      }
    } catch (e) {
      _showDialog(context, "Error", "Error sending request: $e");
    }
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("True Recommendations"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildDropdown(),
            if (_selectedRecipe != null || _recipes.isNotEmpty)
              Center(
                child: Container(
                  width: screenWidth * 0.9,
                  child: _buildRecipeDropdown(),
                ),
              ),
            ElevatedButton(
              onPressed: () =>
                  _fetchRecommendations(_selectedMealType ?? '', 'single'),
              child: Text('Random Recommendations'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToRecipeDetail(context),
              child: Text('Detailed Recipes'),
            ),
            ElevatedButton(
              onPressed: _addToTodayData,
              child: Text("Add to Today's Data"),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRecipeDetail(BuildContext context) {
    print('Navigate to recipe detail called.');
    if (_selectedRecipe != null) {
      print('Selected recipe: $_selectedRecipe');
      final recipeData = _recipeDetails[_selectedRecipe];
      if (recipeData != null) {
        print('Navigating to RecipeDetailPage with data: $recipeData');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailPage(recipeData: recipeData),
          ),
        );
      } else {
        print('No data found for selected recipe.');
      }
    } else {
      print('No recipe selected.');
    }
  }
}

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipeData;

  RecipeDetailPage({Key? key, required this.recipeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 将directions字符串分割成列表
    List<String> directions = recipeData['directions']
        .split('.')
        .where((item) => (item as String).trim().isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(recipeData['name'] ?? 'Recipe Detail'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (var i = 0; i < directions.length; i++)
              ListTile(
                leading: Text('${i + 1}'),
                title: Text(directions[i]),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => _showIngredientsDialog(
                      context, recipeData['ingredients']),
                  child: Text('Show Ingredients'),
                ),
                ElevatedButton(
                  onPressed: () => _showNutritionInfoDialog(context),
                  child: Text('Show Nutrition Info'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showIngredientsDialog(BuildContext context, String ingredients) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ingredients'),
          content: SingleChildScrollView(
            child: Text(ingredients),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showNutritionInfoDialog(BuildContext context) {
    // 提取需要的字段
    Map<String, dynamic> nutritionInfo = {
      'calories': recipeData['calories'],
      'carbohydrates_g': recipeData['carbohydrates_g'],
      'sugars_g': recipeData['sugars_g'],
      'fat_g': recipeData['fat_g'],
      'saturated_fat_g': recipeData['saturated_fat_g'],
      'cholesterol_mg': recipeData['cholesterol_mg'],
      'protein_g': recipeData['protein_g'],
      'dietary_fiber_g': recipeData['dietary_fiber_g'],
      'sodium_mg': recipeData['sodium_mg'],
      'calories_from_fat': recipeData['calories_from_fat'],
      'calcium_mg': recipeData['calcium_mg'],
      'iron_mg': recipeData['iron_mg'],
      'magnesium_mg': recipeData['magnesium_mg'],
      'potassium_mg': recipeData['potassium_mg'],
      'vitamin_a_iu_IU': recipeData['vitamin_a_iu_IU'],
      'niacin_equivalents_mg': recipeData['niacin_equivalents_mg'],
      'vitamin_c_mg': recipeData['vitamin_c_mg'],
      'folate_mcg': recipeData['folate_mcg'],
      'thiamin_mg': recipeData['thiamin_mg'],
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nutrition Information'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: nutritionInfo.entries
                  .map((entry) => Text('${entry.key}: ${entry.value}'))
                  .toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
