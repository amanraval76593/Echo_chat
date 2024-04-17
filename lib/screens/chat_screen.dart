import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:echo_chat/helper/format_time.dart';
import 'package:echo_chat/main.dart';
import 'package:echo_chat/models/chat_user.dart';
import 'package:echo_chat/screens/view_proile_screen.dart';
import 'package:echo_chat/widgtes/message_Card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../models/message.dart';

// ignore: must_be_immutable
final textcontroller = TextEditingController();

class ChatScreen extends StatefulWidget {
  ChatUser user;
  ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  bool _showEmoji = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ViewProfile(chatUser: widget.user);
            }));
          },
          child: StreamBuilder(
              stream: Apis.getUserInfo(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                var list = [];
                if (data != null) {
                  list = data!.map((e) => ChatUser.fromJson(e.data())).toList();
                }
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .03),
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        height: mq.height * .050,
                        width: mq.height * .050,
                        imageUrl:
                            list.isNotEmpty ? list[0].image : widget.user.image,
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
                              fontSize: mq.height * .02,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: mq.width * .005,
                        ),
                        Text(
                          list.isNotEmpty
                              ? list[0].isOnline
                                  ? "online"
                                  : "Last active at ${FormatTime.getFormatSentTime(context: context, time: list[0].lastActive)}"
                              : "Last active at ${FormatTime.getFormatSentTime(context: context, time: widget.user.lastActive)}",
                          style: TextStyle(fontSize: mq.height * .015),
                        ),
                      ],
                    )
                  ],
                );
              }),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          if (_showEmoji == true) {
            setState(() {
              _showEmoji = false;
            });
          }
        },
        child: Padding(
          padding: EdgeInsets.only(bottom: mq.height * .03),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: Apis.getMessage(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs.reversed;
                        _list = data!
                            .map((e) => Message.fromJson(e.data()))
                            .toList();
                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              reverse: true,
                              dragStartBehavior: DragStartBehavior.down,
                              physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.only(
                                top: mq.height * .01,
                              ),
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
              _showEmoji == true
                  ? SizedBox(
                      height: mq.height * .35,
                      child: EmojiPicker(
                        textEditingController: textcontroller,
                        config: Config(
                          checkPlatformCompatibility: true,
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
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
                  onPressed: () {
                    setState(() {
                      _showEmoji = !_showEmoji;
                      FocusScope.of(context).unfocus();
                    });
                  },
                  icon: Icon(
                    Icons.emoji_emotions,
                    size: 30,
                    color: Colors.blueAccent,
                  ),
                ),
                Expanded(
                    child: TextField(
                  onTap: () {
                    setState(() {
                      if (_showEmoji == true) {
                        _showEmoji = false;
                      }
                    });
                  },
                  controller: textcontroller,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Type Your message..."),
                )),
                IconButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final List<XFile> images = await picker.pickMultiImage();
                    if (images != null) {
                      for (var image in images) {
                        Apis.sendImageChat(widget.user, File(image.path));
                      }
                    }
                  },
                  icon: Icon(
                    Icons.image,
                    size: 35,
                    color: Colors.blueAccent,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.camera, imageQuality: 70);
                    if (image != null) {
                      print(image.path);

                      Apis.sendImageChat(widget.user, File(image.path));
                    }
                  },
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
              onPressed: () {
                // ignore: unnecessary_null_comparison
                if (textcontroller.text != '') {
                  Apis.sendMessage(widget.user, textcontroller.text, Type.text);
                  textcontroller.text = '';
                }
              },
              icon: Icon(
                Icons.send,
                size: 28,
                color: Colors.blueAccent,
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
}
