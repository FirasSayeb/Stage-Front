import 'dart:convert';

import 'package:app/pages/gerer_events.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ModEvent extends StatefulWidget {
  final String name;
  final String email;
  ModEvent(this.email,this.name);

  @override
  State<ModEvent> createState() => _ModServiceState();
}

class _ModServiceState extends State<ModEvent> {
  final fkey = GlobalKey<FormState>();
  late String name = '';
  double? price;
  late String description;
  late String date;
  late String select = '';
  late Future<Map<String, dynamic>> _eventFuture;

  @override
  void initState() {
    super.initState();
    _eventFuture = getService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier Événement'),
        centerTitle: true,
        elevation: 0,
         backgroundColor: Color.fromARGB(255, 4, 166, 235),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _eventFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final classe = snapshot.data as Map<String, dynamic>?;

            if (classe == null) {
              return Center(child: Text('Événement introuvable'));
            }
            date =classe["date"]??'';
           
            return SingleChildScrollView(
              child: Column(
                children: [
                  Form(
                    key: fkey,
                    child: Column(
                      children: [
                        Container(
  height: MediaQuery.of(context).size.height*0.5,
  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  decoration: BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 2,
        blurRadius: 4,
        offset: Offset(0, 3), 
      ),
    ],
    borderRadius: BorderRadius.circular(8),
    color: Colors.white,
  ),
  child: Padding(
    padding: EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: classe['name'] ?? '',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          onChanged: (value) {
            name = value;
          },
          decoration: InputDecoration(
            labelText: 'Nom',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'champs obligatoire';
            }
            return null;
          },
        ),
        SizedBox(height: 8.0),
        TextFormField(
          initialValue:classe['price'].toString() ?? '',
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          onChanged: (value) {
            price = double.tryParse(value) ?? 0.0;
          },
          decoration: InputDecoration(
            labelText: 'Prix',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 8.0),
        TextFormField(
          initialValue: date,
          decoration: InputDecoration(
            labelText: 'Date',
            filled: true,
            prefixIcon: Icon(Icons.calendar_today),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          ),
          onTap: () {
            _selectDate(date);
          },
        ), SizedBox(height: 8.0),
        TextFormField(
          initialValue: classe['description'] ?? '',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          onChanged: (value) {
            setState(() {
              description = value;
            });
          },
          decoration: InputDecoration(
            labelText: 'description :',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'champs obligatoire';
            }
            return null;
          },
        ),
      ],
    ),
  ),
),

                        ElevatedButton(
                          onPressed: () async {
                            if (fkey.currentState!.validate()) {
                              fkey.currentState!.save();
                              final response = await put(
                                Uri.parse("https://firas.alwaysdata.net/api/updateEvent/${widget.name}"),
                                body: <String, dynamic>{
                                  'name': name,
                                  'description':description,
                                  'price': price.toString(),
                                  'date': select,
                                },
                              );
                              if (response.statusCode == 200) {
                               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GererEvents(widget.email)),
              ).then((_) => setState(() {}));
                              }
                            }
                          },
                          child: Text('Valider'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getService() async {
    try {
      final response =
          await get(Uri.parse("https://firas.alwaysdata.net/api/getEvent/${widget.name}"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['event'];
      } else {
        throw Exception('Échec du chargement de lévénement');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Échec du chargement de lévénement');
    }
  }

  Future<void> _selectDate(String initialDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      setState(() {
        select = picked.toString().split(" ")[0];
      });
    } else {
      setState(() {
        select = initialDate;
      });
    }
  }
}
