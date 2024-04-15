import 'dart:convert';
import 'package:app/pages/gerer_exercices.dart';
import 'package:app/pages/marquer_absence.dart';
import 'package:app/pages/notifier_parent.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ListEleves extends StatefulWidget {
  final String name;
  final String email;

  ListEleves(this.email, this.name);

  @override
  State<ListEleves> createState() => _ListElevesState();
}

class _ListElevesState extends State<ListEleves> {
  String val = "choose";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.name}'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.lightBlue[800],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GererExercices(widget.email, widget.name),
                    ),
                  );
                },
                child: Text('Ajouter Exercice'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.indigo[300],
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ), Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MarquerAbsence(widget.email,widget.name),
                    ),
                  );
                },
                child: Text('Marquer Absence'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.indigo[300],
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  "Sélectionnez l'étudiant pour envoyer une notification : ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), 
                ),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getEleves(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return Center(child: Text('No Eleves'));
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      final eleve = snapshot.data![index];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(eleve['name']),
                          leading: Icon(Icons.notifications),
                          onTap: () {
                            setState(() {
                              val = eleve['name'];
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotifierParent(widget.email, val),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
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
}
