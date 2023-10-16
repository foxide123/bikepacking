import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class GoogleMapsToGpxPage extends StatefulWidget {
  const GoogleMapsToGpxPage({super.key});

  @override
  State<GoogleMapsToGpxPage> createState() => _GoogleMapsToGpxPageState();
}

class _GoogleMapsToGpxPageState extends State<GoogleMapsToGpxPage> {
  final myController = TextEditingController();
  WebViewController? webViewController;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            print(url);
            print(extractCoordinates(url));
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    super.initState();
  }

  Map<String,dynamic> extractCoordinates(String url) {
    String startLat = '';
    String startLon = '';
    String endLat = '';
    String endLon = '';
    String alternative = '';
    print("IN extractCoordinates");

    // Capture everything after "S.browser_fallback_url=" up to the next semicolon
    final fallbackMatch = RegExp(
      r'S\.browser_fallback_url=([^;]+)',
    ).firstMatch(url);

    if (fallbackMatch == null) {
      print("FALLBACKMATCH EMPTY");
      return {};
    }

    final fallbackUrl = Uri.decodeFull(fallbackMatch.group(1)!);

    print("Fallback URL: $fallbackUrl");

    final initialCoordsMatch = RegExp(r'/([\d.-]+),([\d.-]+)/').firstMatch(url);

    if (initialCoordsMatch != null) {
      final initialLatitude = initialCoordsMatch.group(1);
      final initialLongitude = initialCoordsMatch.group(2);

      print('Initial Latitude: $initialLatitude');
      print('Initial Longitude: $initialLongitude');
    }

    // Now, try to extract the coordinates from the fallback URL
    final coordsMatch =
        RegExp(r'!\d+d([\d.-]+)[^!]+!\d+d([\d.-]+)').allMatches(fallbackUrl);

    if (coordsMatch.isNotEmpty) {
      for (int i=0; i<coordsMatch.length; i++) {
        final lat = coordsMatch.elementAt(i).group(1);
        final lon = coordsMatch.elementAt(i).group(2);
        if (coordsMatch.length == 2) {
          if (i == 0) {
            print('Start Lat: $lat');
            print('Start Lon: $lon');
            startLat = lat.toString();
            startLon = lon.toString();
          }
          if (i == 1) {
            print('End Lat: $lat');
            print('End Lon: $lon');
            endLat = lat.toString();
            endLon = lon.toString();
          }
        }
      }
    } else {
      print("Coordinates Match Failed");
    }

    if (url.contains('!5i1')) {
      alternative = '1';
    }else if (url.contains('!5i2')) {
      alternative = '2';
    }else{
      alternative = '';
    }
    return {'start_lat': startLat, 'start_lon': startLon, 'end_lat': endLat, 'end_lon': endLon, 'alternative': alternative};
  }

  String? getGpx(String text) {
    final regex = RegExp(
      r'https?://maps\.(google\.com|app\.goo\.gl)/[^ \n\t]*',
    );
    final match = regex.firstMatch(text);
    return match?.group(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Text("Paste the google maps link"),
          TextField(
            controller: myController,
          ),
          ElevatedButton(
              onPressed: () {
                String url = getGpx(myController.text) ?? '';
                print("URL: $url");
                webViewController?.loadRequest(Uri.parse(url));
              },
              child: Text("Get gpx from Google Maps")),
          SizedBox(
              width: 0.0,
              height: 0.0,
              child: WebViewWidget(controller: webViewController!)
              /*WebView(
    initialUrl: extractedURL,
    onWebViewCreated: (WebViewController webViewController) {
      // You can interact with the WebView using the controller
    },
    javascriptMode: JavascriptMode.unrestricted,
    onPageFinished: (String url) {
      // Process the page content after it's loaded
    },
    navigationDelegate: (NavigationRequest request) {
      // Handle navigation requests, if needed
      return NavigationDecision.navigate;
    },
  )*/
              )
        ],
      ),
    );
  }
}
