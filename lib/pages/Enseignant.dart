import 'dart:convert';

import 'package:app/pages/AjouterClasse.dart';
import 'package:app/pages/Home.dart';
import 'package:app/pages/Profile.dart';
import 'package:app/pages/enseignant_home.dart';
import 'package:app/pages/list_actualites.dart';
import 'package:app/pages/list_elves.dart';
import 'package:app/pages/voir_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
class Enseignant extends StatefulWidget { 
  final String email;
  Enseignant(this.email);

  @override
  State<Enseignant> createState() => _SigninState();
} 

class _SigninState extends State<Enseignant> { 

  Future<List<Map<String, dynamic>>> getClasses() async { 
  try {
    final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getClasses"));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['list'];
      return data.cast<Map<String, dynamic>>(); 
    } else {
      throw Exception('Échec du chargement des  classes');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Échec du chargement des  classes');
  }
}
  @override
  Widget build(BuildContext context) {  
    return MaterialApp(  
      debugShowCheckedModeBanner: false,        
     home:Scaffold(
      appBar: AppBar(title:  Text("bienvenu ${widget.email} "),centerTitle: true,elevation: 0, backgroundColor: Color.fromARGB(255, 4, 166, 235),), 
      body: SingleChildScrollView(child: Column(
        children: [ Padding(padding: EdgeInsets.all(5)),
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
                      child: GridView.builder(
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
      onTap: () { 
        Navigator.push(
      context,   
      MaterialPageRoute(builder: (context) => ListEleves(widget.email,snapshot.data![index]['name'])));
      },
      title: Text( 
        "Nom: ${snapshot.data![index]['name']}\n ",
       
      ), 
      subtitle: Row(
  children: [
    Expanded(
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            "https://firas.alwaysdata.net/storage/$fileNameWithExtension",
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.3,
            fit: BoxFit.cover,
          ),
        ),
      ),
    ),
    Expanded(
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            "https://firas.alwaysdata.net/storage/$fileName2WithExtension",
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.3,
            fit: BoxFit.cover,
          ),
        ),
      ),
    ),
  ],
),

    ),
  ),
);


                        }, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
                      ),
                    );
                  }
                },
              ),

        
        ],
      )) ,
      drawer: Drawer(
        child: Container(
         
          color: Colors.white,
          child: ListView(  
            children: [ const Padding(padding: EdgeInsets.only(top: 30)), ListTile( 
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
      MaterialPageRoute(builder: (context) => Enseignant(widget.email)));},
              ),ListTile(
                title: Text("Voir Actualites"),
                leading: Icon(Icons.newspaper),
                onTap: () { Navigator.push(
      context,   
      MaterialPageRoute(builder: (context) => ListActualites(widget.email)));},
              ), 
               ListTile(
                title: Text("Consulter Messages"),
                leading: Icon(Icons.notification_add),
                onTap: () { Navigator.push(
      context,   
      MaterialPageRoute(builder: (context) => VoirNotifications(widget.email)));},
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