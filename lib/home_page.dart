import 'package:bikepacking/features/strava/domain/enities/athlete.dart';
import 'package:bikepacking/features/strava/domain/enities/route.dart';
import 'package:bikepacking/features/strava/presentation/bloc/bloc/strava_bloc.dart';
import 'package:bikepacking/features/strava/presentation/widgets/top_bar_back_action.dart';
import 'package:bikepacking/main.dart';
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StravaBloc, StravaState>(
      listener: (context, state) {
      },
      child: Scaffold(
          body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/wallpaper.png'),
                          fit: BoxFit.fitWidth)),
                ),
                Positioned(
                  top: 50,
                  left: 80,
                  child: Image.asset('assets/logo.png'),
                  height: 180,
                )
              ],
            ),
          ),
          athleteId == 0
              ? Container(
                  color: Color(0xffd5be97),
                  height: 350,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2,
                              height: 175,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x00BA704F), // ARGB with 0% opacity
                                    Color(0xFFBA704F), // ARGB with 100% opacity
                                  ],
                                ),
                              ),
                              child: Column(
                                children: [
                                  Image.asset("assets/map_retro.png",
                                      height: 120),
                                  Text("Downloaded Maps"),
                                ],
                              ),
                            ),
                            onTap: ()=>GoRouter.of(context).push("/maplibreDownloadedMaps"),
                          ),
                          /* GestureDetector(
                            child: Container(
                              width: MediaQuery.of(context).size.width/2,
                              height: 175,
                              decoration: BoxDecoration(color: Color(0xffBA704F)),
                              child: Column(
                                children: [
                                  Text("AUTHENTICATE")
                                ],
                              ),
                            ),
                            onTap: ()=>authenticate(context),
                          ),*/

                          GestureDetector(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2,
                              height: 175,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x00BA704F), // ARGB with 0% opacity
                                    Color(0xff975a28), // ARGB with 100% opacity
                                  ],
                                ),
                              ),
                              child: Column(
                                children: [
                                  Image.asset("assets/bikepacking.png",
                                      height: 130),
                                  SizedBox(height: 10),
                                  Text("Bikepacking",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge),
                                ],
                              ),
                            ),
                            onTap: () =>
                                GoRouter.of(context).push("/bikepackingPage"),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            child: Container(
                                width: MediaQuery.of(context).size.width / 2,
                                height: 175,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0x00E48F45),
                                      Color(0xffE48F45),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Image.asset('assets/files_retro.png',
                                        height: 120),
                                    SizedBox(height: 10),
                                    Text("Gpx files",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge)
                                  ],
                                )),
                            onTap: () =>
                                GoRouter.of(context).push("/deviceGpxFiles"),
                          ),
                          GestureDetector(
                            child: Container(
                                width: MediaQuery.of(context).size.width / 2,
                                height: 175,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0x00F5CCA0),
                                      Color.fromARGB(255, 209, 153, 93),
                                      // Color(0xffF5CCA0),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Image.asset(
                                        'assets/google_maps_converter.png',
                                        height: 120),
                                    Text(
                                      "Google Maps to GPX",
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                )),
                            onTap: () => GoRouter.of(context)
                                .push("/googleMapsToGpxPage"),
                          )
                        ],
                      )
                    ],
                  ),
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
                                    GoRouter.of(context).pushNamed(
                                        "routeDetails",
                                        extra: routes[index]);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.network(
                                            routes[index].mapUrls.url),
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
        ],
      )),
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
