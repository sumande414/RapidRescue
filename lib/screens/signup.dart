import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../functions/database_functions.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../widgets/form_container_widget.dart';
import '../functions/firebase_auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _rtpPassword = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  Position? _currentPosition;

  bool isHospital = false;
  bool login = false;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _rtpPassword.dispose();
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PRIMARY_BACKGROUND_COLOR,
      body: Center(
          child: SizedBox(
        width: 300,
        height: 600,
        child: Card(
            color: PRIMARY_CARD_BACKGROUND_COLOR,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "Rapid Rescue",
                      style: CARD_HEAD,
                    ),
                    const SizedBox(height: 25),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          login
                              ? Container()
                              : FormContainerWidget(
                                  hintText:
                                      (isHospital) ? "Hospital Name" : "Name",
                                  controller: _name,
                                  hintTextStyle: CARD_FORM_BODY,
                                ),
                          const SizedBox(height: 15),
                          login
                              ? Container()
                              : FormContainerWidget(
                                  hintText: "Phone Number",
                                  controller: _phone,
                                  hintTextStyle: CARD_FORM_BODY,
                                ),
                          const SizedBox(height: 15),
                          FormContainerWidget(
                            hintText: "Email",
                            controller: _email,
                            hintTextStyle: CARD_FORM_BODY,
                          ),
                          const SizedBox(height: 15),
                          FormContainerWidget(
                            hintText: "Password",
                            hintTextStyle: CARD_FORM_BODY,
                            controller: _password,
                            isPasswordField: true,
                          ),
                          const SizedBox(height: 15),
                          login
                              ? Container()
                              : FormContainerWidget(
                                  hintText: "Retype Password",
                                  hintTextStyle: CARD_FORM_BODY,
                                  controller: _rtpPassword,
                                  isPasswordField: true,
                                ),
                                const SizedBox(height: 10,),
                          !login && isHospital
                              ? Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _getCurrentPosition();
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 200,
                                        decoration: BoxDecoration(
                                            color: PRIMARY_BACKGROUND_COLOR,
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: Center(
                                            child: Text(
                                          "Fetch Location",
                                          style: CARD_BUTTON,
                                        )),
                                      ),
                                    ),
                                    const Spacer(),
                                    (_currentPosition != null)
                                        ? const Icon(Icons.check,color: Colors.green,)
                                        : const Icon(Icons.close, color: Colors.red)
                                  ],
                                )
                              : Container(),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                if (login) {
                                  signin(
                                      email: _email.text,
                                      password: _password.text);
                                } else {
                                  signup(
                                      email: _email.text,
                                      password: _password.text);
                                  if (isHospital) {
                                    addHospital(
                                        email: _email.text,
                                        name: _name.text,
                                        phone: _phone.text,
                                        hospitalCoordinates: _currentPosition!);
                                        addAll(email: _email.text, type: "hospital");
                                  } else {
                                    addUser(
                                        email: _email.text,
                                        name: _name.text,
                                        phone: _phone.text);
                                    addAll(email: _email.text, type: "user");
                                  }
                                }
                              }
                            },
                            child: Container(
                              height: 40,
                              width: 350,
                              decoration: BoxDecoration(
                                  color: PRIMARY_BACKGROUND_COLOR,
                                  borderRadius: BorderRadius.circular(30)),
                              child: Center(
                                  child: Text(
                                login ? "Sign In" : "Sign Up",
                                style: CARD_BUTTON,
                              )),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  login ? "Not Signed up?" : "Already Signed up?",
                                  style: CARD_BODY),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      login = !login;
                                    });
                                  },
                                  child: Text(login ? "Sign Up" : "Sign In",
                                      style: const TextStyle(color: Colors.blue)))
                            ],
                          ),
                          login? Container():Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  !isHospital
                                      ? "Registering your hospital?"
                                      : "Registering Yourself?",
                                  style: CARD_BODY),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isHospital = !isHospital;
                                    });
                                  },
                                  child: const Text("Click Here",
                                      style: TextStyle(color: Colors.blue)))
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      )),
    );
  }
}
