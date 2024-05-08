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
    return  Scaffold(
        appBar: AppBar(
          title: Text('réinitialiser le mot de passe') ,
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color.fromARGB(255, 4, 166, 235),
        ),
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
                  "réinitialiser le mot de passe ",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const Padding(padding: EdgeInsets.all(4)),
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
                            } 
                            return null;
                          },
                          onSaved: (newValue) {
                            code = int.parse(newValue!) ;
                          }, 
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                             border: OutlineInputBorder(),
                              labelText: "Code :",
                          ),
                        ),
                      ),
                     
                      Container(
                         padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.1,vertical:MediaQuery.of(context).size.height*0.02 ),
                        child: TextFormField(
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
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                             border: OutlineInputBorder(),
                              labelText: "Mot de passe :",
                           suffixIcon: IconButton(
                                icon: Icon(Icons.remove_red_eye),
                                onPressed: () {
                                  setState(() {
                                    hide1 = !hide1; 
                                  });
                                },
                              ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.1,vertical:MediaQuery.of(context).size.height*0.02 ),
                        child: TextFormField(
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
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                             border: OutlineInputBorder(),
                              labelText:"Confirme Password:",
                            suffixIcon: IconButton(
                                icon: Icon(Icons.remove_red_eye),
                                onPressed: () {
                                  setState(() {
                                    hide2 = !hide2;
                                  });
                                },
                              ),
                          ),
                        ),
                      ),Padding(padding: EdgeInsets.all(4)),
                      GestureDetector(
                        onTap: () async {
                          if (fkey.currentState!.validate()) {
                            fkey.currentState!.save();
                            print(widget.email+user.password+valide);
                             if (user.password != valide) {
          showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("Error"),
                                                    content: Text("'Les mots de passe ne sont pas les mêmes'"),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop(false);
                                                        },
                                                        child: Text("OK"),
                                                      ),
                                                      
                                                    ],
                                                  );
                                                },
                                              );
        } else  if(code !=widget.value) {
           showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("Error"),
                                                    content: Text("Verifier Code"),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop(false);
                                                        },
                                                        child: Text("OK"),
                                                      ),
                                                      
                                                    ],
                                                  );
                                                },
                                              );
        }
                               else{
                                 Map<String, String> userData = {
                                  'email':widget.email,
                              'password': user.password,
                            };  
                               print(widget.email+user.password+valide);
                            http.Response response = await http.post(
                              Uri.parse("https://firas.alwaysdata.net/api/newpass"),
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
                      
                     
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    
  }
}
