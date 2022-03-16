import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joelfindtechnician/models/answer_model.dart';
import 'package:joelfindtechnician/models/postcustomer_model.dart';
import 'package:joelfindtechnician/models/replypost_model.dart';
import 'package:joelfindtechnician/models/token_social_model.dart';
import 'package:joelfindtechnician/state/show_circleavatar.dart';
import 'package:joelfindtechnician/state/show_general_profile.dart';
import 'package:joelfindtechnician/state/show_image_post.dart';
import 'package:joelfindtechnician/state/show_profile.dart';
import 'package:joelfindtechnician/utility/check_user_social.dart';
import 'package:joelfindtechnician/utility/time_to_string.dart';
import 'package:joelfindtechnician/widgets/show_image.dart';
import 'package:joelfindtechnician/widgets/show_progress.dart';
import 'package:joelfindtechnician/widgets/show_text.dart';

class DetailNotiSocial extends StatefulWidget {
  final String reply;
  const DetailNotiSocial({Key? key, required this.reply}) : super(key: key);

  @override
  _DetailNotiSocialState createState() => _DetailNotiSocialState();
}

class _DetailNotiSocialState extends State<DetailNotiSocial> {
  String? reply;
  bool load = true;
  File? file;

  String? currentDocIdPostCustomer;

  PostCustomerModel? currentPostCustomerModel;
  TokenSocialModel? tokenSocialModel;
  var user = FirebaseAuth.instance.currentUser;

  TextEditingController textEditingController = TextEditingController();
  bool showAddPhotoReplyPost = false; // true show Icon
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
    reply = widget.reply;
    print('#16mar job ==> $reply');
    readPostCustomer();
  }

  Future<void> readPostCustomer() async {
    if (replyPostModels.isNotEmpty) {
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
          .collection('social')
          .doc(user!.uid)
          .get()
          .then((value) {
        tokenSocialModel = TokenSocialModel.fromMap(value.data()!);
      });

      await FirebaseFirestore.instance
          .collection('postcustomer')
          .get()
          .then((value) async {
        load = false;
        for (var item in value.docs) {
          String docIdPostCustomer = item.id;

          PostCustomerModel postCustomerModel =
              PostCustomerModel.fromMap(item.data());

          await FirebaseFirestore.instance
              .collection('postcustomer')
              .doc(docIdPostCustomer)
              .collection('replypost')
              .get()
              .then((value) async {
            if (value.docs.isNotEmpty) {
              await FirebaseFirestore.instance
                  .collection('postcustomer')
                  .doc(docIdPostCustomer)
                  .collection('replypost')
                  .where('reply', isEqualTo: reply)
                  .get()
                  .then((value) async{
                for (var item in value.docs) {
                  currentDocIdPostCustomer = item.id;
                  currentPostCustomerModel = postCustomerModel;

                  showIconSentAnswers.add(false);
                  showAnswerTextFields.add(false);
                  fileAnswers.add(null);
                  answerControllers.add(TextEditingController());

                  ReplyPostModel replyPostModel =
                      ReplyPostModel.fromMap(item.data());
                  replyPostModels.add(replyPostModel);

                      await FirebaseFirestore.instance
        .collection('postcustomer')
        .doc(currentDocIdPostCustomer)
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

                }
              });
            }
          });
        }
        setState(() {});
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
                    ShowText(title: currentPostCustomerModel!.job),
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
  } // build

  Row newName() {
    return Row(
      children: [
        ShowCircleAvatar(url: currentPostCustomerModel!.pathUrl),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShowText(
              title: currentPostCustomerModel!.name,
            ),
            ShowText(
              title: TimeToString(timestamp: currentPostCustomerModel!.timePost)
                  .findString(),
            ),
          ],
        ),
      ],
    );
  }

  Row newProvince() {
    return Row(
      children: [
        Icon(Icons.location_on),
        ShowText(title: currentPostCustomerModel!.district),
        SizedBox(width: 8),
        Icon(Icons.location_on),
        ShowText(title: currentPostCustomerModel!.amphur),
        SizedBox(width: 8),
        Icon(Icons.location_on),
        ShowText(title: currentPostCustomerModel!.province),
      ],
    );
  }

  Widget newReply(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16),
      child: Row(
        children: [
          InkWell(
              onTap: () => processMove(user!.uid),
              child: ShowCircleAvatar(url: tokenSocialModel!.avatarSocial)),
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

  Future<void> processMove(String uidAvatar) async {
    print('#23jan uidAvatar ==>> $uidAvatar');
    var result =
        await CheckUserSocial(uidChecked: uidAvatar).processCheckUserSocial();
    print('#23jan uidAvatar ==>> $uidAvatar === result ==> $result');
    if (!result) {
      if (uidAvatar == currentPostCustomerModel!.uidCustomer) {
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

  processTakePhoto(ImageSource source) async {
    try {
      var result = await ImagePicker()
          .pickImage(source: source, maxWidth: 800, maxHeight: 800);
      setState(() {
        file = File(result!.path);
      });
    } catch (e) {}
  }

  Future<void> processInsertPostCustomer(String urlImagePost) async {
    String token = currentPostCustomerModel!.token;
    // print('#16mar processInsertPostCustomer Work token Owner Post ==> $token');
    String name = tokenSocialModel!.nameSocial;
    String pathImage = tokenSocialModel!.avatarSocial;
    String reply = textEditingController.text;
    DateTime dateTime = DateTime.now();
    Timestamp timeReply = Timestamp.fromDate(dateTime);
    String uid = user!.uid;
    String status = 'online';
    ReplyPostModel model = ReplyPostModel(
        name: name,
        pathImage: pathImage,
        reply: reply,
        timeReply: timeReply,
        uid: uid,
        urlImagePost: urlImagePost,
        status: status);
    String titleNoti = 'Answer from ${tokenSocialModel!.nameSocial}';
    String bodyNoti = model.reply;
    bodyNoti = 'reply@$bodyNoti';
    String apiSentNotification =
        'https://www.androidthai.in.th/eye/apiNotification.php?isAdd=true&token=$token&title=$titleNoti&body=$bodyNoti';
    await Dio().get(apiSentNotification).then((value) async {
      await Firebase.initializeApp().then((value) async {
        await FirebaseFirestore.instance
            .collection('postcustomer')
            .doc(currentDocIdPostCustomer)
            .collection('replypost')
            .doc()
            .set(model.toMap())
            .then((value) {
          print('#28Nov Insert Reply Success');
          textEditingController.text = '';
          file = null;
          readPostCustomer();
        });
      });
    }).catchError((onError) {
      print('#16mar onError ==>> ${onError.toString()}');
    });
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
            user!.uid != replyPostModels[index].uid
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
                                // Navigator.pop(context);
                                // Map<String, dynamic> map = {};
                                // map['status'] = 'offline';

                                // await FirebaseFirestore.instance
                                // .collection('postcustomer')
                                // .doc(docIdReply)
                                // .collection('replypost')
                                // .doc(docIdNotifications[index])
                                // .update(map)
                                // .then((value) => readDataNotifiction());
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
}
