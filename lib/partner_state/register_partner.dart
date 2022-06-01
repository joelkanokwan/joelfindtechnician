import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joelfindtechnician/alertdialog/alert_detail.dart';
import 'package:joelfindtechnician/alertdialog/my_dialog.dart';
import 'package:joelfindtechnician/model.dart';
import 'package:joelfindtechnician/models/subdistruct_model.dart';
import 'package:joelfindtechnician/models/typetechnic_model.dart';
import 'package:joelfindtechnician/models/user_model_old.dart';
import 'package:joelfindtechnician/partner_state/partner_signin.dart';
import 'package:joelfindtechnician/widgets/show_image.dart';
import 'package:joelfindtechnician/widgets/show_text.dart';

class RegisterPartner extends StatefulWidget {
  @override
  _RegisterPartnerState createState() => _RegisterPartnerState();
}

class _RegisterPartnerState extends State<RegisterPartner> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController idCardlController = TextEditingController();
  TextEditingController phonenumberlController = TextEditingController();
  TextEditingController jobtypeController = TextEditingController();
  TextEditingController jobscopeController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController nameOfBankController = TextEditingController();
  TextEditingController ownerAccountController = TextEditingController();
  TextEditingController branchController = TextEditingController();
  int? indexProvince;
  List<String> provinces = [
    'เชียงใหม่',
    'กรุงเทพ',
    'ชลบุรี',
  ];

  int? _selectChoice;

  String? province, amphur, subdistrict, typetechnic;
  bool amphurbool = true;
  bool subdistrictbool = true;

  int? province_id;
  List<AmphurModel> amphurModels = [];
  List<SubDistrictModel> subdistrictModel = [];

  List<TypeTechnicModel> typetechnicModels = [];

  List<Widget> widgets = [];
  List<bool> typetechnicBool = [];

  List<String> typeTechnicStrings = [];

  File? file;

  @override
  void initState() {
    super.initState();
    readAllType();
  }

  processTakePhoto(ImageSource source) async {
    try {
      var result = await ImagePicker()
          .getImage(source: source, maxWidth: 800, maxHeight: 800);
      setState(() {
        file = File(result!.path);
      });
    } catch (e) {}
  }

  Future<void> readAllType() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('typetechnic')
          .get()
          .then((value) {
        int index = 0;
        for (var item in value.docs) {
          TypeTechnicModel model = TypeTechnicModel.fromMap(item.data());
          setState(() {
            typetechnicModels.add(model);
            typetechnicBool.add(false);
            widgets.add(creatWidget(model, index));
          });
          index++;
        }
      });
    });
  }

  Widget creatWidget(TypeTechnicModel model, int index) => CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(model.name),
        value: typetechnicBool[index],
        onChanged: (value) {
          setState(() {
            typetechnicBool[index] = !typetechnicBool[index];
            print('### typetechnicBool ==> $typetechnicBool');
          });
        },
      );

  Future<Null> normalDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Column(
            children: [
              Row(
                children: [
                  Radio(
                    activeColor: Colors.amber,
                    value: 0,
                    groupValue: indexProvince,
                    onChanged: (value) {
                      setState(() {
                        indexProvince = 0;
                      });
                    },
                  ),
                  SizedBox(width: 10),
                  Text(
                    provinces[0],
                  ),
                ],
              ),
              Row(
                children: [
                  Radio(
                    activeColor: Colors.amber,
                    value: 1,
                    groupValue: indexProvince,
                    onChanged: (value) {
                      setState(() {
                        indexProvince = 1;
                      });
                    },
                  ),
                  SizedBox(width: 10),
                  Text(
                    provinces[1],
                  ),
                ],
              ),
              Row(
                children: [
                  Radio(
                    activeColor: Colors.amber,
                    value: 2,
                    groupValue: indexProvince,
                    onChanged: (value) {
                      setState(() {
                        indexProvince = 2;
                      });
                    },
                  ),
                  SizedBox(width: 10),
                  Text(
                    provinces[2],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  print('indexProvince ==> $indexProvince');
                });
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> checkNameAndAddData() async {
    await Firebase.initializeApp().then((value) async {
      print('Initial Success');
      await FirebaseFirestore.instance
          .collection('user')
          .where('name', isEqualTo: nameController.text)
          .get()
          .then((event) async {
        print('event ==> ${event.docs}');
        if (event.docs.length == 0) {
          print('ชื่อร้านไม่ซ้ำ');
          UserModelOld userModelFirebase = UserModelOld(
            email: emailController.text,
            uid: '',
            name: nameController.text,
            phoneNumber: phonenumberlController.text,
            jobType: jobtypeController.text,
            jobScope: jobscopeController.text,
            address: addressController.text,
            accept: false,
            about: '',
            img: '',
            province: province!,
            amphure: amphur!,
            district: subdistrict!,
            typeTechnics: typeTechnicStrings,
          );
          await FirebaseFirestore.instance
              .collection('user')
              .doc()
              .set(userModelFirebase.toMap())
              .then((value) {
            print('Insert Data Success');
          });
        } else {
          print('ชื่อร้านซ้ำ');
          MyDialog()
              .normalDialog(context, 'ชื่อร้านซ้ำ', 'เปลี่ยนชื่อร้านใหม่');
        }
      });
    });
  }

  // void insertValueToSheet() {
  // RegisterFoam registerFoam = RegisterFoam(
  // nameController.text,
  //
  // phonenumberlController.text,
  // jobtypeController.text,
  // jobscopeController.text,
  // addressController.text,
  // emailController.text,
  // );
  // FormController formController = FormController();
  // showDialog(
  // context: context,
  // builder: (context) => SuccessRegister(
  // title: "",
  // discription: "",
  // buttonText: "",
  // ),
  // );
  // _formKey.currentState!.reset();
  // _showSnackbar("");
  // formController.submitForm(registerFoam, (String response) {
  // print("Response: $response");
  // if (response == FormController.STATUS_SUCCESS) {
  // _showSnackbar("Submitted");
  // } else {
  // _showSnackbar("Error Occurred!");
  // }
  // });
  // }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if ((province?.isEmpty ?? true) ||
          (amphur?.isEmpty ?? true) ||
          (subdistrict?.isEmpty ?? true)) {
        MyDialog().normalDialog(context, 'ที่อยู่ไม่ครบ', '');
      } else {
        if (checkChooseTypeTechnic()) {
          checkNameAndAddData();
        } else {
          MyDialog().normalDialog(context, 'โปรดเลือกชนิดของงาน', '');
        }
      }
    }
  }

  bool checkChooseTypeTechnic() {
    bool result = false; // false => ยังไม่มีการเลือกประเภทของงาน
    int index = 0;
    typeTechnicStrings.clear();
    for (var item in typetechnicBool) {
      if (item) {
        result = true;
        typeTechnicStrings.add(typetechnicModels[index].name);
      }

      index++;
    }

    print('### typeTechnicString ==> $typeTechnicStrings');
    return result;
  }

  _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState!.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 50, horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'ข้อมูลส่วนบุคคล',
                  ),

                  buildName(),
                  buildIdCard(),
                  buildPhone(),
                  buildEmail(),
                  buildScope(),
                  buildAddress(),
                  // buildOldProvince(context),
                  province == null
                      ? buildProvince()
                      : Text('จังหวัด ${province!}'),
                  amphurbool
                      ? SizedBox()
                      : amphur == null
                          ? buildAmphur()
                          : Text('อำเภอ ${amphur!}'),
                  subdistrictbool
                      ? SizedBox()
                      : subdistrict == null
                          ? buildSubDistrict()
                          : Text('ตำบล ${subdistrict!}'),

                  buildJobType(context),
                  SizedBox(height: 20),
                  Text('ข้อมูลการโอนเงิน'),
                  Text('ธนาคารไทยพาณิชย์'),

                  buildOwnerAccount(),
                  buildAccountNumber(),

                  ElevatedButton(
                    onPressed: () {
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
                    child: Text('Browse'),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 50,
                    width: 330,
                    child: FlatButton(
                      textColor: Colors.white,
                      color: Colors.blueAccent,
                      child: Text(
                        'ตกลง',
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _submitForm,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Container(
                    child: TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDetail(
                            title: "",
                            discription: "",
                            buttonText: "",
                          ),
                        );
                      },
                      child: Text(
                        'สนใจร่วมเป็นพาร์ทเนอร์ต้องทำยังไง ?',
                        style: GoogleFonts.lato(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
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

  DropdownButton<String> buildProvince() {
    return DropdownButton<String>(
      hint: Text('โปรดเลือกจังหวัด'),
      onChanged: (value) {
        setState(() {
          if (amphurModels.isNotEmpty) {
            amphurModels.clear();
            amphur = null;
            subdistrictModel.clear();
            subdistrictbool = true;
          }
          province = value;

          switch (province) {
            case 'เชียงใหม่':
              province_id = 38;
              findAmphur();

              break;
            case 'กรุงเทพ':
              province_id = 1;
              findAmphur();
              break;
            case 'ชลบุรี':
              province_id = 11;
              findAmphur();
              break;
            default:
          }
        });
      },
      value: province,
      items: provinces
          .map(
            (e) => DropdownMenuItem<String>(
              child: Text(e),
              value: e,
            ),
          )
          .toList(),
    );
  }

  Future<void> findAmphur() async {
    print('### province_id = $province_id');
    String apiAmphur =
        'https://www.androidthai.in.th/eye/Amphur.php?isAdd=true&province_id=$province_id';
    await Dio().get(apiAmphur).then((value) {
      for (var item in json.decode(value.data)) {
        AmphurModel model = AmphurModel.fromMap(item);
        // print('### amphure ==>> ${model.name_th}');

        setState(() {
          amphurModels.add(model);
          amphurbool = false;
        });
      }
      // print('### value amphur == $value');
    });
  }

  DropdownButton<String> buildAmphur() {
    return DropdownButton<String>(
      hint: Text('โปรดเลือกอำเภอ'),
      onChanged: (value) {
        setState(() {
          if (subdistrictModel.isNotEmpty) {
            subdistrictModel.clear();
            subdistrictbool = true;
          }

          amphur = value;
          subdistrictbool = false;
          findSubDistrict(amphur!);
        });
      },
      value: amphur,
      items: amphurModels
          .map(
            (e) => DropdownMenuItem<String>(
              child: Text(e.name_th),
              value: e.name_th,
            ),
          )
          .toList(),
    );
  }

  Future<void> findSubDistrict(String nameAmphure) async {
    String amphure_id = '';
    for (var item in amphurModels) {
      if (nameAmphure == item.name_th) {
        amphure_id = item.id;
      }
    }

    print('### amphur_id ==>> $amphure_id');

    String apiSubDisTrict =
        'https://www.androidthai.in.th/eye/getDistriceByAmphure.php?isAdd=true&amphure_id=$amphure_id';
    await Dio().get(apiSubDisTrict).then((value) {
      for (var item in json.decode(value.data)) {
        SubDistrictModel model = SubDistrictModel.fromMap(item);
        setState(() {
          subdistrictModel.add(model);
        });
      }
    });
  }

  DropdownButton<String> buildSubDistrict() {
    return DropdownButton<String>(
      hint: Text('โปรดเลือกตำบล'),
      onChanged: (value) {
        setState(() {
          subdistrict = value;
        });
      },
      value: subdistrict,
      items: subdistrictModel
          .map(
            (e) => DropdownMenuItem<String>(
              child: Text(e.name_th),
              value: e.name_th,
            ),
          )
          .toList(),
    );
  }

  Widget buildJobType(BuildContext context) {
    return Column(
      children: [
        ShowText(
          title: 'ประเภทของงาน',
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemCount: typetechnicModels.length,
          itemBuilder: (context, index) => CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(typetechnicModels[index].name),
            value: typetechnicBool[index],
            onChanged: (value) {
              setState(() {
                typetechnicBool[index] = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Row buildOldProvince(BuildContext context) {
    return Row(
      children: [
        Container(
          child: FlatButton.icon(
            onPressed: () {
              normalDialog(context);
            },
            icon: Icon(
              Icons.location_on_outlined,
              color: Colors.orange,
            ),
            label: Text(
              indexProvince == null ? 'จังหวัด' : provinces[indexProvince!],
              style: GoogleFonts.lato(fontSize: 15),
            ),
          ),
        ),
        Container(
          child: FlatButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.location_on_outlined,
              color: Colors.orange,
            ),
            label: Text(
              'อำเภอ',
              style: GoogleFonts.lato(fontSize: 15),
            ),
          ),
        ),
        Container(
          child: FlatButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.location_on_outlined,
              color: Colors.orange,
            ),
            label: Text(
              'ตำบล',
              style: GoogleFonts.lato(fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  TextFormField buildAddress() {
    return TextFormField(
      controller: addressController,
      validator: (value) {
        if (value!.isEmpty) {
          return 'กรุณาระบุที่อยู่ปัจจุบัน';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "ที่อยู่ปัจจุบัน/ที่ตั้งบริษัท",
        labelStyle: GoogleFonts.lato(
          color: Colors.grey,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  TextFormField buildNameOfBank() {
    return TextFormField(
      controller: nameOfBankController,
      validator: (value) {
        if (value!.isEmpty) {
          return 'กรุณาระบุชื่อธนาคาร';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "ชื่อธนาคาร",
        labelStyle: GoogleFonts.lato(
          color: Colors.grey,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  TextFormField buildOwnerAccount() {
    return TextFormField(
      controller: ownerAccountController,
      validator: (value) {
        if (value!.isEmpty) {
          return 'กรุณาระบุชื่อเจ้าของบัญชี';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "ชื่อเจ้าของบัญชี",
        labelStyle: GoogleFonts.lato(
          color: Colors.grey,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  TextFormField buildbranch() {
    return TextFormField(
      controller: branchController,
      validator: (value) {
        if (value!.isEmpty) {
          return 'กรุณาระบุสาขา';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "สาขา",
        labelStyle: GoogleFonts.lato(
          color: Colors.grey,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  TextFormField buildAccountNumber() {
    return TextFormField(
      maxLength: 10,
      controller: accountNumberController,
      validator: (value) {
        if (value!.trim().length != 10) {
          return 'กรุณาระบุหมายเลขบัญชีธนาคาร';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "หมายเลขบัญชีธนาคาร",
        labelStyle: GoogleFonts.lato(
          color: Colors.grey,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }

  TextFormField buildScope() {
    return TextFormField(
      controller: jobscopeController,
      validator: (value) {
        if (value!.isEmpty) {
          return 'กรุณาระบุขอบเขตการทำงาน';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "ขอบเขตการทำงาน",
        labelStyle: GoogleFonts.lato(
          color: Colors.grey,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  TextFormField buildEmail() {
    return TextFormField(
      controller: emailController,
      validator: (value) {
        if (value!.isEmpty) {
          return 'กรุณาระบุอีเมล์';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "อีเมล์",
        labelStyle: GoogleFonts.lato(
          color: Colors.grey,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  TextFormField buildIdCard() {
    return TextFormField(
      maxLength: 13,
      controller: idCardlController,
      validator: (value) {
        if (value!.trim().length != 13) {
          return 'กรุณาระบุหมายเลขบัตรให้ถูกต้อง';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "หมายเลขบัตรประจำตัวประชาชน/หมายเลขประจำตัวผู้เสียภาษี",
        labelStyle: GoogleFonts.lato(
          color: Colors.grey,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }

  TextFormField buildPhone() {
    return TextFormField(
      maxLength: 10,
      controller: phonenumberlController,
      validator: (value) {
        if (value!.trim().length != 10) {
          return 'กรุณาระบุหมายเลขโทรศัพท์ให้ถูกต้อง';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "หมายเลขโทรศัพท์",
        labelStyle: GoogleFonts.lato(
          color: Colors.grey,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }

  TextFormField buildName() {
    return TextFormField(
      controller: nameController,
      validator: (value) {
        if (value!.isEmpty) {
          return 'กรุณาระบุชื่อสกุล/บริษัท';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "ชื่อสกุล/บริษัท",
        labelStyle: GoogleFonts.lato(
          color: Colors.grey,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => PartnerSignin(),
          ));
        },
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
      ),
      title: Text(
        "ลงทะเบียนพาร์ทเนอร์",
        style: GoogleFonts.lato(
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> jobtypeDialog() async {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('โปรดเลือกประเภทของงาน'),
          actions: [],
          content: GestureDetector(
            onTap: () {
              setState() {}
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widgets,
            ),
          ),
        ),
      ),
    );
  }
}
