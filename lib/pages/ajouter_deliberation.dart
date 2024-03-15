import 'dart:convert';
import 'dart:io';

import 'package:app/pages/Admin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';

class AjouterDel extends StatefulWidget {
  final String email;
  AjouterDel(this.email);

  @override
  State<AjouterDel> createState() => _AjouterDelState();
}

class _AjouterDelState extends State<AjouterDel> {
  final GlobalKey<FormState> fkey = GlobalKey<FormState>();
  PlatformFile? file;
  late Response response2;
  String errorMessage = '';

  Future<void> pickSingleFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        file = result.files.first;
      });
    }
  }

  Future<void> uploadFile() async {
  if (file == null) {
    // No file selected
    return;
  }

  try {
    // Convert PlatformFile to File
    File fileFromPicker = File(file!.path!);

    // Read the bytes of the file
    List<int> fileBytes = await fileFromPicker.readAsBytes();

   
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://10.0.2.2:8000/api/addNote"),
    ); 
    request.fields['email'] = widget.email;
    request.files.add(http.MultipartFile.fromBytes( 
      'file',    
      fileBytes,
      filename: file!.name,              
    ));
      
     
    var response = await request.send();
    print(fileBytes);
    print(file!.name);
    if (response.statusCode == 200) {
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Admin(widget.email)),
      );
    } else {
     
      setState(() {
        errorMessage = "Error: ${response.statusCode}";
      });
    }
  } catch (e) {
    // Handle error
    setState(() {
      errorMessage = "Error: $e"; 
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter Notes'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(160, 0, 54, 99),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: fkey,
          child: Column(
            children: [
              Lottie.asset('assets/file.json',
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width),
              Padding(padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02)),
              ElevatedButton.icon(
                onPressed: pickSingleFile,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 61, 186, 228)),
                ),
                icon: Icon(Icons.insert_drive_file_sharp),
                label: Text(
                  'Pick Excel File',
                  style: TextStyle(fontSize: 25),
                ),
              ),
              Center(
                child: FutureBuilder(
                  future: getParents(),
                  builder:(context, snapshot) {
                    return GestureDetector(
                    onTap: () async {
                      if (fkey.currentState!.validate()) {
                        fkey.currentState!.save();
                        await uploadFile(); 
                        for(int i=0;i<snapshot.data!.length;i++){
                            response2 = await post(
                  Uri.parse('https://fcm.googleapis.com/fcm/send'),
                  headers: {    
                    'Content-Type': 'application/json',
                    'Authorization':
                        'key=AAAA4WMATYA:APA91bFxzOAlkcvXkHv6pyk9-Bqb8rtUwF6TXiBiEAQLuiGUwr6X084p-GR2lSSfJM_-H6urIktOdKGYhqPjKEscHN9XoxN8AMMvxXjbq27ZzQbk-S589EH-euzjPeduKyoXgt1lXuSE',
                  },
                  body: jsonEncode({
                    "to": snapshot.data![i]['token'],
                    "notification": {"title": "Notification", "body": "Notes Sont Disponibles"}  
                  }),  
                ); 
                print("-------------------------------");
                print( { 
                    "to": snapshot.data![i]['token'],
                    "notification": {"title": "Notification", "body": "Notes Sont Disponibles"}
                  }
                    );
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
                  );
                  },
                   
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
    );
  }
  Future<List<Map<String,dynamic>>> getParents()async { 
   try{ 
   final response =await get(Uri.parse("http://10.0.2.2:8000/api/getParents"));
   if(response.statusCode==200){
     List<dynamic> classesData = jsonDecode(response.body)['list'];
      List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(classesData);
      return classes;
   }else{
    throw Exception('failed to get parents');
   } 
   }catch(e){ 
    print(e); 
    throw Exception('Failed to load parents'); 
   }
  }
}
