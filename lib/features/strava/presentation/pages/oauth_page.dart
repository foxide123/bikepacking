import 'dart:convert';

import 'package:bikepacking/core/local_storage_keys.dart';
import 'package:bikepacking/features/strava/presentation/bloc/bloc/strava_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart';

class OAuthPage extends StatefulWidget {
  final String? scope;
  final String? code;
  const OAuthPage({this.scope, this.code, super.key});

  @override
  State<OAuthPage> createState() => _OAuthPageState();
}

class _OAuthPageState extends State<OAuthPage> {
  late SharedPreferences prefs;

  @override
  void initState() {
    getTokens(widget.scope, widget.code);
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

  void getTokens(scope, code) {
    BlocProvider.of<StravaBloc>(context)
        .add(ExchangeCodeForTokens(scope: scope, code: code));
  }
}
