import 'dart:convert';
import 'dart:io';
import 'package:app/pages/gerer_eleves.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ModifierEleve extends StatefulWidget {
  final int id;
  final String email;
  ModifierEleve(this.email, this.id);

  @override
  _ModifierEleveState createState() => _ModifierEleveState();
}

class _ModifierEleveState extends State<ModifierEleve> {
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

  PlatformFile? file;
  String? path;
  String? select;
  String num='';
  final selectedParents=[];
  late String name ;
  late String lastname;
  late String date = '';
  late String classe ;
  late String parent1 = '';
  late String parent2 = '';
  late String fileName;
late Future<List<Map<String, dynamic>>> _classes;
  late Future<List<Map<String, dynamic>>> _parents;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    classe="";
    fetchData();
     _classes = getClasses();
    _parents = getParents();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse("https://firas.alwaysdata.net/api/getEleve/${widget.id}"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['eleve'] as Map<String, dynamic>;
        setState(() {
          num = data['num'];
          name = data['name'];
          lastname = data['lastname'];
          date = data['date_of_birth'];
          classe = data['class_name'];
          parent1 = data['parent_names'] != null && data['parent_names'].isNotEmpty ? data['parent_names'][0] : '';
          parent2 = data['parent_names'] != null && data['parent_names'].length > 1 ? data['parent_names'][1] : '';
          path = data['profil'];
          fileName = path != null ? path!.split('/').last : '';
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building UI with classe: $classe');
    return  Scaffold(
        appBar: AppBar(
          title: const Text("Modifier"),
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color.fromARGB(160, 0, 54, 99),
        ),
        body: classe.isNotEmpty ? SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
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
                     Column( 
                            children: [
                              Container(
                                 padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.1,vertical:MediaQuery.of(context).size.height*0.02 ),
                                child: TextFormField( 
                                  initialValue: num,
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
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                              labelText: "Numero inscription :",
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.1,vertical:MediaQuery.of(context).size.height*0.02 ),
                                child: TextFormField(
                                  initialValue: name,
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
                                  decoration: InputDecoration(
                                   border: OutlineInputBorder(),
                              labelText: "Nom :",
                                ),
                                ),
                              ),
                              Container(
                                 padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.1,vertical:MediaQuery.of(context).size.height*0.02 ),
                                child: TextFormField(
                                  initialValue: lastname,
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
                                  decoration: InputDecoration(
                                     border: OutlineInputBorder(),
                                labelText: "prénom :",
                                  ),
                                ),
                              ),
                              Container(
                                 padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.1,vertical:MediaQuery.of(context).size.height*0.02 ),
                                child: TextFormField(
                                  initialValue: date,
                                  decoration: InputDecoration(
                                    labelText: 'Date',
                                    filled: true,
                                    prefixIcon: Icon(Icons.calendar_today),
                                    enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                                  ),
                                  onTap: () {
                                    _selectDate(date);
                                  },
                                ),
                              ),
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: _classes,
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
                                        setState(() {
                                          classe = value.toString(); 
                                        });
                                      },
                                    );
                                  }
                                },
                              ),
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: _parents,
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
                                      hint: Text("sélectionner tuteurs"), 
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
                              Text(
  'Selected Tuteurs:',
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
    itemCount: selectedParents.length,
    itemBuilder: (context, index) {
      return ListTile(
        title: Text(
          selectedParents[index],
          style: TextStyle(fontSize: 16),
        ),
      );
    },
  ),
),
                            ],
                          ),
                      
                      
                    
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          print("classe $classe");
                          var request = MultipartRequest(
                            'POST',
                            Uri.parse("https://firas.alwaysdata.net/api/updateEleve/${widget.id}"),
                          );
                          request.fields['name'] = name!;
                          request.fields['num'] = num!;
                          request.fields['lastname'] = lastname!;
                          request.fields['date'] = select ?? date ?? '';
                          request.fields['class'] = classe!;
                          request.fields['list'] = selectedParents.join(',');
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
                          if (response.statusCode == 200) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => GererEleves(widget.email)));
                          }
                          print(response.statusCode);
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

  Future<void> _selectDate(String initialDate) async {
     DateTime now = DateTime.now();
  DateTime elevenYearsAgo = DateTime(now.year - 11, now.month, now.day);
  DateTime fiveYearsAgo = DateTime(now.year - 5, now.month, now.day);
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: fiveYearsAgo,
    firstDate: elevenYearsAgo, 
    lastDate: fiveYearsAgo,
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
