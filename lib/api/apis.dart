import 'dart:io';
import 'package:echo_chat/models/chat_user.dart';
import 'package:echo_chat/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Apis {
  static late ChatUser me;
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static User get user => auth.currentUser!;
  Future<bool> userExist() async {
    return (await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  Future<void> getSelfInfo() async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((user) {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
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

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
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
    await ref.doc(time).set(message.toJson());
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
