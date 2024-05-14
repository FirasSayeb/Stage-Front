import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';

class VoirNotes extends StatefulWidget {
  final String email;
  VoirNotes(this.email);

  @override
  State<VoirNotes> createState() => _VoirNotesState();
}

class _VoirNotesState extends State<VoirNotes> {
  int? _selectedEleveId;

  Future<List<Map<String, dynamic>>> getNotes(int id) async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getNotes/$id"));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body)['list'];
        final List<Map<String, dynamic>> notes = List<Map<String, dynamic>>.from(responseData);
        return Future.value(notes); 
      } else {
        throw Exception('Échec du chargement des notes');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement des notes');
    }
  }

  Future<List<Map<String, dynamic>>> getEleves() async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getFils/${widget.email}"));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body)['list'];
        final List<Map<String, dynamic>> eleves = List<Map<String, dynamic>>.from(responseData);
        return eleves;
      } else {
        throw Exception('Échec du chargement des eleves');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement des eleves');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('consulter notes'),
         backgroundColor: Color.fromARGB(255, 4, 166, 235),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Sélectionner un élevé:',
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
                  future: getNotes(_selectedEleveId!),
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
                              "Notes pour l'élevé sélectionné :",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: notes.length,
                            itemBuilder: (context, index) {
                              final note = notes[index];
                              final subject = note['matiere'] ?? 'Unknown';
                              final noteText = note['note'] ?? 'No Note';
                              return Container(
                                child: Card(
                                    elevation: 4,
                                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                                  child: ListTile(
                                     contentPadding: EdgeInsets.all(16.0),
                                        leading: SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.4,
                                          height: MediaQuery.of(context).size.width * 0.4, 
                                          child: Lottie.asset(
                                            'assets/not.json',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                    title: Text("Matiere: $subject"),
                                    subtitle: Text('Note: $noteText'),
                                  ),
                                ),
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
