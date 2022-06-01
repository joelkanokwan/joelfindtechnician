import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joelfindtechnician/alertdialog/my_dialog.dart';

class CustomerConfirmation extends StatefulWidget {
  const CustomerConfirmation({Key? key}) : super(key: key);

  @override
  State<CustomerConfirmation> createState() => _CustomerConfirmationState();
}

class _CustomerConfirmationState extends State<CustomerConfirmation> {
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
        title: Text('Customer Confirmation'),
      ),
      body: Container(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shop name :',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Customer name :',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Order number : ',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Appointment Date :',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(thickness: 3),
                      SizedBox(height: 8),
                      Text(
                        'Address : ',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(thickness: 3),
                      SizedBox(height: 8),
                      Text(
                        'Detail of work : ',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(thickness: 3),
                      Text(
                        'Wanranty : ',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(thickness: 3),
                      Text(
                        'Total Price : ',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ปุ่มโชว์วันที่ Appointment Date
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'ขอคืนเงิน',
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      MyDialog().normalDialog(
                          context,
                          'คุณยืนยันว่างานเสร็จเรียบร้อย ?',
                          'หลังจากกดยืนยันแล้ว ไม่สามารถขอคืนเงินได้ไม่ว่ากรณีใดทั้งสิ้น');
                    },
                    child: Text(
                      'งานเสร็จเรียบร้อย',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
