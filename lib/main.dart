import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bookaslot2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';






Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('email');
  print(email);
  runApp(MaterialApp(home: email == null ? MyApp() : bookaslot2(username: email,)));
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}


class MyHomePage extends StatefulWidget{


  @override
  _Myhomepagestate createState() => _Myhomepagestate();
}

class _Myhomepagestate extends State<MyHomePage> with WidgetsBindingObserver{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  Future<FirebaseUser> googlesignin() async{
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: gSA.accessToken,
      idToken: gSA.idToken,
    );
    final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

    Future<bool> ret1() async {
      QuerySnapshot g = await Firestore.instance.collection('Gmailuserlist')
          .where('Email', isGreaterThan: '')
          .getDocuments();
      bool i1 = false;
      var d = g.documents;
      for (int j = 0; j < g.documents.length; j++) {
        if (user.email == d[j]['Email'].toString()) {
          i1 = true;
        }
      }
      return i1;
    }

    bool gmailcheck = await ret1();

    if(gmailcheck == true) {
      _scaffoldKey.currentState.showSnackBar(
          new SnackBar(duration: new Duration(seconds: 4), content:
          new Row(
            children: <Widget>[
              new CircularProgressIndicator(),
              new Text("  Signing-In...")
            ],
          ),
          ));
      try {
        Future<bool> ret() async {
          QuerySnapshot q = await Firestore.instance.collection('ParkingDB')
              .where('Email', isGreaterThan: '')
              .getDocuments();
          bool i1 = false;
          var d = q.documents;
          for (int j = 0; j < q.documents.length; j++) {
            if (user.email == d[j]['Email'].toString()) {
              i1 = true;
            }
          }
          return i1;
        }

        bool j = await ret();
        if (!j) {
          Firestore.instance.collection("ParkingDB").document().setData(
              {'Email': user.email});
          print('User added to the database');
        }
        if (user != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('email', user.email);
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => bookaslot2(username: user.email,)));
        }
      } catch (e) {
        print(e);
      }
      return user;
    }

    else{
      Flushbar(
        padding: EdgeInsets.all(10),
        borderRadius: 8,
        backgroundColor: Colors.blue,
        boxShadows: [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(3, 3),
            blurRadius: 3,
          ),
        ],
        duration: new Duration(seconds: 4),
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        leftBarIndicatorColor: Colors.red,
        forwardAnimationCurve: Curves.easeInOutCubic,
        title: "Sorry! Invalid Access",
        message: "Your Gmail is not authorized to login",
        flushbarPosition: FlushbarPosition.TOP,
        icon: Icon(Icons.warning, color: Colors.red,),

      ).show(context);
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String un;
  String pw;




  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("APP_STATE: $state");

    if(state == AppLifecycleState.resumed){

    }else if(state == AppLifecycleState.inactive){
      // app is inactive
    }else if(state == AppLifecycleState.paused){
      // user quit our app temporally
    }
  }


  var _u = new TextEditingController();
  var _p = new TextEditingController();

  Widget _email() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color(0xFF6CA8F1),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextFormField(
            controller: _u,
            validator: (val) =>
            val.isEmpty
                ? 'Email cannot be empty'
                : null,

            onSaved: (val) => un = val,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'Enter your Email',
              hintStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Varela',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _password() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color(0xFF6CA8F1),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextFormField(
            controller: _p,
            validator: (val) =>
            val.isEmpty
                ? 'Password cannot be empty'
                : null,
            onSaved: (val) => pw = val,
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Enter your Password',
              hintStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Varela',
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _loginbutton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () => signin(),
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'LOGIN',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }
  Widget _extratext() {
    return Column(
      children: <Widget>[
        Text(
          '- OR -',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 20.0),
        Text(
          'Sign in with',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Varela',
          ),
        ),
      ],
    );
  }
  Widget _socialicon(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }

  Widget _iconrow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _socialicon(
                () => googlesignin(),
            AssetImage(
              'assets/images/gimage.png',
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: <Widget>[
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF73AEF5),
                        Color(0xFFFFFFFF),
                        Color(0xFF478DE0),
                        Color(0xFF398AE5),
                      ],
                      stops: [0.1, 0.4, 0.7, 0.9],
                    ),
                  ),
                ),
                Container(
                  height: double.infinity,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 120.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'My Parking App',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Pacifico',
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 30.0),
                        _email(),
                        SizedBox(
                          height: 30.0,
                        ),
                        _password(),
                        _loginbutton(),
                        _extratext(),
                        _iconrow(),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),


    );
  }

  Future<void> signin() async {

    if (_formKey.currentState.validate()) {

      _formKey.currentState.save();

      try {

        await FirebaseAuth.instance.signInWithEmailAndPassword(email: un, password: pw);
        _scaffoldKey.currentState.showSnackBar(
            new SnackBar(duration: new Duration(seconds: 4), content:
            new Row(
              children: <Widget>[
                new CircularProgressIndicator(),
                new Text("  Signing-In...")
              ],
            ),
            ));
        Future<bool> ret() async{
          QuerySnapshot q = await Firestore.instance.collection('ParkingDB')
              .where('Email', isGreaterThan: '')
              .getDocuments();
          bool i1 = false;
          var d = q.documents;
          for (int j = 0; j < q.documents.length; j++) {
            if(un == d[j]['Email'].toString()){
              i1 = true;
            }
          }
          return i1;
        }

        bool j = await ret();
        if(!j){
          Firestore.instance.collection("ParkingDB").document().setData({'Email': un});
          print('User added to the database');
        }
        Navigator.push(context, MaterialPageRoute(builder: (context) => bookaslot2(username: un,)));
      } catch (e) {

        switch(e.message){
          case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
            Flushbar(
              padding: EdgeInsets.all(10),
              borderRadius: 8,
              backgroundColor: Colors.blue,
              boxShadows: [
                BoxShadow(
                  color: Colors.black45,
                  offset: Offset(3, 3),
                  blurRadius: 3,
                ),
              ],
              duration: new Duration(seconds: 4),
              dismissDirection: FlushbarDismissDirection.HORIZONTAL,
              leftBarIndicatorColor: Colors.red,
              forwardAnimationCurve: Curves.easeInOutCubic,
              title: "Oops! Please Check you Internet Connection",
              message: " ",
              flushbarPosition: FlushbarPosition.TOP,
              icon: Icon(Icons.network_check, color: Colors.red,),

            ).show(context);
            break;
          default:
            Flushbar(
              padding: EdgeInsets.all(10),
              borderRadius: 8,
              backgroundColor: Colors.blue,
              boxShadows: [
                BoxShadow(
                  color: Colors.black45,
                  offset: Offset(3, 3),
                  blurRadius: 3,
                ),
              ],
              duration: new Duration(seconds: 4),
              dismissDirection: FlushbarDismissDirection.HORIZONTAL,
              leftBarIndicatorColor: Colors.red,
              forwardAnimationCurve: Curves.easeInOutCubic,
              title: "Invalid Credentails.! Please try again",
              message: "Please check your Username/Password",
              flushbarPosition: FlushbarPosition.TOP,
              icon: Icon(Icons.warning, color: Colors.red,),

            ).show(context);
        }
        print(e.message);
      }

    }
  }

}




// ignore: must_be_immutable
/*class Page2 extends StatefulWidget{
  String username;
  Page2({Key key, this.username}) : super (key: key);
  @override
  _Page2state createState() => _Page2state();
}*/

/*class _Page2state extends State<Page2> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(backgroundColor: Color(0xFFFF9861),
        appBar: AppBar(
          backgroundColor: Color(0xFFFF9861),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            new IconButton(icon: Icon(MdiIcons.logout, color: Color(0xFFFFFFFF), size: 35.0,), onPressed: (){_signout(context);})
          ],
        ),
        body: ListView(
            children: <Widget>[
              SizedBox(height: 25.0,),
              Padding(
                padding: EdgeInsets.only(left: 40.0),
                child: Wrap(
                  children: <Widget>[Row(
                    children: <Widget>[
                      Text('Welcome\t',
                          style: TextStyle(
                              fontFamily: 'Pacifico',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 25.0
                          )),
                      Text('${widget.username}'.substring(0, 8) + '!!!!',
                          style: TextStyle(
                              fontFamily: 'Pacifico',
                              color: Colors.black,
                              fontSize: 25.0
                          ))
                    ],
                  ),
                ]),
              ),
              SizedBox(height: 40.0),
              Container(
                  padding: EdgeInsets.only(left: 20.0, right: 5.0),
                  height: MediaQuery
                      .of(context)
                      .size
                      .height - 350.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(80.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black87,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 25.0
                        )
                      ]
                  ),
                  child: Padding(
                      padding: EdgeInsets.only(
                          left: 1.0, right: 1.0, top: 16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text('DASHBOARD',
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: .6)),
                            RaisedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context, MaterialPageRoute(
                                      builder: (context) =>
                                          slotshow(
                                            username: '${widget.username}',)));
                                },
                                textColor: Colors.white,
                                splashColor: Colors.grey,
                                padding: const EdgeInsets.all(0.0),
                                child: Container(
                                  width: 250.0,
                                  height: 80.0,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        Color(0xFFFF9861),
                                        Color(0xFF42A5F5),
                                      ],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(10.0),
                                  child: const Text(
                                      'MY BOOKINGS',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20,
                                          fontFamily: 'Pacifico')
                                  ),
                                )
                            ),
                            RaisedButton(
                                onPressed: () {
                                  checkuser();
                                },
                                textColor: Colors.white,
                                splashColor: Colors.grey,
                                padding: const EdgeInsets.all(0.0),
                                child: Container(
                                  width: 250.0,
                                  height: 80.0,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        Color(0xFFFF9861),
                                        Color(0xFF42A5F5),
                                      ],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(10.0),
                                  child: const Text(
                                      'BOOK A SLOT',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20,
                                          fontFamily: 'Pacifico')
                                  ),
                                )
                            )
                          ]
                      )
                  )
              )
            ]
        )
    );
  }
  Future<void> checkuser() async {
    QuerySnapshot querySnapshot = await Firestore.instance.collection(
        'ParkingDB')
        .where('Email', isEqualTo: '${widget.username}')
        .getDocuments();
    var doc = querySnapshot.documents;
    print(doc[0].documentID);
    print(doc[0]['Slot_no']);
    if (doc[0]['Slot_no'] != null) {
      print('Inside if');
      Fluttertoast.showToast(
          msg: "You have already booked a slot cannot book again. Please cancel the slot you have booked for booking again",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) =>
          slotshow(username: doc[0]['Email'],)));
    }
    else{
      Navigator.push(
          context, MaterialPageRoute(
          builder: (context) => bookaslot(username: '${widget.username}',)));
    }
  }
   _signout(context) async {
     Alert(
       context: context,
       type: AlertType.warning,
       title: "Are you sure you want to Logout?",
       buttons: [
         DialogButton(
           child: Text(
             "NO",
             style: TextStyle(color: Colors.white, fontSize: 20),
           ),
           onPressed: () => Navigator.pop(context),
           width: 120,
         ),
         DialogButton(
           child: Text(
             "YES",
             style: TextStyle(color: Colors.white, fontSize: 20),
           ),
           onPressed: () async{
               try {
                 Navigator.of(context).popUntil((route) => route.isFirst);
                 Navigator.pushReplacement(
                     context, MaterialPageRoute(
                     builder: (context) => MyHomePage()));
                 Flushbar(
                   padding: EdgeInsets.all(10),
                   borderRadius: 8,
                   backgroundColor: Colors.blue,
                   boxShadows: [
                     BoxShadow(
                       color: Colors.black45,
                       offset: Offset(3, 3),
                       blurRadius: 3,
                     ),
                   ],
                   duration: new Duration(seconds: 4),
                   dismissDirection: FlushbarDismissDirection.HORIZONTAL,
                   forwardAnimationCurve: Curves.easeInOutCubic,
                   title: "Logged Out Successfully",
                   message: " ",
                   flushbarPosition: FlushbarPosition.TOP,
                   icon: Icon(Icons.thumb_up, color: Colors.white,),
                 ).show(context);
               }
               catch (e) {
                 print(e.message);
               }
           },
           width: 120,
         ),
       ],
     ).show();
   }
}*/








