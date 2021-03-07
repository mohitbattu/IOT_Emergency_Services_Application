import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:telephony/telephony.dart';
import 'dart:async';
import 'package:intl/intl.dart';

Future<void> gmailMessage(List<File> filing) async {
  String email = "mscrsai123@gmail.com";
  String password = 'Muppicharan@1';
  List<File> writing = filing;
  final smtpServer = gmail(email, password);
  String time =
      DateFormat('EEE,d MMM , yyyy').format(DateTime.now()).toString();
  var message = Message()
    ..from = Address(email, 'Sai Charan')
    ..ccRecipients.addAll(['mohitbattu2010@gmail.com', '190180170s@gmail.com'])
    ..subject = "Emergency Help Me"
    ..text = 'Hey this is Sai charan Please help me I am in danger mode.' +
        '\n' +
        '$time';
  message..attachments.add(FileAttachment(writing[0]));
  await Future.delayed(Duration(seconds: 10));
  message..attachments.add(FileAttachment(writing[1]));
  await Future.delayed(Duration(seconds: 10));
  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}

Future<void> sendingSMS(String message, String recipents) async {
  final Telephony telephony = Telephony.instance;
  bool permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
  print(permissionsGranted);
  telephony.sendSms(to: recipents, message: message);
}
