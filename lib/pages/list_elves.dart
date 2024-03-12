
import 'dart:convert';

import 'package:app/pages/notifier_parent.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ListEleves extends StatefulWidget {
  final String name;
  final String email;
  ListEleves(this.email,this.name);

  @override
  State<ListEleves> createState() => _ListElevesState();
}

class _ListElevesState extends State<ListEleves> {
  String val="choose";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.name}') ,
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color.fromARGB(160, 0, 54, 99),),
          body: SingleChildScrollView(
            child: Column(
              children: [
               FutureBuilder<List<Map<String, dynamic>>>(
  future: getEleves(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    } else if (snapshot.data == null || snapshot.data!.isEmpty) {
      return Center(child: Text('No Eleves'));
    } else {
      return Column(
        children: [
          Padding(padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.1)),
          Center(child: Text("Number of Eleves: ${snapshot.data!.length.toString()}")),
          DropdownButton(
  items: snapshot.data!.map<DropdownMenuItem<String>>((eleve) {
    return DropdownMenuItem<String>(
      value: eleve['name'], 
      child: Text(eleve['name']), 
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      val = value.toString();   
    }); 
    Navigator.push(context, MaterialPageRoute(builder: (context) => NotifierParent(widget.email,val),));
  }, 
  value: val != "choose" ? val : (snapshot.data!.isNotEmpty ? snapshot.data![0]['name'] : null),
)
 
        ],
      );
    }
  },
)


              ], 
            ),
          ),
    );
  }
  Future<List<Map<String,dynamic>>> getEleves()async { 
   try{ 
   final response =await get(Uri.parse("http://10.0.2.2:8000/api/getEleves/${widget.name}"));
   if(response.statusCode==200){
     List<dynamic> classesData = jsonDecode(response.body)['eleves'];
      List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(classesData);
      return classes;
   }else{ 
    throw Exception('failed to get eleves');
   } 
   }catch(e){
    print(e); 
    throw Exception('Failed to load eleves');  
   }
  }
}