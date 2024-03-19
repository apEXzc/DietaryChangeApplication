import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const String weeklyReportUrl = 'http://3.10.233.31:3000/report/weekly';
const String monthlyReportUrl = 'http://3.10.233.31:3000/report/monthly';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String currentReport = 'weekly';

  String reportContent = '';

  Future<void> fetchReport(String type) async {
    String url = type == 'weekly' ? weeklyReportUrl : monthlyReportUrl;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          reportContent = data.toString();
        });
      } else {
        print('Failed to load report.');
      }
    } catch (e) {
      print('Error fetching report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report'),
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _reportTypeButton('weekly', 'Weekly'),
              _reportTypeButton('monthly', 'Monthly'),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(reportContent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportTypeButton(String type, String text) {
    bool isSelected = type == currentReport;
    return Expanded(
      child: TextButton(
        onPressed: () {
          setState(() {
            currentReport = type;
            fetchReport(type);
          });
        },
        child: Text(text),
        style: TextButton.styleFrom(
          foregroundColor:
              isSelected ? Colors.white : Colors.black, // Text color
          backgroundColor: isSelected
              ? Colors.blueGrey
              : Colors.grey[300], // Background color
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchReport(currentReport);
  }
}
