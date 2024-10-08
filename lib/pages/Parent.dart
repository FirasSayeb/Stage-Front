import 'dart:convert';

import 'package:app/model/Actualite.dart';
import 'package:app/pages/Home.dart';
import 'package:app/pages/Profile.dart';
import 'package:app/pages/ajouter_message.dart';
import 'package:app/pages/marquer_absence.dart';
import 'package:app/pages/voir_absence.dart';
import 'package:app/pages/voir_emploi.dart';
import 'package:app/pages/voir_event.dart';
import 'package:app/pages/voir_exercices.dart';
import 'package:app/pages/voir_messages_parent.dart';
import 'package:app/pages/voir_notes.dart';
import 'package:app/pages/voir_services.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Parent extends StatefulWidget {
  final String email;
  Parent(this.email);
  @override
  State<Parent> createState() => _SignupState();
} 

class _SignupState extends State<Parent> { 

  Future<void> _clearUserSession() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('email');
  await prefs.remove('role');
}

  late String searchString='';
   Future<List<Actualite>> getActualites() async {
    try { 
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getActualites"));
      if (response.statusCode == 200) {
        final List responseData = jsonDecode(response.body)['list']; 
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
      final res = await get(Uri.parse("https://firas.alwaysdata.net/api/getName/${widget.email}"));
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
     home:Scaffold(
      appBar:  AppBar(
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
      body:Column(
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
                              contentPadding: EdgeInsets.all(16.0),
                              title: Row(
                                children: [
                                  Text(
                                    " ${snapshot.data![index].body}",
                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  ),
                                  
                                    
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
      drawer: Drawer(
        child: Container(
         
          color:  Colors.white,
          child: ListView( 
            children: [  
             Padding(padding: EdgeInsets.only(top:50)),
              ListTile( 
                  title:  Text(" ${widget.email}"),
                  leading: const Icon(Icons.person),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Profil(widget.email)));
                  }, 
                ),
              ListTile(
                title: Text("Home"),
                leading: Icon(Icons.home),
                onTap: () { Navigator.push(
      context,   
      MaterialPageRoute(builder: (context) => Parent(widget.email)));},
              ),
              ListTile(
                title: Text("Notes"),
                leading: Icon(Icons.grade),
                onTap: () { Navigator.push(
      context,   
      MaterialPageRoute(builder: (context) => VoirNotes(widget.email)));},
              ),
               ListTile(
                title: Text("Absences"),
                leading: Icon(Icons.do_not_disturb_alt_sharp),
                onTap: () { Navigator.push(
      context,   
      MaterialPageRoute(builder: (context) =>VoirAbsence(widget.email)));},
              ),
              ListTile(
                title: Text("Exercices"),
                leading: Icon(Icons.task),
                onTap: () { Navigator.push(
      context,   
      MaterialPageRoute(builder: (context) => VoirExcercices(widget.email)));},
              ), ListTile(
                title: Text("Emplois"),
                leading: Icon(Icons.calendar_month),
                onTap: () { Navigator.push(
      context,   
      MaterialPageRoute(builder: (context) => VoirEmploi(widget.email)));},
              ),
               ListTile(
                title: Text("Messages"),
                leading: Icon(Icons.notification_add),
                onTap: () { Navigator.push(
      context,   
      MaterialPageRoute(builder: (context) => VoirMessagesP(widget.email)));},
              ),
               ListTile(
                title: Text("Services"),
                leading: Icon(Icons.miscellaneous_services),
                onTap: () { Navigator.push(
      context,   
      MaterialPageRoute(builder: (context) => VoirServices(widget.email)));},
              ),
              ListTile(
                title: Text("Événements"),
                leading: Icon(Icons.event),
                onTap: () { Navigator.push(
      context,   
      MaterialPageRoute(builder: (context) => VoirEvent(widget.email)));},
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
      )
     )
    );  
  } 
}