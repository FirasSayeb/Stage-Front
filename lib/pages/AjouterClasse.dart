import 'dart:convert';

import 'package:app/pages/gerer_classes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http; 
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';

class AjouterClasse extends StatefulWidget {
  final String email;

  AjouterClasse(this.email);

  @override
  State<AjouterClasse> createState() => _HomeState(); 
}

class _HomeState extends State<AjouterClasse> { 
  PlatformFile? file,file2;
  String? path;
  String? secondFilePath;
  Future<void> picksinglefile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      file = result.files.first;

      if (kIsWeb) {
        path = base64Encode(file!.bytes!); 
      } else {
        path = file!.path;
      }
    }
  }

  Future<void> pickSecondFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      file2 = result.files.first;
      if (kIsWeb) {
        secondFilePath = base64Encode(file!.bytes!); 
      } else {
        secondFilePath = file!.path;
      }
    }
  }

  late String name;
  final fkey = GlobalKey<FormState>(); 
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    name = '';
    errorMessage = '';
  }

  @override 
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
          title: Text('Ajouter Classe') ,
          centerTitle: true,
          elevation: 0,
           backgroundColor: Color.fromARGB(255, 4, 166, 235),
        ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                const Padding(padding: EdgeInsets.all(10)),
                Container(
                  alignment: FractionalOffset.center,
                  height: MediaQuery.of(context).size.height*0.4,
                  child: Lottie.asset("assets/cla.json"),
                ),
                
                Center(
                  child: Form( 
                    key: fkey,
                    child: Column(
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
                              name = newValue!;
                            },
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Nom:",
                            ),  
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: picksinglefile,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Color.fromARGB(255, 61, 186, 228)
                            )
                          ),
                          icon: Icon(Icons.insert_drive_file_sharp),
                          label: Text(
                            'Choisir Emploi',
                            style: TextStyle(fontSize: 25),
                          )
                        ),
                        const Padding(padding: EdgeInsets.all(2)),
                        ElevatedButton.icon(
                          onPressed: pickSecondFile,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Color.fromARGB(255, 61, 186, 228)
                            )
                          ),
                          icon: Icon(Icons.insert_drive_file_sharp),
                          label: Text(
                            'Choisir  calendrier des examens',
                            style: TextStyle(fontSize: 12),
                          )
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              if (fkey.currentState!.validate()) {
                                fkey.currentState!.save();
                                print(name);

                                var request = http.MultipartRequest(
                                  'POST', 
                                  Uri.parse("https://firas.alwaysdata.net/api/addClasse")
                                );

                                request.fields['name'] = name;
                                

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

                                if (secondFilePath != null && secondFilePath!.isNotEmpty) {
                                 
 if (kIsWeb) {
                                    request.files.add(http.MultipartFile.fromBytes(
                                      'examens',
                                      file2!.bytes!,
                                      filename: file2!.name,
                                    ));
                                  } else {
                                    request.files.add(await MultipartFile
                                        .fromPath('examens', secondFilePath!));
                                  }}
                                try {
                                  final streamedResponse = await request.send();
                                  final response = await http.Response.fromStream(streamedResponse);

                                  if (response.statusCode == 200) {  
                                    Navigator.push(
                                      context, 
                                      MaterialPageRoute(builder: (context) => GererClasses(widget.email))
                                    );
                                  } else { 
                                    setState(() {
                                      errorMessage = "Error: ${response.statusCode}, ${response.body}";
                                    });
                                  }
                                } catch (e) {
                                  print('Error: $e');
                                  setState(() {
                                    errorMessage = 'Error occurred while sending the request';
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
