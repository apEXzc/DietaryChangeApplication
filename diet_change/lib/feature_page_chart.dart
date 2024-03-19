import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ProgressRingChart extends StatefulWidget {
  final double consumedCalories;
  final double totalCalories;

  const ProgressRingChart({
    Key? key,
    required this.consumedCalories,
    required this.totalCalories,
  }) : super(key: key);

  @override
  ProgressRingChartState createState() => ProgressRingChartState();
}

class ProgressRingChartState extends State<ProgressRingChart> {
  double get progress => widget.consumedCalories / widget.totalCalories;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const double outerRingDiameter = 110;
    const double outerRingRadius = outerRingDiameter / 2;
    const double centerSpaceRadius = 40;

    return SizedBox(
      width: outerRingDiameter,
      height: outerRingDiameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 0,
              centerSpaceRadius: centerSpaceRadius,
              sections: [
                PieChartSectionData(
                  color: Colors.grey.shade300,
                  value: 100 - (progress * 100),
                  title: '',
                  radius: outerRingRadius,
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                PieChartSectionData(
                  color: Colors.green,
                  value: progress * 100,
                  title: '',
                  radius: outerRingRadius,
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Today’s target',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${widget.totalCalories.toStringAsFixed(0)} KCals',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SurveyPage extends StatefulWidget {
  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final TextEditingController _favoriteFoodController = TextEditingController();
  final TextEditingController _dislikedFoodController = TextEditingController();
  Timer? _favoriteDebounce;
  Timer? _dislikedDebounce;
  List<String> _favoriteFoodResults = [];
  List<String> _dislikedFoodResults = [];
  List<String> _selectedFavoriteFoods = [];
  List<String> _selectedDislikedFoods = [];

  @override
  void initState() {
    super.initState();
    _favoriteFoodController.addListener(_onFavoriteSearchChanged);
    _dislikedFoodController.addListener(_onDislikedSearchChanged);

    _fetchFoodLists();
  }

  void _fetchFoodLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var url = Uri.parse('http://3.10.233.31:3000/submitfav/foodlist');
    try {
      var response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          _selectedFavoriteFoods = List<String>.from(data[0]);
          _selectedDislikedFoods = List<String>.from(data[1]);
        });
      } else {
        if (!mounted) return;
        _showDialog(context, "Failed to fetch food lists");
      }
    } catch (e) {
      if (!mounted) return;
      _showDialog(context, "Server error");
    }
  }

  void _onFavoriteSearchChanged() {
    if (_favoriteDebounce?.isActive ?? false) _favoriteDebounce!.cancel();
    _favoriteDebounce = Timer(const Duration(seconds: 1), () {
      _performSearch(_favoriteFoodController.text, true);
    });
  }

  void _onDislikedSearchChanged() {
    if (_dislikedDebounce?.isActive ?? false) _dislikedDebounce!.cancel();
    _dislikedDebounce = Timer(const Duration(seconds: 1), () {
      _performSearch(_dislikedFoodController.text, false);
    });
  }

  void _performSearch(String query, bool isFavorite) async {
    if (query.isEmpty) {
      setState(() {
        if (isFavorite) {
          _favoriteFoodResults = [];
        } else {
          _dislikedFoodResults = [];
        }
      });
      return;
    }

    var url = Uri.parse('http://3.10.233.31:3000/search?term=$query');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          if (isFavorite) {
            _favoriteFoodResults = List<String>.from(data['descriptions']);
          } else {
            _dislikedFoodResults = List<String>.from(data['descriptions']);
          }
        });
      } else {
        if (!mounted) return;
        _showDialog(context, "Sorry, Invalid data");
      }
    } catch (e) {
      if (!mounted) return;
      _showDialog(context, "Server Error");
    }
  }

  void _showDialog(BuildContext context, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showDialogAndNavigateBack(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _favoriteFoodController.dispose();
    _dislikedFoodController.dispose();
    _favoriteDebounce?.cancel();
    _dislikedDebounce?.cancel();
    super.dispose();
  }

  Widget _buildSearchField(TextEditingController controller, bool isFavorite) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText:
              isFavorite ? 'Search Favorite Food' : 'Search Disliked Food',
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(controller.text, isFavorite),
          ),
        ),
      ),
    );
  }

  Widget _buildFoodList(List<String> foods, bool isFavorite) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: foods.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(foods[index]),
          onTap: () {
            setState(() {
              if (isFavorite) {
                if (!_selectedFavoriteFoods.contains(foods[index])) {
                  _selectedFavoriteFoods.add(foods[index]);
                }
              } else {
                if (!_selectedDislikedFoods.contains(foods[index])) {
                  _selectedDislikedFoods.add(foods[index]);
                }
              }
              _favoriteFoodResults = [];
              _dislikedFoodResults = [];
            });
          },
        );
      },
    );
  }

  Widget _buildSelectedFoodList(bool isFavorite) {
    List<String> selectedFoods =
        isFavorite ? _selectedFavoriteFoods : _selectedDislikedFoods;
    if (selectedFoods.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(isFavorite
            ? 'No favorite foods selected'
            : 'No disliked foods selected'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: selectedFoods.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(selectedFoods[index]),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                selectedFoods.removeAt(index);
              });
            },
          ),
        );
      },
    );
  }

  void _confirmSelection() async {
    var url = Uri.parse('http://3.10.233.31:3000/submitfav');

    var body = json.encode({
      'favoriteFoods': _selectedFavoriteFoods,
      'dislikedFoods': _selectedDislikedFoods,
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        _showDialogAndNavigateBack(context, "Successfully saved");
      } else {
        if (!mounted) return;
        _showDialog(context, "Server Error 1");
      }
    } catch (e) {
      if (!mounted) return;
      _showDialog(context, "Server error 2");
      print('Error occurred while sending data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dietary Survey')),
      body: Column(
        children: [
          _buildSearchField(_favoriteFoodController, true),
          Visibility(
            visible: _favoriteFoodResults.isNotEmpty,
            child: Expanded(child: _buildFoodList(_favoriteFoodResults, true)),
          ),
          _buildSelectedFoodList(true),
          _buildSearchField(_dislikedFoodController, false),
          Visibility(
            visible: _dislikedFoodResults.isNotEmpty,
            child: Expanded(child: _buildFoodList(_dislikedFoodResults, false)),
          ),
          _buildSelectedFoodList(false),
          ElevatedButton(
            onPressed: _confirmSelection,
            child: const Text('Confirm Selection'),
          ),
        ],
      ),
    );
  }
}
