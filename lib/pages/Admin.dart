import 'dart:convert';
import 'dart:io';

import 'package:app/model/Actualite.dart';
import 'package:app/pages/Home.dart';
import 'package:app/pages/Profile.dart';
import 'package:app/pages/ajouter_actualite.dart';
import 'package:app/pages/ajouter_deliberation.dart';
import 'package:app/pages/ajouter_notification.dart';
import 'package:app/pages/gerer_classes.dart';
import 'package:app/pages/gerer_eleves.dart';
import 'package:app/pages/gerer_emploi.dart';
import 'package:app/pages/gerer_events.dart';
import 'package:app/pages/gerer_services.dart';
import 'package:app/pages/gerer_utilisateurs.dart';
import 'package:app/pages/moifier_actualite.dart';
import 'package:app/pages/valider_event.dart';
import 'package:app/pages/valider_service.dart';
import 'package:app/pages/voir_all_absences.dart';
import 'package:app/pages/voir_messages.dart';
import 'package:app/pages/voir_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Admin extends StatefulWidget {
  final String email;
  Admin(this.email);

  @override
  _AdminState createState() => _AdminState();
}



class _AdminState extends State<Admin> {
  late String searchString = '';
  Future<void> _clearUserSession() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('email');
  await prefs.remove('role');
}

  Future<List<Actualite>> getActualites() async {
    try {
      final response =
          await http.get(Uri.parse("https://firas.alwaysdata.net/api/getActualites"));
      if (response.statusCode == 200) {
        final List responseData = jsonDecode(response.body)['list'];
        print(responseData[0]['file_path']);
        return responseData.map((data) => Actualite.fromJson(data)).toList();
      } else {
        throw Exception('Échec du chargement des actualités');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement des actualités');
    }
  }
  late Future<String> name;

  Future<String> getName() async {
    try {
      final res = await http.get(Uri.parse("https://firas.alwaysdata.net/api/getName/${widget.email}"));
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['name'];
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement nom');
    }
    return ''; 
  }

  @override
  void initState() {
    super.initState();
    name = getName();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: FutureBuilder<String>(
            future: name,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text('Chargement...');
              } else if (snapshot.hasError) {
                return Text('Erreur');
              } else {
                return Text('Bienvenu ${snapshot.data}');
              }
            },
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color.fromARGB(255, 4, 166, 235),
        ),
        body: Column(
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
            Expanded(
              child: FutureBuilder<List<Actualite>>(
                future: getActualites(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        if (searchString.isEmpty ||
                            snapshot.data![index].userName.toLowerCase().contains(searchString)
                            || snapshot.data![index].body.toLowerCase().contains(searchString)||
                                snapshot.data![index].createdAt.toLowerCase().contains(searchString)
                            ) {
                          String? filePath = snapshot.data![index].filePath;
                          String fileName = filePath != null ? filePath.split('/').last : '';
                          return Card(
                            elevation: 4,
                            
                            child: ListTile(
                              title: Row(
                                children: [
                                  Text(
                                    " ${snapshot.data![index].body}",
                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  ),
                                  //Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.2)),
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
                                                builder: (context) => ModierActualite(
                                                  snapshot.data![index].id,
                                                  widget.email,
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
                                              print(snapshot.data![index].id);
                                              deleteActualite(snapshot.data![index].id);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => Admin(widget.email)),
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
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Créé à: ${snapshot.data![index].createdAt}',
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    'Créé par: ${snapshot.data![index].userName}',
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                  Image.network(
                                    "https://firas.alwaysdata.net/storage/$fileName",
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height * 0.3,
                                    fit: BoxFit.cover,
                                  )
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AjouterActualite(widget.email)));
        },child: Icon(Icons.add),),
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
  onTap: () async {
    await _clearUserSession();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
  },
)
 
              ],
            ),
          ),
        ),
      ),
    );
  }
}
      

  void deleteActualite(int actualiteId) async {
    final url = Uri.parse("https://firas.alwaysdata.net/api/deleteActualite/$actualiteId");

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        print("success");
      } else {
        print("failed");
      }
    } catch (e) {
      print('Error deleting actualite: $e');
    }
  }
