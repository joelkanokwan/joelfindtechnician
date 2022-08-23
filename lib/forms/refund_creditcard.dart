import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:joelfindtechnician/utility/my_constant.dart';

class RefundCreditCard {
  int? amount;
  String? charge_test;
  RefundCreditCard({
    this.amount,
    this.charge_test,
  });
  Future<String> createRefound() async {
    try {
      http.Response response = await http.post(
          Uri.parse("https://api.omise.co/charges/$charge_test/refunds"),
          headers: {
            'Authorization':
                'Basic ' + base64Encode(utf8.encode(MyConstant.secretKey)),
            'Omise-Version': '2019-05-29',
            'Cache-Control': 'no-cache',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({'amount': amount}));
      return jsonDecode(response.body)["id"];
    } catch (e) {
      throw e;
    }
  }
}
// ใส่ในปุ่มคืนเงิน
  // String charge_test_true =
      // 'chrg_test_5rf6d5a1f65ree87ce4';
  // int amount_true = 1200000;
  // RefoundCreditCard refoundCreditCard =
      // RefoundCreditCard(amount: amount_true,charge_test: charge_test_true);
  // String id =
      // await refoundCreditCard.createRefound();
