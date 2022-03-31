// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:joelfindtechnician/models/postcustomer_model.dart';
import 'package:joelfindtechnician/models/social_my_notification.dart';

class CustomerNotiModel {
  final String title;
  final Timestamp timestamp;
  final bool navigatorBool;
  final PostCustomerModel? postCustomerModel;
  final SocialMyNotificationModel? socialMyNotificationModel;
  final bool fontWeight;
  final String? docIdPostCustomer;
  final String? customerName;

  CustomerNotiModel({
    required this.title,
    required this.timestamp,
    required this.navigatorBool,
    this.postCustomerModel,
    this.socialMyNotificationModel,
    required this.fontWeight,
    this.docIdPostCustomer,
    this.customerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'timestamp': timestamp,
      'navigatorBool': navigatorBool,
      'postCustomerModel': postCustomerModel?.toMap(),
      'socialMyNotificationModel': socialMyNotificationModel?.toMap(),
      'fontWeight': fontWeight,
      'docIdPostCustomer': docIdPostCustomer,
      'customerName': customerName,
    };
  }

  factory CustomerNotiModel.fromMap(Map<String, dynamic> map) {
    return CustomerNotiModel(
      title: map['title'] ?? '',
      timestamp: (map['timestamp']),
      navigatorBool: map['navigatorBool'] ?? false,
      postCustomerModel: map['postCustomerModel'] != null ? PostCustomerModel.fromMap(map['postCustomerModel']) : null,
      socialMyNotificationModel: map['socialMyNotificationModel'] != null ? SocialMyNotificationModel.fromMap(map['socialMyNotificationModel']) : null,
      fontWeight: map['fontWeight'] ?? false,
      docIdPostCustomer: map['docIdPostCustomer'],
      customerName: map['customerName'],
    );
  }

  factory CustomerNotiModel.fromJson(String source) => CustomerNotiModel.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}
