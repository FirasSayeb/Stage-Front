import 'dart:convert';
import 'dart:io';
import 'package:app/pages/ajouter_deliberation.dart';
import 'package:app/pages/ajouter_notification.dart';
import 'package:app/pages/gerer_events.dart';
import 'package:app/pages/gerer_services.dart';
import 'package:app/pages/modifier_eleve.dart';
import 'package:app/pages/valider_event.dart';
import 'package:app/pages/valider_service.dart';
import 'package:http/http.dart' as http;
import 'package:app/pages/Admin.dart';
import 'package:app/pages/Home.dart';
import 'package:app/pages/Profile.dart';
import 'package:app/pages/ajouter_eleve.dart';
import 'package:app/pages/gerer_classes.dart';
import 'package:app/pages/gerer_emploi.dart';
import 'package:app/pages/gerer_utilisateurs.dart';
import 'package:flutter/material.dart';

class GererEleves extends StatefulWidget {
  final String email;
  GererEleves(this.email);

  @override
  State<GererEleves> createState() => _GererClassesState();
}

class _GererClassesState extends State<GererEleves> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(  
      debugShowCheckedModeBanner: false,        
     home:Scaffold(
      appBar: AppBar(title: const Text("Gerer Eleves "),centerTitle: true,elevation: 0,backgroundColor: Color.fromARGB(160,0,54,99)), 
      body: SingleChildScrollView(child: Column(
        children: [
          TextField(
            
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Rechercher...',
              suffixIcon: IconButton(
                icon: Icon(Icons.clear), onPressed: () {  },
                
              ),
            ),
           
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01)),
          FutureBuilder<List<Map<String, dynamic>>>(
                future: getEleves(),
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
                           if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(child: Text('No data available'));
    }
                          return Card(
  elevation: 4,
  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
  child: GestureDetector(
   
    child: ListTile(
      title: Column(
        children: [
           Row(
                                mainAxisAlignment: MainAxisAlignment.end,
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
          builder: (context) => ModifierEleve(widget.email,snapshot.data![index]['id']),
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
                                backgroundImage: FileImage(File(snapshot.data![index]['profil'] ?? '')),
                                radius: 30,
                              ),
                              Text( 
            "Numero: ${snapshot.data![index]['num']}",
           
          ),
          Text(
            "Name: ${snapshot.data![index]['name']}",
           
          ),Text(    
            "LastName: ${snapshot.data![index]['lastname']}",
            
          ),Text( 
            "ClassName: ${snapshot.data![index]['class_name']}", 
             
          ),  
          Text( 
            "Date of birth: ${snapshot.data![index]['date_of_birth']}",
             
          ), 
         Text(
    "Tuteurs : ${snapshot.data != null && snapshot.data!.isNotEmpty ? snapshot.data![index]['parent_names'] ?? '' : ''} ",
),

 
 
        ],
      ),
      subtitle: Column(  
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

        ],
      ),
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
      )) ,drawer: Drawer(
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
        floatingActionButton: FloatingActionButton(
           child: Icon(Icons.add),
          onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => AjouterEleve(widget.email)));
        }),
     )  
    );
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
  deleteEleve(String name)async{
  try{
     final response=await http.delete(Uri.parse("https://firas.alwaysdata.net/api/deleteEleve/$name"));
     if(response.statusCode==200){
      print('success');
     }else{
   throw Exception('Failed to delete eleve');  
     }
  }catch(e) { 
    print('Error: $e');
    throw Exception('Failed to delete eleve'); 
  } 
}
}