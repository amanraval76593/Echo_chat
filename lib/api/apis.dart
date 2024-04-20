//import 'dart:html';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:echo_chat/models/chat_user.dart';
import 'package:echo_chat/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

class Apis {
  static late ChatUser me;
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static User get user => auth.currentUser!;
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> getPushToken() async {
    await messaging.requestPermission();
    await messaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        print("push token : $t");
      }
    });
  }

  static Future<void> sendPushNotification(
      ChatUser chatuser, String message) async {
    try {
      final body = {
        "to": chatuser.pushToken,
        "notification": {"title": chatuser.name, "body": message}
      };
      var response = await post(
          Uri.parse(
              'https://fcm.googleapis.com/v1/projects/echo-chat-ef901/messages:send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer AAAANqM_IdY:APA91bHhY4ieQryAtLXgiE4nEtnE-BxkNSXRqCHq3pQmBAffSy7uctymQXp9g94H_gRn48mEfk7xqSTKdPVp4gpodogmixHwoFr3WQ1o77M-VwmVy-83ButZYxIWVDcUKkTmj_RGpn-o'
          },
          body: jsonEncode(body));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print("Following error was found during sending notification : $e");
    }
  }

  Future<bool> userExist() async {
    return (await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  Future<bool> AddUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      return false;
    }
  }

  Future<void> getSelfInfo() async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((user) {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        getPushToken();
      } else {
        createUser().then((value) {
          getSelfInfo();
        });
      }
    });
  }

  Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        about: "New message",
        name: user.displayName.toString(),
        createdAt: time,
        lastActive: time,
        isOnline: false,
        id: user.uid,
        email: user.email.toString(),
        pushToken: time);

    return (await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson()));
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(
      List<String> userId) {
    return firestore
        .collection('users')
        .where('id', whereIn: userId.isEmpty ? [''] : userId)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  static Future<void> sendFirstMessage(
      ChatUser chatuser, String message, Type type) async {
    await firestore
        .collection('users')
        .doc(chatuser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatuser, message, type));
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_${id}'
      : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMessage(
      ChatUser chatuser) {
    return firestore
        .collection('chat/${getConversationID(chatuser.id)}/message')
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser chatuser) {
    return firestore
        .collection('chat/${getConversationID(chatuser.id)}/message')
        .limit(1)
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUser chatuser, String msg, Type type) async {
    String time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message message = Message(
        msg: msg,
        toId: chatuser.id,
        read: "",
        type: type,
        sent: time,
        fromId: user.uid);
    final ref =
        firestore.collection('chat/${getConversationID(chatuser.id)}/message');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatuser, type == Type.text ? msg : "image"));
  }

  Future<void> updateUserInfo() async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'name': me.name, 'about': me.about});
  }

  Future<void> updateReadStatus(Message message) async {
    firestore
        .collection('chat/${getConversationID(message.fromId)}/message')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  Future<void> updateMessage(Message message, String newMessage) async {
    firestore
        .collection('chat/${getConversationID(message.toId)}/message')
        .doc(message.sent)
        .update(
      {'msg': newMessage},
    );
  }

  Future<void> DeleteMessage(Message message) async {
    firestore
        .collection('chat/${getConversationID(message.toId)}/message')
        .doc(message.sent)
        .delete();

    await storage.refFromURL(message.msg).delete();
  }

  static Future<void> updateProfilePic(File file) async {
    final ext = file.path.split(".").last;
    final ref = storage.ref().child("profile_image/${user.uid}.$ext");
    print("extension : $ext");
    await ref
        .putFile(file, SettableMetadata(contentType: "image/$ext"))
        .then((p0) {
      print("Data transferred : ${p0.bytesTransferred / 1000} kb");
    });
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'image': me.image});
  }

  static Future<void> sendImageChat(ChatUser chatUser, File file) async {
    final ext = file.path.split(".").last;
    final ref = storage.ref().child(
        "images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext");
    print("extension : $ext");
    await ref
        .putFile(file, SettableMetadata(contentType: "image/$ext"))
        .then((p0) {
      print("Data transferred : ${p0.bytesTransferred / 1000} kb");
    });
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }
}
