import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ViewAll extends StatefulWidget {
  final String email;
  const ViewAll(this.email);

  @override
  State<ViewAll> createState() => _ViewAllState();
}

class _ViewAllState extends State<ViewAll> {
  String searchString = '';
  late Future<List<Map<String, dynamic>>> _futureAbsences;

  @override
  void initState() {
    super.initState();
    _futureAbsences = getAbsences();
  }

  Future<List<Map<String, dynamic>>> getAbsences() async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getAbsence"));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body)['list'];
        final List<Map<String, dynamic>> eleves = List<Map<String, dynamic>>.from(responseData);
        return eleves;
      } else {
        throw Exception('Échec du chargement des absences');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement des absences');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('consulter Absences'),
         backgroundColor: Color.fromARGB(255, 4, 166, 235),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureAbsences,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> absences = snapshot.data!;
            List<Map<String, dynamic>> filteredAbsences = absences.where((absence) {
              final user = absence['user_name']!.toLowerCase();
final eleve = absence['eleve_name']!.toLowerCase();
final matiere = (absence['matiere'] ?? 'Unknown').toLowerCase();
final date = (absence['date'] ?? 'No Date').toLowerCase();

             return user.contains(searchString) || eleve.contains(searchString) || matiere.contains(searchString) || date.contains(searchString);

            }).toList();

            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchString = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Rechercher...',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              searchString = '';
                            });
                          },
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01)),
                    for (final absence in filteredAbsences)
                      ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Prof: ${absence['user_name']}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Eleve: ${absence['eleve_name']}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Matiere: ${absence['matiere'] ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Date: ${absence['date'] ?? 'No Date'}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
