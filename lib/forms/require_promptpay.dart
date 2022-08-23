

import 'package:flutter/material.dart';
import 'package:joelfindtechnician/forms/omise_promptpay.dart';
import 'package:jovial_svg/jovial_svg.dart';

class RequirePromptPay extends StatefulWidget {
  const RequirePromptPay({Key? key}) : super(key: key);

  @override
  State<RequirePromptPay> createState() => _RequirePromptPayState();
}

class _RequirePromptPayState extends State<RequirePromptPay> {
  String qrcode_url = '';

  // void _show() async {
    // OmisePromptPay promptPay =
        // OmisePromptPay(amount: '100000', currency: 'THB', type: 'promptpay');
    // String sourceid = await promptPay.createSource();
    // String charge2 = await promptPay.chargeSource();
// 
    // setState(() {
      // qrcode_url = charge2;
    // });
  // }
// 
  // @override
  // void initState() {
    // _show();
    // super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PromptPay QR Code'),
      ),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(left: 20.0, right: 20.0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 20,
            padding: EdgeInsets.all(15.0),
            child: ScalableImageWidget.fromSISource(
                si: ScalableImageSource.fromSvgHttpUrl(Uri.parse(qrcode_url))),
          ),
          Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 450),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.qr_code),
        onPressed: () {
          setState(
            () async {
              OmisePromptPay promptpay = OmisePromptPay(
                  amount: '50000', currency: 'THB', type: 'promptpay');
              String sourceid = await promptpay.createSource();
              String charge2 = await promptpay.chargeSource();
              setState(
                () {
                  qrcode_url = charge2;
                },
              );
            },
          );
        },
      ),
       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
