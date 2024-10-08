import 'dart:convert';
import 'dart:io';

import 'package:app/pages/Admin.dart';
import 'package:app/pages/Home.dart';
import 'package:app/pages/Profile.dart';
import 'package:app/pages/ajouter_deliberation.dart';
import 'package:app/pages/ajouter_notification.dart';
import 'package:app/pages/ajouter_parent.dart';
import 'package:app/pages/gerer_classes.dart';
import 'package:app/pages/gerer_eleves.dart';
import 'package:app/pages/gerer_emploi.dart';
import 'package:app/pages/gerer_events.dart';
import 'package:app/pages/gerer_services.dart';
import 'package:app/pages/valider_event.dart';
import 'package:app/pages/valider_service.dart';
import 'package:app/pages/voir_all_absences.dart';
import 'package:app/pages/voir_messages.dart';
import 'package:app/pages/voir_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GererUtilisateurs extends StatefulWidget {
  final String email; 
  GererUtilisateurs(this.email);

  @override
  State<GererUtilisateurs> createState() => _GererUtilisateursState();
}

class _GererUtilisateursState extends State<GererUtilisateurs> {
  late String searchString = '';

  Future<List<Map<String, dynamic>>> getParents() async {
    try {
      final response = await http.get(Uri.parse('https://firas.alwaysdata.net/api/getParents'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body)['list'];
        final List<Map<String, dynamic>> parentList = responseData.map((data) => data as Map<String, dynamic>).toList();
        return parentList;
      } else {
        throw Exception('Échec du chargement des parents');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement des parents');
    }
  }

  deleteParent(String email) async {
    try {
      final response = await http.delete(Uri.parse('https://firas.alwaysdata.net/api/deleteParent/$email'));
      if (response.statusCode == 200) {
        print("success");
      } else {
        print("failed");
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to delete parent');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Parents "),
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
  future: getParents(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    } else {
      final List<Map<String, dynamic>> parents = snapshot.data!;
      final List<Map<String, dynamic>> filteredParents = searchString.isEmpty
          ? parents
          : parents.where((parent) =>
              parent['name'].toLowerCase().contains(searchString) ||
              parent['email'].toLowerCase().contains(searchString)).toList();
      
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ListView.builder(
          itemCount: filteredParents.length,
          itemBuilder: (context, index) {
            String? filePath = filteredParents[index]['avatar'];
            String fileName = filePath != null ? filePath.split('/').last : '';
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage("https://firas.alwaysdata.net/storage/$fileName"),
                  radius: 30,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Nom : " + filteredParents[index]['name'],
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
                                  builder: (context) => Profil(
                                    filteredParents[index]["email"],
                                  ),
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
                                print(filteredParents[index]["email"]);
                                deleteParent(filteredParents[index]["email"]);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => GererUtilisateurs(widget.email)),
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
                    SizedBox(height: 4),
                    Text(
                      filteredParents[index]['email'],
                      style: TextStyle(color: Colors.grey),
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
)

              ],
            ),
          ),
        ),
        drawer: Drawer(
          child: Container( 
            color: Colors.white,
            child: ListView(
              children: [const Padding(padding: EdgeInsets.only(top: 30)),ListTile( 
                  title:  Text(" ${widget.email}"),
                  leading: const Icon(Icons.person),
                  onTap: () { 
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Profil(widget.email)));
                  },
                ),
                
                ListTile(
                  title: const Text("Home"), 
                  leading: const Icon(Icons.home),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Admin(widget.email)));
                  },
                ),
                ListTile(
                  title: const Text("Enseignants"),
                  leading: const Icon(Icons.school),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GererEmploi(widget.email)));
                  },
                ),ListTile(
                title: const Text("Services"),
                leading: const Icon(Icons.miscellaneous_services),
                onTap: () { 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => GererServices(widget.email)));
                },
              ),ListTile(
                title: const Text("événements"),
                leading: const Icon(Icons.event),
                onTap: () { 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => GererEvents(widget.email)));
                },
              ),
                ListTile(
                  title: const Text("Parents"),
                  leading: const Icon(Icons.verified_user), 
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GererUtilisateurs(widget.email)));
                  },
                ), ListTile(
                  title: const Text("Notes"), 
                  leading: const Icon(Icons.grade),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AjouterDel(widget.email)));
                  },
                ),
                ListTile(
                  title: const Text("Classes"), 
                  leading: const Icon(Icons.class_),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GererClasses(widget.email)));
                  },
                ),
                ListTile(
                  title: const Text("élevés"), 
                  leading: const Icon(Icons.smart_toy_rounded),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GererEleves(widget.email)));
                  },
                ),ListTile( 
                title: Text("Messages"),
                leading: Icon(Icons.notification_add),
                onTap: () { Navigator.push(
      context,   
      MaterialPageRoute(builder: (context) => VoirMessages(widget.email)));},
              ),
                ListTile(
                  title: const Text("Absences"), 
                  leading: const Icon(Icons.edit_calendar),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewAll(widget.email)));
                  },
                ),
                ListTile(
                  title: const Text("Valider Services"), 
                  leading: const Icon(Icons.check),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ValiderService(widget.email)));
                  },
                ),
                ListTile(
                  title: const Text("Valider événements"), 
                  leading: const Icon(Icons.check),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ValiderEvent(widget.email)));
                  },
                ),
                ListTile(  
                  title: const Text("Deconnexion"),
                  leading: const Icon(Icons.exit_to_app),
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => AjouterParent(widget.email)));
          },
        ),
      ),
    );
  }
}
