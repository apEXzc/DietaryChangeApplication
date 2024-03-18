import 'package:flutter/material.dart';

class DailyNutrition extends StatefulWidget {
  final Map<String, double> nutritionData;

  const DailyNutrition({Key? key, required this.nutritionData})
      : super(key: key);

  @override
  _DailyNutritionState createState() => _DailyNutritionState();
}

class _DailyNutritionState extends State<DailyNutrition> {
  late List<NutritionData> data;
  ScrollController _controller = ScrollController();
  @override
  void initState() {
    super.initState();

    data = [];
    widget.nutritionData.forEach((key, value) {
      if (key.startsWith('r')) {
        String nonRKey = key.substring(1);
        double nonRValue = widget.nutritionData[nonRKey] ?? 1.0;
        double ratio = value / nonRValue;
        if (ratio > 1.0) {
          ratio = 1.0;
        }

        data.add(NutritionData(nonRKey, ratio * 100));
      }
    });
    data.forEach((item) {
      print('Mapped Name: ${item.name}, Value: ${item.value}');
    });
  }

  String _getUnit(String name) {
    if (['Fat', 'Protein', 'Carbohydrate'].contains(name)) {
      return 'g';
    } else if (['VitaminA'].contains(name)) {
      return 'IU';
    }
    return 'mg';
  }

  void _showValueDialog(String name, double value) {
    double originalValue = widget.nutritionData[name] ?? 0.0;
    double rValue = widget.nutritionData['r$name'] ?? 0.0;
    double difference = originalValue - rValue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(name),
          content: Text(
              'Remaining: ${difference.toStringAsFixed(2)} ${_getUnit(name)}'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _onNotification(ScrollNotification notification) {
    if (notification is OverscrollNotification) {
      if (_controller.offset <= 0 && notification.overscroll < 0) {
        return false;
      }
      if (_controller.position.maxScrollExtent <= _controller.offset &&
          notification.overscroll > 0) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
      child: ListView.builder(
        controller: _controller,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPress: () =>
                _showValueDialog(data[index].name, data[index].value),
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      data[index].name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    LinearProgressIndicator(
                      value: data[index].value / 100,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.lightGreen),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class NutritionData {
  final String name;
  final double value;

  NutritionData(this.name, this.value);
}
