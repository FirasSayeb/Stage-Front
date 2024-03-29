import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Profil extends StatefulWidget {
  final String email;
  Profil(this.email);

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  bool hide = true; 
  late String password;
  late String? phone;
  late String? address;
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
      name = file!.name;
      path = file!.path;
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
              path= file==null ? snapshot.data!['avatar'] : path;
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
      backgroundImage:  FileImage(File(path!)) ,
      radius: 30, 
    ),
  ),
),

                    TextFormField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.text_fields),
                      ),
                      initialValue: snapshot.data!['name'],
                      readOnly: true,
                    ), 
                    TextFormField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.email),
                      ),
                      initialValue: snapshot.data!['email'],
                      readOnly: true,
                    ),
                    TextFormField(
                     
                      onSaved: (newValue) {
                        password = newValue!;
                      },
                      keyboardType: TextInputType.text,
                      obscureText: hide, 
                      decoration: InputDecoration( 
                        hintText: "Modifier Password:", 
                        icon: Icon(Icons.password),
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
                    TextFormField(
                      validator: (value) {
                        if( value==null ||value.isEmpty){
                          return "champs obligatoire";
                        }return null  ;
                      },
                      onSaved: (newValue) {
                        phone=newValue;
                      },
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        icon: Icon(Icons.phone),
                      ),
                      initialValue: snapshot.data!['phone'],
                    ),
                    TextFormField(validator: (value) {
                        if( value==null ||value.isEmpty){
                          return "champs obligatoire";
                        }return null  ;
                      }, onSaved: (newValue) {
                        address=newValue;
                      }, 
                      decoration: InputDecoration(
                        icon: Icon(Icons.location_city),
                      ),
                      initialValue: snapshot.data!['address'],
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final response = await http.put(
                              Uri.parse("https://firas.alwaysdata.net/api/updateUser/"),
                              body: <String, dynamic>{
                                'email': widget.email,
                                'password':password,
                                'file':path,
                                'phone':phone,
                                'address':address
                              },
                            ); print(<String, dynamic>{
                                'email': widget.email,
                                'password':password,
                                'file':path,
                                'phone':phone,
                                'address':address
                              },);
                            if (response.statusCode == 200) {
                              print(<String, dynamic>{
                                'email': widget.email,
                                'password':password,
                                'file':path, 
                                'phone':phone, 
                                'address':address
                              },);
                             Navigator.pop(context);
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
        ),
      ),
    );
  }
}  
