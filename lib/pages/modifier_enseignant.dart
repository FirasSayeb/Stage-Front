import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ModEnsignant extends StatefulWidget {
  final String email;
  ModEnsignant(this.email);

  @override
  State<ModEnsignant> createState() => _ModEnsignantState();
}

class _ModEnsignantState extends State<ModEnsignant> {
  List<String> selectedClasses = [];
  bool hide = true;
  late String password;
  late String? phone;
  late String? address;
  late Future<Map<String, dynamic>> _getUserFuture;
  PlatformFile? file;
  String? name;
  String? path;
  late Future<List<Map<String, dynamic>>> _classesFuture;

  @override
  void initState() {
    super.initState();

    _getUserFuture = getUser(widget.email);
    _classesFuture = getClasses(); 
  }

 Future<void> picksinglefile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null) {
    setState(() {
      file = result.files.first;
      name = file!.name;
      if (kIsWeb) {
        path = base64Encode(file!.bytes!); // Convert bytes to base64 string
      } else {
        path = file!.path;
      }
      print(file!.bytes);
      print(file!.extension);
      print(file!.name);
      print(path);
    });
  }
}


  Future<Map<String, dynamic>> getUser(String email) async {
    try {
      final response = await http.get(
        Uri.parse('https://firas.alwaysdata.net/api/getUser/${widget.email}'),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body)['user'];
        return responseData;
      } else {
        throw Exception('Failed to load user');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load user');
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${widget.email}'),
        backgroundColor: const Color.fromARGB(160, 0, 54, 99),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _getUserFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              path = file == null ? snapshot.data!['avatar'] : path;
              String fileName = path!.split('/').last;
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _classesFuture,
                builder: (context, classesSnapshot) {
                  if (classesSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (classesSnapshot.hasError) {
                    return Center(child: Text('Failed to get classes'));
                  } else {
                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              picksinglefile();
                            },
                            child: ListTile(
                              title: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  "https://firas.alwaysdata.net/storage/$fileName",
                                ),
                                radius: 30,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width * 0.1,
                                vertical: MediaQuery.of(context).size.height * 0.02),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Nom :',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: snapshot.data!['name'],
                              readOnly: true,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width * 0.1,
                                vertical: MediaQuery.of(context).size.height * 0.02),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Email :',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: snapshot.data!['email'],
                              readOnly: true,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width * 0.1,
                                vertical: MediaQuery.of(context).size.height * 0.02),
                            child: TextFormField(
                              onSaved: (newValue) {
                                password = newValue!;
                              },
                              keyboardType: TextInputType.text,
                              obscureText: hide,
                              decoration: InputDecoration(
                                labelText: 'Modifier Mot de passe :',
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
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width * 0.1,
                                vertical: MediaQuery.of(context).size.height * 0.02),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "champs obligatoire";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                phone = newValue;
                              },
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'numéro de téléphone  :',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: snapshot.data!['phone'],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width * 0.1,
                                vertical: MediaQuery.of(context).size.height * 0.02),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "champs obligatoire";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                address = newValue;
                              },
                              decoration: InputDecoration(
                                labelText: 'address  :',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: snapshot.data!['address'],
                            ),
                          ),
                          Center(
                            child: DropdownButton(
                              value: selectedClasses.isNotEmpty ? selectedClasses.first : null,
                              hint: Text("select classe(s)"),
                              items: classesSnapshot.data!.map((e) {
                                return DropdownMenuItem(
                                  child: Text(e['name'].toString()),
                                  value: e['name'].toString(),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (!selectedClasses.contains(value)) selectedClasses.addAll([value.toString()]);
                                setState(() {});
                              },
                            ),
                          ),Text(
  'Selected Classes:',
  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
),
SizedBox(height: 10),
Container(
  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    color: Colors.grey[200],
  ),
  child: ListView.builder(
    shrinkWrap: true,
    itemCount: selectedClasses.length,
    itemBuilder: (context, index) {
      return ListTile(
        title: Text(
          selectedClasses[index],
          style: TextStyle(fontSize: 16),
        ),
      );
    },
  ),
),

                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                 
                                  var request = http.MultipartRequest(
                                    'POST',
                                    Uri.parse("https://firas.alwaysdata.net/api/updateEnseignant"),
                                  );

                                  request.fields['email'] = widget.email;
                                  request.fields['password'] = password;
                                  request.fields['address'] = address!;
                                  request.fields['phone'] = phone!;
                                  request.fields['list'] = selectedClasses.join(',');
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

                                  print(request.fields);

                                  if (response.statusCode == 200) {
                                    print(request.fields);

                                    Navigator.pop(context);
                                  } else {
                                    var response2 = await http.Response.fromStream(response);
                                    final result = json.decode(json.encode(response2.body));
                                    print(response.statusCode);
                                    print(result);
                                  }
                                }
                              },
                              child: Text('Valider'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getClasses() async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getClasses"));
      if (response.statusCode == 200) {
        List<dynamic> classesData = jsonDecode(response.body)['list'];
        List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(classesData);
        return classes;
      } else {
        throw Exception('Failed to load classes');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load classes');
    }
  }
}
