import 'package:flutter/material.dart';
import 'feature_page_chart.dart';
import 'botton_bar.dart';
import 'recom.dart';
import 'truerecom.dart';
import 'daily_nutrition_chart.dart';
import './report.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';

class Feature extends StatefulWidget {
  const Feature({super.key});

  @override
  State<Feature> createState() => _FeatureState();
}

class _FeatureState extends State<Feature>
    with RouteAware, WidgetsBindingObserver {
  double totalCalories = 9999;
  double consumedCalories = 999;
  Map<String, double> nutritionData = {};
  bool _showTopBanner = true;
  late Future _nutritionDataFuture;
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _nutritionDataFuture = fetchData();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      fetchData();
    }
  }

  @override
  void didPopNext() {
    fetchData();
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print('No token found');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.114.74.46:3000/userupnutrition'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          totalCalories = data['energy'].round().toDouble();
          consumedCalories = data['rEnergy'].round().toDouble();
          nutritionData = {
            'Fat': data['Fat'].toDouble(),
            'rFat': data['rFat'].toDouble(),
            'Protein': data['Protein'].toDouble(),
            'rProtein': data['rProtein'].toDouble(),
            'Carbohydrate': data['Carbohydrate'].toDouble(),
            'rCarbohydrate': data['rCarbohydrate'].toDouble(),
            'VitaminA': data['vitaminA'].toDouble(),
            'rVitaminA': data['rvitaminA'].toDouble(),
            'VitaminC': data['vitaminC'].toDouble(),
            'rVitaminC': data['rvitaminC'].toDouble(),
            'Calcium': data['Ca'].toDouble(),
            'rCalcium': data['rCa'].toDouble(),
            'Iron': data['Fe'].toDouble(),
            'rIron': data['rFe'].toDouble(),
            'Sodium': data['Na'].toDouble(),
            'rSodium': data['rNa'].toDouble(),
            'Potassium': data['K'].toDouble(),
            'rPotassium': data['rK'].toDouble(),
            'Cholesterol': data['Chol'].toDouble(),
            'rCholesterol': data['rChol'].toDouble(),
          };
        });
      } else {
        print(
            'Failed to load nutrition data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = 0;
    });
    switch (index) {
      case 0:
        /* Navigator.pushNamed(context, '/dashboard'); */
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportPage(),
          ),
        );
        break;
      case 2:
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SurveyPage()),
        );
        break;
      case 4:
      /* Navigator.pushNamed(context, '/data_analysis'); */
    }
  }

  @override
  Widget build(BuildContext context) {
    double currentWidth = MediaQuery.of(context).size.width;
    double scaleFactor = currentWidth / 430;
    const pageTitle = 'EatEvolve';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56.0,
        leadingWidth: 56.0,
        leading: InkWell(
          onTap: () {},
          child: Container(
            width: 40.0,
            height: 40.0,
            margin: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        ),
        title: Text(
          pageTitle,
          style: TextStyle(
            fontSize: scaleFactor * 20,
            color: const Color.fromRGBO(0, 0, 0, 1),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.black, // Choosing the icon color
            ),
            onPressed: () {
              // Define the action when the bell icon is pressed
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_showTopBanner)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrueRecom(),
                    ),
                  );
                },
                child: Container(
                  color: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Don't know what to eat?",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      InkWell(
                        child: Icon(Icons.close, color: Colors.white),
                        onTap: () {
                          setState(() {
                            _showTopBanner = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(top: _showTopBanner ? 50.0 : 0),
            child: FutureBuilder(
              future: _nutritionDataFuture,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 30.0 *
                                  scaleFactor), // Add padding to the left
                          child: const Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 15.0 *
                                  scaleFactor), // Add padding to the left
                          child: const Text(
                            'Calories',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 253.0,
                              child: ProgressRingChart(
                                consumedCalories: consumedCalories,
                                totalCalories: totalCalories,
                              ),
                            ),
                            SizedBox(
                              width: 40 * scaleFactor,
                            ),
                            SizedBox(
                              child: Padding(
                                padding:
                                    EdgeInsets.only(left: 20.0 * scaleFactor),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 15 * scaleFactor,
                                              height: 15 * scaleFactor,
                                              decoration: const BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            SizedBox(width: 8 * scaleFactor),
                                            Text(
                                                '${consumedCalories.toInt()} Kals Consumed'),
                                          ],
                                        ),
                                        SizedBox(height: 8 * scaleFactor),
                                        Row(
                                          children: [
                                            Container(
                                              width: 15 * scaleFactor,
                                              height: 15 * scaleFactor,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            SizedBox(width: 8 * scaleFactor),
                                            Text(
                                                '${(totalCalories - consumedCalories).toInt()} Kals Remaining'),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 15.0 *
                                  scaleFactor), // Add padding to the left
                          child: const Text(
                            'Nutrients',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        SizedBox(
                          key: UniqueKey(),
                          child: DailyNutrition(nutritionData: nutritionData),
                        )
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
        onAddPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecomPage(nutritionData: nutritionData),
            ),
          );
        },
      ),
    );
  }
}
