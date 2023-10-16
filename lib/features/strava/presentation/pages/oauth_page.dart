import 'dart:convert';

import 'package:bikepacking/core/security/local_storage_keys.dart';
import 'package:bikepacking/features/strava/presentation/bloc/bloc/strava_bloc.dart';
import 'package:bikepacking/features/strava/presentation/widgets/top_bar_back_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
    super.initState();
    getTokens(widget.scope, widget.code);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      popScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBarBackAction(),
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

  void popScreen() async {
    await Future.delayed(Duration(seconds: 3));
    if (mounted) {
      GoRouter.of(context).go("/");
    }
  }
}
