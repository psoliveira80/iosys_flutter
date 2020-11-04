import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iosys/offline_page.dart';
import 'login_page.dart';
import 'webview_page.dart';
import 'splash_screen.dart';
import 'auth.dart';

class RootPage extends StatefulWidget {

  String statusText = "Carregando...";

  @override
  _RootPageState createState() => _RootPageState();
}


class _RootPageState extends State<RootPage> {

  Auth auth = Auth();

  @override
  Widget build(BuildContext context) {
    return SplashScreenPage(auth: auth, statusText: widget.statusText);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    //new Future.delayed(const Duration(seconds: 3),() => _checaLogin());
    _checaLogin();
  }

  Future<Map> _checaLogin() async{

    widget.statusText = "Checando credenciais...";
    await auth.checaToken();

    if(auth.isConnected || auth.endereco == "") {

      if (auth.loginIsValid && !auth.cancelaLogin) {
        setState(() {widget.statusText = "Credenciais válidas! Abrindo...";});
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => WebViewPage(auth:auth)));
      }
      else {
        setState(() {widget.statusText = "Credenciais inválidas, abrindo login...";});
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Login(auth:auth)));
      }

    }
    else {
      setState(() {widget.statusText = "Conexão indisponível...";});
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => OfflinePage(errorMsg: auth.msgResult)));
    }

  }


}
