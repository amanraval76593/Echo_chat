import 'package:echo_chat/api/apis.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return Apis.user.uid == widget.message.fromId
        ? _bluefield()
        : _greenfield();
  }

  Widget _bluefield() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.lightBlue),
                color: Color.fromARGB(255, 210, 227, 242),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.width * .04),
            padding: EdgeInsets.all(mq.width * .04),
            child: Text(
              widget.message.msg,
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: mq.width * .04, horizontal: mq.width * .07),
          child: Text(
            "12:25 PM",
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
        )
      ],
    );
  }

  Widget _greenfield() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: mq.width * .04, horizontal: mq.width * .07),
          child: Row(
            children: [
              Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
              ),
              SizedBox(
                width: mq.width * .01,
              ),
              Text(
                widget.message.read + "12:00 AM",
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.lightGreen),
                color: Color.fromARGB(255, 194, 239, 196),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20))),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.width * .04),
            padding: EdgeInsets.all(mq.width * .04),
            child: Text(
              widget.message.msg,
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }
}
