import 'package:app/model/user.dart';
import 'package:app/pages/Home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class ResetPassword extends StatefulWidget {
  final int value;
  final String email;
  ResetPassword(this.value,this.email);

  @override
  State<ResetPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ResetPassword> {
  
  
  User user = User(); 
  final GlobalKey<FormState> fkey = GlobalKey<FormState>();
  String errorMessage = '';
  String valide="";
  bool hide1=true;
  bool hide2=true;
  late int code;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(10)),
              Container(
                alignment: FractionalOffset.center,
                height: 180,
                child: Lottie.asset("assets/Animatio.json"),
              ),
              const Padding(padding: EdgeInsets.all(5)),
              Container(
                alignment: Alignment.topCenter,
                child: const Text(
                  "Reset Password ",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const Padding(padding: EdgeInsets.all(4)),
              Center(
                child: Form(
                  key: fkey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty || value.length == 0) {
                            return "champs obligatoire";
                          } 
                          return null;
                        },
                        onSaved: (newValue) {
                          code = int.parse(newValue!) ;
                        }, 
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Code:",
                          icon: Icon(Icons.qr_code),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(4)),
                      TextFormField(
                        obscureText: hide1,
                        validator: (value) {
                          if (value!.isEmpty || value.length == 0) {
                            return "champs obligatoire";
                          } 
                          return null;
                        },
                        onSaved: (newValue) {
                          user.password = newValue!;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Password:",
                          icon: Icon(Icons.password),suffixIcon: IconButton(
                              icon: Icon(Icons.remove_red_eye),
                              onPressed: () {
                                setState(() {
                                  hide1 = !hide1; 
                                });
                              },
                            ),
                        ),
                      ),Padding(padding: EdgeInsets.all(4)),
                      TextFormField(
                         obscureText: hide2,
                        validator: (value) {
                          if (value!.isEmpty || value.length == 0) {
                            return "champs obligatoire";
                          } 
                          return null;
                        },
                        onSaved: (newValue) {
                          valide = newValue!;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Confirme Password:",
                          icon: Icon(Icons.password), suffixIcon: IconButton(
                              icon: Icon(Icons.remove_red_eye),
                              onPressed: () {
                                setState(() {
                                  hide2 = !hide2;
                                });
                              },
                            ),
                        ),
                      ),Padding(padding: EdgeInsets.all(4)),
                      GestureDetector(
                        onTap: () async {
                          if (fkey.currentState!.validate()) {
                            fkey.currentState!.save();
                               if(code ==widget.value && user.password==valide){
                                 Map<String, String> userData = {
                                  'email':widget.email,
                              'password': user.password,
                            };  

                            http.Response response = await http.post(
                              Uri.parse("http://10.0.2.2:8000/api/newpass"),
                              body: userData,
                            );

                            if (response.statusCode == 200) {
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Home()),
                              );
                            } else {
                             
                              setState(() {
                                errorMessage =
                                    "Error: ${response.statusCode}, ${response.body}";
                              });
                            } 
                               }
                               else if(code!=widget.value) {
                                setState(() {
                                errorMessage =
                                    "Error: Verifier Code "; 
                              });}else if(user.password!=valide){
                                  setState(() {
                                errorMessage =
                                    "Error: Password et verifier password sont differents ";
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
                          child: const Text("Valider  "),
                        ),
                      ), 
                      Padding(padding: EdgeInsets.all(5)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Home()),
                              );
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
        ),
      ),
    );
  }
}
