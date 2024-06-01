import 'dart:convert';
import 'dart:io';

import 'package:app/pages/Admin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:open_file/open_file.dart';

class ModierActualite extends StatefulWidget {
  final int id;
  final String email;
  ModierActualite(this.id, this.email);

  @override
  _ModierActualiteState createState() => _ModierActualiteState();
}

class _ModierActualiteState extends State<ModierActualite> {
  PlatformFile? file;
  String? name;
  String? path;
  String? selectedname;
  String? selectedpath;
  String _body = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<Map<String, dynamic>>? _futureActualite;

  @override
  void initState() {
    super.initState();
    _futureActualite = getActualite();
  }

  Future<Map<String, dynamic>> getActualite() async {
    final response = await http.get(Uri.parse("https://firas.alwaysdata.net/api/getActualite/${widget.id}"));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      _body = responseData['actualite'][0]["body"];
      name = responseData['actualite'][0]["file_path"] != null
          ? responseData['actualite'][0]["file_path"].split('/').last
          : '';
      path = responseData['actualite'][0]["file_path"];
      return responseData;
    } else {
      throw Exception('Échec du chargement de actualite');
    }
  }

  Future<void> pickSingleFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        file = result.files.single;
        selectedname = file!.name;
        if (kIsWeb) {
          path = base64Encode(file!.bytes!);
        } else {
          path = file!.path;
        }
        name = selectedname;
        print("$name  name from function");
        print("$path path from function");
        print(file);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 4, 166, 235),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureActualite,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1, vertical: MediaQuery.of(context).size.height * 0.02),
                          child: TextFormField(
                            initialValue: _body,
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            onChanged: (value) {
                              _body = value;
                            },
                            decoration: InputDecoration(
                              labelText: 'Nom : ',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'champs obligatoire';
                              }
                              return null;
                            },
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              height: 200,
                              child: Card(
                                elevation: 4,
                                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16.0),
                                  title: Text(''),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 8.0),
                                      ListTile(
                                        title: Text(
                                          'fichier: ${name != null ? name! : 'pas de fichier'}',
                                          style: TextStyle(fontSize: 14.0),
                                        ),
                                        onTap: () {
                                          pickSingleFile();
                                        },
                                      ),
                                      SizedBox(height: 8.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  var request = http.MultipartRequest(
                                    'POST',
                                    Uri.parse("https://firas.alwaysdata.net/api/updateActualite/${widget.id}"),
                                  );
                                  request.fields['body'] = _body;
                                  request.fields['email'] = widget.email;
                                  if (file != null) {
                                    if (kIsWeb) {
                                      request.files.add(http.MultipartFile.fromBytes(
                                        'file',
                                        file!.bytes!,
                                        filename: file!.name,
                                      ));
                                    } else {
                                      request.files.add(await MultipartFile.fromPath('file', path!));
                                    }
                                  }
                                  var response = await request.send();
                                  var response2 = await http.Response.fromStream(response);
                                  if (response.statusCode == 200) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => Admin(widget.email)),
                                    );
                                  } else {
                                    print('Failed to update actualite');
                                    print(json.decode(json.encode(response2.body)));
                                  }
                                }
                              },
                              child: Text('Valider'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
