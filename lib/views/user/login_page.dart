import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dmzj/app/api.dart';
import 'package:flutter_dmzj/app/user_helper.dart';
import 'package:flutter_dmzj/app/user_info.dart';
import 'package:flutter_dmzj/models/user/user_model.dart';
import 'package:flutter_dmzj/app/utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text("登录"),
          actions: <Widget>[
            MaterialButton(
              textColor: Colors.white,
              onPressed: () => _openRegister(),
              child: Text("注册"),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _userController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.account_circle),
                    fillColor: Colors.transparent,
                    filled: true,
                    labelText: '用户名',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _passwordController,
                  onSubmitted: (text) {
                    _doLogin(_userController.text, _passwordController.text);
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    fillColor: Colors.transparent,
                    filled: true,
                    labelText: '密码',
                  ),
                ),
              ),
              !_loading
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: MaterialButton(
                        color: Theme.of(context).accentColor,
                        textColor: Colors.white,
                        minWidth: double.infinity,
                        child: Text("登录"),
                        onPressed: () => _doLogin(
                            _userController.text, _passwordController.text),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
              // Row(
              //   children: <Widget>[
              //     Expanded(
              //       child: IconButton(
              //         iconSize: 36.0,
              //         color: Colors.grey,
              //         icon: ImageIcon(
              //           AssetImage("assets/qq.png"),
              //         ),
              //         onPressed: () => Utils.showToast(
              //             msg: "暂未支持", toastLength: Toast.LENGTH_SHORT),
              //       ),
              //     ),
              //     Expanded(
              //       child: IconButton(
              //         iconSize: 36.0,
              //         color: Colors.grey,
              //         icon: ImageIcon(
              //           AssetImage("assets/weibo.png"),
              //         ),
              //         onPressed: () => Utils.showToast(
              //             msg: "暂未支持", toastLength: Toast.LENGTH_SHORT),
              //       ),
              //     ),
              //     Expanded(
              //       child: IconButton(
              //         iconSize: 36.0,
              //         color: Colors.grey,
              //         icon: ImageIcon(
              //           AssetImage("assets/weixin.png"),
              //         ),
              //         onPressed: () => Utils.showToast(
              //             msg: "暂未支持", toastLength: Toast.LENGTH_SHORT),
              //       ),
              //     )
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }

  _openRegister() async {
    const url = 'https://m.dmzj.com/register.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _doLogin(String username, String password) async {
    if (username.length == 0 || password.length == 0) {
      Utils.showToast(msg: "检查你的输入");
      return;
    }
    setState(() {
      _loading = true;
    });

    try {
      var result = await http.post(Uri.parse(Api.loginV2),
          body: {"passwd": password, "nickname": username});
      var body = result.body;
      var data = UserLgoinModel.fromJson(jsonDecode(body));
      if (data.result == 1) {
        Provider.of<AppUserInfo>(context, listen: false).changeIsLogin(true);
        Provider.of<AppUserInfo>(context, listen: false)
            .changeBindTel(data.data!.bind_phone!.length != 0);
        Provider.of<AppUserInfo>(context, listen: false)
            .changeLoginInfo(data.data);
        Provider.of<AppUserInfo>(context, listen: false)
            .getUserProfile(data.data!.uid, data.data!.dmzj_token);
        Utils.showToast(msg: "登录成功");
        UserHelper.loadComicHistory();
        Navigator.pop(context);
      } else {
        Utils.showToast(msg: data.msg!);
      }
      print(body);
    } catch (e) {
      print(e);
      Utils.showToast(msg: "登录失败,请重试");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
