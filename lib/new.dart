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

        nameController.clear();
        rollNumberController.clear(); // Keep class input value

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Students',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 8.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInputField(nameController, 'Name', Icons.person),
            SizedBox(height: 10),
            _buildInputField(classController, 'Class', Icons.class_),
            SizedBox(height: 10),
            _buildInputField(rollNumberController, 'Roll Number', Icons.confirmation_number),
            SizedBox(height: 20),
            _buildActionButton('Add Student', addStudent, Colors.blueAccent),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.person, color: Colors.blueAccent),
                      title: Text(
                        '${student['name']} (${student['roll_number']})',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text('Class: ${student['class']}'),
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

  Widget _buildInputField(TextEditingController controller, String label, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          labelText: label,
          contentPadding: EdgeInsets.all(12.0),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
