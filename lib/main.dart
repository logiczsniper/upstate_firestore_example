import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:upstate/upstate.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthModel extends StateElement {
  FirebaseAuth _dataModel;
  FirebaseUser _user;

  AuthModel(FirebaseAuth model, StateElement parent) : super(parent) {
    _dataModel = model;
  }

  bool get isSignedIn => _user != null;
  String get userStatus {
    if (_user == null) {
      return "No user signed in.";
    } else {
      return "Welcome user: ${_user.uid}";
    }
  }

  void signIn() async {
    await _dataModel.signInAnonymously();
    _setUser();
    notifyChange();
  }

  void signOut() async {
    await _dataModel.signOut();
    _setUser();
    notifyChange();
  }

  Future<void> _setUser() async {
    _user = await _dataModel.currentUser();
  }
}

StateElement converter(obj, parent) {
  if (obj is FirebaseAuth) {
    return AuthModel(obj, parent);
  } else {
    return null;
  }
}

void main() {
  runApp(
    StateWidget(
      state: StateObject(
        {
          'auth': _auth,
        },
        converter: converter,
      ),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Upstate & Firestore Demo',
      home: MyHomePage(title: 'Upstate & Firestore Demo Home Page'),
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'User status:',
            ),
            StateBuilder(
              paths: [
                StatePath(['auth'])
              ],
              builder: (context, state) => Text(
                "${state['auth'].userStatus}",
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 100,
        child: StateBuilder(
          paths: [
            StatePath(['auth'])
          ],
          builder: (context, state) => FloatingActionButton(
            onPressed: state['auth'].isSignedIn ? state['auth'].signOut : state['auth'].signIn,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            child: Text("Sign " + (state['auth'].isSignedIn ? "out" : "in")),
          ),
        ),
      ),
    );
  }
}
