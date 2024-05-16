import 'dart:convert';

import 'package:app/pages/AjouterExercice.dart';
import 'package:app/pages/ModExercice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';

class GererExercices extends StatefulWidget {
  final String email;
  final String name;
  GererExercices(this.email, this.name);

  @override
  State<GererExercices> createState() => _GererExercicesState();
}

class _GererExercicesState extends State<GererExercices> {
  late String searchString = '';

  Future<List<Map<String, dynamic>>> getExercices() async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getExercices/${widget.name}"));
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body.toString())['list'];
        if (responseData != null) {
          final List<Map<String, dynamic>> parentList =
              (responseData as List<dynamic>).map((data) => data as Map<String, dynamic>).toList();
          return parentList;
        } else {
          throw Exception('Échec du chargement des exercices');
        }
      } else {
        throw Exception('Échec du chargement des exercices');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement des exercices');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exercices "),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 4, 166, 235),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
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

              FutureBuilder<List<Map<String, dynamic>>>(
                future: getExercices(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    
                    final List<Map<String, dynamic>> filteredData = snapshot.data!.where((exercise) {
  final name = exercise['name'].toLowerCase();
  final description = exercise['description'].toLowerCase();
  return name.contains(searchString) || description.contains(searchString);
}).toList();


                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: ListView.builder(
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4,
                           
                            child: ListTile(
                               contentPadding: EdgeInsets.all(16.0),
  leading: SizedBox(
    width: MediaQuery.of(context).size.width * 0.4,
    child: Lottie.asset( 
      'assets/ex.json',
      fit: BoxFit.contain,
    ),
  ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Nom : " + filteredData[index]['name'],
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      PopupMenuButton<String>(
                                        itemBuilder: (BuildContext context) => [
                                          PopupMenuItem<String>(
                                            value: 'modify',
                                            child: Text('Modifier'),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                        onSelected: (String value) async {
                                          if (value == 'modify') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ModExercice(filteredData[index]['name']),
                                              ),
                                            );
                                          } else if (value == 'delete') {
                                            bool confirmDelete = await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text("Confirmation"),
                                                  content: Text("Etes-vous sûr que vous voulez supprimer?"),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop(false);
                                                      },
                                                      child: Text("Non"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop(true);
                                                      },
                                                      child: Text("Oui"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            if (confirmDelete == true) {
                                              deleteExercice(filteredData[index]['name']);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => GererExercices(widget.email, widget.name),
                                                ),
                                              ).then((_) => setState(() {}));
                                            }
                                          }
                                        },
                                        icon: Icon(Icons.more_vert),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Description : " + filteredData[index]['description'],
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AjouterExercice(widget.email, widget.name),
            ),
          );
        },
      ),
    );
  }

  deleteExercice(String name) async {
    try {
      final response = await delete(Uri.parse("https://firas.alwaysdata.net/api/deleteExercice/$name"));
      if (response.statusCode == 200) {
        print('Success: Exercice deleted');
      } else {
        throw Exception('Failed to delete exercice');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to delete exercice');
    }
  }
}
