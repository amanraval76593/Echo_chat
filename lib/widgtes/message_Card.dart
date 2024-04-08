import 'package:echo_chat/api/apis.dart';
import 'package:echo_chat/helper/format_time.dart';
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
        ? _greenfield()
        : _bluefield();
  }

  Widget _bluefield() {
    if (widget.message.read.isEmpty) {
      Apis().updateReadStatus(widget.message);
    }
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
            FormatTime.getFormatTime(
                context: context, time: widget.message.sent),
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
                color:
                    widget.message.read.isNotEmpty ? Colors.blue : Colors.grey,
              ),
              SizedBox(
                width: mq.width * .01,
              ),
              Text(
                FormatTime.getFormatTime(
                    context: context, time: widget.message.sent),
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
