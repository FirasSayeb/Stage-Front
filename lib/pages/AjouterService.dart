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
   late String description;
   late String name;
   late double price;
  final fkey = GlobalKey<FormState>(); 
  String errorMessage = '';
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
       appBar: AppBar(
          title: Text('Ajouter Service') ,
          centerTitle: true,
          elevation: 0,
           backgroundColor: Color.fromARGB(255, 4, 166, 235),
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
                  child: Lottie.asset("assets/ser.json"),
                ),
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
                              name = newValue!;
                            },
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: 'Nom :',
  
      border: OutlineInputBorder(),
                            ),  
                          ),
                        ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.1,vertical:MediaQuery.of(context).size.height*0.02 ),
                        child: TextFormField(
                          validator: (value) {
                            if(value!.isEmpty || value.length==0){
                                   return "champs obligatoire";
                            }return null;
                          },
                        onSaved: (newValue) {
                          
                          if (newValue != null && newValue.isNotEmpty) {
                            price = double.parse(newValue);
                          }
                        },
                        keyboardType: TextInputType.number, 
                        decoration: InputDecoration(
                          labelText: 'Prix :',
  
      border: OutlineInputBorder(),
                        ),
                      ),
                      ),
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
                              description = newValue!;
                            },
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                             border: OutlineInputBorder(),
                              labelText: "Description:",
                            ),
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
                                 'description':description,
                                 'price':price.toString()  
                                };
                                
                                Response response = await post(
                                  Uri.parse("https://firas.alwaysdata.net/api/addService"),
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