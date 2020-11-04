import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iosys/root_page.dart';
import 'login_page.dart';
import 'auth.dart';

class OfflinePage extends StatefulWidget {

  String errorMsg;
  OfflinePage({this.errorMsg = ""});

  @override
  _OfflinePageState createState() => _OfflinePageState();
}

class _OfflinePageState extends State<OfflinePage> {

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
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: SvgPicture.asset(
                      "assets/images/not_connected.svg",
                      height: 10.0,
                      width: 10.0,
                      //allowDrawingOutsideViewBox: true,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    children: <Widget>[
                      Text(
                        widget.errorMsg,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(color: Color(0xffD75A4A)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5.0),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RaisedButton(
                            color: Color(0xff31457A),
                            child: Text(
                              "Repetir",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RootPage(),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.all(5.0),
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

                              setState(() {
                                Navigator.pushReplacement(
                                    context, MaterialPageRoute(builder: (context) => Login(auth: Auth())));
                              });
                            },
                          )
                        ],
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
