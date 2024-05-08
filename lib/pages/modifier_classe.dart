 import 'dart:convert';
import 'package:app/pages/gerer_classes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

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
  late String body;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    body=""; 
    getClasse();
  }

  Future<void> getClasse() async {
    try {
      final response = await http.get(Uri.parse(
          "https://firas.alwaysdata.net/api/getClasse/${widget.id}"));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(response.body)['classe'];
        setState(() {
          body = responseData["name"] ?? ''; 
          name = responseData["emploi"] != null
              ? responseData["emploi"].split('/').last
              : '';
          path = responseData["emploi"];
          name2 = responseData["examens"] != null
              ? responseData["examens"].split('/').last
              : '';
          path2 = responseData["examens"];
        });
      } else {
        throw Exception('Échec du chargement de  classe');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement de  classe');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier"),
        centerTitle: true,
        elevation: 0,
         backgroundColor: Color.fromARGB(255, 4, 166, 235),
      ),
      body: body.isNotEmpty ? SingleChildScrollView(
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
                    initialValue: body ?? '',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    onChanged: (value) {
                      setState(() {
                        body = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Nom',
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

Container(
  height: 150,
  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  decoration: BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 2,
        blurRadius: 4,
        offset: Offset(0, 3), 
      ),
    ],
    borderRadius: BorderRadius.circular(8),
    color: Colors.white,
  ),
  child: Padding(
    padding: EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            'Emlpoi: ${name != null ? name! : 'Pas de fichier'}',
            style: TextStyle(fontSize: 14.0),
          ),
          onTap: () {
            pickSingleFile();
          },
        ),
        ListTile(
          title: Text(
            'Examens: ${name2 != null ? name2! : 'Pas de fichier'}',
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

                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        var request = http.MultipartRequest(
                          'POST',
                          Uri.parse(
                              "https://firas.alwaysdata.net/api/updateClasse/${widget.id}"),
                        );
                        request.fields['body'] = body!;
                        if (file != null && file!.path!.isNotEmpty) {
                          print(path);
                          var file =
                              await http.MultipartFile.fromPath('file', path!);
                          request.files.add(file);
                        }
                        if (file2 != null && file2!.path!.isNotEmpty) {
                          print(path2);
                          var file2 = await http.MultipartFile.fromPath(
                              'examens', path2!);
                          request.files.add(file2);
                        }
                        var response = await request.send();
                        if (response.statusCode == 200) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      GererClasses(widget.email)));
                        }
                      }
                    },
                    child: Text('Valider'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ): Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}