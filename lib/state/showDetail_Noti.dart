import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:joelfindtechnician/models/answer_model.dart';
import 'package:joelfindtechnician/models/notification_model.dart';
import 'package:joelfindtechnician/models/postcustomer_model.dart';
import 'package:joelfindtechnician/models/replypost_model.dart';
import 'package:joelfindtechnician/models/user_model_old.dart';
import 'package:joelfindtechnician/state/show_circleavatar.dart';
import 'package:joelfindtechnician/state/show_general_profile.dart';
import 'package:joelfindtechnician/state/show_image_post.dart';
import 'package:joelfindtechnician/state/show_profile.dart';
import 'package:joelfindtechnician/utility/check_user_social.dart';
import 'package:joelfindtechnician/utility/process_sent_noti_by_token.dart';
import 'package:joelfindtechnician/utility/time_to_string.dart';
import 'package:joelfindtechnician/widgets/show_image.dart';
import 'package:joelfindtechnician/widgets/show_progress.dart';
import 'package:joelfindtechnician/widgets/show_text.dart';

class ShowDetailNoti extends StatefulWidget {
  final String title, message;
  final UserModelOld userModelOld;

  const ShowDetailNoti({
    Key? key,
    required this.userModelOld,
    required this.title,
    required this.message,
  }) : super(key: key);

  @override
  _ShowDetailNotiState createState() => _ShowDetailNotiState();
}

class _ShowDetailNotiState extends State<ShowDetailNoti> {
  String? title, message;
  List<PostCustomerModel> postCustomerModels = [];
  bool load = true;
  UserModelOld? userModelOld;
  File? file;
  bool showAddPhotoReplyPost = false; // true show Icon
  TextEditingController textEditingController = TextEditingController();

  String? docIdReply;

  List<ReplyPostModel> replyPostModels = [];
  String? docIdUser, docIdMyNotification;
  List<String> docIdNotifications = [];
  List<bool> showAnswerTextFields = [];
  List<bool> showIconSentAnswers = [];
  List<List<AnswerModel>> listAnswerModels = [];
  List<String> docIdReplyPosts = [];
  List<List<String>> listDocIdAnswers = [];
  List<File?> fileAnswers = [];
  List<TextEditingController> answerControllers = [];

  var permissionAnswers = <bool>[];

  @override
  void initState() {
    super.initState();
    title = widget.title;
    message = widget.message;

    userModelOld = widget.userModelOld;
    print(
        '#28Nov ค่าที่ได้จากคลิก Noti ที่ ShowDetailNoti ==>> $title, $message');
    readDataNotifiction();
  }

  processTakePhoto(ImageSource source) async {
    try {
      var result = await ImagePicker()
          .pickImage(source: source, maxWidth: 800, maxHeight: 800);

      setState(() {
        file = File(result!.path);
      });
    } catch (e) {}
  }

  processTakePhotoAnswer(ImageSource source, int index) async {
    try {
      var result = await ImagePicker()
          .getImage(source: source, maxWidth: 800, maxHeight: 800);
      setState(() {
        fileAnswers[index] = File(result!.path);
      });
    } catch (e) {}
  }

  Future<void> readDataNotifiction() async {
    if (postCustomerModels.isNotEmpty) {
      setState(() {
        load = true;
      });
      postCustomerModels.clear();
      replyPostModels.clear();
      showAddPhotoReplyPost = false;
      file = null;
      fileAnswers.clear();
      docIdNotifications.clear();
      listAnswerModels.clear();
      docIdReplyPosts.clear();
      listDocIdAnswers.clear();
      showIconSentAnswers.clear();
      showAnswerTextFields.clear();
      answerControllers.clear();
      permissionAnswers.clear();
    }

    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('user')
          .where('uid', isEqualTo: userModelOld!.uid)
          .get()
          .then((value) async {
        for (var item in value.docs) {
          docIdUser = item.id;
        }
      });
    });

    // For ReadPost on Postcustomer

    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('postcustomer')
          .where('job', isEqualTo: message)
          .get()
          .then((value) async {
        for (var item in value.docs) {
          docIdReply = item.id;

          PostCustomerModel model = PostCustomerModel.fromMap(item.data());

          await FirebaseFirestore.instance
              .collection('user')
              .doc(docIdUser)
              .collection('mynotification')
              .where('message', isEqualTo: message)
              .get()
              .then((value) async {
            for (var item in value.docs) {
              docIdMyNotification = item.id;
              print('@4Dec docIdMyNotification ==>> $docIdMyNotification');

              NotificationModel notificationModel =
                  NotificationModel.fromMap(item.data());
              if (notificationModel.status == 'unread') {
                Map<String, dynamic> map = {};
                map['status'] = 'read';
                await FirebaseFirestore.instance
                    .collection('user')
                    .doc(docIdUser)
                    .collection('mynotification')
                    .doc(docIdMyNotification)
                    .update(map)
                    .then((value) {
                  print('@4Dec Update Success');
                });
              }
            }
          });

          await FirebaseFirestore.instance
              .collection('postcustomer')
              .doc(docIdReply)
              .collection('replypost')
              .orderBy('timeReply', descending: true)
              .get()
              .then((value) async {
            print('@4Dec value ==>> ${value.docs}');

            if (value.docs.isNotEmpty) {
              for (var item in value.docs) {
                showIconSentAnswers.add(false);
                showAnswerTextFields.add(false);
                fileAnswers.add(null);
                answerControllers.add(TextEditingController());
                String docIdReplyPost2 = item.id;

                List<AnswerModel> answerModels = [];
                List<String> docIdAnswers = [];

                await FirebaseFirestore.instance
                    .collection('postcustomer')
                    .doc(docIdReply)
                    .collection('replypost')
                    .doc(docIdReplyPost2)
                    .collection('answer')
                    .orderBy('timePost', descending: false)
                    .get()
                    .then((value) {
                  if (value.docs.isNotEmpty) {
                    for (var item in value.docs) {
                      AnswerModel answerModel =
                          AnswerModel.fromMap(item.data());
                      answerModels.add(answerModel);
                      docIdAnswers.add(item.id);
                    }
                  }
                });

                ReplyPostModel replyPostModel =
                    ReplyPostModel.fromMap(item.data());

                if (replyPostModel.status == 'online') {
                  setState(() {
                    replyPostModels.add(replyPostModel);
                    docIdNotifications.add(item.id);
                    listAnswerModels.add(answerModels);
                    docIdReplyPosts.add(docIdReplyPost2);
                    listDocIdAnswers.add(docIdAnswers);
                    permissionAnswers
                        .add(userModelOld!.uid == replyPostModel.uid);
                  });
                }
              }
            }
          });

          setState(() {
            load = false;
            postCustomerModels.add(model);
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ShowDetail Noti'),
      ),
      body: load
          ? ShowProgress()
          : GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              behavior: HitTestBehavior.opaque,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    newName(),
                    ShowText(title: postCustomerModels[0].job),
                    Divider(thickness: 2),
                    newProvince(),
                    Divider(thickness: 2),
                    newReply(context),
                    file == null
                        ? SizedBox()
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 64),
                                width: 230,
                                height: 200,
                                child: Image.file(
                                  file!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    file = null;
                                  });
                                },
                                icon: Icon(Icons.clear),
                              ),
                            ],
                          ),
                    replyPostModels.isEmpty ? SizedBox() : listReplyPost(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget listReplyPost() {
    return ListView.builder(
      physics: ScrollPhysics(),
      shrinkWrap: true,
      itemCount: replyPostModels.length,
      itemBuilder: (context, index) => Row(
        children: [
          Container(
              margin: EdgeInsets.only(left: 80, bottom: 4),
              child: newContent(index, context)),
        ],
      ),
    );
  }

  Widget newContent(int index, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
                onTap: () {
                  processMove(replyPostModels[index].uid);
                },
                child: ShowCircleAvatar(url: replyPostModels[index].pathImage)),
            Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              width: 180,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShowText(title: replyPostModels[index].name),
                  ShowText(
                      title: TimeToString(
                              timestamp: replyPostModels[index].timeReply)
                          .findString()),
                  ShowText(title: replyPostModels[index].reply),
                ],
              ),
            ),
            userModelOld!.uid != replyPostModels[index].uid
                ? SizedBox()
                : IconButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: ListTile(
                            leading: ShowImage(),
                            title: ShowText(
                              title: 'Confirm Delete ?',
                            ),
                            subtitle: ShowText(
                              title: 'คุณต้องการจะลบ ?',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                Map<String, dynamic> map = {};
                                map['status'] = 'offline';

                                print('##4Dec map => $map');
                                print(
                                    '##4Dec docIdNoti = ${docIdNotifications[index]}');

                                await FirebaseFirestore.instance
                                    .collection('postcustomer')
                                    .doc(docIdReply)
                                    .collection('replypost')
                                    .doc(docIdNotifications[index])
                                    .update(map)
                                    .then((value) => readDataNotifiction());
                              },
                              child: Text('ok'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('No'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.delete,
                    ),
                  ),
          ],
        ), // answer Row
        replyPostModels[index].urlImagePost.isEmpty
            ? SizedBox()
            : Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                width: 150,
                height: 120,
                child: InkWell(
                  onTap: () {
                    print('Click');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowImagePost(
                                  pathImage:
                                      replyPostModels[index].urlImagePost,
                                )));
                  },
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => ShowImage(),
                    placeholder: (context, url) => ShowProgress(),
                    imageUrl: replyPostModels[index].urlImagePost,
                  ),
                ),
              ),
        listAnswerModels[index].isEmpty
            ? SizedBox()
            : newListAnswer(listAnswerModels[index], docIdReplyPosts[index]),

        permissionAnswers[index]
            ? TextButton(
                onPressed: () {
                  setState(() {
                    showAnswerTextFields[index] = true;
                  });
                },
                child: Text(
                  'ตอบกลับ',
                ),
              )
            : SizedBox(),
        showAnswerTextFields[index]
            ? Row(
                children: [
                  SizedBox(
                    width: 30,
                  ),
                  InkWell(
                      onTap: () => processMove(userModelOld!.uid),
                      child: ShowCircleAvatar(url: userModelOld!.img)),
                  Container(
                    height: 50,
                    width: 150,
                    child: TextFormField(
                      controller: answerControllers[index],
                      onChanged: (value) {
                        if (value.isEmpty) {
                          setState(() {
                            showIconSentAnswers[index] = false;
                          });
                        } else {
                          setState(() {
                            showIconSentAnswers[index] = true;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        suffix: IconButton(
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: ListTile(
                                    leading: ShowImage(),
                                    title: ShowText(
                                      title: 'Take Photo Answer',
                                    ),
                                    subtitle: ShowText(
                                        title: 'Please Choose your photo'),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        processTakePhotoAnswer(
                                            ImageSource.camera, index);
                                      },
                                      child: Text(
                                        'Camera',
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        processTakePhotoAnswer(
                                            ImageSource.gallery, index);
                                      },
                                      child: Text(
                                        'Gallery',
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Cancel',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: Icon(Icons.add_a_photo)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  ((showIconSentAnswers[index]) || (fileAnswers[index] != null))
                      ? IconButton(
                          onPressed: () async {
                            if (fileAnswers[index] == null) {
                              // No Image Upload
                              processInsertNewAnswer(
                                  answerControllers[index].text, '', index);
                            } else {
                              String nameImage =
                                  'answer/${Random().nextInt(10000000)}.jpg';
                              FirebaseStorage storage =
                                  FirebaseStorage.instance;
                              Reference reference =
                                  storage.ref().child('answer/$nameImage');
                              UploadTask uploadTask =
                                  reference.putFile(fileAnswers[index]!);
                              await uploadTask.whenComplete(() async {
                                await reference.getDownloadURL().then((value) {
                                  String urlImage = value;
                                  processInsertNewAnswer(
                                      answerControllers[index].text,
                                      urlImage,
                                      index);
                                });
                              });
                            }
                          },
                          icon: Icon(Icons.send),
                        )
                      : SizedBox(),
                ],
              )
            : SizedBox(),
        fileAnswers[index] == null
            ? SizedBox()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      left: 100,
                    ),
                    width: 120,
                    height: 100,
                    child: Image.file(
                      fileAnswers[index]!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        fileAnswers[index] = null;
                      });
                    },
                    icon: Icon(Icons.clear),
                  ),
                ],
              ),
      ],
    );
  }

  Widget newListAnswer(List<AnswerModel> answerModels, String docIdReplyPost) {
    List<Widget> widgets = [];

    for (var model in answerModels) {
      if (model.status == 'online') {
        widgets.add(
          Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 30),
                  InkWell(
                      onTap: () => processMove(model.uidPost),
                      child: ShowCircleAvatar(url: model.urlPost)),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShowText(title: model.namePost),
                        ShowText(
                          title: TimeToString(timestamp: model.timePost)
                              .findString(),
                        ),
                        ShowText(
                          title: model.answer,
                        )
                      ],
                    ),
                  ),
                  userModelOld!.name == model.namePost
                      ? IconButton(
                          onPressed: () async {
                            print(
                                '#5Dec ==> delete at doc ==> $docIdReplyPost');
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: ListTile(
                                  leading: ShowImage(),
                                  title: ShowText(
                                    title: 'Confirm Delete',
                                  ),
                                  subtitle: ShowText(
                                    title: 'Delete ${model.answer} ?',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      print('docCustomer ==> $docIdReply');
                                      await FirebaseFirestore.instance
                                          .collection('postcustomer')
                                          .doc(docIdReply)
                                          .collection('replypost')
                                          .doc(docIdReplyPost)
                                          .collection('answer')
                                          .where('answer',
                                              isEqualTo: model.answer)
                                          .get()
                                          .then((value) async {
                                        for (var item in value.docs) {
                                          String docIdAnswer = item.id;
                                          print(
                                              'delete t doc ==>> $docIdAnswer');

                                          Map<String, dynamic> data = {};
                                          data['status'] = 'offline';

                                          await FirebaseFirestore.instance
                                              .collection('postcustomer')
                                              .doc(docIdReply)
                                              .collection('replypost')
                                              .doc(docIdReplyPost)
                                              .collection('answer')
                                              .doc(docIdAnswer)
                                              .update(data)
                                              .then((value) =>
                                                  readDataNotifiction());
                                        }
                                      });
                                    },
                                    child: Text('Delete'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(Icons.delete_forever),
                        )
                      : SizedBox(),
                ],
              ),
              model.urlImage.isEmpty
                  ? SizedBox()
                  : Container(
                      width: 100,
                      height: 80,
                      child: InkWell(
                        onTap: () {
                          print('Click');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ShowImagePost(
                                      pathImage: model.urlImage)));
                        },
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: model.urlImage,
                          placeholder: (context, url) => ShowProgress(),
                          errorWidget: (context, url, error) => ShowImage(),
                        ),
                      ),
                    ),
            ],
          ),
        );
      }
    }
    return Column(
      children: widgets,
    );
  }

  Row newProvince() {
    return Row(
      children: [
        Icon(Icons.location_on),
        ShowText(title: postCustomerModels[0].district),
        SizedBox(width: 8),
        Icon(Icons.location_on),
        ShowText(title: postCustomerModels[0].amphur),
        SizedBox(width: 8),
        Icon(Icons.location_on),
        ShowText(title: postCustomerModels[0].province),
      ],
    );
  }

  Widget newReply(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16),
      child: Row(
        children: [
          InkWell(
              onTap: () => processMove(userModelOld!.uid),
              child: ShowCircleAvatar(url: userModelOld!.img)),
          Container(
            width: 200,
            height: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextFormField(
                controller: textEditingController,
                onChanged: (value) {
                  showAddPhotoReplyPost = true;
                  setState(() {
                    if (value.isEmpty) {
                      showAddPhotoReplyPost = false;
                    }
                  });
                },
                decoration: InputDecoration(
                  suffix: IconButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: ListTile(
                            leading: ShowImage(),
                            title: ShowText(title: 'Choose Image'),
                            subtitle: ShowText(title: 'Please Choose Image'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                processTakePhoto(ImageSource.camera);
                              },
                              child: Text('Camera'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                processTakePhoto(ImageSource.gallery);
                              },
                              child: Text('Gallery'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.camera_alt_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
          ((showAddPhotoReplyPost) || (file != null))
              ? IconButton(
                  onPressed: () async {
                    if (file == null) {
                      processInsertPostCustomer('');
                    } else {
                      await Firebase.initializeApp().then((value) async {
                        String nameImage = 'reply${Random(100000000)}.jpg';
                        FirebaseStorage storage = FirebaseStorage.instance;
                        Reference reference =
                            storage.ref().child('replypost/$nameImage');
                        UploadTask task = reference.putFile(file!);
                        await task.whenComplete(() async {
                          await reference.getDownloadURL().then((value) {
                            processInsertPostCustomer(value);
                          });
                        });
                      });
                    }
                  },
                  icon: Icon(Icons.send))
              : SizedBox(),
        ],
      ),
    );
  }

  Row newName() {
    return Row(
      children: [
        newCircleAvatar(postCustomerModels[0].pathUrl),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShowText(
              title: postCustomerModels[0].name,
            ),
            ShowText(
              title: TimeToString(timestamp: postCustomerModels[0].timePost)
                  .findString(),
            ),
          ],
        ),
      ],
    );
  }

  Container newCircleAvatar(String url) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      width: 48,
      height: 48,
      child: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(url),
      ),
    );
  }

  Future<void> processInsertPostCustomer(String urlImagePost) async {
    String token = postCustomerModels[0].token;
    // print('#16mar processInsertPostCustomer Work token Owner Post ==> $token');

    String name = userModelOld!.name;
    String pathImage = userModelOld!.img;
    String reply = textEditingController.text;

    DateTime dateTime = DateTime.now();
    Timestamp timeReply = Timestamp.fromDate(dateTime);

    String uid = userModelOld!.uid;
    String status = 'online';

    ReplyPostModel model = ReplyPostModel(
        name: name,
        pathImage: pathImage,
        reply: reply,
        timeReply: timeReply,
        uid: uid,
        urlImagePost: urlImagePost,
        status: status);

    String titleNoti = 'Answer from ${userModelOld!.name}';
    String bodyNoti = model.reply;
    bodyNoti = 'reply@$bodyNoti';

    String apiSentNotification =
        'https://www.androidthai.in.th/eye/apiNotification.php?isAdd=true&token=$token&title=$titleNoti&body=$bodyNoti';

    await Dio().get(apiSentNotification).then((value) async {
      await Firebase.initializeApp().then((value) async {
        await FirebaseFirestore.instance
            .collection('postcustomer')
            .doc(docIdReply)
            .collection('replypost')
            .doc()
            .set(model.toMap())
            .then((value) {
          print('#28Nov Insert Reply Success');
          textEditingController.text = '';
          file = null;
          readDataNotifiction();
        });
      });
    }).catchError((onError) {
      print('#16mar onError ==>> ${onError.toString()}');
    });
  }

  Future<void> processInsertNewAnswer(
      String answer, String urlImage, int index) async {
    AnswerModel answerModel = AnswerModel(
        answer: answer,
        namePost: userModelOld!.name,
        urlPost: userModelOld!.img,
        urlImage: urlImage,
        timePost: Timestamp.fromDate(DateTime.now()),
        status: 'online',
        uidPost: userModelOld!.uid);

    print('docPostCustomer ==> $docIdReply');
    print('docReplyPost ==>> ${docIdReplyPosts[index]}');

    await FirebaseFirestore.instance
        .collection('postcustomer')
        .doc(docIdReply)
        .collection('replypost')
        .doc(docIdNotifications[index])
        .collection('answer')
        .doc()
        .set(answerModel.toMap())
        .then((value) {
      // required sent notification
      String tokenSocialPost = postCustomerModels[0].token;
      String titile = 'Have New Messge';
      String body = answer;

      ProcessSentNotiByToken(token: tokenSocialPost, title: titile, body: body)
          .sentNoti();

      readDataNotifiction();
    });
  }

  Future<void> processMove(String uidAvatar) async {
    print('#23jan uidAvatar ==>> $uidAvatar');

    var result =
        await CheckUserSocial(uidChecked: uidAvatar).processCheckUserSocial();
    print('#23jan uidAvatar ==>> $uidAvatar === result ==> $result');

    if (!result) {
      if (uidAvatar == userModelOld!.uid) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ShowProfile()));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ShowGeneralProfile(
                      uidTechnic: uidAvatar,
                      showContact: false,
                    )));
      }
    }
  }
}
