import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<Map<String, dynamic>> students = [];
  String classNumber = '';
  String subjectCode = '';
  bool isLoading = false;
  List<String> attendanceHistory = [];

  @override
  void initState() {
    super.initState();
    _loadAttendanceHistory();
  }

  void _loadAttendanceHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      attendanceHistory = prefs.getStringList('attendance_history') ?? [];
    });
  }

  void _saveAttendanceHistory(String entry) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      attendanceHistory.add(entry);
      prefs.setStringList('attendance_history', attendanceHistory);
    });
  }

  void getStudents() async {
    if (classNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter class number.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse('https://iec-college.onrender.com/students/$classNumber'),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      setState(() {
        students = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load students.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void markAttendance() async {
    if (subjectCode.isEmpty) {
      await _showSubjectCodeDialog();
      if (subjectCode.isEmpty) return;
    }

    setState(() {
      isLoading = true;
    });

    List<Map<String, dynamic>> attendance = students.map((student) {
      return {
        'roll_number': student['roll_number'],
        'name': student['name'],
        'status': (student['status'] ?? false) ? 'Present' : 'Absent',
        'class_number': classNumber,
        'subject_code': subjectCode,
      };
    }).toList();

    final response = await http.post(
      Uri.parse('https://iec-college.onrender.com/mark_attendance'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(attendance),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 201) {
      final result = json.decode(response.body);
      _saveAttendanceHistory('Class: $classNumber, Subject: $subjectCode, Link: ${result['link']}');

      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Attendance Marked!', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Link: ${result['link']}'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: result['link']));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Link copied to clipboard!')),
                    );
                  },
                  child: Text('Copy Link'),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to mark attendance.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _showSubjectCodeDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String tempSubjectCode = '';
        return AlertDialog(
          title: Text('Enter Subject Code'),
          content: TextField(
            onChanged: (value) {
              tempSubjectCode = value;
            },
            decoration: InputDecoration(labelText: 'Subject Code'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                setState(() {
                  subjectCode = tempSubjectCode;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showStudentDetails(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${student['name']} Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Roll Number: ${student['roll_number']}'),
              Text('Status: ${(student['status'] ?? false) ? 'Present' : 'Absent'}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Take Attendance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  child: TextField(
                    onChanged: (value) => classNumber = value,
                    decoration: InputDecoration(
                      labelText: 'Enter Class Number',
                      contentPadding: EdgeInsets.all(12.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: getStudents,
                  child: Text('Load Students'),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return Card(
                        elevation: 2,
                        child: ListTile(
                          title: Text('${student['name']}'),
                          onLongPress: () => _showStudentDetails(student),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: markAttendance,
                  child: Text('Submit Attendance'),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 6.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
