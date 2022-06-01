import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Partnerconfirmation extends StatefulWidget {
  const Partnerconfirmation({ Key? key }) : super(key: key);

  @override
  State<Partnerconfirmation> createState() => _PartnerconfirmationState();
}

class _PartnerconfirmationState extends State<Partnerconfirmation> {
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
    title: Text('Partner Confirmation'),
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
         ],
       ),
     ),
      
    );
  }
}