import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:http/http.dart' as http;
import 'package:joelfindtechnician/alertdialog/my_dialog.dart';
import 'package:joelfindtechnician/customer_state/login_success.dart';
import 'package:joelfindtechnician/utility/my_constant.dart';
import 'package:omise_flutter/omise_flutter.dart';

class RequireCreditCard extends StatefulWidget {
  final String totalPrice;
  final String docMynotification;
  final String taxID;
  const RequireCreditCard({
    Key? key,
    required this.totalPrice,
    required this.docMynotification,
    required this.taxID,
  }) : super(key: key);

  @override
  _RequireCreditCardState createState() => _RequireCreditCardState();
}

class _RequireCreditCardState extends State<RequireCreditCard> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  String? totalPrice;
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? docMynotification;

  var user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    totalPrice = widget.totalPrice;
    docMynotification = widget.docMynotification;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusScopeNode()),
          child: Column(
            children: [
              CreditCardWidget(
                cardBgColor: Colors.black,
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                showBackView: isCvvFocused,
                obscureCardNumber: true,
                obscureCardCvv: true,
                onCreditCardWidgetChange: (CreditCardBrand) {},
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: [
                    CreditCardForm(
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      onCreditCardModelChange: onCreditCardModelChange,
                      themeColor: Colors.blue,
                      formKey: formKey,
                      cardNumberDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Number',
                          hintText: 'xxxx xxxx xxxx xxxx'),
                      expiryDateDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Expired Date',
                          hintText: 'xx/xx'),
                      cvvCodeDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'CVV',
                          hintText: 'xxx'),
                      cardHolderDecoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Card Holder',
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          primary: Color.fromARGB(255, 159, 115, 209)),
                      child: Container(
                        margin: EdgeInsets.all(8.0),
                        child: Text(
                          'Confirm Pay $totalPrice Bath',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'halter',
                            fontSize: 14,
                            package: 'flutter_credit_card',
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (cardHolderName.isEmpty) {
                            MyDialog().normalDialog(context, 'No Card Holder',
                                'Please fill card holder');
                          } else {
                            processCreditCard();
                          }
                        } else {
                          print('inValid');
                        }
                      },
                    )
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  Future<void> processCreditCard() async {
    final numbers = cardNumber.split(' ');
    cardNumber =
        '${numbers[0].trim()}${numbers[1].trim()}${numbers[2].trim()}${numbers[3].trim()}';

    print(
        'CardNumber = $cardNumber, expriryDate = $expiryDate, cvvCode = $cvvCode');

    final dates = expiryDate.split('/');
    print('dates ==>> $dates');

    OmiseFlutter omiseFlutter = OmiseFlutter(MyConstant.publicKey);
    await omiseFlutter.token
        .create(cardHolderName, cardNumber, '${dates[0].trim()}',
            '${dates[1].trim()}', cvvCode)
        .then((value) async {
      String token = value.id!;
      print('#9Apr token Omise ==>> $token ');

      String secretKey = MyConstant.secretKey;
      String basicAuth = 'Basic ' + base64Encode(utf8.encode(secretKey + ":"));

      Map<String, String> headerMap = {};
      headerMap['authorization'] = basicAuth;
      headerMap['Cache-Control'] = 'no-cache';
      headerMap['Content-Type'] = 'application/x-www-form-urlencoded';

      

      Map<String, dynamic> data = {};
      data['amount'] = '$totalPrice' + '00';
      data['currency'] = 'thb';
      data['card'] = token;

      Uri chargeUri = Uri.parse('https://api.omise.co/charges');
      http.Response response = await http.post(
        chargeUri,
        headers: headerMap,
        body: data,
      );

      var resultCharge = json.decode(response.body);
      print('resultCharge ==>> $resultCharge');
      print('Status ==>> ${resultCharge['status']}');

      if (resultCharge['status'] == 'successful') {
        Map<String, dynamic> map = {};
        map['taxID'] = widget.taxID;
        map['status'] = 'charged';

        await FirebaseFirestore.instance
            .collection('social')
            .doc(user!.uid)
            .collection('myNotification')
            .doc(docMynotification)
            .update(map)
            .then((value) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginSuccess(),
              ),
              (route) => false);
        });
      } else {
        MyDialog().normalDialog(context, 'Cannot Charge',
            'Please contact bank or choose other payment method');
      }
    });
  }
}
