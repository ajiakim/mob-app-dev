import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fan_page1/driver.dart';
import 'package:fan_page1/views/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fan_page1/ui/loading.dart';
import 'admin_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController, _passwordController;

  get model => null;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _loading = false;
  String _email = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    final emailInput = TextFormField(
      autocorrect: false,
      controller: _emailController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      decoration: const InputDecoration(
          labelText: "EMAIL ADDRESS",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          hintText: 'Enter Email'),
    );
    final passwordInput = TextFormField(
      autocorrect: false,
      controller: _passwordController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter Password';
        }
        return null;
      },
      obscureText: true,
      decoration: const InputDecoration(
        labelText: "PASSWORD",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        hintText: 'Enter Password',
        suffixIcon: Padding(
          padding: EdgeInsets.all(15), // add padding to adjust icon
          child: Icon(Icons.lock),
        ),
      ),
    );
    final submitButton = OutlinedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Processing Data')));
          _email = _emailController.text;
          _password = _passwordController.text;

          // _emailController.clear();
          // _passwordController.clear();

          setState(() {
            _loading = true;
            login();
          });
        }
      },
      child: const Text('Submit'),
      style: TextButton.styleFrom(primary: Colors.lightGreen[300]),
    );

    final registerButton = OutlinedButton(
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (con) => const RegisterPage()));
      },
      child: const Text('Register'),
      style: TextButton.styleFrom(primary: Colors.lightGreen[300]),
    );

    final google = IconButton(
      icon: Image.asset('allTheThings/Gmail-logo.png'),
      iconSize: 60,
      onPressed: (){
        googleSignIn();
      },
    );

    return Scaffold(
      backgroundColor: Colors.blueGrey[400],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _auth.currentUser != null
                ? Text(_auth.currentUser!.uid)
                : _loading
                ? const Loading()
                : Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  // Add TextFormFields and ElevatedButton here.
                  emailInput,
                  passwordInput,
                  submitButton,
                  registerButton,
                  google
                ],
              ),
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> login() async {
    await Firebase.initializeApp();
    try {
      UserCredential _ = await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      roleCheck();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (con) => AppDriver()));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user found for that email.')));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Wrong password provided for that user.')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Something Else")));
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      _loading = false;
    });
  }

  void roleCheck() async{
    FirebaseFirestore.instance.collection('user').doc(_auth.currentUser!.uid).get().then((value){
      if(value.data()!['role'] == 'ADMIN'){
        Navigator.pushReplacement(context,MaterialPageRoute(builder:  (con) => Admin()));
      }else{
        Navigator.pushReplacement(context,MaterialPageRoute(builder:  (con) => AppDriver()));
      }
    });
  }

  void signOut() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    if(_auth.currentUser != null) {
      await _auth.signOut();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Logged out")));
    }else{
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No user logged in")));
    }
    setState(() {

    });
  }

  void  googleSignIn() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    Navigator.pushReplacement(context,MaterialPageRoute(builder:  (con) => AppDriver()));
  }

}