import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joelfindtechnician/forms/require_credit_card.dart';

class CheckOut extends StatefulWidget {
  const CheckOut({Key? key}) : super(key: key);

  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  bool? display;
  int? indexDisplay;
  var displayWidgets = <Widget>[];

  @override
  void initState() {
    super.initState();
    displayWidgets.add(Text('This is QR CODE'));
    displayWidgets.add(RequireCreditCard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text('Check Out'),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Card(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                print('#30Mar You Click QR CODE');
                                display = true;
                                indexDisplay = 0;
                                setState(() {});
                              },
                              child: Icon(
                                Icons.qr_code,
                              ),
                            ),
                            Text(
                              'QR Code',
                              style: GoogleFonts.lato(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.amberAccent,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Card(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                                onTap: () {
                                  print('#30Mar You Click CreditCard');
                                  display = true;
                                  indexDisplay = 1;
                                  setState(() {});
                                },
                                child: Icon(Icons.credit_card)),
                            Text(
                              'Credit card',
                              style: GoogleFonts.lato(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.amberAccent,
                    ),
                  ),
                 
                ],
              ),
              // Text('data')
               display == null
                  ? SizedBox()
                  : SizedBox(
                      width: 400,
                      height: 600,
                      child: displayWidgets[indexDisplay!]),
            ],
          ),
        ),
      ),
    );
  }
}