import 'package:app/pages/Home.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
class Parent extends StatefulWidget {
  const Parent({super.key}); 

  @override
  State<Parent> createState() => _SignupState();
} 

class _SignupState extends State<Parent> {   
  @override
  Widget build(BuildContext context) { 
    return MaterialApp( 
      debugShowCheckedModeBanner: false,
     home:Scaffold(
      appBar: AppBar(title: const Text("Parent "),centerTitle: true,elevation: 0,backgroundColor: Color.fromARGB(160,0,54,99),), 
      body: Container(child: Lottie.asset("assets/Ani.json"),height: 400,width: 300,),
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
      MaterialPageRoute(builder: (context) => Parent()));},
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