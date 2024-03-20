import 'package:app/pages/gerer_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';

class AjouterService extends StatefulWidget {
  final String email;
  AjouterService(this.email);

  @override
  State<AjouterService> createState() => _AjouterServiceState();
}

class _AjouterServiceState extends State<AjouterService> {

   late String name;
   late double price;
  final fkey = GlobalKey<FormState>(); 
  String errorMessage = '';
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                const Padding(padding: EdgeInsets.all(10)),
                Container(
                  alignment: FractionalOffset.center,
                  height: MediaQuery.of(context).size.height*0.4,
                  child: Lottie.asset("assets/anii.json"),
                ),
                const Padding(padding: EdgeInsets.all(5)),
                Container(
                  alignment: Alignment.topCenter,
                  child: const Text(
                    "Ajouter Service ",
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
                            hintText: "Name:", 
                            icon: Icon(Icons.text_fields_sharp),
                          ),  
                        ),
                      TextFormField(
  onSaved: (newValue) {
    
    if (newValue != null && newValue.isNotEmpty) {
      price = double.parse(newValue);
    }
  },
  keyboardType: TextInputType.number, 
  decoration: InputDecoration(
    hintText: "Price:",
    icon: Icon(Icons.price_change),
  ),
),

                     
                           Padding(padding: EdgeInsets.all(5)), 
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              if (fkey.currentState!.validate()) {
                                fkey.currentState!.save();
                               

                                Map<String, dynamic> userData = {
                                 'name':name,
                                 'price':price.toString()  
                                };
                                
                                Response response = await post(
                                  Uri.parse("http://192.168.1.11:80/api/addService"),
                                  body: userData,   
                                );
                                   print(userData);
                                if (response.statusCode == 200) {  
                                  print(userData);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => GererServices(widget.email)));
                                } else { 
                                  setState(() { 
                                    errorMessage = "Error: ${response.statusCode}, ${response.body}";
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
    );
  }
}