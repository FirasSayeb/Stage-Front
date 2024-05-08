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
  late Future<Map<String, dynamic>> _exerciceFuture;

  @override
  void initState() {
    super.initState();
    _exerciceFuture = getExercice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier Exercice'),
        centerTitle: true,
        elevation: 0,
         backgroundColor: Color.fromARGB(255, 4, 166, 235),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: _exerciceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final exercice = snapshot.data as Map<String, dynamic>?;

                  if (exercice == null) {
                    return Center(child: Text('Exercice introuvable'));
                  }

                  return Form(
                    key: fkey,
                    child: Column(
                      children: [
                        Container(
  height: 200,
  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  decoration: BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 2,
        blurRadius: 4,
        offset: Offset(0, 3), 
      ),
    ],
    borderRadius: BorderRadius.circular(8),
    color: Colors.white,
  ),
  child: Padding(
    padding: EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: exercice['name'] ?? '',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          onSaved: (newValue) {
            name = newValue!;
          },
          onChanged: (value) {
            name = value;
          },
          decoration: InputDecoration(
            labelText: 'Nom',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'champs obligatoire';
            }
            return null;
          },
        ),
        SizedBox(height: 8.0),
        TextFormField(
          keyboardType: TextInputType.text,
          initialValue: exercice['description'] ?? '',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          onSaved: (newValue) {
            description = newValue!;
          },
          onChanged: (value) {
            description = value;
          },
          decoration: InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'champs obligatoire';
            }
            return null;
          },
        ),
      ],
    ),
  ),
),

                        ElevatedButton(
                          onPressed: () async {
                            if (fkey.currentState!.validate()) {
                              fkey.currentState!.save();
                              final response = await put(
                                Uri.parse("https://firas.alwaysdata.net/api/updateExercice/${widget.name}"),
                                body: <String, dynamic>{
                                  'name': name.isNotEmpty ? name : exercice['name'],
                                  'description': description.isNotEmpty ? description : exercice['description'],
                                },
                              );
                              if (response.statusCode == 200) {
                                
                                Navigator.of(context).pop(true);
                              }
                            }
                          },
                          child: Text('Valider'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getExercice() async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getExercice/${widget.name}"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['exercice'];
      } else {
        throw Exception('Échec du chargement de lexercice');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement de lexercice');
    }
  }
}
