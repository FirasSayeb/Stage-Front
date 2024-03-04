import 'dart:convert';
import 'package:app/model/user.dart';
import 'package:app/pages/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  User user = User(); 
  final GlobalKey<FormState> fkey = GlobalKey<FormState>(); 
  String errorMessage = '';

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
                child: Lottie.asset("assets/A.json"),
              ),
              const Padding(padding: EdgeInsets.all(5)),
              Container(
                alignment: Alignment.topCenter,
                child: const Text(
                  "Reset Password ",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const Padding(padding: EdgeInsets.all(10)),
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
                          user.email = newValue!;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Email:",
                          icon: Icon(Icons.email),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(10)),
                      GestureDetector(
                        onTap: () async {
                          if (fkey.currentState!.validate()) {
                            fkey.currentState!.save();

                            Map<String, String> userData = {
                              'email': user.email,
                            };  

                            http.Response response = await http.post(
                              Uri.parse("http://10.0.2.2:8000/api/respass"),
                              body: userData,
                            ); 

                            if (response.statusCode == 200) {
                              
                              Navigator.push( 
                                context, 
                                MaterialPageRoute(builder: (context) => ResetPassword(jsonDecode(response.body)["code"],user.email)),
                              );
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
                          child: const Text("Valider  "),
                        ),
                      ), 
                      Padding(padding: EdgeInsets.all(5)),
                      GestureDetector(
                        onTap: () {
                          // Handle navigation to the previous page
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
        ),
      ),
    );
  }
}
