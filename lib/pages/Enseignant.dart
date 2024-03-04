import 'package:app/pages/Home.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
class Enseignant extends StatefulWidget { 
  const Enseignant({super.key});

  @override
  State<Enseignant> createState() => _SigninState();
} 

class _SigninState extends State<Enseignant> { 
  @override
  Widget build(BuildContext context) {  
    return MaterialApp(  
      debugShowCheckedModeBanner: false,        
     home:Scaffold(
      appBar: AppBar(title: const Text("Enseignant "),centerTitle: true,elevation: 0,backgroundColor: Color.fromARGB(160,0,54,99),), 
      body: Container(child: Lottie.asset("assets/Anim.json"),height: 400,width: 300,),
      drawer: Drawer(
        child: Container(
         
          color:  Color.fromARGB(160,0,54,99),
          child: ListView(  
            children: [  
             Padding(padding: EdgeInsets.only(top:50)),
              ListTile(
                title: Text("Home"),
                leading: Icon(Icons.home),
                onTap: () { Navigator.push(
      context,   
      MaterialPageRoute(builder: (context) => Enseignant()));},
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