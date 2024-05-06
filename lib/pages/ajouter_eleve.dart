import 'package:app/pages/gerer_eleves.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart'as http;
import 'dart:convert';

class AjouterEleve extends StatefulWidget {
  final String email;

  AjouterEleve(this.email);

  @override
  State<AjouterEleve> createState() => _AjouterEleveState();
}

class _AjouterEleveState extends State<AjouterEleve> {
  late String date = "";
  late String name;
  late String num;
  final selectedParents = [];
  late String lastname;
  late String selectedClass;
  final fkey = GlobalKey<FormState>();
  String errorMessage = '';
  late String selected = '';
  late String parent1;
  late String parent2;
  PlatformFile? file;
  String? path;
  late Future<List<Map<String, dynamic>>> _classes;
  late Future<List<Map<String, dynamic>>> _parents;

  @override
  void initState() {
    super.initState();
    name = '';
    errorMessage = '';
    selectedClass = '';
    _classes = getClasses();
    _parents = getParents();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter Eleve'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(160, 0, 54, 99),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Center(
                        child: Form(
                          key: fkey,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.1,
                                    vertical: MediaQuery.of(context)
                                            .size
                                            .height *
                                        0.02),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty || value.length == 0) {
                                      return "champs obligatoire";
                                    } else if (value.length < 3) {
                                      return "verifier votre champs";
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    num = newValue!;
                                  },
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Numero inscription :",
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.1,
                                    vertical: MediaQuery.of(context)
                                            .size
                                            .height *
                                        0.02),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty || value.length == 0) {
                                      return "champs obligatoire";
                                    } else if (value.length < 3) {
                                      return "verifier votre champs";
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    name = newValue!;
                                  },
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Nom :",
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.1,
                                    vertical: MediaQuery.of(context)
                                            .size
                                            .height *
                                        0.02),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty || value.length == 0) {
                                      return "champs obligatoire";
                                    } else if (value.length < 3) {
                                      return "verifier votre champs";
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    lastname = newValue!;
                                  },
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "prénom :",
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.1,
                                    vertical: MediaQuery.of(context)
                                            .size
                                            .height *
                                        0.02),
                                child: TextFormField(
                                  controller:
                                      TextEditingController(text: date),
                                  onSaved: (newValue) {
                                    date = newValue!;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'date de naissance',
                                    filled: true,
                                    prefixIcon: Icon(Icons.calendar_today),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.blue)),
                                  ),
                                  onTap: () {
                                    _selectDate();
                                  },
                                ),
                              ),
                              Padding(padding: EdgeInsets.all(10)),
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: _classes,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text(
                                        'Error: ${snapshot.error}');
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return Text('No data available');
                                  } else {
                                    return DropdownButton(
                                      value: selected.isNotEmpty
                                          ? selected
                                          : null,
                                      hint: Text("sélectionner  classe"),
                                      items: snapshot.data!.map((e) {
                                        return DropdownMenuItem(
                                          child: Text(e['name'].toString()),
                                          value: e['name'].toString(),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selected = value.toString();
                                        });
                                      },
                                    );
                                  }
                                },
                              ),
                              ElevatedButton.icon(
                                  onPressed: picksinglefile,
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(Color
                                              .fromARGB(255, 61, 186, 228))),
                                  icon: Icon(Icons.insert_drive_file_sharp),
                                  label: Text(
                                    'Choisir une image',
                                    style: TextStyle(fontSize: 25),
                                  )),
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: _parents,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text(
                                        'Error: ${snapshot.error}');
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return Text('No data available');
                                  } else {
                                    return DropdownButton(
                                      value: selectedParents.isNotEmpty
                                          ? selectedParents[0]
                                          : null,
                                      hint: Text("sélectionner tuteurs"),
                                      items: snapshot.data!.map((e) {
                                        return DropdownMenuItem(
                                          child: Text(
                                              e['email'].toString()),
                                          value: e['email'].toString(),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          if (selectedParents.contains(
                                              value.toString())) {
                                            selectedParents.remove(
                                                value.toString());
                                          } else {
                                            selectedParents.add(
                                                value.toString());
                                          }
                                          if (selectedParents.length > 2) {
                                            selectedParents
                                                .removeAt(0);
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

                              GestureDetector(
                                onTap: () async {
                                  if (fkey.currentState!.validate()) {
                                    fkey.currentState!.save();
                                    var request = MultipartRequest(
                                      'POST',
                                      Uri.parse(
                                          "https://firas.alwaysdata.net/api/addEleve"),
                                    );

                                    // Add form data
                                    request.fields['name'] = name;
                                    request.fields['num'] = num;
                                    request.fields['lastname'] = lastname;
                                    request.fields['date'] = date;
                                    request.fields['class'] = selected;
                                    request.fields['list'] =
                                        selectedParents.join(',');

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

                                    // Send request
                                    var response =
                                        await request.send();
                                    if (response.statusCode == 200) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  GererEleves(widget.email)));
                                    } else {
                                      showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("Error"),
                                                    content: Text("Échec d'ajout eleve"),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop(true);
                                                        },
                                                        child: Text("OK"),
                                                      ),
                                                      
                                                    ],
                                                  );
                                                },
                                              );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  margin:
                                      const EdgeInsets.symmetric(
                                          horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlueAccent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text("Ajouter "),
                                ),
                              ),
                              Text(
                                errorMessage,
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

Future<void> _selectDate() async {
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
      date = picked.toString().split(" ")[0];
      print('Selected Date: $date');
    });
  }
}



  Future<List<Map<String, dynamic>>> getParents() async {
    try {
      final response = await get(Uri.parse(
          'https://firas.alwaysdata.net/api/getParents'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            jsonDecode(response.body)['list'];
        final List<Map<String, dynamic>> parentList =
            responseData.map((data) => data as Map<String, dynamic>).toList();
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
      final response = await get(Uri.parse(
          "https://firas.alwaysdata.net/api/getClasses"));
      if (response.statusCode == 200) {
        List<dynamic> classesData =
            jsonDecode(response.body)['list'];
        List<Map<String, dynamic>> classes =
            List<Map<String, dynamic>>.from(classesData);
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
