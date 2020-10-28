import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login_page.dart';
import 'auth.dart';

class SplashScreenPage extends StatefulWidget {

  Auth auth;
  String statusText;
  SplashScreenPage({this.auth, this.statusText = "Carregando..."});

  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();

}

class _SplashScreenPageState extends State<SplashScreenPage> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
   
    return Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor: Color(0xff3B5997),
          body: SafeArea(
            top: true,
            bottom: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                    ),
                    child: SvgPicture.asset(
                      "assets/images/logo.svg",
                      height: 20.0,
                      width: 20.0,
                      //allowDrawingOutsideViewBox: true,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent
                        ),
                        width: 200,
                        height: 100,

                        child: SpinKitRing(
                          color: Colors.white,
                          size: 50.0,
                        ),
                      ),
                      Text(
                        widget.statusText,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff4381C8)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                      ),
                      RaisedButton(
                        color: Color(0xff782014),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15
                          ),
                        ),
                        onPressed: (){

                          widget.auth.cancelaLogin = true;

                          setState(() {
                            Navigator.pushReplacement(
                                context, MaterialPageRoute(builder: (context) => Login(auth:widget.auth)));
                          });
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
}
        

    
  
}
