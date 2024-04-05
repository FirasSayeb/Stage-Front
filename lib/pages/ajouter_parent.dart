import 'package:app/pages/gerer_utilisateurs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  String? deviceToken;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> picksinglefile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        file = result.files.first;
        path = file!.path;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter Tuteur'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(160, 0, 54, 99),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05)),
                Center(
                  child: Form(
                    key: fkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            nom = newValue!;
                          },
                          decoration: InputDecoration(label: Text('nom :'), icon: Icon(Icons.text_fields)),
                        ),
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
                            email = newValue!;
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(label: Text('email :'), icon: Icon(Icons.email)),
                        ),
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
                            password = newValue!;
                          },
                          decoration: InputDecoration(
                            icon: Icon(Icons.password),
                            suffixIcon: IconButton(
                              icon: Icon(hide ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  hide = !hide;
                                });
                              },
                            ),
                            label: Text('password :'),
                          ),
                          obscureText: hide,
                        ),
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
                            address = newValue!;
                          },
                          decoration: InputDecoration(label: Text('Address :'), icon: Icon(Icons.location_city)),
                        ),
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
                            phone = newValue!;
                          },
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(label: Text('phone :'), icon: Icon(Icons.phone)),
                        ),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: picksinglefile,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 61, 186, 228)),
                            ),
                            icon: Icon(Icons.insert_drive_file_sharp),
                            label: Text(
                              'Pick Image',
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              if (fkey.currentState!.validate()) {
                                fkey.currentState!.save();
                                try {
                                  var file = await MultipartFile.fromPath('file', path!);
                                  final request = http.MultipartRequest(
                                    'POST',
                                    Uri.parse('https://firas.alwaysdata.net/api/addParent'),
                                  )
                                    ..fields['name'] = nom
                                    ..fields['email'] = email
                                    ..fields['password'] = password
                                    ..fields['address'] = address
                                    ..fields['phone'] = phone
                                    ..fields['token'] = deviceToken!;
                                    
                                         
    request.files.add(file);
                                  final streamedResponse = await request.send();
                                  final response = await http.Response.fromStream(streamedResponse);

                                  if (response.statusCode == 200) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => GererUtilisateurs(widget.email)),
                                    );
                                  } else {
                                    setState(() {
                                      errorMessage = 'Échec d\'ajout du parent';
                                    });
                                  }
                                } catch (e) {
                                  print('Error: $e');
                                  setState(() {
                                    errorMessage = 'Échec d\'ajout du parent';
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
}
