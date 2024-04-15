import 'dart:convert';

import 'package:app/pages/list_elves.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class MarquerAbsence extends StatefulWidget {
  final String email;
  final String name;
  MarquerAbsence(this.email, this.name);

  @override
  State<MarquerAbsence> createState() => _MarquerAbsenceState();
}

class _MarquerAbsenceState extends State<MarquerAbsence> {
  String errorMessage='';
  late Response response2;
  late List<bool> absenceList;
  late DateTime selectedDateTime;
  late String selectedOption;
  List<String> options = ['matiere 1', 'matiere 2', 'matiere 3'];

  final _formKey = GlobalKey<FormState>(); // Key for the form

  @override
  void initState() {
    super.initState();
    absenceList = [];
    selectedDateTime = DateTime.now();
    selectedOption = options.first;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDateTime) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Marquer Absence"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromARGB(160, 0, 54, 99),
      ),
      body: Form(
        key: _formKey,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: getEleves(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Center(child: Text('No Eleves'));
            } else {
              if (absenceList.isEmpty) {
                absenceList = List.generate(snapshot.data!.length, (index) => true);
              }
              return SingleChildScrollView( // Wrap in SingleChildScrollView to prevent overflow
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectDateTime(context),
                      child: Text("Sélectionnez la date et l'heure"),
                    ),
                    SizedBox(height: 20),
                    DropdownButton<String>(
                      value: selectedOption,
                      items: options.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option, 
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedOption = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final eleve = snapshot.data![index];
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: CheckboxListTile(
                            title: Text(eleve['name']),
                            value: absenceList[index],
                            onChanged: (bool? value) {
                              setState(() {
                                absenceList[index] = value!;
                                print(absenceList);
                              });
                            },
                          ),
                        );
                      },
                    ), Center(
                          child: GestureDetector(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                   
                               Map<String, dynamic> userData = {
                                'email': widget.email,
                                'selectedDateTime': selectedDateTime.toString(),
                                'selectedOption': selectedOption,
                                'absenceList': absenceList.toString(),
                              };
                                        print(userData);
                                
                                Response response = await post(
                                  Uri.parse("https://firas.alwaysdata.net/api/marquerAbsence"),
                                  body: userData,   
                                );
                                   print(userData);
                                   response2 = await post(
                                          Uri.parse(
                                              'https://fcm.googleapis.com/fcm/send'),
                                          headers: {
                                            'Content-Type':
                                                'application/json',
                                            'Authorization':
                                                'key=AAAA4WMATYA:APA91bFxzOAlkcvXkHv6pyk9-Bqb8rtUwF6TXiBiEAQLuiGUwr6X084p-GR2lSSfJM_-H6urIktOdKGYhqPjKEscHN9XoxN8AMMvxXjbq27ZzQbk-S589EH-euzjPeduKyoXgt1lXuSE',
                                          },
                                          body: jsonEncode({
                                            "to": token,
                                            "notification": {
                                              "title": "Notification",
                                              "body": "votre enfant est absent"
                                            }
                                          }),
                                        );
                                if (response.statusCode == 200) {  
                                  Navigator.push(context,MaterialPageRoute(builder: (context) => ListEleves(widget.email, widget.name),));
                                } else { 
                                  setState(() { 
                                    errorMessage = "Error: ${response.statusCode}, ${response.body}";
                                  });
                                }  
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.lightBlueAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text("Ajouter "),
                            ),
                          ), 
                        ),
                       
                        Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getEleves() async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getEleves/${widget.name}"));
      if (response.statusCode == 200) {
        List<dynamic> classesData = jsonDecode(response.body)['eleves'];
        List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(classesData);
        return classes;
      } else {
        throw Exception('failed to get eleves');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load eleves');
    }
  } 
   Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await get(Uri.parse(
          "https://firas.alwaysdata.net/api/getUsers/${widget.name}"));
      if (response.statusCode == 200) {
        List<dynamic> classesData = jsonDecode(response.body)['list'];
        List<Map<String, dynamic>> classes =
            List<Map<String, dynamic>>.from(classesData);
        return classes;
      } else {
        throw Exception('failed to get users');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load users');
    }
  }
}
