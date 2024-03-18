
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

class VoirExcercices extends StatefulWidget {
  final String email;
  VoirExcercices(this.email);

  @override
  State<VoirExcercices> createState() => _VoirExcercicesState();
}

class _VoirExcercicesState extends State<VoirExcercices> {
   int? _selectedEleveId;
  Future<List<Map<String, dynamic>>> getExercices(int id) async {
    try {
      final response = await get(Uri.parse("http://10.0.2.2:8000/api/getExer/$id"));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body)['list'];
        final List<Map<String, dynamic>> notes = List<Map<String, dynamic>>.from(responseData);
        return Future.value(notes); 
      } else {
        throw Exception('Failed to load exercices');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load exercices');
    }
  }

  Future<List<Map<String, dynamic>>> getEleves() async {
    try {
      final response = await get(Uri.parse("http://10.0.2.2:8000/api/getFils/${widget.email}"));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body)['list'];
        final List<Map<String, dynamic>> eleves = List<Map<String, dynamic>>.from(responseData);
        return eleves;
      } else {
        throw Exception('Failed to load eleves');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load eleves');
    }
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Exercices Viewer'),
      ),
      body: SingleChildScrollView( 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Select an eleve:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getEleves(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<Map<String, dynamic>> eleves = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: eleves.length,
                        itemBuilder: (context, index) {
                          final eleve = eleves[index];
                          final eleveName = eleve['name'] ?? 'Unknown';
                          return RadioListTile<int>(
                            title: Text(eleveName),
                            value: eleve['id'],
                            groupValue: _selectedEleveId,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedEleveId = value;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            ),
            if (_selectedEleveId != null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: FutureBuilder(
                  future: getExercices(_selectedEleveId!),
                  builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      List<Map<String, dynamic>> notes = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Exercices for selected eleve:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: notes.length,
                            itemBuilder: (context, index) {
                              final note = notes[index];
                              final subject = note['name'] ?? 'Unknown';
                              final noteText = note['description'] ?? 'No Description';
                              return ListTile(
                                title: Text("Name: $subject"),
                                subtitle: Text('Description: $noteText'),
                              );
                            },
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
}