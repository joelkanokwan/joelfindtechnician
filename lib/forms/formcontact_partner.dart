import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:joelfindtechnician/alertdialog/my_dialog.dart';
import 'package:joelfindtechnician/alertdialog/select_province.dart';
import 'package:joelfindtechnician/models/answer_model.dart';
import 'package:joelfindtechnician/models/appointment_model.dart';
import 'package:joelfindtechnician/models/postcustomer_model.dart';
import 'package:joelfindtechnician/models/replypost_model.dart';
import 'package:joelfindtechnician/models/user_model_old.dart';
import 'package:joelfindtechnician/state/model.dart';
import 'package:joelfindtechnician/state/show_circleavatar.dart';
import 'package:joelfindtechnician/state/show_image_post.dart';
import 'package:joelfindtechnician/utility/find_token.dart';
import 'package:joelfindtechnician/utility/find_user_by_uid.dart';
import 'package:joelfindtechnician/utility/my_constant.dart';
import 'package:joelfindtechnician/utility/process_sent_noti_by_token.dart';
import 'package:joelfindtechnician/widgets/show_image.dart';
import 'package:joelfindtechnician/widgets/show_image_network.dart';
import 'package:joelfindtechnician/widgets/show_progress.dart';
import 'package:joelfindtechnician/widgets/show_text.dart';

class FormContactPartner extends StatefulWidget {
  final PostCustomerModel? postCustomerModel;
  final UserModelOld userModelOld;
  final String docIdPostCustomer;
  const FormContactPartner({
    Key? key,
    required this.postCustomerModel,
    required this.userModelOld,
    required this.docIdPostCustomer,
  }) : super(key: key);

  @override
  _FormContactPartnerState createState() => _FormContactPartnerState();
}

class _FormContactPartnerState extends State<FormContactPartner> {
  DateTime? date;
  TimeOfDay? time;

  File? image;
  String? imgUrl;

  PostCustomerModel? postCustomerModel;

  UserModelOld? userModelOld;

  String? customerName, phoneNumber, emailAddress;
  Timestamp? timeStamp;
  String? docIdCustomer;
  bool load = true;

  var listAnswerModels = <List<AnswerModel>>[];

  var replypostModels = <ReplyPostModel>[];

  var user = FirebaseAuth.instance.currentUser;

  final _formKey = GlobalKey<FormState>();

  String getTime() {
    if (time == null) {
      return 'Appointment Time';
    } else {
      final hours = time!.hour.toString().padLeft(2, '0');
      final minutes = time!.minute.toString().padLeft(2, '0');

      return '$hours:$minutes';
    }
  }

  String getDate() {
    if (date == null) {
      return 'Appointment Date';
    } else {
      return '${date!.day}/${date!.month}/${date!.year}';
    }
  }

  Future pickDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2023),
    );
    if (newDate == null) return;

    setState(() {
      date = newDate;
    });
  }

  Future pickTime(BuildContext context) async {
    final initialTime = TimeOfDay(hour: 9, minute: 0);
    final newTime = await showTimePicker(
      context: context,
      initialTime: time ?? initialTime,
    );

    if (newTime == null) return;

    setState(() {
      time = newTime;
    });
  }

  @override
  void initState() {
    super.initState();
    userModelOld = widget.userModelOld;
    postCustomerModel = widget.postCustomerModel;
    docIdCustomer = widget.docIdPostCustomer;
    readData();
  }

  Future<void> readData() async {
    if (replypostModels.isNotEmpty) {
      replypostModels.clear();
      listAnswerModels.clear();
    }

    await FirebaseFirestore.instance
        .collection('postcustomer')
        .doc(docIdCustomer)
        .collection('replypost')
        .orderBy('timeReply', descending: true)
        .get()
        .then((value) async {
      for (var item in value.docs) {
        ReplyPostModel replyPostModel = ReplyPostModel.fromMap(item.data());
        setState(() {
          load = false;
        });
        if (userModelOld!.uid == replyPostModel.uid) {
          var answerModels = <AnswerModel>[];

          await FirebaseFirestore.instance
              .collection('postcustomer')
              .doc(docIdCustomer)
              .collection('replypost')
              .doc(item.id)
              .collection('answer')
              .get()
              .then((value) {
            for (var item in value.docs) {
              AnswerModel answerModel = AnswerModel.fromMap(item.data());
              answerModels.add(answerModel);
            }
          });

          setState(() {
            replypostModels.add(replyPostModel);
            listAnswerModels.add(answerModels);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: newAppBar(context),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 18),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  newName(),
                  SizedBox(height: 10),
                  newPhone(),
                  SizedBox(height: 10),
                  newEmail(),
                  SizedBox(height: 10),
                  postCustomerModel == null ? SizedBox() : newAddress(),
                  SizedBox(height: 15),
                  postCustomerModel == null ? SizedBox() : newLocation(),
                  SizedBox(height: 15),
                  newAppointment(context),
                  newWhoPost(),
                  Divider(),
                  newJobPost(),
                  Divider(),
                  load
                      ? ShowProgress()
                      : replypostModels.isEmpty
                          ? SizedBox()
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              itemCount: replypostModels.length,
                              itemBuilder: (context, index) => Column(
                                children: [
                                  Row(
                                    children: [
                                      ShowCircleAvatar(
                                          url:
                                              replypostModels[index].pathImage),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ShowText(
                                            title: replypostModels[index].name,
                                          ),
                                          ShowText(
                                              title:
                                                  replypostModels[index].reply),
                                        ],
                                      ),
                                    ],
                                  ),
                                  ShowImageNetWork(
                                    urlPath:
                                        replypostModels[index].urlImagePost,
                                    tapFunc: () {
                                      print('Image Reply');
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ShowImagePost(
                                                pathImage:
                                                    replypostModels[index]
                                                        .urlImagePost),
                                          ));
                                    },
                                  ),
                                  listAnswerModels[index].isEmpty
                                      ? SizedBox()
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics: ScrollPhysics(),
                                          itemCount:
                                              listAnswerModels[index].length,
                                          itemBuilder: (context, index2) =>
                                              Column(
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 32,
                                                  ),
                                                  ShowCircleAvatar(
                                                      url: listAnswerModels[
                                                              index][index2]
                                                          .urlPost),
                                                  Column(
                                                    children: [
                                                      ShowText(
                                                          title:
                                                              listAnswerModels[
                                                                          index]
                                                                      [index2]
                                                                  .namePost),
                                                      ShowText(
                                                          title:
                                                              listAnswerModels[
                                                                          index]
                                                                      [index2]
                                                                  .answer),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              ShowImageNetWork(
                                                urlPath: listAnswerModels[index]
                                                        [index2]
                                                    .urlImage,
                                                tapFunc: () {
                                                  print('image answer');
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ShowImagePost(
                                                                pathImage: listAnswerModels[
                                                                            index]
                                                                        [index2]
                                                                    .urlImage),
                                                      ));
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                  SizedBox(
                                    height: 36,
                                  ),
                                ],
                              ),
                            ),
                  buttonSentForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row newJobPost() {
    return Row(
      children: [
        ShowText(title: postCustomerModel!.job),
      ],
    );
  }

  Row newWhoPost() {
    return Row(
      children: [
        ShowCircleAvatar(url: postCustomerModel!.pathUrl),
        ShowText(
          title: postCustomerModel!.name,
          textStyle: MyConstant().h2Style(),
        ),
      ],
    );
  }

  Container buttonSentForm() {
    return Container(
      height: 50,
      width: 330,
      child: FlatButton(
        textColor: Colors.white,
        color: Colors.blueAccent,
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            print(
                'name = $customerName, phone = $phoneNumber, email = $emailAddress');

            if (date == null) {
              MyDialog().normalDialog(
                  context, 'Appoint Date ?', 'Please Choose Appoint Date');
            } else if (time == null) {
              MyDialog().normalDialog(
                  context, 'Appoint Time ?', 'Please Choose Appoint Time');
            } else {
              DateTime appointDateTime = DateTime(
                  date!.year, date!.month, date!.day, time!.hour, time!.minute);
              print('date ==> $appointDateTime');

              timeStamp = Timestamp.fromDate(appointDateTime);

              String token = await FindToken().processFindToken();

              AppointmentModel appointmentModel = AppointmentModel(
                approve: 'unread',
                avatarSocial: user!.photoURL ?? '',
                customerName: customerName!,
                docIdPostcustomer: docIdCustomer!,
                emailAddress: emailAddress!,
                nameSocial: user!.displayName ?? '',
                phoneNumber: phoneNumber!,
                timeAppointment: timeStamp!,
                tokenSocial: token,
                uidSocial: user!.uid,
                timeContact: Timestamp.fromDate(DateTime.now()),
               
              );

             
             

              var docUser =
                  await FindUserByUid(uid: userModelOld!.uid).getDocUser();

              var tokenTechnicial = await FindToken()
                  .processFindTokenByDocUser(docUser: docUser!);

              await FirebaseFirestore.instance
                  .collection('user')
                  .doc(docUser)
                  .collection('appointment')
                  .doc()
                  .set(appointmentModel.toMap())
                  .then((value) async {
                print('Set Success ==> ');
                ProcessSentNotiByToken(
                        token: tokenTechnicial!,
                        title: postCustomerModel!.job,
                        body: 'Contact @ From $customerName')
                    .sentNoti()
                    .then((value) => Navigator.pop(context));
              });
            }
          }
        },
        child: Text(
          'Sent foam to technician',
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Row newAppointment(BuildContext context) {
    return Row(
      children: [
        FlatButton.icon(
          onPressed: () {
            pickDate(context);
          },
          icon: Icon(
            Icons.date_range_outlined,
            size: 30,
            color: Colors.orange,
          ),
          label: Text(getDate()),
        ),
        FlatButton.icon(
          padding: EdgeInsets.only(right: 10),
          onPressed: () {
            pickTime(context);
          },
          icon: Icon(
            Icons.watch_later_outlined,
            size: 30,
            color: Colors.orange,
          ),
          label: Text(getTime()),
        ),
      ],
    );
  }

  Row newLocation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ShowText(
          title: postCustomerModel!.district,
          textStyle: MyConstant().h2Style(),
        ),
        ShowText(
          title: postCustomerModel!.amphur,
          textStyle: MyConstant().h2Style(),
        ),
        ShowText(
          title: postCustomerModel!.province,
          textStyle: MyConstant().h2Style(),
        ),
      ],
    );
  }

  Widget newAddress() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShowText(
              title: 'Address',
              textStyle: MyConstant().h2Style(),
            ),
            ShowText(
              title: postCustomerModel!.address,
            ),
          ],
        ),
      ],
    );
  }

  TextFormField newEmail() {
    return TextFormField(
      onSaved: (newValue) => emailAddress = newValue!.trim(),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please type your email address';
        } else {
          return null;
        }
      },
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email Address',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  TextFormField newPhone() {
    return TextFormField(
      onSaved: (newValue) => phoneNumber = newValue!.trim(),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please type your phone number';
        } else {
          return null;
        }
      },
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  TextFormField newName() {
    return TextFormField(
      onSaved: (newValue) => customerName = newValue!.trim(),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please type your name';
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        labelText: 'Customer Name',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
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
      title: Text('Foam contact technician'),
    );
  }
}
