import 'dart:convert';
import 'dart:io';
import 'package:app/pages/gerer_eleves.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ModifierEleve extends StatefulWidget {
  final int id;
  final String email;
  ModifierEleve(this.email, this.id);

  @override
  _ModifierEleveState createState() => _ModifierEleveState();
}

class _ModifierEleveState extends State<ModifierEleve> {
  Future<void> pickSingleFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        file = result.files.first;
        name = file!.name;
        path = file!.path;
      });
    }
  }

  PlatformFile? file;
  String? path;
  String? select;
  String num='';
  final selectedParents=[];
  late String name = '';
  late String lastname = '';
  late String date = '';
  late String classe = '';
  late String parent1 = '';
  late String parent2 = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    print('Building UI with classe: $classe');
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
                  future: getEleve(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final eleve = snapshot.data as Map<String, dynamic>?;

                      if (eleve == null) {
                        return Center(child: Text('Eleve not found'));
                      }

                      path ??= eleve['profil'];
                      classe = eleve['class_name']; 

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              pickSingleFile();
                            },
                            child: ListTile(
                              title: CircleAvatar(
                                backgroundImage: FileImage(File(path ?? '')),
                                radius: 30,
                              ),
                            ),
                          ),
                          Container(
                            height: 400,
                            child: Card(  
                              elevation: 4,  
                              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16.0),
                                title: Column( 
                                  children: [
                                    TextFormField( 
                                      initialValue: eleve['num'],
                                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                      onChanged: (value) {
                                        num = value;
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter some text';
                                        }
                                        return null;
                                      },
                                    ),
                                    TextFormField(
                                      initialValue: eleve['name'],
                                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                      onChanged: (value) {
                                        name = value;
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter some text';
                                        }
                                        return null;
                                      },
                                    ),
                                    TextFormField(
                                      initialValue: eleve['lastname'],
                                      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                      onChanged: (value) {
                                        lastname = value;
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter some text';
                                        }
                                        return null;
                                      },
                                    ),
                                    TextFormField(
                                      initialValue: eleve['date_of_birth'],
                                      decoration: InputDecoration(
                                        labelText: 'Date',
                                        filled: true,
                                        prefixIcon: Icon(Icons.calendar_today),
                                        enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                                      ),
                                      onTap: () {
                                        _selectDate(eleve['date_of_birth']);
                                      },
                                    ),
                                    FutureBuilder<List<Map<String, dynamic>>>(
                                      future: getClasses(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text('Error: ${snapshot.error}');
                                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                          return Text('No data available');
                                        } else {
                                          return  DropdownButton(
  value: classe.isNotEmpty ? classe : null, 
  hint: Text("select classe"),
  items: snapshot.data!.map((e) {
    return DropdownMenuItem(
      child: Text(e['name'].toString()),
      value: e['name'].toString(),
    );
  }).toList(), 
  onChanged: (value) {
    print("Selected class: $value"); 
    
      classe = value.toString(); 
  
  },
);




                                        }
                                      },
                                    ),
                                     FutureBuilder<List<Map<String, dynamic>>>(
  future: getParents(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    } else if (snapshot.hasError) { 
      return Text('Error: ${snapshot.error}');
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Text('No data available'); 
    } else {
      return DropdownButton(
        value: selectedParents.isNotEmpty ? selectedParents[0] : null,
        hint: Text("select parent"), 
        items: snapshot.data!.map((e){
          return DropdownMenuItem(
            child: Text(e['email'].toString()),
            value: e['email'].toString(), 
          );
        }).toList(),
       onChanged: (value) {
  setState(() {
    
    if (selectedParents.contains(value.toString())) {
     
      selectedParents.remove(value.toString());
    } else {
     
      selectedParents.add(value.toString());
    }
   
    if (selectedParents.length > 2) {
      selectedParents.removeAt(0); 
    }
  });
},


      );
    } 
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
                                print("classe $classe");
                                final response = await http.put(
                                  Uri.parse("https://firas.alwaysdata.net/api/updateEleve/${widget.id}"),
                                   body: <String, dynamic>{
        'name': name ?? '',
        'num': num ?? '',
        'lastname': lastname ?? '',
        'date': select ?? eleve['date_of_birth'] ?? '',
        'class': classe ?? '',
       'list':selectedParents.join(','), 
        'file': path ?? '',  
      },
                                );
                                   print({
        'name': name ?? '',
        'num': num ?? '',
        'lastname': lastname ?? '',
        'date': select ?? eleve['date_of_birth'] ?? '',
        'class': classe ?? '',
'list':selectedParents.join(','), 
        'file': path ?? '',  
      });
                                if (response.statusCode == 200) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => GererEleves(widget.email)));
                                }
                                print(response.statusCode);
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

  Future<void> _selectDate(String initialDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      setState(() {
        select = picked.toString().split(" ")[0];
      });
    } else {
      setState(() {
        select = initialDate;
      });
    }
  }

 Future<Map<String, dynamic>> getEleve() async {
  try {
    final response = await http.get(Uri.parse("https://firas.alwaysdata.net/api/getEleve/${widget.id}"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['eleve'] as Map<String, dynamic>;
      num =data['num'] ?? '';
      name = data['name'] ?? '';
      lastname = data['lastname'] ?? '';
      date = data['date_of_birth'] ?? '';
      classe = data['class_name'] ?? '';
      parent1 = data['parent_names'] != null && data['parent_names'].isNotEmpty ? data['parent_names'][0] : '';
      parent2 = data['parent_names'] != null && data['parent_names'].length > 1 ? data['parent_names'][1] : '';

      return data; 
    } else {
      throw Exception('Failed to load eleve');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to load eleve');
  }
}
Future<List<Map<String, dynamic>>> getParents() async {
  try {
    final response = await http.get(Uri.parse('https://firas.alwaysdata.net/api/getParents'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body)['list'];
      final List<Map<String, dynamic>> parentList = responseData.map((data) => data as Map<String, dynamic>).toList();
      return parentList;
    } else {
      throw Exception('Failed to load parents');
    }
  } catch (e) {
    print('Error: $e');  
    throw Exception('Failed to load parents'); 
  }
}

  Future<List<Map<String, dynamic>>> getClasses() async {
    try {
      final response = await http.get(Uri.parse("https://firas.alwaysdata.net/api/getClasses"));

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
