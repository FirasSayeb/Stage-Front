import 'dart:convert';
import 'dart:io';

import 'package:app/pages/Admin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';

class AjouterDel extends StatefulWidget {
  final String email;
  AjouterDel(this.email);

  @override
  State<AjouterDel> createState() => _AjouterDelState();
}

class _AjouterDelState extends State<AjouterDel> {
  final GlobalKey<FormState> fkey = GlobalKey<FormState>();
  PlatformFile? file;
  late Response response2;
  String errorMessage = '';
  late String path;

  Future<void> picksinglefile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      file = result.files.first;
      if (kIsWeb) {
        path = base64Encode(file!.bytes!); 
      } else {
        path = file!.path!;
      }
      print(file!.bytes);
      print(file!.extension);
      print(file!.name);
      print(path);
    }
  }

  
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter Notes'),
        centerTitle: true,
        elevation: 0,
         backgroundColor: Color.fromARGB(255, 4, 166, 235),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: fkey,
          child: Column(
            children: [
              Lottie.asset('assets/file.json',
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width),
              Padding(padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02)),
              ElevatedButton.icon(
                onPressed: picksinglefile,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 61, 186, 228)),
                ),
                icon: Icon(Icons.insert_drive_file_sharp),
                label: Text(
                  'Choisir un fichier Excel',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Center(
                child: FutureBuilder(
                  future: getParents(),
                  builder:(context, snapshot) {
                    return GestureDetector(
                    onTap: () async {
                      if (fkey.currentState!.validate()) {
                        fkey.currentState!.save();
                        var request = http.MultipartRequest(
      'POST',
      Uri.parse("https://firas.alwaysdata.net/api/addNote"),
    ); 
    request.fields['email'] = widget.email;
    if (file!=null) {
                                  if (kIsWeb) {
                                    request.files.add(http.MultipartFile.fromBytes(
                                      'file', 
                                      file!.bytes!,
                                      filename: file!.name,
                                    ));
                                  } else {
                                    request.files.add(await MultipartFile
                                        .fromPath('file', path!));
                                  }
                                }
      
     
    var response = await request.send();
    //print(fileBytes);
   // print(file!.name);
   print(widget.email);
    if (response.statusCode == 200) {
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Admin(widget.email)),
      );
    } else {
     
      showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("Error"),
                                                    content: Text("Échec d\'ajout Notes"),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop(false);
                                                        },
                                                        child: Text("OK"),
                                                      ),
                                                      
                                                    ],
                                                  );
                                                },
                                              );
    } 
                        for(int i=0;i<snapshot.data!.length;i++){
                            response2 = await post(
                  Uri.parse('https://fcm.googleapis.com/fcm/send'),
                  headers: {    
                    'Content-Type': 'application/json',
                    'Authorization':
                        'key=AAAA4WMATYA:APA91bFxzOAlkcvXkHv6pyk9-Bqb8rtUwF6TXiBiEAQLuiGUwr6X084p-GR2lSSfJM_-H6urIktOdKGYhqPjKEscHN9XoxN8AMMvxXjbq27ZzQbk-S589EH-euzjPeduKyoXgt1lXuSE',
                  },
                  body: jsonEncode({
                    "to": snapshot.data![i]['token'],
                    "notification": {"title": "Notification", "body": "Notes Sont Disponibles"}  
                  }),  
                ); 
                print("-------------------------------");
                print( { 
                    "to": snapshot.data![i]['token'],
                    "notification": {"title": "Notification", "body": "Notes Sont Disponibles"}
                  }
                    );
                        }
                      }
                      if(response2.statusCode==200){
                        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Admin(widget.email)),
      );
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
                  );
                  },
                   
                ),
              ),
             
            ],
          ),
        ),
      ),
    );
  }
  Future<List<Map<String,dynamic>>> getParents()async { 
   try{ 
   final response =await get(Uri.parse("https://firas.alwaysdata.net/api/getParents"));
   if(response.statusCode==200){
     List<dynamic> classesData = jsonDecode(response.body)['list'];
      List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(classesData);
      return classes;
   }else{
    throw Exception('échec du chargement des parents');
   } 
   }catch(e){ 
    print(e); 
    throw Exception('échec du chargement des parents'); 
   }
  }
}
