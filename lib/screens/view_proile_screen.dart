import "package:cached_network_image/cached_network_image.dart";
import "package:echo_chat/helper/format_time.dart";
import "package:echo_chat/main.dart";
import "package:echo_chat/models/chat_user.dart";
import "package:flutter/material.dart";

class ViewProfile extends StatelessWidget {
  ChatUser chatUser;
  ViewProfile({super.key, required this.chatUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          chatUser.name,
          style: TextStyle(
              fontSize: mq.height * .025, fontWeight: FontWeight.w500),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: mq.width * .25, vertical: mq.height * .02),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * .1),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                height: mq.height * .19,
                width: mq.height * .2,
                imageUrl: chatUser.image,
              ),
            ),
            SizedBox(
              height: mq.height * .02,
            ),
            Text(
              "About : ${chatUser.about}",
              style: TextStyle(
                  fontSize: mq.height * .02, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: mq.height * .02,
            ),
            Text(
              "Email : ${chatUser.email}",
              style: TextStyle(
                  fontSize: mq.height * .015, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: mq.height * .02,
            ),
            Text(
              "Joined at ${FormatTime.getFormatSentTime(context: context, time: chatUser.createdAt)}",
              style: TextStyle(
                  fontSize: mq.height * .018, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
