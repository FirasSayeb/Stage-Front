import 'package:app/pages/gerer_classes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http; // Alias http package to avoid conflicts
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
  PlatformFile? file;
  String? path;
  String? secondFilePath;
  Future<void> picksinglefile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      file = result.files.first;
      path = file!.path;
      print(file!.bytes);
      print(file!.extension);
      print(file!.name);
      print(file!.path);
    }
  }

  Future<void> pickSecondFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      file = result.files.first;
      setState(() {
        secondFilePath = file!.path;
      });
      print(secondFilePath); 
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
          backgroundColor: const Color.fromARGB(160, 0, 54, 99),
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
                  child: Lottie.asset("assets/add.json"),
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
                            'Choisissez Emploi',
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
                            'Choisir le calendrier des examens',
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
                                   var file = await MultipartFile.fromPath('file', path!);
        request.files.add(file);
                                 
                                }

                                if (secondFilePath != null && secondFilePath!.isNotEmpty) {
                                 
var file2 = await MultipartFile.fromPath('examens', secondFilePath!);
        request.files.add(file2);}
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
