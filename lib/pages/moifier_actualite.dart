import 'dart:convert';
import 'package:app/pages/Admin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/model/Actualite.dart';

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
  String? body;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<List<Actualite>> getActualite() async {
    try {
      final response =
          await http.get(Uri.parse("http://10.0.2.2:8000/api/getActualite/${widget.id}"));
      if (response.statusCode == 200) {
        final List responseData = jsonDecode(response.body)['actualite'];
        return responseData.map((data) => Actualite.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load actualite');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load actualite');
    }
  }

  Future<void> pickSingleFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        file = result.files.first;
        name = file!.name;
        path = file!.path;
        print("$name  name from function");
        print("$path path from function");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Modifier"),
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color.fromARGB(160, 0, 54, 99),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: FutureBuilder<List<Actualite>>(
                  future: getActualite(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final actualite = snapshot.data![0]; // Assuming you only fetch one actualite
                      name = name ?? (actualite.filePath != null ? actualite.filePath!.split('/').last : '');
                      path = path ?? (actualite.filePath != null ? actualite.filePath! : '');
                      body = actualite.body;
                      return Column(
                        children: [
                          Container(
                            height: 200,
                            child: Card(
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16.0),
                                title: TextFormField(
                                  initialValue: actualite.body,
                                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  onChanged: (value) {
                                    body = value;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                if (file != null) {
                                  setState(() {
                                    path = file!.path!;
                                  });
                                }
                                final response = await http.put(
                                  Uri.parse("http://10.0.2.2:8000/api/updateActualite/${widget.id}"),
                                  body: <String, dynamic>{
                                    'body': body!,
                                    'file': path!,
                                  },
                                );
                                if (response.statusCode == 200) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Admin(widget.email)));
                                }
                              }
                            },
                            child: Text('Valider'),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
