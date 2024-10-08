import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class Profil extends StatefulWidget {
  final String email;
  Profil(this.email);

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  bool hide = true; 
  String errorMessage = '';
  late String password;
  late String phone;
  late String address;
  late Future<Map<String, dynamic>> _getUserFuture; 
  PlatformFile? file;
  String? name;
  String? path;
  @override
  void initState() {
    super.initState();
    _getUserFuture = getUser(widget.email); 
  }

  Future<void> pickSingleFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        file = result.files.first;
        if (kIsWeb) {
          path = base64Encode(file!.bytes!); 
        } else {
          path = file!.path;
        }
        name = file!.name;
        print("$name  name from function");
        print("$path path from function");
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
        throw Exception('Échec du chargement de lutilisateur');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement de lutilisateur');
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenu ${widget.email}'),
        backgroundColor: Color.fromARGB(255, 4, 166, 235),
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
              String? filePath = snapshot.data!['avatar'];
              String fileName = filePath != null ? filePath.split('/').last : '';
              path = file == null ? snapshot.data!['avatar'] : path;
              phone = snapshot.data!['phone'] ?? '';
              address = snapshot.data!['address'] ?? '';
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        pickSingleFile(); 
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
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1, vertical: MediaQuery.of(context).size.height * 0.02),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Nom : ',
                          border: OutlineInputBorder()
                        ),
                        initialValue: snapshot.data!['name'],
                        readOnly: true,
                      ),
                    ), 
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1, vertical: MediaQuery.of(context).size.height * 0.02),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email : ',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: snapshot.data!['email'],
                        readOnly: true,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1, vertical: MediaQuery.of(context).size.height * 0.02),
                      child: TextFormField(
                        onSaved: (newValue) {
                          password = newValue!;
                        },
                        keyboardType: TextInputType.text,
                        obscureText: hide, 
                        decoration: InputDecoration( 
                          labelText: 'Modifier mot de passe :',
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
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1, vertical: MediaQuery.of(context).size.height * 0.02),
                      child: TextFormField(
                        validator: (value) {
                          if(value == null || value.isEmpty){
                            return "champs obligatoire";
                          } else if (value.length < 8 || value.length > 8) {
                                  return "verifier votre champs";
                                }
                          return null;
                        },
                        onSaved: (newValue) {
                          phone = newValue!;
                        },
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'phone :',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: snapshot.data!['phone'],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1, vertical: MediaQuery.of(context).size.height * 0.02),
                      child: TextFormField(
                        validator: (value) {
                          if(value == null || value.isEmpty){
                            return "champs obligatoire";
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          address = newValue!;
                        }, 
                        decoration: InputDecoration(
                          labelText: 'Address :',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: snapshot.data!['address'],
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                    Center(
                      child: ElevatedButton(
                       onPressed: () async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://firas.alwaysdata.net/api/updateUser'),
    );
    request.fields['email'] = widget.email;
    request.fields['password'] = password;
    if (address.isNotEmpty) request.fields['address'] = address;
    if (phone.isNotEmpty) request.fields['phone'] = phone;
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
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      print(<String, dynamic>{
        'email': widget.email,
        'password': password,
        'file': path,
        'phone': phone,
        'address': address
      });
      Navigator.pop(context);
    }
    print(response.statusCode);
    print(response.body);
  }
},

                        child: Text('Valider'),
                      ),
                    ),
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ); 
            } 
          },
        ),
      ),
    );
  }
}
