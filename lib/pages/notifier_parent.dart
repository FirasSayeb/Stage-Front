
import 'dart:convert';
import 'package:app/pages/Enseignant.dart';
import 'package:collection/collection.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';

class NotifierParent extends StatefulWidget {
  final String name;
  final String email;
  NotifierParent(this.email,this.name);

  @override
  State<NotifierParent> createState() => _NotifierParentState();
}

class _NotifierParentState extends State<NotifierParent> {
  final fkey=GlobalKey<FormState>();
  late String message;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String errorMessage='';
  final selectedClasses=[];
  final tokens=[];
  late Response response2;
  @override
  Widget build(BuildContext context) { 
    return Scaffold(
       appBar: AppBar(title: Text('Envoyer Message'),centerTitle: true,
          elevation: 0,  
           backgroundColor: Color.fromARGB(255, 4, 166, 235),),
      body: SingleChildScrollView(
      child: Form(key:fkey ,child:Column(children: [ 
        Lottie.asset('assets/aaa.json',height: MediaQuery.of(context).size.height*0.4,width:MediaQuery.of(context).size.width),
        Container(
          padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.1,vertical:MediaQuery.of(context).size.height*0.02 ),
          child: TextFormField( 
             validator: (value) {
                                  if (value!.isEmpty || value.length == 0) {
                                return "champs obligatoire";
                              } 
                              return null;
                                },
            onChanged: (value) { 
              message=value; 
            },onSaved: (newValue) {
              message=newValue!;
            },
            decoration: InputDecoration(  
               border: OutlineInputBorder(),
              labelText: 'Message :'
            ),
          ),
        ),FutureBuilder<List<Map<String,dynamic>>>(future: getUsers(), builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
  
                              return Center(child: CircularProgressIndicator());
  
                            } else if (snapshot.hasError) {
  
                              return Center(child: Text('Impossible dobtenir les parents'));
   
                            } else {
  
                              return ListView.builder(
  shrinkWrap: true,  
  itemCount: snapshot.data!.length,   
  itemBuilder: (context, index) {
    final eleve = snapshot.data![index];
    final email = eleve['email'].toString();
    final isChecked = selectedClasses.contains(email);
    print(selectedClasses);
    print(isChecked);
    return CheckboxListTile(
      title: Text(email),
      value: isChecked, 
      onChanged: (value) {
        setState(() {
          if (value == true) {
            selectedClasses.add(email);
          } else {
            selectedClasses.remove(email);
          }
        });
      },
    );
  },
);

  
             }
           
                          
        },),
        FutureBuilder<List<Map<String,dynamic>>>(
          future: getUsers(),
          builder:(context, snapshot) {
            return  Center(
             child:  GestureDetector(
                                  onTap: () async { 
                                    if (fkey.currentState!.validate()) {
                                      fkey.currentState!.save();
                                       for (int i = 0; i < selectedClasses.length; i++) {
                                        Map<String, dynamic>? user = snapshot.data!.firstWhereOrNull((user) => user['email'] == selectedClasses[i]);
      
      
      if (user != null) {
        tokens.add(user['token']);
      }
                  }
                              print(tokens);
                                      Map<String, dynamic> userData = {
                                         'email':widget.email,
                                         'message':message,
                                         'list':selectedClasses.join(','),
                                         'device_token': await _firebaseMessaging.getToken(),
                                      };
                                          
                                      Response response = await post( 
                                        Uri.parse( 
                                            "https://firas.alwaysdata.net/api/addNotification"),
                                        body: userData,
                                      );  
                                      print(userData);
                                      
                                      if (response.statusCode == 200) { 
                                        print(userData);  
                                        for (int j = 0; j < tokens.length; j++) {
                 response2 = await post(
                  Uri.parse('https://fcm.googleapis.com/fcm/send'),
                  headers: {    
                    'Content-Type': 'application/json',
                    'Authorization':
                        'key=AAAA4WMATYA:APA91bFxzOAlkcvXkHv6pyk9-Bqb8rtUwF6TXiBiEAQLuiGUwr6X084p-GR2lSSfJM_-H6urIktOdKGYhqPjKEscHN9XoxN8AMMvxXjbq27ZzQbk-S589EH-euzjPeduKyoXgt1lXuSE',
                  },
                  body: jsonEncode({
                    "to": tokens[j],
                    "notification": {"title": "Notification", "body": message}
                  }),
                ); 
                print("-------------------------------");
                print( { 
                    "to": tokens[j],
                    "notification": {"title": "Notification", "body": message}
                  }
                    );
              }
                                        
        
        if (response2.statusCode == 200) { 
          Navigator.push( 
            context,
            MaterialPageRoute(builder: (context) => Enseignant(widget.email)),
          ); 
        }  
        
                                       /* NotificationService().showNotification(
                                          title: 'Notification',
                                          body: message
                                        );*/      
                                       /* Navigator.push(
                                            context, 
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Admin(widget.email)));*/
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
                                    child: const Text("Envoyer "),
                                  ),
                                ),
          );
          },
        )
      ],),),
    ),

    );
  }
  Future<List<Map<String,dynamic>>> getUsers()async { 
   try{ 
   final response =await get(Uri.parse("https://firas.alwaysdata.net/api/getParents/${widget.name}"));
   if(response.statusCode==200){
     List<dynamic> classesData = jsonDecode(response.body)['list'];
      List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(classesData);
      return classes;
   }else{
    throw Exception('Échec du chargement des parents');
   } 
   }catch(e){ 
    print(e); 
    throw Exception('Échec du chargement des parents'); 
   }
  }
}