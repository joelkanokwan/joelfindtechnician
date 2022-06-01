import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joelfindtechnician/alertdialog/my_dialog.dart';
import 'package:joelfindtechnician/forms/check_out.dart';
import 'package:joelfindtechnician/forms/require_credit_card.dart';
import 'package:joelfindtechnician/models/appointment_model.dart';
import 'package:joelfindtechnician/models/customer_noti_model.dart';
import 'package:joelfindtechnician/models/postcustomer_model.dart';
import 'package:joelfindtechnician/models/social_my_notification.dart';
import 'package:joelfindtechnician/models/user_model_old.dart';
import 'package:joelfindtechnician/utility/time_to_string.dart';
import 'package:joelfindtechnician/widgets/show_form.dart';
import 'package:joelfindtechnician/widgets/show_progress.dart';
import 'package:joelfindtechnician/widgets/show_text.dart';

class CheckDetail extends StatefulWidget {
  final CustomerNotiModel? customerNotiModel;
  const CheckDetail({
    Key? key,
    this.customerNotiModel,
  }) : super(key: key);

  @override
  _CheckDetailState createState() => _CheckDetailState();
}

class _CheckDetailState extends State<CheckDetail> {
  File? image;
  CustomerNotiModel? customerNotiModel;
  UserModelOld? userModelOld;
  AppointmentModel? appointmentModel;
  SocialMyNotificationModel? socialMyNotificationModel;
  PostCustomerModel? postCustomerModel;

  bool load = true;
  bool? haveData;

  var user = FirebaseAuth.instance.currentUser;
  String? appointDateStr;
  String? taxID;
  String? docMynotification;

  @override
  void initState() {
    super.initState();
    customerNotiModel = widget.customerNotiModel;

    if (customerNotiModel == null) {
      setState(() {
        load = false;
        haveData = false;
      });
    } else {
      findDataTechnic();
    }
  }

  Future<void> findDataTechnic() async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(customerNotiModel!.socialMyNotificationModel!.docIdTechnic)
        .get()
        .then((value) async {
      if (value.data() == null || customerNotiModel == null) {
        haveData = false;
      } else {
        haveData = true;
        userModelOld = UserModelOld.fromMap(value.data()!);

        String? customerName = customerNotiModel!.customerName;

        String docIdPostcustomer =
            customerNotiModel!.socialMyNotificationModel!.docIdPostCustomer;

        await FirebaseFirestore.instance
            .collection('user')
            .doc(customerNotiModel!.socialMyNotificationModel!.docIdTechnic)
            .collection('appointment')
            .where('customerName', isEqualTo: customerName)
            .where('docIdPostcustomer', isEqualTo: docIdPostcustomer)
            .get()
            .then((value) async {
          for (var item in value.docs) {
            appointmentModel = AppointmentModel.fromMap(item.data());
            appointDateStr =
                TimeToString(timestamp: appointmentModel!.timeAppointment)
                    .findString();

            setState(() {});
          }
        });

        await FirebaseFirestore.instance
            .collection('postcustomer')
            .doc(appointmentModel!.docIdPostcustomer)
            .get()
            .then((value) {
          postCustomerModel = PostCustomerModel.fromMap(value.data()!);
          setState(() {});
        });

        await FirebaseFirestore.instance
            .collection('social')
            .doc(user!.uid)
            .collection('myNotification')
            .where('customerName', isEqualTo: appointmentModel!.customerName)
            .where('docIdPostCustomer',
                isEqualTo: appointmentModel!.docIdPostcustomer)
            .get()
            .then((value) {
          for (var item in value.docs) {
            docMynotification = item.id;
            socialMyNotificationModel =
                SocialMyNotificationModel.fromMap(item.data());
            load = false;
            setState(() {});
          }
        });
      }
    });
  }

  _imageFromCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.camera);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      image = pickedImageFile;
    });
  }

  _imageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      image = pickedImageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: newAppBar(context),
      body: load
          ? Center(child: ShowProgress())
          : haveData!
              ? newContent(context)
              : Center(child: ShowText(title: 'No Data')),
    );
  }

  GestureDetector newContent(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusScopeNode()),
      behavior: HitTestBehavior.opaque,
      child: Container(
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
                        'Please pay before :',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Shop name : ${userModelOld!.name}',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Customer name : ${appointmentModel?.customerName ?? ''}',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Email address : ${appointmentModel!.emailAddress}',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      ShowForm(
                          label: 'Tax ID',
                          changeFunc: (string) => taxID = string!.trim()),
                      SizedBox(height: 8),
                      Text(
                        'Order number :  $docMynotification',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Appointment Date : ${appointDateStr}',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(thickness: 3),
                      SizedBox(height: 8),
                      Text(
                        'Address : ${postCustomerModel!.address} ต. ${postCustomerModel!.district}  อ.  ${postCustomerModel!.amphur}  จ.  ${postCustomerModel!.province}',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(thickness: 3),
                      SizedBox(height: 8),
                      Text(
                        'Detail of work : ${socialMyNotificationModel!.detailOfWork}',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(thickness: 3),
                      Text(
                        'Wanranty :  ${socialMyNotificationModel!.waranty}',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(thickness: 3),
                      Text(
                        'Total Price :  ${socialMyNotificationModel!.totalPrice}',
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
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: FlatButton(
                  textColor: Colors.white,
                  color: Colors.blueAccent,
                  onPressed: () {
                    if (taxID?.isEmpty ?? true) {
                      MyDialog().normalDialog(
                          context, 'No Tax ID', 'Please Fill Tax ID');
                    } else {
                      if (socialMyNotificationModel!.status == 'charged') {
                        MyDialog()
                            .normalDialog(context, 'Paid', 'Payment Sucess');
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckOut(
                                taxID: taxID!,
                                totalPrice:
                                    socialMyNotificationModel!.totalPrice,
                                docMynotification: docMynotification!,
                              ),
                            ));
                      }
                    }
                  },
                  child: Text(
                    'Payment',
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar newAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
      ),
      title: Text('Check detail'),
    );
  }
}
