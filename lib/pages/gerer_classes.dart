import 'dart:convert';
import 'dart:io';
import 'package:app/pages/Admin.dart';
import 'package:app/pages/AjouterClasse.dart';
import 'package:app/pages/Home.dart';
import 'package:app/pages/Profile.dart';
import 'package:app/pages/ajouter_deliberation.dart';
import 'package:app/pages/ajouter_notification.dart';
import 'package:app/pages/gerer_eleves.dart';
import 'package:app/pages/gerer_emploi.dart';
import 'package:app/pages/gerer_events.dart';
import 'package:app/pages/gerer_services.dart';
import 'package:app/pages/gerer_utilisateurs.dart';
import 'package:app/pages/modifier_classe.dart';
import 'package:app/pages/valider_event.dart';
import 'package:app/pages/valider_service.dart';
import 'package:app/pages/voir_all_absences.dart';
import 'package:app/pages/voir_messages.dart';
import 'package:app/pages/voir_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';

class GererClasses extends StatefulWidget {
  final String email;
  GererClasses(this.email); 

  @override
  State<GererClasses> createState() => _GererClassesState();
}

class _GererClassesState extends State<GererClasses> {
  late String searchString = '';

  Future<List<Map<String, dynamic>>> getClasses() async {
    try {
      final response = await http.get(Uri.parse("https://firas.alwaysdata.net/api/getClasses"));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['list'];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Échec du chargement des classes');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement des classes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Classes "),
          centerTitle: true,
          elevation: 0,
           backgroundColor: Color.fromARGB(255, 4, 166, 235),
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
              Padding(padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01)),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: getClasses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          if (searchString.isEmpty ||
                              snapshot.data![index]['name'].toLowerCase().contains(searchString)) {
                            String filePath = snapshot.data![index]['emploi'] ?? '';
                            String fpath = snapshot.data![index]['examens'] ?? '';
                            List<String> pathParts = filePath.split('/');
                            List<String> pathPart = fpath.split('/');
                            String fileNameWithExtension = pathParts.last;
                            String fileName2WithExtension = pathPart.last;
                            return Card(
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  String filePath = snapshot.data![index]['emploi'];
                                  OpenFile.open(filePath);
                                },
                                child: ListTile(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        snapshot.data![index]['name'],
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
                                                    builder: (context) => ModifierClasse(widget.email, snapshot.data![index]['id']),
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
                                                  deleteClasse(snapshot.data![index]['name']);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => GererClasses(widget.email)),
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
                                      Image.network(
                                        "https://firas.alwaysdata.net/storage/$fileNameWithExtension",
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.height * 0.3,
                                        fit: BoxFit.cover,
                                      ),
                                      Image.network(
                                        "https://firas.alwaysdata.net/storage/$fileName2WithExtension",
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.height * 0.3,
                                        fit: BoxFit.cover,
                                      )
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
                    );
                  }
                },
              ),
            ],
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => AjouterClasse(widget.email)));
          },
        ),
      ),
    );
  }
}

deleteClasse(String name) async {
  try {
    final response = await http.delete(Uri.parse("https://firas.alwaysdata.net/api/deleteClasse/$name"));
    if (response.statusCode == 200) {
      print('success');
    } else {
      throw Exception('Failed to delete classe');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to delete classe');
  }
}
