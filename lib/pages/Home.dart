import 'dart:convert';

import 'package:app/model/user.dart';
import 'package:app/pages/Enseignant.dart';
import 'package:app/pages/forgot_password.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:app/pages/Admin.dart';
import 'package:app/pages/Parent.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool hide = true;
  User user = User();
  final fkey = GlobalKey<FormState>();
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                const Padding(padding: EdgeInsets.all(10)),
                Container(
                  alignment: Alignment.topCenter,
                  child: const Text(
                    "welcome ",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Container(
                  alignment: FractionalOffset.center,
                  height: 220,
                  child: Lottie.asset("assets/Animation.json"),
                ),
                const Padding(padding: EdgeInsets.all(5)),
                Container(
                  alignment: Alignment.topCenter,
                  child: const Text(
                    "Sign In ",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
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
                            user.password = newValue!;
                          },
                          keyboardType: TextInputType.text,
                          obscureText: hide,
                          decoration: InputDecoration(
                            hintText: "Password:",
                            icon: Icon(Icons.password),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.remove_red_eye),
                              onPressed: () {
                                setState(() {
                                  hide = !hide;
                                });
                              },
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(3)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ForgotPassword()),
                            );
                          },
                          child: Container(
                            child: Text('Forget Password '),
                            padding: EdgeInsets.all(10),
                          ),
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              if (fkey.currentState!.validate()) {
                                fkey.currentState!.save();
                                print(user.email + "  " + user.password);

                                Map<String, String> userData = {
                                  'email': user.email,
                                  'password': user.password,
                                };

                                Response response = await post(
                                  Uri.parse("http://10.0.2.2:8000/api/auth"),
                                  body: userData,
                                );

                                if (response.statusCode == 200) {
                                  print("User authenticated successfully");

                                  if (json.decode(response.body)['redirect_url'] ==
                                      "admin") {
                                    Navigator.push(
                                      context, 
                                      MaterialPageRoute(
                                          builder: (context) =>  Admin(user.email,)),
                                    ); 
                                  } else if (json.decode(response.body)['redirect_url'] ==
                                      "parent") {  
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Parent()),
                                    );
                                  } else if (json.decode(response.body)['redirect_url'] ==
                                      "enseignant") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Enseignant()),
                                    );
                                  }
                                } else {
                                  setState(() {
                                    errorMessage = "Authentication failed: ${response.body}";
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
                              child: const Text("Sign in "),
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
