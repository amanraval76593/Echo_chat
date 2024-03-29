import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:echo_chat/main.dart';
import 'package:echo_chat/models/chat_user.dart';
import 'package:echo_chat/widgtes/message_Card.dart';
import 'package:flutter/material.dart';

import '../api/apis.dart';
import '../models/message.dart';

// ignore: must_be_immutable
class ChatScreen extends StatefulWidget {
  ChatUser user;
  ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: InkWell(
          onTap: () {},
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .03),
                child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  height: mq.height * .050,
                  width: mq.height * .050,
                  imageUrl: widget.user.image,
                ),
              ),
              SizedBox(
                width: mq.width * .05,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name,
                    style: TextStyle(
                        fontSize: mq.height * .02, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: mq.width * .005,
                  ),
                  Text(
                    "Last active at 11:00 pm",
                    style: TextStyle(fontSize: mq.height * .015),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: mq.height * .03),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: StreamBuilder(
                stream: Apis.getMessage(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      print("data : ${jsonEncode(data?[0].data())}");
                      // list =
                      //     data!.map((e) => ChatUser.fromJson(e.data())).toList();
                      _list.clear();
                      _list.add(Message(
                          msg: "Hii",
                          toId: "",
                          read: "",
                          type: Type.text,
                          sent: "",
                          fromId: Apis.user.uid));
                      _list.add(Message(
                          msg: "Hello",
                          toId: "xyz",
                          read: "",
                          type: Type.text,
                          sent: "",
                          fromId: "xyz"));
                      if (_list.isNotEmpty) {
                        return ListView.builder(
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.only(top: mq.height * .01),
                            itemCount: _list.length,
                            itemBuilder: (context, index) {
                              return MessageCard(message: _list[index]);
                            });
                      } else {
                        return Center(
                            child: Text(
                          "Say Hii 👋 ",
                          style: TextStyle(fontSize: 20),
                        ));
                      }
                  }
                },
              ),
            ),
            _BottomTextField(),
          ],
        ),
      ),
    );
  }
}

Widget _BottomTextField() {
  return Row(
    children: [
      Expanded(
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.emoji_emotions,
                  size: 30,
                  color: Colors.blueAccent,
                ),
              ),
              Expanded(
                  child: TextField(
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: "Type Your message..."),
              )),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.image,
                  size: 35,
                  color: Colors.blueAccent,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.camera_alt,
                  size: 35,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        width: 10,
      ),
      CircleAvatar(
        radius: 25,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 3, 8, 5),
          child: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.send,
              size: 28,
              color: Colors.white,
            ),
          ),
        ),
      ),
      SizedBox(
        width: mq.width * .02,
      )
    ],
  );
}
