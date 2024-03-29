import 'dart:convert';

import 'package:app/model/user.dart';
import 'package:app/pages/Enseignant.dart';
import 'package:app/pages/forgot_password.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
   String? validateEmail(String? value) {
      const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
          r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
          r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
          r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
          r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
          r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
          r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
      final regex = RegExp(pattern);

      return value!.isEmpty || !regex.hasMatch(value)
          ? 'Enter a valid email address'
          : null;
    }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firebaseMessaging.getToken().then((String? token) {
      print("Firebase Token: $token");
      mtoken=token;

    });
  }
  String? mtoken;
  bool hide = true;
  User user = User();
  final fkey = GlobalKey<FormState>();
  String errorMessage = '';
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
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
                  height: MediaQuery.of(context).size.height*0.4,
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
                          validator: validateEmail,
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
                                  'token':mtoken!,
                                };  
                                 print(mtoken); 
                                Response response = await post(
                                  Uri.parse("https://firas.alwaysdata.net/api/auth"),
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
                                          builder: (context) =>  Parent(user.email)),
                                    );
                                  } else if (json.decode(response.body)['redirect_url'] ==
                                      "enseignant") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>  Enseignant(user.email)),
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
