import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyConstant {
  static String publicKey = 'pkey_test_5nl5d96exz02lo5t02m';
  static String secretKey = 'skey_test_5nl5d96f6usasnwyid4';

 
 

  static List<Color> colors = [
    Colors.blue,
    Colors.yellow,
    Colors.pink,
    Colors.green,
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.pink,
    Colors.green,
    Colors.purple,
  ];

  static List<String> pathImageIcons = [
    'assets/images/aircon.png',
    'assets/images/electricity.png',
    'assets/images/toilet.png',
    'assets/images/aircon.png',
    'assets/images/electricity.png',
    'assets/images/toilet.png',
    'assets/images/aircon.png',
    'assets/images/electricity.png',
    'assets/images/toilet.png',
  ];

  static List<String> provinces = [
    'เชียงใหม่',
    'กรุงเทพ',
    'ชลบุรี',
  ];

  static List<String> adminEmails = ['iam@gmail.com', 'master@abc.com'];
  static String urlNoAvatar =
      'https://firebasestorage.googleapis.com/v0/b/joelfindtechnician.appspot.com/o/Images%2FiconMasterUng%202.png?alt=media&token=c8ccc4f4-7f4a-4957-8615-ee7cef548ef0';

  TextStyle h1Style() => TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
      );
  TextStyle h2Style() => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      );
  TextStyle h2StyleWhite() => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );
  TextStyle h4Style() => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );
}
