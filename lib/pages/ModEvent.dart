import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ModEvent extends StatefulWidget {
  final String name;
  ModEvent(this.name);

  @override
  State<ModEvent> createState() => _ModServiceState();
}

class _ModServiceState extends State<ModEvent> {
  final fkey=GlobalKey<FormState>();
 late String name = ''; 
   double? price ;
  late String date;
  late String select = ''; 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modifier Event'), centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromARGB(160, 0, 54, 99),),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: fkey,
                child: FutureBuilder<Map<String, dynamic>>(
                  future: getService(),   
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator()); 
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final classe = snapshot.data as Map<String, dynamic>?;

                      if (classe == null) {
                        return Center(child: Text('Event not found'));
                      }

                      return Column(
                        children: [
                          Container(
                            height: 200, 
                            child: Card(
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16.0),
                                title: TextFormField(
                                  initialValue: classe['name'] != null ? classe['name'] : '',
                                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  onChanged: (value) {
                                    name = value;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8.0),
                                    TextFormField( 
                                      keyboardType: TextInputType.number,
                                  initialValue: classe['price'].toString() != null ? classe['price'].toString() : '',
                                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  onChanged: (value) {
                                    price = double.parse(value);
                                  },
                                 
                                ),TextFormField(
                                      initialValue: classe['date'],
                                      decoration: InputDecoration(
                                        labelText: 'Date',
                                        filled: true,
                                        prefixIcon: Icon(Icons.calendar_today),
                                        enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                                      ),
                                      onTap: () {
                                        _selectDate(classe['date']);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (fkey.currentState!.validate()) {
                                fkey.currentState!.save();
                                final response = await put(
                                  Uri.parse("http://192.168.1.11:80/api/updateEvent/${widget.name}"),
                                  body: <String, dynamic>{
                                    'name': name.isNotEmpty ? name : classe['name'], 
        'price': price != null ? price.toString() : classe['price'].toString(),
        'date': select.isNotEmpty ? select : classe['date'],
                                  },  
                                );       
                                if (response.statusCode == 200) {
                                  Navigator.pop(context);
                                }  
                              }  
                            },
                            child: Text('Valider'), 
                          ), 
                        ],  
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
    ); 
  }
  Future<Map<String, dynamic>> getService() async {
    try {
      final response = 
          await get(Uri.parse("http://192.168.1.11:80/api/getEvent/${widget.name}"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['event']; 
      } else {
        throw Exception('Failed to load event'); 
      }
    } catch (e) { 
      print('Error: $e');
      throw Exception('Failed to load event');
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