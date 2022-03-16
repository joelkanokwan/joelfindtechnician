// ignore_for_file: await_only_futures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joelfindtechnician/customer_state/ctm_aboutus.dart';
import 'package:joelfindtechnician/customer_state/ctm_contactus.dart';
import 'package:joelfindtechnician/customer_state/ctm_howtouseapp.dart';
import 'package:joelfindtechnician/customer_state/ctm_notification.dart';
import 'package:joelfindtechnician/customer_state/ctm_ordethistory.dart';
import 'package:joelfindtechnician/customer_state/ctm_termandconditon.dart';
import 'package:joelfindtechnician/forms/check_detail.dart';
import 'package:joelfindtechnician/models/postcustomer_model.dart';
import 'package:joelfindtechnician/models/replypost_model.dart';
import 'package:joelfindtechnician/models/token_social_model.dart';
import 'package:joelfindtechnician/state/ctm_list_answer.dart';
import 'package:joelfindtechnician/state/detail_noti_social.dart';
import 'package:joelfindtechnician/state/login_page.dart';
import 'package:joelfindtechnician/customer_state/social_service.dart';
import 'package:joelfindtechnician/state/community_page.dart';
import 'package:joelfindtechnician/utility/find_token.dart';

class LoginSuccess extends StatefulWidget {
  @override
  _LoginSuccessState createState() => _LoginSuccessState();
}

class _LoginSuccessState extends State<LoginSuccess> {
  final User = FirebaseAuth.instance.currentUser!;
  String? token, myTitle, myMessage;

  FlutterLocalNotificationsPlugin flutterLocalNoti =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings? androidInitializationSettings;
  InitializationSettings? initializationSettings;

  PostCustomerModel? postCustomerModel;

  @override
  initState() {
    super.initState();

    findToken();
    setupLocalNoti();
  }

  Future<void> setupLocalNoti() async {
    androidInitializationSettings =
        AndroidInitializationSettings('ic_launcher');
    initializationSettings =
        InitializationSettings(android: androidInitializationSettings);
    await flutterLocalNoti.initialize(initializationSettings!,
        onSelectNotification: onSelectNoti);
  }

  Future<void> onSelectNoti(String? string) async {
    if (string != null) {
      processClickNoti();
    }
  }

  Future<void> processClickNoti() async {
    bool checkMessage = true;

    List<String?> strings = myMessage!.split('@');
    print('#16mar strings ==>> $strings');
    if (!(strings[0]?.isEmpty ?? true)) {
      strings[0] = strings[0]!.trim();
      if ((strings[0] == 'NonApprove') ||
          (strings[0] == 'TimeOut') ||
          (strings[0] == 'Confirm')) {
        checkMessage = false;
      }
    }

    if (strings[0] == 'reply') {
      // มาจากการตอบของ Technic ระดับ Reply ติดไว้เป็นการบ้าน เมื่อสร้างรายละเอียดเสร็จ
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>DetailNotiSocial(reply: strings[1]!.trim()),
          ));
    } else {
      if (checkMessage) {
        await FirebaseFirestore.instance
            .collection('postcustomer')
            .get()
            .then((value) async {
          for (var item in value.docs) {
            PostCustomerModel postCustomerModel =
                PostCustomerModel.fromMap(item.data());
            await FirebaseFirestore.instance
                .collection('postcustomer')
                .doc(item.id)
                .collection('replypost')
                .get()
                .then((value) {
              for (var item in value.docs) {
                ReplyPostModel replyPostModel =
                    ReplyPostModel.fromMap(item.data());
                if (replyPostModel.reply == myMessage) {
                  this.postCustomerModel = postCustomerModel;
                }
              }
            });
          }

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CtmListAnswer(postCustomerModel: this.postCustomerModel!),
              ));
        });
      } else {
        print('Noti form Cancel AppointMent');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              if (strings[0] == 'Confirm') {
                return CheckDetail();
              } else {
                return CustomerNotification();
              }
            },
          ),
        );
      } // end if
    }
  }

  Future<void> alertNotifiction(String title, String message) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channelId',
      'channelName',
      priority: Priority.high,
      importance: Importance.max,
      ticker: 'test2',
    );
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNoti
        .show(0, title, message, notificationDetails)
        .then((value) async {
      print('#6jan ค่าที่ได้จาก Noti ==> $title');
    });
  }

  Future<void> findToken() async {
    token = await FindToken().processFindToken();
    print('#6jan token ที่ userSocial Login อยู่ ==>$token');

    String uidSocialLogin = User.uid;
    String nameSocial = User.displayName ?? '';
    String avatarSocial = User.photoURL ?? '';
    print(
        '#6jan uid ==> $uidSocialLogin, name ==> $nameSocial, avatar ==> $avatarSocial');
    TokenSocialModel tokenSocialModel = TokenSocialModel(
        token: token!, nameSocial: nameSocial, avatarSocial: avatarSocial);
    await FirebaseFirestore.instance
        .collection('social')
        .doc(uidSocialLogin)
        .get()
        .then((value) async {
      print('#6jan value ==> ${value.data()}');
      if (value.data() == null) {
        await FirebaseFirestore.instance
            .collection('social')
            .doc(uidSocialLogin)
            .set(tokenSocialModel.toMap())
            .then((value) => print('#6jan setToken Success'));
      } else {
        await FirebaseFirestore.instance
            .collection('social')
            .doc(uidSocialLogin)
            .update(tokenSocialModel.toMap())
            .then((value) => print('#6jan updateToken Success'));
      }
    });
    //เปิดแอปอยู่ทำงานที่นี่
    await FirebaseMessaging.onMessage.listen((event) {
      myTitle = event.notification!.title.toString();
      myMessage = event.notification!.body.toString();
      print('#16mar onMessage ทำงาน title = $myTitle, message = $myMessage');
      alertNotifiction(myTitle!, myMessage!);
    });

    //ไม่ได้เปิดแอฟทำงานที่นี่
    await FirebaseMessaging.onMessageOpenedApp.listen((event) {
      myTitle = event.notification!.title.toString();
      myMessage = event.notification!.body.toString();
      print(
          '#16mar onMessageOpenApp ทำงาน title = $myTitle, message = $myMessage');
      // alertNotifiction(myTitle!, myMessage!);
      processClickNoti();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(User.photoURL!),
                  ),
                  SizedBox(height: 8),
                  Text(
                    User.displayName!,
                    style: GoogleFonts.lato(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    ' ' + User.email!,
                    style: GoogleFonts.lato(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 40),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: FlatButton(
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        color: Color(0xFFF5F6F9),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CommunityPage(
                                        userSocialbol: true,
                                      )));
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.design_services_outlined,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                'Go to Service',
                                style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: FlatButton(
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        color: Color(0xFFF5F6F9),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CustomerNotification()));
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.notification_important_outlined,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                'Notification',
                                style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: FlatButton(
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        color: Color(0xFFF5F6F9),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CustomerOrderHistory()));
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                'Order History',
                                style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: FlatButton(
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        color: Color(0xFFF5F6F9),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CustomerAboutUs()));
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_pin_circle_outlined,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                'About Us',
                                style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: FlatButton(
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        color: Color(0xFFF5F6F9),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CustomerContactUs()));
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.message_outlined,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                'Contact Us',
                                style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: FlatButton(
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        color: Color(0xFFF5F6F9),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CustomerHowtouseApp()));
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.label_important_outline,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                'How to use App',
                                style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: FlatButton(
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        color: Color(0xFFF5F6F9),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CustomerTermandConditon()));
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_outlined,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                'Term and condition',
                                style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: FlatButton(
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        color: Color(0xFFF5F6F9),
                        onPressed: () {
                          SocialService().signOut();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.power_settings_new,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                'SignOut',
                                style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
