import 'dart:convert'; 
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:app/pages/Admin.dart';

class AjouterActualite extends StatefulWidget {
  final String email;

  AjouterActualite(this.email);

  @override
  State<AjouterActualite> createState() => _HomeState();
}

class _HomeState extends State<AjouterActualite> {
  PlatformFile? file;
  dynamic path;
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

  late String body;
  final fkey = GlobalKey<FormState>();
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    body = '';
    errorMessage = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter Actualite'),
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
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Lottie.asset("assets/add.json"),
                ),
                const Padding(padding: EdgeInsets.all(5)),
                Container(
                  alignment: Alignment.topCenter,
                  child: const Text(
                    "Ajouter Actualite ",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(5)),
                Center(
                  child: Form(
                    key: fkey,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.1,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.02),
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
                              body = newValue!;
                            },
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: 'Body',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                            onPressed: picksinglefile,
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Color.fromARGB(255, 61, 186, 228))),
                            icon: Icon(Icons.insert_drive_file_sharp),
                            label: Text(
                              'Choisir une image',
                              style: TextStyle(fontSize: 25),
                            )),
                        const Padding(padding: EdgeInsets.all(10)),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              if (fkey.currentState!.validate()) {
                                fkey.currentState!.save();
                                print(body);

                                var request = http.MultipartRequest(
                                  'POST',
                                  Uri.parse(
                                      "https://firas.alwaysdata.net/api/addActualite"),
                                );

                                request.fields['body'] = body;
                                request.fields['email'] = widget.email;

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
                                var response = await request.send();

                                if (response.statusCode == 200) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Admin(widget.email))).then((_) =>
                                      setState(() {}));
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Error"),
                                        content:
                                            Text("Échec d\'ajout actualite"),
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
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
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
