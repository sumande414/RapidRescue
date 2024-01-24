import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rapid_rescue/firebase_options.dart';
import 'package:rapid_rescue/screens/post_login_screen.dart';
import 'package:rapid_rescue/screens/signup.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent));
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(navigationBarTheme: NavigationBarThemeData(
        iconTheme: MaterialStateProperty.all(IconThemeData(color: Colors.white)),
                labelTextStyle:
                    MaterialStateProperty.all(TextStyle(color: Colors.white))),
        useMaterial3: true
      ),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.userChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return PostLoginScreen();
            }
            else{
              return SignupScreen();
            }
          }
        )
    );
  }
}
