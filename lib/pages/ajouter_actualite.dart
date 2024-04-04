import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:app/pages/Admin.dart';
import 'package:flutter/material.dart';

class AjouterActualite extends StatefulWidget {
  final String email;

  AjouterActualite(this.email);

  @override
  State<AjouterActualite> createState() => _HomeState(); 
}

class _HomeState extends State<AjouterActualite> { 
  PlatformFile? file;
  String? path;
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
  late String body;
  final fkey = GlobalKey<FormState>(); 
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    body = '';
    errorMessage = '';
  }

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
       appBar: AppBar(
          title: Text('Ajouter Actualite') ,
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
                Container(
                  alignment: FractionalOffset.center,
                  height: MediaQuery.of(context).size.height*0.4,
                  child: Lottie.asset("assets/add.json"),
                ),
                const Padding(padding: EdgeInsets.all(5)),
                Container(
                  alignment: Alignment.topCenter,
                  child: const Text(
                    "Ajouter Actualite ",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(5)),
                Center(
                  child: Form( 
                    key: fkey,
                    child: Column(
                      children: [
                        Container(
                           padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.1,vertical:MediaQuery.of(context).size.height*0.02 ),
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
                              body = newValue!;
                            },
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: "Nom:", 
                              icon: Icon(Icons.text_fields_sharp),
                            ),  
                          ),
                        ),
                        ElevatedButton.icon(
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
                        const Padding(padding: EdgeInsets.all(10)),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              if (fkey.currentState!.validate()) {
                                fkey.currentState!.save();
                                print(body);

                                 var request = MultipartRequest(
        'POST',
        Uri.parse("https://firas.alwaysdata.net/api/addActualite"),
      );

      request.fields['body'] = body;
      request.fields['email'] = widget.email;
      
      if (path != null && path!.isNotEmpty) {
        var file = await MultipartFile.fromPath('file', path!);
        request.files.add(file);
      }
             var response = await request.send();                  

                                if (response.statusCode == 200) {  
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Admin(widget.email)));
                                } else {
                                  setState(() {
                                    errorMessage = "Error: ${response.statusCode}";
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
    );
  }
}
