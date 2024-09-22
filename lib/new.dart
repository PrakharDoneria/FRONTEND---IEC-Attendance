import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewStudentPage extends StatefulWidget {
  @override
  _NewStudentPageState createState() => _NewStudentPageState();
}

class _NewStudentPageState extends State<NewStudentPage> {
  final List<Map<String, dynamic>> students = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();

  void addStudent() async {
    final name = nameController.text;
    final classNumber = classController.text;
    final rollNumber = rollNumberController.text;

    if (name.isNotEmpty && classNumber.isNotEmpty && rollNumber.isNotEmpty) {
      final response = await http.post(
        Uri.parse('https://iec-college.onrender.com/add_students'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode([
          {
            'name': name,
            'class': classNumber,
            'roll_number': rollNumber,
          }
        ]),
      );

      if (response.statusCode == 201) {
        setState(() {
          students.add({
            'name': name,
            'class': classNumber,
            'roll_number': rollNumber,
          });
        });

        // Clear the text fields after adding
        nameController.clear();
        classController.clear();
        rollNumberController.clear();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Student added successfully!'),
          backgroundColor: Colors.green,
        ));
      } else {
        final errorMessage = json.decode(response.body)['error'] ?? 'Failed to add student.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all fields.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void uploadStudentList() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Upload student list functionality to be implemented.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Students', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  contentPadding: EdgeInsets.all(12.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4,
              child: TextField(
                controller: classController,
                decoration: InputDecoration(
                  labelText: 'Class',
                  contentPadding: EdgeInsets.all(12.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4,
              child: TextField(
                controller: rollNumberController,
                decoration: InputDecoration(
                  labelText: 'Roll Number',
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
              onPressed: addStudent,
              child: Text(
                'Add Student',
                style: TextStyle(fontSize: 16),
              ),
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
                      title: Text('${student['name']} (${student['roll_number']})'),
                      subtitle: Text('Class: ${student['class']}'),
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
              onPressed: uploadStudentList,
              child: Text(
                'Upload Students List',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
