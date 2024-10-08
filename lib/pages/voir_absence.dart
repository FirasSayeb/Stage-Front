
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';

class VoirAbsence extends StatefulWidget {
  final String email;
  const VoirAbsence(this.email);

  @override
  State<VoirAbsence> createState() => _VoirAbsenceState();
}

class _VoirAbsenceState extends State<VoirAbsence> {
   int? _selectedEleveId;

  Future<List<Map<String, dynamic>>> getAbsences(int id) async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getAbsences/$id"));
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
        title: Text('consulter absences'),
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
                  future: getAbsences(_selectedEleveId!),
                  builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      List<Map<String, dynamic>> absences = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              "Absences pour l'élevé sélectionné :",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: absences.length,
                            itemBuilder: (context, index) {
                              final absence = absences[index];
                              final subject = absence['matiere'] ?? 'Unknown';
                              final date = absence['date'] ?? 'No Date';
                              final prof =absence['user_name'];
                              return Card(
                                elevation: 4,
    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16.0),
                                    leading: SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.4,
                                      height: MediaQuery.of(context).size.width * 0.4, 
                                      child: Lottie.asset(
                                        'assets/abs2.json',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                title: Text(
                                  "Prof: $prof",
                                  style: TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold, 
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, 
                                  children: [
                                    Text(
                                      'Matiere: $subject',
                                      style: TextStyle(
                                        fontSize: 16, 
                                      ),
                                    ),
                                    Text(
                                      'Date: $date',
                                      style: TextStyle(
                                        fontSize: 16, 
                                      ),
                                    ),
                                  ],
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