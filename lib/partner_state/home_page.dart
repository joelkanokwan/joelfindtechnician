import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joelfindtechnician/customer_state/social_service.dart';
import 'package:joelfindtechnician/forms/formto_technician.dart';
import 'package:joelfindtechnician/models/appointment_model.dart';
import 'package:joelfindtechnician/models/token_model.dart';
import 'package:joelfindtechnician/models/user_model_old.dart';
import 'package:joelfindtechnician/partner_state/mywallet.dart';
import 'package:joelfindtechnician/partner_state/partner_aboutus.dart';
import 'package:joelfindtechnician/partner_state/partner_contactus.dart';
import 'package:joelfindtechnician/partner_state/partner_howtouseapp.dart';
import 'package:joelfindtechnician/partner_state/partner_notification.dart';
import 'package:joelfindtechnician/partner_state/partner_orderhistory.dart';
import 'package:joelfindtechnician/partner_state/partner_termandconditon.dart';
import 'package:joelfindtechnician/partner_state/partner_signin.dart';
import 'package:joelfindtechnician/state/community_page.dart';
import 'package:joelfindtechnician/state/showDetail_Noti.dart';
import 'package:joelfindtechnician/state/show_profile.dart';
import 'package:joelfindtechnician/utility/my_constant.dart';
import 'package:joelfindtechnician/widgets/show_progress.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? docUser;
  UserModelOld? userModelOld;
  FirebaseMessaging? firebaseMessaging;

  FlutterLocalNotificationsPlugin flutterLocalNoti =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings? androidInitializationSettings;

  InitializationSettings? initializationSettings;

  String? myTitle;

  String? myMessage, token;

  @override
  void initState() {
    super.initState();
    findUser();
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
      print('#28Nov สิ่งที่ได้จาการคลิก Notification ตอนเปิดแอปอยู่');
      processAfterClickNoti(myTitle!, myMessage!);
    }
  }

  Future<void> findToken(String docUser) async {
    print('@@@@ docUser ==> $docUser');

    await Firebase.initializeApp().then((value) async {
      await FirebaseMessaging.instance.getToken().then((value) async {
        token = value!;
        print('#6jan token ที่ Login อยู่ ==>> $value');

        await FirebaseFirestore.instance
            .collection('user')
            .doc(docUser)
            .collection('mytoken')
            .get()
            .then((value) async {
          print('@@@@ value ==>>> ${value.docs}');
          TokenModel model = TokenModel(token: token!);
          Map<String, dynamic> data = model.toMap();
          if (value.docs.isEmpty) {
            //insert

            await FirebaseFirestore.instance
                .collection('user')
                .doc(docUser)
                .collection('mytoken')
                .doc('doctoken')
                .set(data)
                .then((value) => print('@@@@ success insert token'));
          } else {
            //update
            await FirebaseFirestore.instance
                .collection('user')
                .doc(docUser)
                .collection('mytoken')
                .doc('doctoken')
                .update(data)
                .then((value) => print('@@@@ success Update token'));
          }
        });
      });
    });

    await FirebaseMessaging.onMessage.listen((event) {
      String title = event.notification!.title.toString();
      String message = event.notification!.body.toString();
      print('#28Nov onMessage ทำงาน title = $title, message = $message');
      myTitle = title;
      myMessage = message;
      alertNotifiction(title, message);
    });
    await FirebaseMessaging.onMessageOpenedApp.listen((event) {
      String title = event.notification!.title.toString();
      String message = event.notification!.body.toString();
      myTitle = title;
      myMessage = message;
      alertNotifiction(title, message);

      processAfterClickNoti(title, message);
    });
  }

  Future<void> processAfterClickNoti(String title, String message) async {
    print(
        '#3feb processAfterClickNoti Work ==>>> title = $title, message = $message');

    List<String> strings = message.split('@');
    print('#3feb strings ==> $strings');

    if (strings[0].trim() == 'Contact') {
      String customerName = strings[1].trim();
      customerName = customerName.substring(4).trim();

      print('#3feb customerName = $customerName');

      await FirebaseFirestore.instance
          .collection('user')
          .doc(docUser)
          .collection('appointment')
          .where('customerName', isEqualTo: customerName)
          .get()
          .then((value) {
        for (var item in value.docs) {
          AppointmentModel appointmentModel =
              AppointmentModel.fromMap(item.data());

          if (appointmentModel.approve == 'unread') {
            var docIdAppointment = item.id;

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormtoTechnician(
                    docIdAppointment: docIdAppointment,
                    appointmentModel: appointmentModel, customerName: customerName,
                  ),
                ));
          }
        }
      });
    } else {
      print('#3feb form Orther');
      moveToGeneralNoti(title, message);
    }
  }

  void moveToGeneralNoti(String title, String message) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShowDetailNoti(
            title: title,
            message: message,
            userModelOld: userModelOld!,
          ),
        ));
  }

  Future<Null> findUser() async {
    await Firebase.initializeApp().then((value) async {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('user')
          .where('uid', isEqualTo: firebaseUser!.uid)
          .get()
          .then((value) {
        for (var item in value.docs) {
          docUser = item.id;
          findToken(docUser!);
          setState(() {
            userModelOld = UserModelOld.fromMap(item.data());
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final User = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home Page',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                userModelOld == null ? ShowProgress() : buildCircleAvatar(),
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
                buildMyProfile(context),
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
                                      userSocialbol: false,
                                    )));
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
                              'Communiti Page',
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
                                builder: (context) => MyWallet()));
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              'My Wallet',
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
                                builder: (context) => PartnerNotification(
                                      docUser: docUser!,
                                      userModelold: userModelOld,
                                    )));
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
                                builder: (context) => PartnerOrderHistory()));
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
                                builder: (context) => PartnerAboutUs()));
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
                                builder: (context) => PartnerContactUs()));
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
                                builder: (context) => PartnerHowtoUseApp()));
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
                                    PartnerTermAndCondiotion()));
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
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PartnerSignin()),
                            (route) => false);
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
      ),
    );
  }

  CircleAvatar buildCircleAvatar() {
    return CircleAvatar(
      radius: 70,
      backgroundImage: userModelOld!.img.isEmpty
          ? NetworkImage(MyConstant.urlNoAvatar)
          : NetworkImage(userModelOld!.img),
    );
  }

  Container buildMyProfile(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                builder: (context) => ShowProfile(),
              ),
            ).then((value) => findUser());
          },
          child: Row(
            children: [
              Icon(
                Icons.person_outline,
                color: Colors.orange,
              ),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  'My Profile',
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
    );
  }

  Future<void> alertNotifiction(String title, String message) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channelId',
      'channelName',
      priority: Priority.high,
      importance: Importance.max,
      ticker: 'test',
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNoti
        .show(0, title, message, notificationDetails)
        .then((value) async {
      print('@@@@@@ ค่าที่ได้จาก Noti ==> $title');
      // insert data to firebase
    });
  }
}
