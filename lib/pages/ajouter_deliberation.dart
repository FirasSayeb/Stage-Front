import 'dart:io';

import 'package:app/pages/Enseignant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
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
        MaterialPageRoute(builder: (context) => Enseignant(widget.email)),
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
                child: GestureDetector(
                  onTap: () async {
                    if (fkey.currentState!.validate()) {
                      fkey.currentState!.save();
                      await uploadFile();
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
}
