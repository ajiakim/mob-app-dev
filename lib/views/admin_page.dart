import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fan_page1/driver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _db = FirebaseFirestore.instance;

class Admin extends StatefulWidget {
  const Admin({Key? key}) : super(key: key);

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<Admin> {
  List<String> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.lightGreen[300],
            centerTitle: true,
            title: const Text("Ajia's Mochis"),
            titleTextStyle: const TextStyle(color: Colors.black54, fontSize: 40),
        ),
        backgroundColor: Colors.blueGrey[400],
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('messages').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView(
              children: snapshot.data!.docs.map((document) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  height: 60,
                  color: Colors.purple[100],
                  child: Center(child: Text(document['message'])),
                );
              }).toList(),
            );
          },
        ),
        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                  onPressed: () {
                    add(context);
                  },
                  child: const Icon(Icons.add),
                  backgroundColor: Colors.lightGreen[300],
                  foregroundColor: Colors.grey[700]
              ),
              const SizedBox(
                width: 30,
              ),
              FloatingActionButton(
                  onPressed: () {
                    signOut(context);
                  },
                  tooltip: 'Log out',
                  child: const Icon(Icons.logout),
                  backgroundColor: Colors.lightGreen[300],
                  foregroundColor: Colors.grey[700],
                ),
            ],
        )
    );
  }

  void signOut(BuildContext context) async {
    return showDialog(context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.blueGrey,
            title: const Text("Log Out"),
            content: const Text("How Sure Are You About This?", textAlign: TextAlign.center,),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  await _auth.signOut();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                      const SnackBar(content: Text('User logged out.')));
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (con) => AppDriver()));
                  ScaffoldMessenger.of(context).clearSnackBars();
                },
                child: const Text("eh.."),
                style: TextButton.styleFrom(
                  primary: Colors.lightGreen[300],
                ),
              ),
            ],
          );
        });
  }

  final TextEditingController _textFieldController = TextEditingController();

  void add(BuildContext context) async{
    return showDialog(context: context,
        builder: (context){
          return AlertDialog(
            backgroundColor: Colors.blueGrey,
            content: TextField(
              controller: _textFieldController,
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(hintText: "Enter message"),
            ),
            actions: <Widget>[
              OutlinedButton(
                  onPressed: (){
                    setState(() {
                      databased();
                      Navigator.pop(context);
                    });
                  },
                  child: const Text('Updates'),
                  style: TextButton.styleFrom(
                    primary: Colors.lightGreen[300],))
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
