import 'package:flutter/material.dart';
import 'package:fan_page1/driver.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:splashscreen/splashscreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Scaffold(
        body: FutureBuilder(
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const SomethingWentWrong();
            } else if (snapshot.connectionState == ConnectionState.done) {
              return const Splash();
            } else {
              return Container(color: Colors.grey);
            }
          },
        ),
      ),
    );
  }
}

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 8,
      navigateAfterSeconds: AppDriver(),
      title: const Text(
        'Ajia The Asian',
        textScaleFactor: 3,
      ),
      image: Image.asset(
        'allTheThings/IMG_1734.JPG',
      ),
      loadingText: const Text('Here We Go!!', textScaleFactor: 2,),
      photoSize: 200.0,
      loaderColor: Colors.lightGreen[300],
      backgroundColor: Colors.blueGrey[400],
    );
  }
}

class SomethingWentWrong extends StatelessWidget {
  const SomethingWentWrong({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
    );
  }
}