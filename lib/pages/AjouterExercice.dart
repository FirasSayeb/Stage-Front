import 'dart:convert';

import 'package:app/pages/gerer_exercices.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';

class AjouterExercice extends StatefulWidget { 
  final String email;
  final String name;
  AjouterExercice(this.email,this.name);

  @override
  State<AjouterExercice> createState() => _AjouterExerciceState();
}

class _AjouterExerciceState extends State<AjouterExercice> {
  String errorMessage='';
  final fkey=GlobalKey<FormState>();
  late String description;
  late String name;
  late Response response2;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                const Padding(padding: EdgeInsets.all(10)),
                Container(
                  alignment: FractionalOffset.center,
                  height: MediaQuery.of(context).size.height*0.44,
                  child: Lottie.asset("assets/homework.json"),
                ),
                const Padding(padding: EdgeInsets.all(5)),
                Container(
                  alignment: Alignment.topCenter,
                  child: const Text(
                    "Ajouter Exercice ",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(5)),
                Center(
                  child: Form( 
                    key: fkey,
                    child: Column(
                      children: [ 
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty || value.length == 0) {
                              return "champs obligatoire";
                            } else if (value.length < 3) {
                              return "verifier votre champs";
                            }
                            return null;
                          },
                          onSaved: (newValue) { 
                            name = newValue!;
                          },
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Name:", 
                            icon: Icon(Icons.text_fields_sharp),
                          ),  
                        ),TextFormField(
                          validator: (value) {
                            if (value!.isEmpty || value.length == 0) {
                              return "champs obligatoire";
                            } else if (value.length < 3) {
                              return "verifier votre champs";
                            }
                            return null;
                          },
                          onSaved: (newValue) { 
                            description = newValue!;
                          },
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Description:", 
                            icon: Icon(Icons.text_fields_sharp),
                          ),  
                        ),
                           Padding(padding: EdgeInsets.all(5)), 
                        FutureBuilder(
  future: getUsers(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Failed to get users: ${snapshot.error}'));
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(child: Text('No data available'));
    } else {
      // Debug: print the snapshot data
      print('Snapshot data: ${snapshot.data}');

      return Center(
        child: GestureDetector(
          onTap: () async {
            if (fkey.currentState!.validate()) {
              fkey.currentState!.save();

              Map<String, dynamic> userData = {
                'name': name,
                'email':widget.email, 
                'description': description,
                'class': widget.name
              };

              Response response = await post(
                Uri.parse("http://10.0.2.2:8000/api/addExercice"),
                body: userData,
              );  

              for (int i = 0; i < snapshot.data!.length; i++) {
                final user = snapshot.data![i] as Map<String, dynamic>;
                final token = user['token'] as String;
               response2= await post(
                  Uri.parse('https://fcm.googleapis.com/fcm/send'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization':
                        'key=AAAA4WMATYA:APA91bFxzOAlkcvXkHv6pyk9-Bqb8rtUwF6TXiBiEAQLuiGUwr6X084p-GR2lSSfJM_-H6urIktOdKGYhqPjKEscHN9XoxN8AMMvxXjbq27ZzQbk-S589EH-euzjPeduKyoXgt1lXuSE',
                  },
                  body: jsonEncode({ 
                    "to": token,
                    "notification": {"title": "Notification", "body": name}
                  }),
                ); 
                print( jsonEncode({
                    "to": token,
                    "notification": {"title": "Notification", "body": name}
                  }));
              }
                  
              if (response.statusCode == 200 && response2.statusCode==200) {
                Navigator.push(
                    context,
                    MaterialPageRoute( 
                        builder: (context) => GererExercices(
                            widget.email, widget.name))); 
              } else {
                setState(() { 
                  errorMessage =
                      "Error: ${response.statusCode}, ${response.body}";
                });
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text("Ajouter "),
          ),
        ),
      );
    }
  },
),

                        Padding(padding: EdgeInsets.all(5)),
                        GestureDetector(  
                          onTap: () { 
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            decoration: BoxDecoration(
                              color: Colors.lightBlueAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text("Go Back  "),
                          ),
                        ),
                        Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
 Future<List<Map<String,dynamic>>> getUsers()async { 
   try{ 
   final response =await get(Uri.parse("http://10.0.2.2:8000/api/getUsers/${widget.name}"));
   if(response.statusCode==200){
     List<dynamic> classesData = jsonDecode(response.body)['list'];
      List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(classesData);
      return classes;
   }else{ 
    throw Exception('failed to get users');
   }
   }catch(e){
    print(e); 
    throw Exception('Failed to load users');  
   }
  }
}