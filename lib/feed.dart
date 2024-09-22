import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'attendance.dart';
import 'new.dart';
import 'attendance_history.dart';

class FeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance App", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue, // Customize app bar color
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0), // Add padding for better spacing
        child: ListView(
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.add, size: 28, color: Colors.blue),
                title: Text('Add New Student', style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewStudentPage()),
                  );
                },
              ),
            ),
            Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.check_circle, size: 28, color: Colors.green),
                title: Text('Take Attendance', style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AttendancePage()),
                  );
                },
              ),
            ),
            Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.history, size: 28, color: Colors.orange),
                title: Text('Attendance History', style: TextStyle(fontSize: 18)),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  List<String>? history = prefs.getStringList('attendance_history') ?? [];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendanceHistoryPage(history: history),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}