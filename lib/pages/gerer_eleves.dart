import 'dart:convert';
import 'dart:io';
import 'package:app/pages/gerer_classes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Admin.dart';
import 'Home.dart';
import 'Profile.dart';
import 'ajouter_deliberation.dart';
import 'ajouter_eleve.dart';
import 'ajouter_notification.dart';
import 'gerer_emploi.dart';
import 'gerer_events.dart';
import 'gerer_services.dart';
import 'gerer_utilisateurs.dart';
import 'modifier_eleve.dart';
import 'valider_event.dart';
import 'valider_service.dart';
import 'voir_all_absences.dart';

class GererEleves extends StatefulWidget {
  final String email;
  GererEleves(this.email);

  @override
  State<GererEleves> createState() => _GererClassesState();
}

class _GererClassesState extends State<GererEleves> {
  late String searchString = '';
  int? _selectedclass;

  Future<List<Map<String, dynamic>>> getClasses() async {
    try {
      final response = await http.get(Uri.parse("https://firas.alwaysdata.net/api/getClasses"));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['list'];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load classes');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load classes');
    }
  }

  Future<List<Map<String, dynamic>>> getEleves(int id) async {
    try {
      final response = await http.get(Uri.parse("https://firas.alwaysdata.net/api/getElevs/$id"));
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Eleves "),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color.fromARGB(160, 0, 54, 99),
        ),
        body: SingleChildScrollView(
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
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Select classe:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: getClasses(),
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
                              groupValue: _selectedclass,
                              onChanged: (int? value) {
                                setState(() {
                                  _selectedclass = value;
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
              if (_selectedclass != null) ...[
                Padding(padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01)),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: getEleves(_selectedclass!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  String? filePath = snapshot.data![index]['profil'];
                                  String fileName = filePath != null ? filePath.split('/').last : '';
                                  if (searchString.isEmpty ||
                                      (snapshot.data![index]['name'].toLowerCase().contains(searchString) ||
                                          snapshot.data![index]['num'].toLowerCase().contains(searchString) ||
                                          snapshot.data![index]['lastname'].toLowerCase().contains(searchString) ||
                                          snapshot.data![index]['class_name'].toLowerCase().contains(searchString))) {
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
                                                            builder: (context) => ModifierEleve(widget.email, snapshot.data![index]['id']),
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
                                                          deleteEleve(snapshot.data![index]['name']);
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
                                                "Numero: ${snapshot.data![index]['num']}",
                                              ),
                                              Text(
                                                "Name: ${snapshot.data![index]['name']}",
                                              ),
                                              Text(
                                                "LastName: ${snapshot.data![index]['lastname']}",
                                              ),
                                              Text(
                                                "ClassName: ${snapshot.data![index]['class']['name']}",
                                              ),
                                              Text(
                                                "Date of birth: ${snapshot.data![index]['date_of_birth']}",
                                              ),
                                              Text(
  "Tuteurs: ${
    snapshot.data![index] != null && 
    snapshot.data![index]['parents'] != null && 
    snapshot.data![index]['parents'].isNotEmpty 
      ? snapshot.data![index]['parents']
          .map((parent) => parent['name'])
          .join(', ') 
      : ''
  }",
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
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ]
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
                  title: Text("Enseignants"),
                  leading: Icon(Icons.school),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GererEmploi(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Services"),
                  leading: Icon(Icons.miscellaneous_services),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GererServices(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Events"),
                  leading: Icon(Icons.event),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GererEvents(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Tuteurs"),
                  leading: Icon(Icons.verified_user),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GererUtilisateurs(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Notes"),
                  leading: Icon(Icons.grade),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AjouterDel(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Classes"),
                  leading: Icon(Icons.class_),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GererClasses(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Eleves"),
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
                  title: const Text("Absences"), 
                  leading: const Icon(Icons.edit_calendar),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewAll(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Valider Services"),
                  leading: Icon(Icons.check),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ValiderService(widget.email)));
                  },
                ),
                ListTile(
                  title: Text("Valider Events"),
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
}
