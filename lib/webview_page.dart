import 'dart:async';
import 'dart:convert';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'login_page.dart';
import 'firebase_notification.dart';
import 'auth.dart';

class WebViewPage extends StatefulWidget {

  Auth auth;
  WebViewPage({this.auth});

  @override
  _WebViewPageState createState() => _WebViewPageState();

}

class _WebViewPageState extends State<WebViewPage> {

  final flutterWebViewPlugin = new FlutterWebviewPlugin();
  StreamSubscription<WebViewStateChanged> _onchanged;
  String barcode;
  final assetsAudioPlayer = AssetsAudioPlayer();
  FirebaseNotifications notifications = FirebaseNotifications();

  @override
  void initState() {
    super.initState();
    notifications.iniciarFirebaseListeners();

    _onchanged = flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if(mounted) {
        if(state.type== WebViewState.finishLoad){
          print("loaded...>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        }
        else if (state.type== WebViewState.abortLoad){ // if there is a problem with loading the url
          print("there is a problem...");
        }
        else if(state.type== WebViewState.startLoad){ // if the url started loading
          print("start loading...");
        }
      }
    });

  }

  @override
  Widget build(BuildContext context) {

    String url = widget.auth.endereco+'/_r2_app/api_fwk/app_login/&app=on&flg_mobile=true&token='+widget.auth.token;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Container(
          margin: const EdgeInsets.only(top: 0.0),
          child: SafeArea(
            top: true,
            bottom: true,
            child: WebviewScaffold(
              url: url,
              withZoom: true,
              withLocalStorage: true,
              hidden: true,
              //initialChild: SplashScreenPage(),
              javascriptChannels: [
                JavascriptChannel(
                  name: 'appIosys',
                  onMessageReceived: (JavascriptMessage message) {

                    final flutterWebviewPlugin = new FlutterWebviewPlugin();
                    Map mapResult = jsonDecode(message.message) ?? [];

                    switch(mapResult["MOD_FUNC"]) {
                      case "startScan": {

                        scan((){
                          flutterWebviewPlugin.evalJavascript("(function(){var func = function(code){eval(\$('#"+mapResult["idElement"]+"').attr('app-func-callback'))};func.call(null,'"+this.barcode+"');})()");
                        });

                      }
                      break;

                      case "exitApp": {
                        widget.auth.limpaToken();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            //builder: (context) => RootPage(),
                            builder: (context) => Login(auth:widget.auth),
                          ),
                        );
                      }
                      break;

                      default: {
                        //statements;
                      }
                      break;
                    }

                  }
                ),
              ].toSet(),
            ),
          ),
        )
    );

  }

  Future scan(Function fn) async {

    try {
      var scanResult = await BarcodeScanner.scan();
      setState(() {
        this.barcode = scanResult.rawContent;
        assetsAudioPlayer.open(Audio("assets/sound/beep.mp3"));
        fn();
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          this.barcode = 'Talvez você não possua permissão para acessar a câmera!';
        });
      } else {
        setState(() => this.barcode = 'Erro desconhecido: $e');
      }
    } on FormatException{
      setState(() => this.barcode = 'Não foi possível realizar a leitura corretamente! Tente novamente.');
    } catch (e) {
      setState(() => this.barcode = 'Erro desconhecido: $e');
    }
  }

}
