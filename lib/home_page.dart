import 'package:bikepacking/features/strava/presentation/bloc/bloc/strava_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
 String token = "";
  @override
  Widget build(BuildContext context) {
    return BlocListener<StravaBloc, StravaState>(
      listener: (context, state) {
        if(state is AccessTokenRetrieved){
          setState(() {
            token = state.token;
          });
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Center(
              child: ElevatedButton(
                child: Text("AUTHENTICATE"),
                onPressed: () {
                  authenticate(context);
                },
              ),
            ),
            Text("ACCESS TOKEN: $token"),
          ],
        ),
      ),
    );
  }

  void authenticate(context) {
    BlocProvider.of<StravaBloc>(context).add(AuthenticateUser());
  }
}
