import 'dart:convert';

import 'package:app/model/Actualite.dart';
import 'package:app/pages/Home.dart';
import 'package:app/pages/Profile.dart';
import 'package:app/pages/voir_event.dart';
import 'package:app/pages/voir_exercices.dart';
import 'package:app/pages/voir_notes.dart';
import 'package:app/pages/voir_notifications.dart';
import 'package:app/pages/voir_services.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Parent extends StatefulWidget {
  final String email;
  Parent(this.email);
  @override
  State<Parent> createState() => _SignupState();
} 

class _SignupState extends State<Parent> { 
   Future<List<Actualite>> getActualites() async {
    try { 
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getActualites"));
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
     home:Scaffold(
      appBar: AppBar(title: const Text("Parent "),centerTitle: true,elevation: 0,backgroundColor: Color.fromARGB(160,0,54,99),), 
      body: Container(
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
                             
                            ],
                          ), 
                          onTap: () {
                            
                          },
                        ),
                      );   
                      },   
                    ); 
                  }
                },
              ),
      ),
      drawer: Drawer(
        child: Container(
         
          color:  Color.fromARGB(160,0,54,99),
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
                title: Text("Voir Notes"),
                leading: Icon(Icons.grade),
                onTap: () { Navigator.push(
      context,   
      MaterialPageRoute(builder: (context) => VoirNotes(widget.email)));},
              ),
              ListTile(
                title: Text("Voir Exercices"),
                leading: Icon(Icons.task),
                onTap: () { Navigator.push(
      context,   
      MaterialPageRoute(builder: (context) => VoirExcercices(widget.email)));},
              ),
               ListTile(
                title: Text("Voir Notifications"),
                leading: Icon(Icons.notification_add),
                onTap: () { Navigator.push(
      context,   
      MaterialPageRoute(builder: (context) => VoirNotifications(widget.email)));},
              ),
               ListTile(
                title: Text("Voir Services"),
                leading: Icon(Icons.miscellaneous_services),
                onTap: () { Navigator.push(
      context,   
      MaterialPageRoute(builder: (context) => VoirServices(widget.email)));},
              ),
              ListTile(
                title: Text("Voir Events"),
                leading: Icon(Icons.event),
                onTap: () { Navigator.push(
      context,   
      MaterialPageRoute(builder: (context) => VoirEvent(widget.email)));},
              ),
               ListTile(
                title: Text("Deconnexion"),
                leading: Icon(Icons.exit_to_app),
                onTap: () { Navigator.push(
      context,   
      MaterialPageRoute(builder: (context) => Home()));},
              )
            ],
          ),
        ),
      )
     )
    );  
  } 
}