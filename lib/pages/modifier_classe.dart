import 'dart:convert';
import 'package:app/pages/gerer_classes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ModifierClasse extends StatefulWidget {
  final int id;
  final String email; 
  ModifierClasse(this.email, this.id);

  @override
  _ModifierClasseState createState() => _ModifierClasseState();
}

class _ModifierClasseState extends State<ModifierClasse> {
  PlatformFile? file;
  PlatformFile? file2;
  String? name; 
  String? path;
  String? name2; 
  String? path2;
  String? body;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<Map<String, dynamic>> getClasse() async {
    try {
      final response =
          await http.get(Uri.parse("https://firas.alwaysdata.net/api/getClasse/${widget.id}"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['classe']; 
      } else {
        throw Exception('Failed to load classe'); 
      }
    } catch (e) { 
      print('Error: $e');
      throw Exception('Failed to load classe');
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

  Future<void> pickSecondFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        file2 = result.files.first;
        name2 = file2!.name;
        path2 = file2!.path;
        print("$name2  name2 from function");
        print("$path2 path2 from function");
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
                child: FutureBuilder<Map<String, dynamic>>(
                  future: getClasse(),   
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator()); 
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final classe = snapshot.data as Map<String, dynamic>?;

                      if (classe == null) {
                        return Center(child: Text('Classe not found'));
                      }

                      name = name ?? (classe['emploi'] != null ? classe['emploi'].split('/').last : '');
                      path = path ?? (classe['emploi'] != null ? classe['emploi'] : ''); 
                      name2 = name2 ?? (classe['examens'] != null ? classe['examens'].split('/').last : '');
                      path2 = path2 ?? ( classe['examens'] != null ? classe['examens'] : '');
                      body = body ?? ( classe['name'] != null ? classe['name'] : null); 

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
                                  initialValue: classe['name'] != null ? classe['name'] : '',
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
                                        'Emlpoi: ${name != null ? name! : 'No file'}',
                                        style: TextStyle(fontSize: 14.0),
                                      ),
                                      onTap: () {
                                        pickSingleFile();
                                      },
                                    ),
                                    ListTile(
                                      title: Text(
                                        'Examens: ${name2 != null ? name2! : 'No file'}',
                                        style: TextStyle(fontSize: 14.0),
                                      ),  
                                      onTap: () {  
                                        pickSecondFile();
                                      }, 
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                final response = await http.put(
                                  Uri.parse("https://firas.alwaysdata.net/api/updateClasse/${widget.id}"),
                                  body: <String, dynamic>{
                                    'body': body,
                                    'file': path,   
                                    'examens': path2
                                  },  
                                );
                                if (response.statusCode == 200) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => GererClasses(widget.email)));
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
