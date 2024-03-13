import 'dart:convert';
import 'package:app/pages/Detail.dart';
import 'package:app/pages/Profile.dart';
import 'package:app/pages/ajouter_actualite.dart';
import 'package:app/pages/ajouter_notification.dart';
import 'package:app/pages/gerer_events.dart';
import 'package:app/pages/gerer_services.dart';
import 'package:app/pages/moifier_actualite.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/model/Actualite.dart';
import 'package:app/pages/Home.dart';
import 'package:app/pages/gerer_classes.dart';
import 'package:app/pages/gerer_eleves.dart';
import 'package:app/pages/gerer_emploi.dart';
import 'package:app/pages/gerer_utilisateurs.dart';


class Admin extends StatefulWidget {
  final String email;
  Admin(this.email);

  @override
  _AdminState createState() => _AdminState();  
}

class _AdminState extends State<Admin> {
  Future<List<Actualite>> getActualites() async {
    try {
      final response = await http.get(Uri.parse("http://10.0.2.2:8000/api/getActualites"));
      if (response.statusCode == 200) {
        final List responseData = jsonDecode(response.body)['list']; 
        return responseData.map((data) => Actualite.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load actualites');
      }
    } catch (e) { 
      print('Error: $e');  
      throw Exception('Failed to load actualites');
    }
  } 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome ${widget.email}') ,
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color.fromARGB(160, 0, 54, 99),
        ),
        body: Column(
          children: [
            Container(
                padding: EdgeInsets.all(20),
                child: GestureDetector(
                  child: Text("Ajouter Actualite"),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AjouterActualite(widget.email))) ,
                ),
              )  
              ,
               
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
                           String? filePath = snapshot.data![index].filePath;
                          String fileName = filePath != null ? filePath.split('/').last : '';
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.0),
                          title: Text( 
                            snapshot.data![index].body,
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8.0),
                              Text(
                                'Created At: ${snapshot.data![index].createdAt}',
                                style: TextStyle(fontSize: 14.0),
                              ),
                              SizedBox(height: 4.0),  
                              Text( 
                                'Created By: ${snapshot.data![index].userName}',
                                style: TextStyle(fontSize: 14.0),
                              ),SizedBox(height: 8.0), 
                              Text(
                                'File: $fileName',
                                style: TextStyle(fontSize: 14.0),
                              ),SizedBox(height: 8.0),
                              Row(children: [ElevatedButton(onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ModierActualite(snapshot.data![index].id,widget.email)));
                              }, child: Text("modifier")),Padding(padding: EdgeInsets.only(right: 20)),ElevatedButton(onPressed: (){
                                print(snapshot.data![index].id); 
                             deleteActualite(snapshot.data![index].id);
                             Navigator.push(context, MaterialPageRoute(builder: (context) => Admin(widget.email)));
                              }, child: Text("supprimer"),style:ButtonStyle(
                                backgroundColor:MaterialStatePropertyAll(Colors.red)) ,)],)
                            ],
                          ), 
                          onTap: () {
                             Navigator.push(context, MaterialPageRoute(builder: (context) =>Detail(snapshot.data![index].id)));
                          },
                        ),
                      );   
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
void deleteActualite(int actualiteId) async {
  final url = Uri.parse("http://10.0.2.2:8000/api/deleteActualite/$actualiteId");
  
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
