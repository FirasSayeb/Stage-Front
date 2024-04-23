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
  final fkey = GlobalKey<FormState>();
  late String name = '';
  double? price;
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
        title: Text('Modifier Event'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromARGB(160, 0, 54, 99),
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
              return Center(child: Text('Event not found'));
            }

            name = classe['name'] ?? '';
            price = double.tryParse(classe['price'].toString()) ?? 0.0;
            date = classe['date'] ?? '';

            return SingleChildScrollView(
              child: Column(
                children: [
                  Form(
                    key: fkey,
                    child: Column(
                      children: [
                        Container(
  height: MediaQuery.of(context).size.height*0.35,
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
          initialValue: name,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          onChanged: (value) {
            name = value;
          },
          decoration: InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
        ),
        SizedBox(height: 8.0),
        TextFormField(
          initialValue: price.toString(),
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          onChanged: (value) {
            price = double.tryParse(value) ?? 0.0;
          },
          decoration: InputDecoration(
            labelText: 'Price',
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
                                  'price': price.toString(),
                                  'date': select,
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
