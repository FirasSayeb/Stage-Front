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
                        validator:validateEmail,
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
                              Uri.parse("https://firas.alwaysdata.net/api/respass"),
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
