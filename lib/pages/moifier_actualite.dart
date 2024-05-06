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
  late String _body;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _body = "";
    getActualite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(160, 0, 54, 99),
      ),
      body: _body.isNotEmpty  
          ? SingleChildScrollView(
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                         Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.05)),
                        Container(
                           padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.1,vertical:MediaQuery.of(context).size.height*0.02 ),
                          child: TextFormField(
                          initialValue: _body,
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          onChanged: (value) {
                            setState(() {
                              _body = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Body',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
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
                                margin: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16.0),
                                  title: Text(''),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 8.0),
                                      ListTile(
                                        title: Text(
                                          'File: ${name != null ? name! : 'No file'}',
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

                                  // Create a new multipart request
                                  var request = http.MultipartRequest(
                                    'POST',
                                    Uri.parse(
                                        "https://firas.alwaysdata.net/api/updateActualite/${widget.id}"),
                                  );

                                  // Add form fields (body and email)
                                  request.fields['body'] = _body;
                                  request.fields['email'] = widget.email;

                                  // Add file if it exists and contains bytes
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
                                  var response2 =
                                      await http.Response.fromStream(response);

                                  // Handle the response
                                  if (response.statusCode == 200) {
                                    // If the update was successful, navigate to Admin page
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Admin(widget.email)));
                                  } else {
                                    // Handle error
                                    print('Failed to update actualite');
                                    print(
                                        json.decode(json.encode(response2.body)));
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
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Future<void> getActualite() async {
    try {
      final response = await http.get(
          Uri.parse("https://firas.alwaysdata.net/api/getActualite/${widget.id}"));
      if (response.statusCode == 200) {
        final List responseData = jsonDecode(response.body)['actualite'];
        setState(() {
          _body = responseData[0]["body"];
          name = responseData[0]["file_path"] != null
              ? responseData[0]["file_path"].split('/').last
              : '';
          path = responseData[0]["file_path"];
        });
      } else {
        throw Exception('Failed to load actualite');
      }
    } catch (e) {
      print('Error: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to load actualite"),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
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

}
  