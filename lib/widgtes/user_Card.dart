// ignore_for_file: must_be_immutable

import 'package:echo_chat/api/apis.dart';
import 'package:echo_chat/helper/format_time.dart';
import 'package:echo_chat/main.dart';
import 'package:echo_chat/models/chat_user.dart';
import 'package:echo_chat/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/message.dart';

class UserCard extends StatefulWidget {
  ChatUser user;
  UserCard({super.key, required this.user});

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  Message? _message;
  var _list = [];
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .02, vertical: 4),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
              stream: Apis.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                if (data != null) {
                  _list = data!.map((e) => Message.fromJson(e.data())).toList();

                  if (_list.isNotEmpty && widget.user.id != _message?.fromId) {
                    _message = _list[0];
                  }
                }

                return ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .3),
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        height: mq.height * .055,
                        width: mq.height * .055,
                        imageUrl: widget.user.image,
                        // placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => CircleAvatar(
                          child: Icon(CupertinoIcons.person),
                        ),
                      ),
                    ),
                    title: Text(widget.user.name),
                    subtitle: _message != null
                        ? _message!.type == Type.text
                            ? Text(_message!.msg)
                            : Row(
                                children: [
                                  Icon(Icons.image),
                                  SizedBox(
                                    width: mq.width * .01,
                                  ),
                                  Text("Photo"),
                                ],
                              )
                        : Text(widget.user.about),
                    trailing: _message == null
                        ? null
                        : _message!.read.isEmpty &&
                                _message!.fromId != Apis.user.uid
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.shade200,
                                ),
                                height: 15,
                                width: 15,
                              )
                            : Text(FormatTime.getFormatSentTime(
                                context: context, time: _message!.sent)));
              })),
    );
  }
}
//  CircleAvatar(
//             child: Icon(CupertinoIcons.person),
//           ),