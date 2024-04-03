

import 'dart:convert';

import 'package:app/pages/Admin.dart';
import 'package:app/pages/Home.dart';
import 'package:app/pages/ModEvent.dart';
import 'package:app/pages/ModService.dart';
import 'package:app/pages/Profile.dart';
import 'package:app/pages/ajouterEvent.dart';
import 'package:app/pages/ajouter_deliberation.dart';
import 'package:app/pages/ajouter_notification.dart';
import 'package:app/pages/gerer_classes.dart';
import 'package:app/pages/gerer_eleves.dart';
import 'package:app/pages/gerer_emploi.dart';
import 'package:app/pages/gerer_services.dart';
import 'package:app/pages/gerer_utilisateurs.dart';
import 'package:app/pages/valider_event.dart';
import 'package:app/pages/valider_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';  

class GererEvents extends StatefulWidget {
  final String email;
  GererEvents(this.email);

  @override
  State<GererEvents> createState() => _GererServicesState();
}

class _GererServicesState extends State<GererEvents> {
 Future<List<Map<String, dynamic>>> getEvents() async {
  try {
    final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getEvents"));
    if (response.statusCode == 200) {
      final dynamic responseData = jsonDecode(response.body.toString())['list'];
      if (responseData != null) {
        final List<Map<String, dynamic>> parentList =
            (responseData as List<dynamic>).map((data) => data as Map<String, dynamic>).toList();
        return parentList;
      } else {
        throw Exception('Response data is null');
      }
    } else {
      throw Exception('Failed to load events');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to load events');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        title: const Text("Gerer Events "),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromARGB(160, 0, 54, 99),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(10)),
              GestureDetector(
                child: Text('Ajouter Event'),
                onTap: () { 
                  print('ajouter Event'); 
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AjouterEvent(widget.email),
                    ),
                  );
                },
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: getEvents(),
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
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                            child: ListTile(
                              title: Text("Name : "+
                                snapshot.data![index]['name'] 
                                ,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(
  "Price: ${snapshot.data![index]['price'].toString()}",
  style: TextStyle(color: Colors.grey),
), 
Text(
  "Date: ${snapshot.data![index]['date']}",
  style: TextStyle(color: Colors.grey),
), 
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton( 
                                        onPressed: () {
                                          Navigator.push(  
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ModEvent(snapshot.data![index]['name']),
                                            ),
                                          ).then((_) => setState(() {}));
                                        },
                                        child: Text('Modifier'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          deleteEvent(snapshot.data![index]['name']);
                                          Navigator.push(
                                            context, 
                                            MaterialPageRoute(
                                              builder: (context) => GererEvents(widget.email),
                                            ),
                                          ); 
                                        },
                                        child: Text('Supprimer'),
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStatePropertyAll(Colors.red),
                                        ),
                                      ),
                                    ],
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
                title: const Text("Home"),
                leading: const Icon(Icons.home),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Admin(widget.email)));
                },
              ),
              ListTile(
                title: const Text("Gérer Enseignants"),
                leading: const Icon(Icons.school),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => GererEmploi(widget.email)));
                },
              ), 
              ListTile(
                title: const Text("Gérer Services"),
                leading: const Icon(Icons.miscellaneous_services),
                onTap: () { 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => GererServices(widget.email)));
                },
              ),ListTile(
                title: const Text("Gérer Events"),
                leading: const Icon(Icons.event),
                onTap: () { 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => GererEvents(widget.email)));
                },
              ),
              ListTile(
                title: const Text("Gérer Tuteurs"),
                leading: const Icon(Icons.verified_user),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => GererUtilisateurs(widget.email)));
                },
              ),ListTile(
                  title: const Text("Gérer Notes"), 
                  leading: const Icon(Icons.grade),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AjouterDel(widget.email)));
                  },
                ),
              ListTile(
                title: const Text("Gérer Classes"),
                leading: const Icon(Icons.class_),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => GererClasses(widget.email)));
                },
              ),
              ListTile(
                title: const Text("Gérer Eleves"),
                leading: const Icon(Icons.smart_toy_rounded),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => GererEleves(widget.email)));
                },
              ),ListTile(
                  title: const Text("Envoyer Notification"), 
                  leading: const Icon(Icons.notification_add),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AjouterNotification(widget.email)));
                  },
                ),  ListTile(
                  title: const Text("Valider  Services"), 
                  leading: const Icon(Icons.check),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ValiderService(widget.email)));
                  },
                ),ListTile(
                  title: const Text("Valider  Events"), 
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
    );
  } 
 deleteEvent(String name) async {
  try {
    final response = await delete(Uri.parse("https://firas.alwaysdata.net/api/deleteEvent/$name"));
    if (response.statusCode == 200) {
      print('Success: Service deleted'); 
    } else { 
      throw Exception('Failed to delete service');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to delete service');
  }
}


}