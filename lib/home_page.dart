import 'package:bikepacking/features/strava/domain/enities/athlete.dart';
import 'package:bikepacking/features/strava/domain/enities/route.dart';
import 'package:bikepacking/features/strava/presentation/bloc/bloc/strava_bloc.dart';
import 'package:bikepacking/features/strava/presentation/widgets/top_bar_back_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String token = "";
  int athleteId = 0;
  late Athlete athlete;
  List<dynamic> routes = [];

  @override
  void initState() {
    final state = context.read<StravaBloc>().state;
    if (state is AccessTokenRetrieved) {
      token = state.token;
      getProfile();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StravaBloc, StravaState>(
      listener: (context, state) {
        if (state is AccessTokenRetrieved) {
          getProfile();
          print("STATE.TOKEN ${state.token}");
          setState(() {
            token = state.token;
          });
        }
        if (state is ProfileRetrieved) {
          getRoutes(state.athlete.id!);
          print("ID in home_page ${state.athlete.id}");
          setState(() {
            athleteId = state.athlete.id!;
            athlete = state.athlete;
          });
        }
        if (state is RoutesRetrieved) {
          setState(() {
            routes = state.routes;
          });
        }
      },
      child: Scaffold(
        appBar: TopBarBackAction(),
        body: athleteId == 0
            ? Column(
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
                  Center(
                    child: ElevatedButton(
                      child: Text("maplibre"),
                      onPressed: (){
                        GoRouter.of(context).push("/maplibreMap");
                      }
                    ),),
                  Center(
                    child: ElevatedButton(
                      child: Text("HERE"),
                      onPressed: (){
                        GoRouter.of(context).push("/hereMap");
                      }
                    ),),
                  Center(
                    child: ElevatedButton(
                      child: Text("GPX FILES"),
                      onPressed: (){
                        GoRouter.of(context).push("/deviceGpxFiles");
                      },
                    )
                  ),
                  Center(
                    child: ElevatedButton(
                      child: Text("Google maps to gpx"),
                      onPressed: (){
                        GoRouter.of(context).push("/googleMapsToGpxPage");
                      },
                    )
                  )
                ],
              )
            : Column(
                children: [
                  Text("ID: ${athleteId}"),
                  Text("Username: ${athlete.username}"),
                  Image.network(athlete.profile!),
                  routes.isEmpty
                      ? Text("ROUTES ARE NULL")
                      : Expanded(
                          child: ListView.builder(
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  GoRouter.of(context).pushNamed("routeDetails", extra:routes[index]);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.network(routes[index].mapUrls.url),
                                      Text(routes[index].name),
                                    ],
                                  ),
                                ),
                              );
                            },
                            itemCount: routes.length,
                          ),
                        ),
                ],
              ),
      ),
    );
  }

  void authenticate(context) {
    BlocProvider.of<StravaBloc>(context).add(AuthenticateUser());
  }

  void getProfile() {
    BlocProvider.of<StravaBloc>(context).add(GetProfile());
  }

  void getRoutes(int athleteId) {
    BlocProvider.of<StravaBloc>(context).add(GetRoutes(athleteId: athleteId));
  }
}
