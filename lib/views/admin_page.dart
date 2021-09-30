import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fan_page1/driver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _db = FirebaseFirestore.instance;

class Admin extends StatefulWidget {
  Admin({Key? key}) : super(key: key);

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<Admin> {
  List<String> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Ajia's Mochis"),
            actions: <Widget>[
              FloatingActionButton(
                  onPressed: (){
                    add(context);
                  },
                  child: const Icon(Icons.add)
              )
            ]
        ),


        backgroundColor: Colors.blueGrey[400],
        body: Container( child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: messages.length,
            itemBuilder: (BuildContext context, int index){
              return Container (
                height: 50,
                color: Colors.lightGreen[300],
                child: Center(child: Text('${messages[index]}')),
              );
            }

        ),),
        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {
                  signOut(context);
                },
                tooltip: 'Log out',
                child: const Icon(Icons.logout),
                backgroundColor: Colors.lightGreen[300],
                foregroundColor: Colors.grey[700],
              ),
            ]
        )
    );
  }

  void signOut(BuildContext context) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    await _auth.signOut();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('User logged out.')));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (con) => AppDriver()));
  }

  final TextEditingController _textFieldController = TextEditingController();

  void add(BuildContext context) async{
    return showDialog(context: context,
        builder: (context){
          return AlertDialog(
            content: TextField(
              controller: _textFieldController,
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(hintText: "Enter message"),
            ),
            actions: <Widget>[
              OutlinedButton(
                  onPressed: (){
                    setState(() {
                      databased();
                      Navigator.pop(context);
                    });
                  },
                  child: Text('Updates'))
            ],
          );
        });
  }

  Future<void> databased() async {
    _db
        .collection("messages")
        .doc()
        .set({
      "message": _textFieldController.text,
      "registration_deadline" : DateTime.now(),

    });
    setState(() {
      read();
    });
  }
  void read() async {
    FirebaseFirestore.instance.collection('messages')
        .get()
        .then((value) {
      if (value.size > 0 ) {
        value.docs.forEach((element) {
          messages.add(element["message"]);
        });
      }
    });
    setState(() {
    });
  }
}
