import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ModExercice extends StatefulWidget {
  final String name;
  ModExercice(this.name);

  @override
  State<ModExercice> createState() => _ModExerciceState();
}

class _ModExerciceState extends State<ModExercice> {
  final fkey = GlobalKey<FormState>();
  late String name = '';
  late String description = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier Exercice'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromARGB(160, 0, 54, 99),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: fkey,
              child: FutureBuilder<Map<String, dynamic>>(
                future: getExercice(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final exercice = snapshot.data as Map<String, dynamic>?;

                    if (exercice == null) {
                      return Center(child: Text('Exercice not found'));
                    }

                    return Column(
                      children: [
                        Container(
                          height: 200,
                          child: Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16.0),
                              title: TextFormField(
                                initialValue: exercice['name'] != null ? exercice['name'] : '',
                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                onSaved: (newValue) {
                                  name = newValue!;
                                },
                                onChanged: (value) {
                                  name = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8.0),
                                  TextFormField(
                                    keyboardType: TextInputType.text,
                                    initialValue: exercice['description'] != null ? exercice['description'] : '',
                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                    onSaved: (newValue) {
                                      description = newValue!;
                                    },
                                    onChanged: (value) {
                                      description = value;
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter some text';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (fkey.currentState!.validate()) {
                              fkey.currentState!.save();
                              final response = await put(
                                Uri.parse("http://192.168.1.11:80/api/updateExercice/${widget.name}"),
                                body: <String, dynamic>{
                                  'name': name.isNotEmpty ? name : exercice['name'],
                                  'description': description.isNotEmpty ? description : exercice['description'],
                                },
                              );
                              if (response.statusCode == 200) {
                                // Refresh the page when popping
                                Navigator.of(context).pop(true);
                              }
                            }
                          },
                          child: Text('Valider'),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getExercice() async { 
    try {
      final response = await get(Uri.parse("http://192.168.1.11:80/api/getExercice/${widget.name}"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['exercice'];
      } else {
        throw Exception('Failed to load exercice');
      } 
    } catch (e) { 
      print('Error: $e');
      throw Exception('Failed to load exercice');
    }
  }
}
