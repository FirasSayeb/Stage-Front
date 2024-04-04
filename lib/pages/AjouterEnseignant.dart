import 'dart:convert'; 
import 'package:app/pages/gerer_emploi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
class AjouterEnseignant extends StatefulWidget {
  final String email;

  AjouterEnseignant(this.email);

  @override
  State<AjouterEnseignant> createState() => _HomeState(); 
}

class _HomeState extends State<AjouterEnseignant> { 
  List<String> selectedClasses = [];
  PlatformFile? file;
  String? path; 
  late String nom;
  late String email;
  late String password;
  late String address;
  late String phone;
  bool hide=true;
  String? deviceToken;
   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
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
  final fkey = GlobalKey<FormState>(); 
  String errorMessage = '';

  @override
void initState() {
  super.initState();
  errorMessage = '';
  _firebaseMessaging.getToken().then((String? token) {
      setState(() {
        deviceToken = token;
      });
    });

}


  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
          title: Text('Ajouter Enseignant') ,
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color.fromARGB(160, 0, 54, 99),
        ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                const Padding(padding: EdgeInsets.all(10)),
               
                const Padding(padding: EdgeInsets.all(5)),
                Container(
                  alignment: Alignment.topCenter,
                  child: const Text(
                    "Ajouter Enseignant ",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(5)),
                Center(
                  child:  Form(
                key: fkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            
                              nom=newValue!;
                           
                          },
  decoration: InputDecoration(
    label: Text('nom :'),
    icon: Icon(Icons.text_fields)
  ), 
),
TextFormField(validator: (value) {
                            if (value!.isEmpty || value.length == 0) {
                              return "champs obligatoire";
                            } else if (value.length < 3) {
                              return "verifier votre champs";
                            }
                            return null;
                          },onSaved: (newValue) {
                            
                              email=newValue!;
                            
                          },keyboardType: TextInputType.emailAddress,
  decoration: InputDecoration(
    label: Text('email :'),
    icon: Icon(Icons.email)
  ),
),TextFormField(validator: (value) {
                            if (value!.isEmpty || value.length == 0) {
                              return "champs obligatoire";
                            } else if (value.length < 3) {
                              return "verifier votre champs";
                            }
                            return null;
                          },onSaved: (newValue) {
                            
                              password=newValue!;
                            
                          },
  decoration: InputDecoration(
    icon: Icon(Icons.password),
                        suffixIcon: IconButton(
                          icon: Icon(hide ? Icons.visibility : Icons.visibility_off), 
                          onPressed: () {
                            setState(() {
                              hide = !hide;  
                            }); 
                          },),
    label: Text('password :'),
    
  ),obscureText: hide, 
),TextFormField(validator: (value) {
                            if (value!.isEmpty || value.length == 0) {
                              return "champs obligatoire";
                            } else if (value.length < 3) {
                              return "verifier votre champs";
                            }
                            return null;
                          },onSaved: (newValue) {
                           
                              address=newValue!;
                            
                          },
  decoration: InputDecoration( 
    
    label: Text('Address :'),
    icon: Icon(Icons.location_city)
  ),
),TextFormField( validator: (value) {
                            if (value!.isEmpty || value.length == 0) {
                              return "champs obligatoire";
                            } else if (value.length < 8 || value.length > 8) {
                              return "verifier votre champs";
                            }
                            return null;
                          },onSaved: (newValue) {
                            
                              phone=newValue!;
                            
                          },keyboardType: TextInputType.phone,
  decoration: InputDecoration(
    label: Text('phone :'),
    icon: Icon(Icons.phone) 
  ),
),Center(
  child:   ElevatedButton.icon(
  
                            onPressed: picksinglefile,
  
                            style: ButtonStyle( 
  
                              backgroundColor: MaterialStateProperty.all(
  
                                Color.fromARGB(255, 61, 186, 228)
  
                              )
  
                            ),
  
                            icon: Icon(Icons.insert_drive_file_sharp),
  
                            label: Text(
  
                              'Choisir une image',
  
                              style: TextStyle(fontSize: 25),
  
                            )
  
                          ),
), Center(
  child:   FutureBuilder<List<Map<String, dynamic>>>(
  
                          future: getClasses(),
                              
                          builder: (context, snapshot) {
  
                            if (snapshot.connectionState == ConnectionState.waiting) {
  
                              return Center(child: CircularProgressIndicator());
  
                            } else if (snapshot.hasError) {
  
                              return Center(child: Text('Failed to get classes'));
  
                            } else {
  
                              return DropdownButton(
  
    value: selectedClasses.isNotEmpty ? selectedClasses.last : null, 
  
    hint: Text("select classe(s)"), 
  
    items: snapshot.data!.map((e){
  
      return DropdownMenuItem(
  
        child: Text(e['name'].toString()),
  
        value: e['name'].toString(),
  
      ); 
  
    }).toList(),  
    
    onChanged: (value) { 
      setState(() {   
          if(!selectedClasses.contains(value))
        selectedClasses.addAll([value.toString()]);
      });
     
    },
  
  );
  
             }
  
                          },
  
                        ),
),
Center(
  child:   GestureDetector( 
  onTap: () async {
  if (fkey.currentState!.validate()) { 
    fkey.currentState!.save();
    try {
      var request = MultipartRequest(
        'POST',
        Uri.parse("https://firas.alwaysdata.net/api/addEnseignant"),
      );

      request.fields['name'] = nom;
      request.fields['email'] = email;
      request.fields['password'] = password;
       request.fields['address'] = address;
       request.fields['phone'] = phone;
       request.fields['list'] = selectedClasses.join(',');
       request.fields['token'] = deviceToken!;
      if (path != null && path!.isNotEmpty) {
        var file = await MultipartFile.fromPath('file', path!);
        request.files.add(file);
      }
             var response = await request.send();
      print(request.fields);
      if (response.statusCode == 200) {
       print(request.fields);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GererEmploi(widget.email)),
        );
      } else {
        setState(() {
          errorMessage = 'Échec d\'ajout du parent';
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        errorMessage = 'Échec d\'ajout du parent';
      });
    }
  }
},

    child:  Container(
  
                                padding: const EdgeInsets.all(20),
  
                                margin: const EdgeInsets.symmetric(horizontal: 20),
  
                                decoration: BoxDecoration(
  
                                  color: Colors.lightBlueAccent,
  
                                  borderRadius: BorderRadius.circular(8),
  
                                ),
  
                                child: const Text("Ajouter "),
  
                              ),
  
                            ),
), Padding(padding: EdgeInsets.all(5)),
                       
                        Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),

                  ])))])]))
                    
                     
                   
                    
                 
                        
                   
    );
  }
  Future<List<Map<String,dynamic>>> getClasses() async {
  try {
    final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getClasses"));
    if (response.statusCode == 200) {
      List<dynamic> classesData = jsonDecode(response.body)['list'];
      List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(classesData);
      return classes; 
    } else {
      throw Exception('Failed to load classes ${response.statusCode}');
    }
  } catch (e) { 
    print('Error: $e');
    throw Exception('Failed to load classes'); 
  }
}
}
