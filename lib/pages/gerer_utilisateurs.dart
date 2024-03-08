import 'dart:convert';
import 'dart:io';

import 'package:app/pages/Admin.dart';
import 'package:app/pages/Home.dart';
import 'package:app/pages/Profile.dart';
import 'package:app/pages/ajouter_notification.dart';
import 'package:app/pages/ajouter_parent.dart';
import 'package:app/pages/gerer_classes.dart';
import 'package:app/pages/gerer_eleves.dart';
import 'package:app/pages/gerer_emploi.dart';
import 'package:app/pages/gerer_events.dart';
import 'package:app/pages/gerer_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GererUtilisateurs extends StatefulWidget {
  final String email; 
  GererUtilisateurs(this.email);

  @override
  State<GererUtilisateurs> createState() => _GererUtilisateursState();
}

class _GererUtilisateursState extends State<GererUtilisateurs> {

   Future<List<Map<String, dynamic>>> getParents() async {
  try {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/getParents'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body)['list'];
      final List<Map<String, dynamic>> parentList = responseData.map((data) => data as Map<String, dynamic>).toList();
      return parentList;
    } else {
      throw Exception('Failed to load parents');
    }
  } catch (e) {
    print('Error: $e');  
    throw Exception('Failed to load parents'); 
  }
}

    deleteParent(String email)async{
      try{
        final response=await http.delete(Uri.parse('http://10.0.2.2:8000/api/deleteParent/$email'));
        if(response.statusCode == 200){
print("success");
        }else{
          print("failed");
        }
      }catch (e) { 
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
        title: const Text("Gerer Parents "),
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
                child: Text('ajouter parent'),
                onTap: () {
                  print('ajouter parent');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AjouterParent(widget.email),
                    ),
                  );
                },
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: getParents(),
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
                              leading: CircleAvatar(
                                backgroundImage: FileImage(File(snapshot.data![index]['avatar'])),
                                radius: 30,
                              ),
                              title: Text(
                                snapshot.data![index]['name'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(
                                    snapshot.data![index]['email'],
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
                                              builder: (context) => Profil(snapshot.data![index]['email']),
                                            ),
                                          );
                                        },  
                                        child: Text('Modifier'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          deleteParent(snapshot.data![index]['email']);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => GererUtilisateurs(widget.email),
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
            color: const Color.fromARGB(160, 0, 54, 99),
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
                  title: const Text("Gérer Enseignants"),
                  leading: const Icon(Icons.school),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GererEmploi(widget.email)));
                  },
                ),ListTile(
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
                  title: const Text("Gérer Parents"),
                  leading: const Icon(Icons.verified_user), 
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GererUtilisateurs(widget.email)));
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
    ),
  );
}

}