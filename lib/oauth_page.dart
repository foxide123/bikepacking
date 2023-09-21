import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart';

class OAuthPage extends StatefulWidget {
  final String scope;
  final String code;
  const OAuthPage({required this.scope, required this.code, super.key});

  @override
  State<OAuthPage> createState() => _OAuthPageState();
}

class _OAuthPageState extends State<OAuthPage> {
  late String scope;
  late String code;

  @override
  void initState() {
    scope = widget.scope;
    code = widget.code;
    getTokens(scope, code);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        Text("SCOPE: ${widget.scope}"),
        Text("CODE: ${widget.code}"),
      ]),
    );
  }

  Future<void> getTokens(String scope, String code) async {
    final clientId = "114033";
    final clientSecret = "9a61e3388bef2b72246277dfd97f172a8584e485";

    final uri = Uri.https(
      "www.strava.com",
      "/oauth/token",
      {
        "client_id": clientId,
        "client_secret": clientSecret,
        "code": code,
        "grant_type": "authorization_code",
      },
    );

    Response response = await post(uri);
    if (response.statusCode == 200 || response.statusCode==202) {
      print('Status code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');
      Map<String, dynamic> responseBody = jsonDecode(response.body);

      String accessToken = responseBody['access_token'];
      String refreshToken = responseBody['refresh_token'];
    }
  }
}
