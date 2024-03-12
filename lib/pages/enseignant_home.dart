

import 'package:app/pages/gerer_exercices.dart';
import 'package:app/pages/list_elves.dart';
import 'package:flutter/material.dart';

class ENSHome extends StatefulWidget {
  final String email;
  final String name;
  ENSHome(this.email,this.name);

  @override
  State<ENSHome> createState() => _ENSHomeState();
}

class _ENSHomeState extends State<ENSHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('${widget.name}',),centerTitle: true,
          elevation: 0, 
          backgroundColor: const Color.fromARGB(160, 0, 54, 99),),
          body: GridView(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),children: [
            Card(child: GestureDetector(onTap: () {
               Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListEleves(widget.email,widget.name),
                    ),
                  );
            },
              child: Container(
              color: const Color.fromARGB(255, 118, 178, 208),
              alignment: Alignment.center,  
               child: Text('Eleves'),
            )),), Card(child: GestureDetector(
              onTap: () {
                Navigator.push( 
                    context,
                    MaterialPageRoute(
                      builder: (context) => GererExercices(widget.email,widget.name),
                    ),
                  );
              },
              child: Container(
               alignment: Alignment.center,
               color: const Color.fromARGB(255, 219, 92, 53), 
               child: Text('Exercices'),
            )),)
          ],),
    );
  }
}