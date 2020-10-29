import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth {

  Auth({this.endereco = "", this.usuario = "", this.senha = "", this.token = ""});

  String endereco;
  String token;
  String usuario;
  String senha;
  String msgResult = "";
  String codErro = "";
  bool isConnected = false;
  bool loginIsValid = false;
  bool cancelaLogin = false;

  Future _checkConnect() async {

    print('<<< usuario='+this.usuario+' senha='+this.senha+' token='+this.token);

    try {
      final response = await http.get(this.endereco).timeout(
          const Duration(seconds: 10));
      if (response.statusCode == 200) {
        isConnected = true;
      }
    }
    on TimeoutException catch (_) {
      this.msgResult = "Sem conexão: Tempo máximo excedido.";
    }
    on SocketException catch (_) {
      this.msgResult = "Sem conexão: SocketException.";
    }
    catch (e) {
      this.msgResult = 'Erro: ' + e.toString();
    }

  }

  Future _checaStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.token = this.token != "" ? this.token : (prefs.getString('token') ?? "");
    this.endereco = this.endereco != "" ? this.endereco : (prefs.getString('endereco') ?? "");
    this.usuario = this.usuario != "" ? this.usuario : (prefs.getString('usuario') ?? "");
  }

  Future _gravaStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', this.token);
    await prefs.setString('endereco', this.endereco);
    await prefs.setString('usuario', this.usuario);
  }

  Future limpaToken() async {
    this.token = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', '');
    print('<<< LIMPA TOKEN >>> usuario='+this.usuario+' senha='+this.senha+' token='+this.token);
  }

  Future checaToken() async{

    Map _mapResponse;
    await _checaStorage();
    print('<<< 1. CANCELA LOGIN = '+this.cancelaLogin.toString());

    if(!this.cancelaLogin) await _gravaStorage();
    else limpaToken();

    var _url = this.endereco+'/_r2_app/auth/executa_login/&app=on&token='+this.token;

    Map _params = {
      "usuario" : this.usuario,
      "senha" : this.senha,
      "token" : this.token
    };

    print('>>>>>>>>>> usuario='+this.usuario+' senha='+this.senha+' token='+this.token);

    Map<String, String> _headers = {
      'Charset': 'utf-8'
    };

    await _checkConnect();
    if(this.isConnected == true) {
      try {
        var response = await http.post(_url, headers: _headers, body: _params);
        if (response.statusCode == 200) {

          _mapResponse = jsonDecode(response.body);

          this.loginIsValid = _mapResponse["success"] ?? false;
          this.token = _mapResponse["token"] ?? "";
          this.msgResult = _mapResponse["msg"];
          this.codErro = _mapResponse["cod"];

          print('<<< 2. CANCELA LOGIN = '+this.cancelaLogin.toString());

          if(!this.cancelaLogin) await _gravaStorage();
          else limpaToken();

        }
        else {
          this.msgResult = "Falha no request. StatusCode=" +
              (response.statusCode).toString() + ".";
        }
      }
      catch (e) {
        this.msgResult = 'Erro: '+e.toString()+'. Procure o administrador.';
      }
    }
    else {
      this.msgResult = "Não foi possível conectar, verifique se o endereço está disponível.";
    }
  }

}