import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_login/modal/api.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginPage(),
  ));
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

// membuat kondisi login dengan tidak login
enum LoginStatus { notSignIn, signIn }

class _LoginPageState extends State<LoginPage> {
  // setelah buat enum LoginStatus, buat kondisi default
  LoginStatus _loginStatus = LoginStatus.notSignIn;

  String username, password;
  final _key = new GlobalKey<FormState>();

  // membuat show hide password
  bool _secureText = true;
  showhide() {
    // jika kondisinya true _secureText kan berubah jadi false
    // jika kondisinya false _secureText kan berubah jadi true
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;

    // jika formnya valid dan tidak ada yg ksong maka akan di save
    if (form.validate()) {
      form.save();
      login();
      // print("$username, $password");
    }
  }

  // membuat method untuk login ke db
  login() async {
    // untuk post wajib ada body properti
    final response = await http.post(BaseUrl.login, body: {
      // sesuaikan dengan key yg sudah dibuat pada api
      "username":
          username, // key username kemudian nilai inputnya dari mana,  dari string username
      "password":
          password // key password kemudian nilai inputnya dari mana,  dari string password
    });
    // harus ada decode, karena setiap resul yg sudah di encode, wajib kita decode
    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];
    String usernameApi = data['username'];
    String namaApi = data['nama'];

    if (value == 1) {
      setState(() {
        _loginStatus = LoginStatus.signIn;
        savePref(value, usernameApi, namaApi);
      });
      Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
    } else {
      Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
    }
  }

  savePref(int value, String username, String nama) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", value);
      preferences.setString("username", username);
      preferences.setString("nama", nama);
      preferences.commit();
    });
  }

  var value;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("value");

      _loginStatus = value == 1 ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", null);
      preferences.commit();
      // ketika signoutnya berhasil login harus notsignout
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  // init state merpakan method yag pertama kali akan dipanggil saat aplikasi di buka
  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    // membuat exception switch
    switch (_loginStatus) {
      case LoginStatus
          .notSignIn: // case saat tidak sign in akan masuk ke hal login
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Login Page",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),

          // Untuk validasi bisa dilakukan dengan cara wrap Listview/textformfield wajib di warp dengan Form
          body: Form(
            key: _key,
            child: ListView(
              padding: EdgeInsets.all(20.0),
              children: <Widget>[
                TextFormField(
                  // untuk validator
                  validator: (e) {
                    if (e.isEmpty) {
                      return "Please insert username";
                    }
                  },
                  onSaved: (e) => username = e,
                  decoration: InputDecoration(
                      hintText: "Username", labelText: "Username"),
                ),
                TextFormField(
                  obscureText: _secureText,
                  onSaved: (e) => password = e,
                  decoration: InputDecoration(
                      hintText: "Password",
                      labelText: "Password",
                      suffixIcon: IconButton(
                        onPressed: showhide,
                        icon: Icon(_secureText
                            ? Icons.visibility_off
                            : Icons.visibility),
                      )),
                ),
                MaterialButton(
                  onPressed: () {
                    check();
                  },
                  child: Text("Login"),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Register()));
                  },
                  child: Text(
                    "Create a new account",
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        );
        break;
      case LoginStatus.signIn: // jika sudah login akan masuk ke main menu
        return MainMenu(signOut);
        break;
    }
  }
}

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String username, password, nama;
  final _key = new GlobalKey<FormState>();

  bool _secureText = true;
  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;

    if (form.validate()) {
      form.save();
      register();
    }
  }

  register() async {
    final response = await http.post(BaseUrl.register,
        body: {"nama": nama, "username": username, "password": password});
    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];

    if (value == 1) {
      Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Register Page",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: Form(
        key: _key,
        child: ListView(
          padding: EdgeInsets.all(20.0),
          children: <Widget>[
            TextFormField(
              validator: (e) {
                if (e.isEmpty) {
                  print("Please insert your name");
                }
              },
              onSaved: (e) => nama = e,
              decoration: InputDecoration(
                  labelText: "Nama Lengkap", hintText: "Nama Lengkap"),
            ),
            TextFormField(
              validator: (e) {
                if (e.isEmpty) {
                  print("Please insert your username");
                }
              },
              onSaved: (e) => username = e,
              decoration:
                  InputDecoration(labelText: "Username", hintText: "Username"),
            ),
            TextFormField(
              validator: (e) {
                if (e.isEmpty) {
                  print("Please insert your password");
                }
              },
              onSaved: (e) => password = e,
              obscureText: _secureText,
              decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Password",
                  suffixIcon: IconButton(
                    onPressed: showHide,
                    icon: Icon(
                        _secureText ? Icons.visibility_off : Icons.visibility),
                  )),
            ),
            MaterialButton(
              onPressed: () {
                check();
              },
              child: Text("Register"),
            )
          ],
        ),
      ),
    );
  }
}

class MainMenu extends StatefulWidget {
  final VoidCallback signOut;
  MainMenu(this.signOut);
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  signOut() {
    setState(() {
      widget.signOut();
    });
  }

  String username = "", nama = "";
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      username = preferences.getString("username");
      nama = preferences.getString("nama");
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              signOut();
            },
            icon: Icon(Icons.lock_open),
          )
        ],
      ),
      body: Center(
        child: Text(
          "Username : $username \n Nama : $nama",
          style: TextStyle(fontFamily: "JSans", fontSize: 24.0),
        ),
      ),
    );
  }
}
