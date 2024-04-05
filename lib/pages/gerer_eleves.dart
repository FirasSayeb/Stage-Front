import 'dart:convert';
import 'dart:io';
import 'package:app/pages/Admin.dart';
import 'package:app/pages/Home.dart';
import 'package:app/pages/Profile.dart';
import 'package:app/pages/ajouter_deliberation.dart';
import 'package:app/pages/ajouter_eleve.dart';
import 'package:app/pages/ajouter_notification.dart';
import 'package:app/pages/gerer_classes.dart';
import 'package:app/pages/gerer_emploi.dart';
import 'package:app/pages/gerer_events.dart';
import 'package:app/pages/gerer_services.dart';
import 'package:app/pages/gerer_utilisateurs.dart';
import 'package:app/pages/modifier_eleve.dart';
import 'package:app/pages/valider_event.dart';
import 'package:app/pages/valider_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GererEleves extends StatefulWidget {
  final String email;
  GererEleves(this.email);

  @override
  State<GererEleves> createState() => _GererClassesState();
}

class _GererClassesState extends State<GererEleves> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    getEleves().then((students) {
      setState(() {
        _filteredStudents = students;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = _searchController.text;
    setState(() {
      _filteredStudents = _filterStudents(query);
    });
  }

  List<Map<String, dynamic>> _filterStudents(String query) {
    if (query.isEmpty) {
      return List.from(_filteredStudents); // Return original list when query is empty
    } else {
      return _filteredStudents.where((student) {
        return student['name'].toLowerCase().contains(query.toLowerCase()) ||
            student['lastname'].toLowerCase().contains(query.toLowerCase()) ||
            student['class_name'].toLowerCase().contains(query.toLowerCase());
        // Add more fields if needed
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Gerer Eleves "),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color.fromARGB(160, 0, 54, 99),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Rechercher...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01)),
              _buildStudentList(),
            ],
          ),
        ),
        drawer: Drawer(
          child: Container(
            color: Colors.white,
            child: ListView(
              children: [
                const Padding(padding: EdgeInsets.only(top: 30)),
                ListTile(
                  title: Text(" ${widget.email}"),
                  leading: Icon(Icons.person),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Profil(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Home"),
                  leading: Icon(Icons.home),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Admin(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Gérer Enseignants"),
                  leading: Icon(Icons.school),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GererEmploi(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Gérer Services"),
                  leading: Icon(Icons.miscellaneous_services),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GererServices(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Gérer Events"),
                  leading: Icon(Icons.event),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GererEvents(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Gérer Tuteurs"),
                  leading: Icon(Icons.verified_user),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GererUtilisateurs(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Gérer Notes"),
                  leading: Icon(Icons.grade),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AjouterDel(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Gérer Classes"),
                  leading: Icon(Icons.class_),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GererClasses(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Gérer Eleves"),
                  leading: Icon(Icons.smart_toy_rounded),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GererEleves(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Envoyer Notification"),
                  leading: Icon(Icons.notification_add),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AjouterNotification(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Valider  Services"),
                  leading: Icon(Icons.check),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ValiderService(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Valider  Events"),
                  leading: Icon(Icons.check),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ValiderEvent(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Deconnexion"),
                  leading: Icon(Icons.exit_to_app),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AjouterEleve(widget.email)));
          },
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    if (_filteredStudents.isEmpty) {
      return Center(child: Text('No matching students found'));
    } else {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ListView.builder(
          itemCount: _filteredStudents.length,
          itemBuilder: (context, index) {
             String? filePath = _filteredStudents[index]['profil'];
                          String fileName = filePath != null ? filePath.split('/').last : '';
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: GestureDetector(
                child: ListTile(
                  title: Column(
                    children: [
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
                                    builder: (context) => ModifierEleve(widget.email, _filteredStudents[index]['id']),
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
                                  deleteEleve(_filteredStudents[index]["name"]);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => GererEleves(widget.email)),
                                  ).then((_) => setState(() {}));
                                }
                              }
                            },
                            icon: Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                      CircleAvatar( 
    backgroundImage: NetworkImage(
      "https://firas.alwaysdata.net/storage/$fileName",
    ),
    radius: 30,
  ),
                      Text(
                        "Numero: ${_filteredStudents[index]['num']}",
                      ),
                      Text(
                        "Name: ${_filteredStudents[index]['name']}",
                      ),
                      Text(
                        "LastName: ${_filteredStudents[index]['lastname']}",
                      ),
                      Text(
                        "ClassName: ${_filteredStudents[index]['class_name']}",
                      ),
                      Text(
                        "Date of birth: ${_filteredStudents[index]['date_of_birth']}",
                      ),
                      Text(
                        "Tuteurs : ${_filteredStudents != null && _filteredStudents.isNotEmpty ? _filteredStudents[index]['parent_names'] ?? '' : ''} ",
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle content
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getEleves() async {
    try {
      final response = await http.get(Uri.parse("https://firas.alwaysdata.net/api/getEleves"));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['list'];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load eleves');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load eleves');
    }
  }

  deleteEleve(String name) async {
    try {
      final response = await http.delete(Uri.parse("https://firas.alwaysdata.net/api/deleteEleve/$name"));
      if (response.statusCode == 200) {
        print('success');
      } else {
        throw Exception('Failed to delete eleve');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to delete eleve');
    }
  }
}