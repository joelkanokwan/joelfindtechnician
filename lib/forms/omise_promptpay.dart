import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:joelfindtechnician/utility/my_constant.dart';

class OmisePromptPay {
  String? amount;
  String? currency;
  String? type;
  String? source_id;
  String? status;
  OmisePromptPay({
    this.amount,
    this.currency,
    this.type,
  });

  Future<String> createSource() async {
    try {
      http.Response response =
          await http.post(Uri.parse("https://api.omise.co/sources"),
              headers: {
                'Authorization':
                    'Basic ' + base64Encode(utf8.encode(MyConstant.publicKey)),
                'Omise-Version': '2019-05-29',
                'Cache-Control': 'no-cache',
                'Content-Type': 'application/json'
              },
              body: jsonEncode({
                'amount': amount,
                'currency': currency,
                'type': type,
              }));
      source_id = jsonDecode(response.body)["id"];
      return jsonDecode(response.body)["id"];
    } catch (e) {
      throw e;
    }
  }

  Future<String> chargeSource() async {
    try {
      http.Response response =
          await http.post(Uri.parse("https://api.omise.co/charges"),
              headers: {
                'Authorization':
                    'Basic ' + base64Encode(utf8.encode(MyConstant.secretKey)),
                'Omise-Version': '2019-05-29',
                'Cache-Control': 'no-cache',
                'Content-Type': 'application/json'
              },
              body: jsonEncode({
                'source': source_id,
                'amount': amount,
                'currency': currency,
              }));
      return jsonDecode(response.body)['source']['scannable_code']['image']
          ['download_uri'];
    } catch (e) {
      throw e;
    }
  }
}
