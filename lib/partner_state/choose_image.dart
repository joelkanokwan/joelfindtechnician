import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joelfindtechnician/alertdialog/my_dialog.dart';
import 'package:joelfindtechnician/models/reference_model.dart';
import 'package:joelfindtechnician/models/user_model_old.dart';

class ChooseImage extends StatefulWidget {
  final UserModelOld userModelOld;
  const ChooseImage({Key? key, required this.userModelOld}) : super(key: key);

  @override
  _ChooseImageState createState() => _ChooseImageState();
}

class _ChooseImageState extends State<ChooseImage> {
  File? image;
  String? imgUrl;

  UserModelOld? userModelOld;
  final formKey = GlobalKey<FormState>();
  TextEditingController descripController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userModelOld = widget.userModelOld;
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
        title: Text('Choose Image'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Center(
                        child: Text(
                          'Choose Profile Photo',
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            color: Colors.purpleAccent,
                          ),
                        ),
                      ),
                      content: SingleChildScrollView(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FlatButton.icon(
                              onPressed: () {
                                _imageFromCamera();
                                Navigator.of(context).pop();
                              },
                              icon: Icon(Icons.camera,
                                  color: Colors.purpleAccent),
                              label: Text('Camera'),
                            ),
                            FlatButton.icon(
                              onPressed: () {
                                _imageFromGallery();
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.image,
                                color: Colors.purpleAccent,
                              ),
                              label: Text('Gallery'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              icon: Icon(Icons.camera_alt_outlined),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  SizedBox(height: 30),
                  image == null
                      ? buildNoImage()
                      : Container(
                          height: 250,
                          child: Image.file(image!),
                        ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: descripController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please write description';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Descrub your image...',
                      hintStyle: GoogleFonts.lato(
                        fontSize: 20,
                      ),
                    ),
                    maxLength: 200,
                    maxLines: 3,
                  ),
                  SizedBox(height: 50),
                  Container(
                    height: 50,
                    width: 350,
                    child: FlatButton(
                      color: Colors.blue,
                      onPressed: () {
                        if (image == null) {
                          MyDialog().normalDialog(
                              context, 'No Image', 'Please choose your image');
                        } else if (formKey.currentState!.validate()) {
                          processUploadAndInsertData();
                        }
                      },
                      child: Text(
                        'Upload Image',
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container buildNoImage() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.amber,
      ),
    );
  }

  Future<void> processUploadAndInsertData() async {
    String nameImage = '${userModelOld!.uid}${Random().nextInt(1000000)}.jpg';
    await Firebase.initializeApp().then((value) async {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference reference = storage.ref().child('Ref/$nameImage');
      UploadTask task = reference.putFile(image!);
      await task.whenComplete(() async {
        await reference.getDownloadURL().then((value) async {
          String urlImage = value;
          // print('#### urlImage = $urlImage');

          String descrip = descripController.text;

          DateTime dateTime = DateTime.now();
          Timestamp timestamp = Timestamp.fromDate(dateTime);

          ReferenceModel model = ReferenceModel(
              datejob: timestamp, descrip: descrip, image: urlImage);

          await FirebaseFirestore.instance
              .collection('user')
              .where('uid', isEqualTo: userModelOld!.uid)
              .get()
              .then((value) async {
            for (var item in value.docs) {
              String docId = item.id;
              await FirebaseFirestore.instance
                  .collection('user')
                  .doc(docId)
                  .collection('referjob')
                  .doc()
                  .set(model.toMap())
                  .then((value) => Navigator.pop(context));
            }
          });
        });
      });
    });
  }
}
