import 'package:app/pages/gerer_events.dart';
import 'package:app/pages/gerer_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';

class AjouterEvent extends StatefulWidget {
  final String email;
  AjouterEvent(this.email);

  @override
  State<AjouterEvent> createState() => _AjouterServiceState();
}

class _AjouterServiceState extends State<AjouterEvent> {
  late String date='';
   late String name;
   late double price;
  final fkey = GlobalKey<FormState>(); 
  String errorMessage = '';
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
          title: Text('Ajouter Event') ,
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color.fromARGB(160, 0, 54, 99),
        ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                const Padding(padding: EdgeInsets.all(10)),
                Container(
                  alignment: FractionalOffset.center,
                  height: MediaQuery.of(context).size.height*0.3,
                  child: Lottie.asset("assets/event.json"),
                ),
                const Padding(padding: EdgeInsets.all(5)),
                Container(
                  alignment: Alignment.topCenter,
                  child: const Text(
                    "Ajouter Event ",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(5)),
                Center(
                  child: Form( 
                    key: fkey,
                    child: Column(
                      children: [
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
                            name = newValue!;
                          },
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Name:", 
                            icon: Icon(Icons.text_fields_sharp),
                          ),  
                        ),
                      TextFormField(
  onSaved: (newValue) {
    
    if (newValue != null && newValue.isNotEmpty) {
      price = double.parse(newValue);
    }
  },
  keyboardType: TextInputType.number, 
  decoration: InputDecoration(
    hintText: "Price:",
    icon: Icon(Icons.price_change),
  ),
),

                     
                           Padding(padding: EdgeInsets.all(5)),  TextFormField(
                                controller: TextEditingController(text: date),
                                onSaved: (newValue) {
                                  date = newValue!;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Date',
                                  filled: true, 
                                  prefixIcon: Icon(Icons.calendar_today),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue)),
                                ),
                                onTap: () {
                                  _selectDate();
                                },
                              ),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              if (fkey.currentState!.validate()) {
                                fkey.currentState!.save();
                               

                                Map<String, dynamic> userData = { 
                                 'name':name,
                                 'price':price.toString(),
                                 'date':date 
                                };
                                
                                Response response = await post(
                                  Uri.parse("https://firas.alwaysdata.net/api/addEvent"),
                                  body: userData,   
                                );
                                  
                                if (response.statusCode == 200) {  
                                 
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => GererEvents(widget.email)));
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
                              child: const Text("Ajouter "),
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
   Future<void> _selectDate() async {
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2050),
  );
  if (picked != null) {
    setState(() {
      date = picked.toString().split(" ")[0];
      print('Selected Date: $date');
    });
  }
}
}