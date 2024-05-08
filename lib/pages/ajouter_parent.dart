import 'dart:convert';

import 'package:app/pages/gerer_utilisateurs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class AjouterParent extends StatefulWidget {
  final String email;

  AjouterParent(this.email);

  @override
  State<AjouterParent> createState() => _HomeState();
}

class _HomeState extends State<AjouterParent> {
  PlatformFile? file;
  String? path;
  late String nom;
  late String email;
  late String password;
  late String address;
  late String phone;
  bool hide = true;
  bool hide2=true;
  late String valide;
  String? deviceToken;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> picksinglefile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      file = result.files.first;
      if (kIsWeb) {
        path = base64Encode(file!.bytes!); 
      } else {
        path = file!.path;
      }
      print(file!.bytes);
      print(file!.extension);
      print(file!.name);
      print(path);
    }
  }

  final fkey = GlobalKey<FormState>();
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    errorMessage = '';
    _firebaseMessaging.getToken().then((String? token) {
      setState(() {
        deviceToken = token;
      });
    });
  }
String? validateEmail(String? value) {
      const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
          r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
          r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
          r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
          r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
          r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
          r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
      final regex = RegExp(pattern);

      return value!.isEmpty || !regex.hasMatch(value)
          ? 'Enter a valid email address'
          : null;
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter Parent'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 4, 166, 235),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02)),
                Center(
                  child: Form(
                    key: fkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.1,vertical:MediaQuery.of(context).size.height*0.02 ),
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty || value.length == 0) {
                                return "champs obligatoire";
                              } else if (value.length < 3) {
                                return "verifier votre champs";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              nom = newValue!;
                            },
                            decoration: InputDecoration( labelText: 'Nom : ',
                            border: OutlineInputBorder(),),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.1,vertical:MediaQuery.of(context).size.height*0.02 ),
                          child: TextFormField(
                            validator: validateEmail,
                            onSaved: (newValue) {
                              email = newValue!;
                            },
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(labelText: 'Email : ',
                            border: OutlineInputBorder(),),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.1,vertical:MediaQuery.of(context).size.height*0.02 ),
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty || value.length == 0) {
                                return "champs obligatoire";
                              } else if (value.length < 3) {
                                return "verifier votre champs";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              password = newValue!;
                            },
                            decoration: InputDecoration(
                               labelText: 'password :',
  border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(hide ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    hide = !hide;
                                  });
                                },
                              ),
                              
                            ),
                            obscureText: hide,
                          ),
                        ), Container(
                        padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.1,vertical:MediaQuery.of(context).size.height*0.02 ),
                        child: TextFormField(
                           obscureText: hide2,
                          validator: (value) {
                            if (value!.isEmpty || value.length == 0) {
                              return "champs obligatoire";
                            } 
                            return null;
                          },
                          onSaved: (newValue) {
                            valide = newValue!;
                          },
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                             border: OutlineInputBorder(),
                              labelText:"Confirme Password:",
                            suffixIcon: IconButton(
                                icon: Icon(Icons.remove_red_eye),
                                onPressed: () {
                                  setState(() {
                                    hide2 = !hide2;
                                  });
                                },
                              ),
                          ),
                        ),
                      ),
                        Container(
                           padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.1,vertical:MediaQuery.of(context).size.height*0.02 ),
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty || value.length == 0) {
                                return "champs obligatoire";
                              } else if (value.length < 3) {
                                return "verifier votre champs";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              address = newValue!;
                            },
                            decoration: InputDecoration( labelText: 'Address :',
  
      border: OutlineInputBorder(),),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.1,vertical:MediaQuery.of(context).size.height*0.02 ),
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty || value.length == 0) {
                                return "champs obligatoire";
                              } else if (value.length < 8 || value.length >8) {
                                return "verifier votre champs";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              phone = newValue!;
                            },
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(labelText: 'phone :',
  
      border: OutlineInputBorder(),),
                          ),
                        ),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: picksinglefile,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 61, 186, 228)),
                            ),
                            icon: Icon(Icons.insert_drive_file_sharp),
                            label: Text(
                              'Choisir une image',
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              if (fkey.currentState!.validate() ) {
                                fkey.currentState!.save();
                                if (password != valide) {
          showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("Error"),
                                                    content: Text("'Les mots de passe ne sont pas les mêmes'"),
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
        } else {
 try {
                                 
                                  final request = http.MultipartRequest(
                                    'POST',
                                    Uri.parse('https://firas.alwaysdata.net/api/addParent'),
                                  )
                                    ..fields['name'] = nom
                                    ..fields['email'] = email
                                    ..fields['password'] = password
                                    ..fields['address'] = address
                                    ..fields['phone'] = phone
                                    ..fields['token'] = deviceToken ?? '';
                                     if (path != null && path!.isNotEmpty) {
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
                                         
   
                                  final streamedResponse = await request.send();
                                  final response = await http.Response.fromStream(streamedResponse);

                                  if (response.statusCode == 200) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => GererUtilisateurs(widget.email)),
                                    );
                                  } else {
                                   showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("Error"),
                                                    content: Text("Échec d'ajout du parent"),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop(true);
                                                        },
                                                        child: Text("OK"),
                                                      ),
                                                      
                                                    ],
                                                  );
                                                },
                                              );
                                  }
                                } catch (e) {
                                  print('Error: $e');
                                  setState(() {
                                    errorMessage = '';
                                  });
                                }
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
}
