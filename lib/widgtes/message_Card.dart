import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:echo_chat/api/apis.dart';
import 'package:echo_chat/helper/dialogs.dart';
import 'package:echo_chat/helper/format_time.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';


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
    bool isMe = Apis.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet();
      },
      child: isMe ? _greenfield() : _bluefield(),
    );
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
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .001),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,

                      imageUrl: widget.message.msg,
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
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
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .001),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,

                      imageUrl: widget.message.msg,
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet() {
    bool isMe = Apis.user.uid == widget.message.fromId;
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        context: context,
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .01, bottom: mq.height * .05),
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(color: Colors.grey),
              ),
              widget.message.type == Type.text
                  ? options(
                      icon: Icon(
                        Icons.copy,
                        size: mq.height * .03,
                      ),
                      optionText: 'Copy',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          Navigator.pop(context);
                          Dialogs.showWarning(context, 'Text Copied');
                        });
                      })
                  : options(
                      icon: Icon(
                        Icons.download,
                        size: mq.height * .03,
                      ),
                      optionText: 'Save',
                      onTap: () async {
                        try {
                          //log('Image Url: ${widget.message.msg}');
                          await GallerySaver.saveImage(widget.message.msg,
                                  albumName: 'We Chat')
                              .then((success) {
                            //for hiding bottom sheet
                            Navigator.pop(context);
                            if (success != null && success) {
                              Dialogs.showWarning(
                                  context, 'Image Successfully Saved!');
                            }
                          });
                        } catch (e) {
                         // log('ErrorWhileSavingImg: $e');
                        }
                      }),
              isMe
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
                      child: Divider(
                        color: Colors.grey.shade600,
                      ),
                    )
                  : SizedBox(),
              isMe
                  ? options(
                      icon: Icon(
                        Icons.delete,
                        size: mq.height * .03,
                      ),
                      optionText: 'Delete',
                      onTap: () {
                        Navigator.pop(context);
                        Apis().DeleteMessage(widget.message);
                      })
                  : SizedBox(),
              isMe
                  ? options(
                      icon: Icon(
                        Icons.edit,
                        size: mq.height * .03,
                      ),
                      optionText: 'Edit',
                      onTap: () {
                        Navigator.pop(context);
                        showEditPanel();
                      })
                  : SizedBox(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
                child: Divider(
                  color: Colors.grey.shade600,
                ),
              ),
              options(
                  icon: Icon(
                    Icons.send_rounded,
                    size: mq.height * .03,
                  ),
                  optionText:
                      'Sent at      ${FormatTime.getFormatSentTime(context: context, time: widget.message.sent)}',
                  onTap: () {}),
              isMe
                  ? SizedBox()
                  : options(
                      icon: Icon(
                        Icons.remove_red_eye,
                        size: mq.height * .03,
                      ),
                      optionText: widget.message.read.isEmpty
                          ? 'Read at         ---'
                          : 'Read at     ${FormatTime.getFormatSentTime(context: context, time: widget.message.read)}',
                      onTap: () {}),
            ],
          );
        });
  }

  void showEditPanel() {
    final FocusNode _focusNode = FocusNode();
    String newMessage = widget.message.msg;
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        context: context,
        builder: (_) {
          return ListView(
            padding: EdgeInsets.only(
                bottom:
                    _focusNode.hasFocus ? mq.height * .40 : mq.height * .01),
            shrinkWrap: true,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: mq.height * .0017,
                ),
                child: Center(
                  child: Text(
                    "Edit Message",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: mq.width * .07, vertical: mq.width * .025),
                child: TextFormField(
                  focusNode: _focusNode,
                  autofocus: true,
                  initialValue: newMessage,
                  style: TextStyle(fontSize: 18),
                  onChanged: (value) {
                    newMessage = value;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: mq.width * .02, vertical: mq.width * .02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: mq.height * .02),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Apis().updateMessage(widget.message, newMessage);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Send',
                        style: TextStyle(fontSize: mq.height * .02),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}

class options extends StatelessWidget {
  Icon icon;
  String optionText;
  var onTap;

  options(
      {super.key,
      required this.icon,
      required this.optionText,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        // color: Colors.grey,
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: mq.height * .015, horizontal: mq.width * .05),
          child: Row(
            children: [
              icon,
              SizedBox(
                width: mq.width * .1,
              ),
              Text(
                optionText,
                style: TextStyle(
                    fontSize: mq.width * .05, fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
