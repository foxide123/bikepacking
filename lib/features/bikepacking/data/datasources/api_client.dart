import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  final Uri currencyURL = Uri.https("api.freecurrencyapi.com", "/v1/currencies",
      {"apikey": "fca_live_JWf0FP3YTdvyfnEIUzXv5oJds9QFsaytgz5Y9ECA"});

  //base_currency - string
  //currencises - string (EUR)
  Future<List<String>> getCurrencies() async {
    List<String> currencies = [];

    http.Response res = await http.get(currencyURL);
    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      var list = body['data'];
      print("list: $list");
      List<String> currencies = [];
      list.values.forEach((currency) {
        final Map<String, dynamic> currencyMap =
            currency as Map<String, dynamic>;
        currencies.add(currencyMap['code'] as String);
      });
      print("CurrencyNames: $currencies");
      currencies.sort((a, b) {
        return a.toLowerCase().compareTo(b.toLowerCase());
      });
      return currencies;
    } else {
      throw Exception("Failed to connect to API");
    }
  }

  Future<double> getRate(String from, String to) async{
    final Uri rateUrl = Uri.https("api.freecurrencyapi.com", "/v1/latest", {"apikey": "fca_live_JWf0FP3YTdvyfnEIUzXv5oJds9QFsaytgz5Y9ECA",
    "base_currency": "${from}", "currencies": "${to}"},);
    http.Response res = await http.get(rateUrl);
    if(res.statusCode == 200){
      var body = jsonDecode(res.body);
      print(body);
      return body["data"]["$to"];
    }else{
      throw Exception("Failed to connect to API");
    }
  }
}
