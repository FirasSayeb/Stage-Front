import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';

class AjouterNotification extends StatefulWidget {
  final String email;
  AjouterNotification(this.email);

  @override
  State<AjouterNotification> createState() => _AjouterNotificationState();
}

class _AjouterNotificationState extends State<AjouterNotification> {
  final fkey = GlobalKey<FormState>();
  late Response response2;
  List<String> selectedClasses = [];
  List<String> tokens = [];
  late String message;
  String errorMessage = '';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = getUsers();
    _firebaseMessaging.getToken().then((String? token) {
      print("Firebase Token: $token");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Envoyer Notification'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(160, 0, 54, 99),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: fkey,
          child: Column(
            children: [
              Lottie.asset('assets/aaa.json',
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width),
              Padding(padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05)),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1,
                    vertical: MediaQuery.of(context).size.height * 0.02),
                child: TextFormField(
                  onChanged: (value) {
                    message = value;
                  },
                  onSaved: (newValue) {
                    message = newValue!;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Message :",
                  ),
                ),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Failed to get classes'));
                  } else {
                    return DropdownButton(
                      value: selectedClasses.isNotEmpty ? selectedClasses.first : null,
                      hint: Text("envoyer à "),
                      items: snapshot.data!.map((e) {
                        return DropdownMenuItem(
                          child: Text(e['email'].toString()),
                          value: e['email'].toString(),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          if (!selectedClasses.contains(value))
                            selectedClasses.addAll([value.toString()]);
                        });
                      },
                    );
                  }
                },
              ),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    if (fkey.currentState!.validate()) {
                      fkey.currentState!.save();
                      for (int i = 0; i < selectedClasses.length; i++) {
                        Map<String, dynamic>? user = (await _usersFuture)
                            .firstWhereOrNull((user) => user['email'] == selectedClasses[i]);

                        if (user != null) {
                          tokens.add(user['token']);
                        }
                      }
                      print(tokens);
                      Map<String, dynamic> userData = {
                        'email': widget.email,
                        'message': message,
                        'list': selectedClasses.join(','),
                        'device_token': await _firebaseMessaging.getToken(),
                      };

                      Response response = await post(
                        Uri.parse("https://firas.alwaysdata.net/api/addNotification"),
                        body: userData,
                      );
                      print(userData);

                      if (response.statusCode == 200) {
                        print(userData);
                        for (int j = 0; j < tokens.length; j++) {
                          response2 = await post(
                            Uri.parse('https://fcm.googleapis.com/fcm/send'),
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization':
                                  'key=AAAA4WMATYA:APA91bFxzOAlkcvXkHv6pyk9-Bqb8rtUwF6TXiBiEAQLuiGUwr6X084p-GR2lSSfJM_-H6urIktOdKGYhqPjKEscHN9XoxN8AMMvxXjbq27ZzQbk-S589EH-euzjPeduKyoXgt1lXuSE',
                            },
                            body: jsonEncode({
                              "to": tokens[j],
                              "notification": {"title": "Notification", "body": message}
                            }),
                          );
                          print("-------------------------------");
                          print({
                            "to": tokens[j],
                            "notification": {"title": "Notification", "body": message}
                          });
                        }

                        if (response2.statusCode == 200) {
                          /* Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Admin(widget.email)),
                      ); */
                        }

                        /* NotificationService().showNotification(
                                  title: 'Notification',
                                  body: message
                                );*/
                        /* Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Admin(widget.email)));*/
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
                    child: const Text("Envoyer "),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await get(Uri.parse("https://firas.alwaysdata.net/api/getUsers"));
      if (response.statusCode == 200) {
        List<dynamic> classesData = jsonDecode(response.body)['list'];
        List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(classesData);
        return classes;
      } else {
        throw Exception('failed to get users');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load users');
    }
  }
}
