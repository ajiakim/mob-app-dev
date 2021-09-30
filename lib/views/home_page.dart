import 'package:fan_page1/driver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _db = FirebaseFirestore.instance;

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase',
      home: AddPost(),
    );
  }
}

class AddPost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen[300],
        centerTitle: true,
        title: const Text("Ajia's Mochis"),
        titleTextStyle: TextStyle(color: Colors.black54,fontSize: 40,),
      ),
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
      backgroundColor: Colors.blueGrey[400],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _signOut(context);
        },
        tooltip: 'Log Out',
        child: const Icon(Icons.logout),
        backgroundColor: Colors.lightGreen[300],
        foregroundColor: Colors.grey[700],
      ),
    );
  }
}

  void _signOut(BuildContext context) async {
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