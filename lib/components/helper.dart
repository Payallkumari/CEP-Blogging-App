import 'package:cloud_firestore/cloud_firestore.dart';

String formateDate(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
}
