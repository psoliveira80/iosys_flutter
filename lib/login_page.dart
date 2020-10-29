import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/svg.dart';
import 'webview_page.dart';
import 'auth.dart';

class Login extends StatefulWidget {

  Auth auth;
  Login({this.auth});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  bool _isBtnLoginPressed = false;
  String barcode;
  String msgResult = "";

  final _ctrlEndereco = TextEditingController();
  final _ctrlUsuario = TextEditingController();
  final _ctrlSenha = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState()  {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }


  @override
  Widget build(BuildContext context) {

    Future _getDadosStorage() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      this._ctrlEndereco.text = this._ctrlEndereco.text != "" ? this._ctrlEndereco.text : await prefs.getString('endereco');
      this._ctrlUsuario.text = this._ctrlUsuario.text != "" ? this._ctrlUsuario.text : await prefs.getString('usuario');
    }

    setState(() {
      _getDadosStorage();
    });

    return Scaffold(
      body: _body(context)
    );
  }

  _body(BuildContext context){
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: true,
        bottom: true,
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(40),
              child: Container(
                color: Colors.white,
                //padding: EdgeInsets.all(40),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                        height: 60,
                        child: Container(
                          constraints: BoxConstraints.expand(),
                          color: Color(0xff3B5997),
                          child: Center(
                            child: Container(
                              height: 50,
                              //width: 50,
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
                        )
                    ),
                    SizedBox(height: 40),
                    _textFormField(
                        "Endereço",
                        controller: _ctrlEndereco,
                        validator: _validaEndereco,
                        icon: Icons.link
                    ),
                    SizedBox(height: 20),
                    _textFormField(
                        "Usuário",
                        controller: _ctrlUsuario,
                        validator: _validaUsuario,
                        icon: Icons.people_alt
                    ),
                    SizedBox(height: 20),
                    _textFormField(
                        "Senha",
                        senha: true,
                        controller: _ctrlSenha,
                        validator: _validaSenha,
                        icon: Icons.vpn_key
                    ),
                    SizedBox(height: 30),
                    _loginButton(
                        (_isBtnLoginPressed ? "Cancelar" : "Entrar"),
                        _isBtnLoginPressed ? Color(0xff782014) : Color(0xff3B5997),
                      context
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                    ),
                    Text(
                      msgResult,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Color(0xffff0000),
                          fontSize: 15
                      ),
                      maxLines: 2,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _textFormField(
      String hint,
      {
        bool senha = false,
        TextEditingController controller,
        FormFieldValidator<String> validator,
        Object icon
      }
      ) {
    return _isBtnLoginPressed ?
    new FocusScope(
      node: new FocusScopeNode(),
      child: new TextFormField(
        enabled: false,
        obscureText: senha,
        controller: controller,
        decoration: new InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            labelStyle: TextStyle(decorationColor: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            fillColor: Colors.grey[100],
            filled: true
        ),
      ),
    )
    : TextFormField(
      controller: controller,
      validator: validator,
      obscureText: senha,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 15),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          suffixIcon: IconButton(
            onPressed: () => controller.clear(),
            icon: Icon(Icons.clear),
            iconSize: 18,
          ),
          prefixIcon: Icon(
            icon,
          ),
      ),
    );
  }

  Future<void> _clickButtonLogin(BuildContext context) async {

    bool formOk = _formKey.currentState.validate();

    String endereco = _ctrlEndereco.text;
    String usuario = _ctrlUsuario.text;
    String senha = _ctrlSenha.text;

    if(!formOk){
      return;
    }

    setState(() {
      _isBtnLoginPressed = true;
    });

    //Auth auth = Auth(endereco:endereco, usuario: usuario, senha: senha);
    widget.auth.endereco = endereco;
    widget.auth.usuario = usuario;
    widget.auth.senha = senha;

    widget.auth.cancelaLogin = false;

    await widget.auth.checaToken();

    if(widget.auth.loginIsValid) {

      _navegaWebView(context, widget.auth);

    }
    else {

      setState(() {
        _isBtnLoginPressed = false;
        msgResult = widget.auth.msgResult;
      });


    }
  }

  _clickButtonCancel() {

    setState(() {
      _isBtnLoginPressed = false;
      widget.auth.cancelaLogin = true;
    });
    
    return;

  }

  _navegaWebView(BuildContext context, Auth auth){
    if(_isBtnLoginPressed) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewPage(auth: auth)
          )
      );
    }
  }

  _loginButton(
      String texto,
      Color cor,
      BuildContext context
      ){
    return RaisedButton(
      color: cor,
      child: Text(
        texto,
        style: TextStyle(
            color: Colors.white,
            fontSize: 15
        ),
      ),
      onPressed: (){
        setState(() {
          msgResult = "";
        });
        _isBtnLoginPressed ? _clickButtonCancel() : _clickButtonLogin(context);
      },
    );
  }

  String _validaEndereco(String endereco){
    if(endereco.isEmpty){
      return "Informe o endereço";
    }
    else {

      if(!endereco.contains('http')) {
        endereco = 'http://'+endereco;
        setState(() {
          this._ctrlEndereco.text = endereco;
        });
      }

      String pattern = r"^(http|https):\/\/(([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])\.)*([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])(:[0-9]+)?(\/[a-zA-Z0-9\_\-\s\.\/\?\%\#\&\=]*)?$";
      RegExp url = new RegExp(pattern);

      if(!url.hasMatch(endereco)) {
        return "Endereço inválido";
      }
      else return null;
    }

  }

  String _validaUsuario(String usuario){
    if(usuario.isEmpty){
      return "Informe o usuário";
    }
    else return null;
  }

  String _validaSenha(String senha){
    if(senha.isEmpty){
      return "Informe a senha";
    }
    else return null;
  }

}
