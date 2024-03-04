import 'package:app/pages/gerer_eleves.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

class AjouterEleve extends StatefulWidget {
  final String email;

  AjouterEleve(this.email);

  @override
  State<AjouterEleve> createState() => _AjouterEleveState();
}

class _AjouterEleveState extends State<AjouterEleve> {
  late String date="";
  late String name;
  late String lastname;
  late String selectedClass; 
  final fkey = GlobalKey<FormState>();
  String errorMessage = '';
  late String selected=''; 
late String parent1;
late String parent2;
PlatformFile? file;
  String? path;
  @override
  void initState() {
    super.initState();
    name = '';
    errorMessage = '';
    selectedClass = '';
    
  }
  Future<void> picksinglefile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      file = result.files.first; 
      path = file!.path;
      print(file!.bytes);
      print(file!.extension);
      print(file!.name);
      print(file!.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    children: [
                      const Padding(padding: EdgeInsets.all(10)),
                      Container(
                        alignment: Alignment.topCenter,
                        child: const Text(
                          "Ajouter Eleve ",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.all(5)),
                      Center(
                        child: Form(
                          key: fkey,
                          child: Column(
                            children: [
                              TextFormField(
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
                                  hintText: "Nom:",
                                  icon: Icon(Icons.text_fields_sharp),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.all(5)),
                              TextFormField(
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
                                  hintText: "Prenom:",
                                  icon: Icon(Icons.text_fields_sharp),
                                ),
                              ),
                              Padding(padding: EdgeInsets.all(10)),
                              TextFormField(
                                controller: TextEditingController(text: date),
                                onSaved: (newValue) {
                                  date = newValue!;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Date',
                                  filled: true, 
                                  prefixIcon: Icon(Icons.calendar_today),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue)),
                                ),
                                onTap: () {
                                  _selectDate();
                                },
                              ),
                              /*TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty || value.length == 0) {
                                    return "champs obligatoire";
                                  } else if (value.length < 3) {
                                    return "verifier votre champs";
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  selected = newValue!;
                                },
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration( 
                                  hintText: "Classe:",
                                  icon: Icon(Icons.class_), 
                                ),
                              )*/Padding(padding: EdgeInsets.all(10)),
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
            return DropdownButton(
              value: selected.isNotEmpty ? selected : null,
              hint: Text("select classe"), 
              items: snapshot.data!.map((e){
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
          ),TextFormField(
  
  onSaved: (newValue) {
 parent1=newValue!;
  },
  keyboardType: TextInputType.emailAddress,
  decoration: InputDecoration(
    hintText: "Parent 1 email:",
    icon: Icon(Icons.email),
  ),
),  
TextFormField(
  
  onSaved: (newValue) { 
    parent2=newValue!;
  },
  keyboardType: TextInputType.emailAddress,
  decoration: InputDecoration(
    hintText: "Parent 2 email:",
    icon: Icon(Icons.email),
  ),
),ElevatedButton.icon(
  
                            onPressed: picksinglefile,
  
                            style: ButtonStyle( 
  
                              backgroundColor: MaterialStateProperty.all(
  
                                Color.fromARGB(255, 61, 186, 228)
  
                              )
  
                            ),
  
                            icon: Icon(Icons.insert_drive_file_sharp),
  
                            label: Text(
  
                              'Pick File',
  
                              style: TextStyle(fontSize: 25),
  
                            )
  
                          ),
      /* FutureBuilder<List<Map<String, dynamic>>>(
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
),*/



                              Padding(padding: EdgeInsets.all(10)),
                              GestureDetector(
                                onTap: () async { 
                                  if (fkey.currentState!.validate()) {
                                    fkey.currentState!.save();
                                    Map<String, dynamic> userData = {
                                      'name': name,
                                      'lastname': lastname,   
                                      'date': date,
                                      'class': selected,  
                                      'parent1': parent1,
                                       'parent2': parent2,
                                       'file': path ?? '', 
                                    };
                                    Response response = await post( 
                                      Uri.parse( 
                                          "http://10.0.2.2:8000/api/addEleve"),
                                      body: userData,
                                    );
                                    if (response.statusCode == 200) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  GererEleves(widget.email)));
                                    } else {
                                      setState(() {
                                        errorMessage =
                                            "Error: ${response.statusCode}, ${response.body}";
                                      });
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlueAccent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text("Ajouter "),
                                ),
                              ),
                              Padding(padding: EdgeInsets.all(5)),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  margin: const EdgeInsets.symmetric(horizontal: 40),
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlueAccent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text("Go Back  "),
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
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2050),
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
    final response = await get(Uri.parse('http://10.0.2.2:8000/api/getParents'));
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

  Future<List<Map<String,dynamic>>> getClasses() async {
  try {
    final response = await get(Uri.parse("http://10.0.2.2:8000/api/getClasses"));
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
