import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joelfindtechnician/forms/check_detail.dart';
import 'package:joelfindtechnician/models/customer_noti_model.dart';
import 'package:joelfindtechnician/models/postcustomer_model.dart';
import 'package:joelfindtechnician/models/social_my_notification.dart';
import 'package:joelfindtechnician/state/ctm_list_answer.dart';
import 'package:joelfindtechnician/utility/time_to_string.dart';
import 'package:joelfindtechnician/widgets/show_progress.dart';
import 'package:joelfindtechnician/widgets/show_text.dart';

class CustomerNotification extends StatefulWidget {
  const CustomerNotification({Key? key}) : super(key: key);

  @override
  _CustomerNotificationState createState() => _CustomerNotificationState();
}

class _CustomerNotificationState extends State<CustomerNotification> {
  var postCustomerModels = <PostCustomerModel>[];

  String uidLogin = FirebaseAuth.instance.currentUser!.uid;

  var docIdPostCustomers = <String>[];

  bool load = true;
  bool? haveData;

  var socialReadeds = <bool>[];

  var customerNotiModels = <CustomerNotiModel>[];
  var customerNotiSortModels = <CustomerNotiModel>[];

  @override
  void initState() {
    super.initState();
    readPostCustomer();
  }

  Future<void> readMyNotification() async {
    // print('#29Mar uidLogin ==> $uidLogin');

    await FirebaseFirestore.instance
        .collection('social')
        .doc(uidLogin)
        .collection('myNotification')
        .get()
        .then((value) async {
      for (var item in value.docs) {
        SocialMyNotificationModel socialMyNotificationModel =
            SocialMyNotificationModel.fromMap(item.data());

        // print(
            // '#29Mar docIdPostCustomer ==>> ${socialMyNotificationModel.docIdPostCustomer}');

        var result = await FirebaseFirestore.instance
            .collection('postcustomer')
            .doc(socialMyNotificationModel.docIdPostCustomer)
            .get()
            .catchError((onError) {});

        PostCustomerModel customerModel =
            PostCustomerModel.fromMap(result.data()!);

        CustomerNotiModel customerNotiModel = CustomerNotiModel(
          title: customerModel.job,
          timestamp: socialMyNotificationModel.timeConfirm,
          navigatorBool: false,
          socialMyNotificationModel: socialMyNotificationModel,
          fontWeight: socialMyNotificationModel.readed,
          // customerName: socialMyNotificationModel.customerName,
        );

        setState(() {
          customerNotiModels.add(customerNotiModel);
          haveData = true;
        });
      }
    });

    var listCustomerNotiMaps = <Map<String, dynamic>>[];
    for (var item in customerNotiModels) {
      Map<String, dynamic> map = item.toMap();
      listCustomerNotiMaps.add(map);
    }

    listCustomerNotiMaps
        .sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    for (var item in listCustomerNotiMaps) {
      CustomerNotiModel customerNotiModel = CustomerNotiModel.fromMap(item);
      setState(() {
        customerNotiSortModels.add(customerNotiModel);
      });
    }
  }

  Future<void> readPostCustomer() async {
    if (postCustomerModels.isNotEmpty) {
      postCustomerModels.clear();
      docIdPostCustomers.clear();
      socialReadeds.clear();
    }
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('postcustomer')
          .orderBy('timePost', descending: true)
          .get()
          .then((value) async {
        for (var item in value.docs) {
          PostCustomerModel postCustomerModel =
              PostCustomerModel.fromMap(item.data());
          if (postCustomerModel.uidCustomer == uidLogin) {
            load = false;
            String docIdPostCustomer = item.id;

            await FirebaseFirestore.instance
                .collection('postcustomer')
                .doc(docIdPostCustomer)
                .collection('replypost')
                .get()
                .then((value) {
              if (value.docs.isNotEmpty) {
                CustomerNotiModel customerNotiModel = CustomerNotiModel(
                  title: postCustomerModel.job,
                  timestamp: postCustomerModel.timePost,
                  navigatorBool: true,
                  postCustomerModel: postCustomerModel,
                  fontWeight: postCustomerModel.socialReaded,
                  docIdPostCustomer: docIdPostCustomer,
                );

                setState(() {
                  haveData = true;
                  postCustomerModels.add(postCustomerModel);
                  docIdPostCustomers.add(docIdPostCustomer);
                  socialReadeds.add(postCustomerModel.socialReaded);
                  customerNotiModels.add(customerNotiModel);
                });
              } else {
                haveData = false;
              }
            });
          } // if
        }
      });

      readMyNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: newAppBar(context),
      body: load
          ? ShowProgress()
          : haveData!
              ? ListView.builder(
                  itemCount: customerNotiSortModels.length,
                  itemBuilder: (context, index) => newContent(
                      customerNotiModel: customerNotiSortModels[index]),
                )
              : Center(child: ShowText(title: 'No Message')),
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
      title: Text('Customer Notification'),
    );
  }

  Widget newContent({required CustomerNotiModel customerNotiModel}) {
    return InkWell(
      onTap: () async {
        if (customerNotiModel.navigatorBool) {
          String docIdPostCustomer = customerNotiModel.docIdPostCustomer!;
          bool socialReaded = customerNotiModel.fontWeight;

          if (!socialReaded) {
            Map<String, dynamic> data = {};
            data['socialReaded'] = true;
            await FirebaseFirestore.instance
                .collection('postcustomer')
                .doc(docIdPostCustomer)
                .update(data)
                .then((value) => print('##23jan Update Success'));
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CtmListAnswer(
                job: customerNotiModel.title,
                postCustomerModel: customerNotiModel.postCustomerModel!,
              ),
            ),
          );
        } else {
          // for form Contact

          print('#29Mar customerNotiModel ==>> ${customerNotiModel.toMap()}');

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckDetail(
                  customerNotiModel: customerNotiModel,
                ),
              ));
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
            ),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 30, 0),
                child: Text(
                  customerNotiModel.title,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: customerNotiModel.fontWeight
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  TimeToString(timestamp: customerNotiModel.timestamp)
                      .findString(),
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
