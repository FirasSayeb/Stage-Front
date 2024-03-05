import 'dart:convert';
import 'package:app/pages/Admin.dart';
import 'package:app/pages/AjouterClasse.dart';
import 'package:app/pages/Home.dart';
import 'package:app/pages/Profile.dart';
import 'package:app/pages/ajouter_notification.dart';
import 'package:app/pages/gerer_eleves.dart';
import 'package:app/pages/gerer_emploi.dart';
import 'package:app/pages/gerer_utilisateurs.dart';
import 'package:app/pages/modifier_classe.dart';
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

 Future<List<Map<String, dynamic>>> getClasses() async { 
  try {
    final response = await http.get(Uri.parse("http://10.0.2.2:8000/api/getClasses"));
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(  
      debugShowCheckedModeBanner: false,        
     home:Scaffold( 
      appBar: AppBar(title: const Text("Gerer Classes "),centerTitle: true,elevation: 0,backgroundColor: Color.fromARGB(160,0,54,99)), 
      body: SingleChildScrollView(child: Column(
        children: [ Padding(padding: EdgeInsets.all(5)), GestureDetector(child: Center(child: Text("Ajouter Classe ")),onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AjouterClasse(widget.email)));
          },),Padding(padding: EdgeInsets.all(10)),
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
      title: Text(
        "Name: ${snapshot.data![index]['name']}\nEmploi : $fileNameWithExtension \nExamens : $fileName2WithExtension",
       
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => ModifierClasse(widget.email,snapshot.data![index]['id']),
                    ),
                  );
                },
                child: Text('Modifier'), 
              ), 
              ElevatedButton(
                onPressed: () {
                  deleteClasse(snapshot.data![index]['name']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GererClasses(widget.email),
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
  ),
);


                        },
                      ),
                    );
                  }
                },
              ),

        
        ],
      ))  
      ,drawer: Drawer(
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
     )  
    );
  }
}
deleteClasse(String name)async{
  try{
     final response=await http.delete(Uri.parse("http://10.0.2.2:8000/api/deleteClasse/$name"));
     if(response.statusCode==200){
      print('success');
     }else{
   throw Exception('Failed to delete classe');  
     } 
  }catch(e) {
    print('Error: $e');
    throw Exception('Failed to delete classe'); 
  } 
}