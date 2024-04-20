import 'package:echo_chat/helper/dialogs.dart';
import 'package:echo_chat/main.dart';
import 'package:echo_chat/models/chat_user.dart';
import 'package:echo_chat/screens/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/apis.dart';
import '../widgtes/user_Card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _issearching = false;
  List<ChatUser> list = [];
  final List<ChatUser> _searchList = [];
  @override
  void initState() {
    Apis().getSelfInfo();
    Apis.updateActiveStatus(true);

    SystemChannels.lifecycle.setMessageHandler((message) {
      if (message!.toString().contains('pause')) Apis.updateActiveStatus(false);
      if (message!.toString().contains('resume')) Apis.updateActiveStatus(true);
      return Future.value(message);
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: WillPopScope(
          onWillPop: () {
            if (_issearching) {
              setState(() {
                _issearching = !_issearching;
              });

              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: _issearching == false
                  ? Text("Echo Chat")
                  : TextField(
                      onChanged: (value) {
                        _searchList.clear();
                        for (var i in list) {
                          if (i.name
                              .toLowerCase()
                              .contains(value.toLowerCase())) {
                            setState(() {
                              _searchList.add(i);
                            });
                          }
                        }
                        setState(() {
                          _searchList;
                        });
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Name..",
                      ),
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      autofocus: true,
                    ),
              leading: Icon(CupertinoIcons.home),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _issearching = !_issearching;
                    });
                  },
                  icon: Icon(_issearching == false
                      ? Icons.search
                      : CupertinoIcons.clear_circled_solid),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                                  user: Apis.me,
                                )));
                  },
                  icon: Icon(Icons.more_vert),
                ),
              ],
            ),
            floatingActionButton: Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                onPressed: () {
                  addUserPanel();
                },
                child: Icon(Icons.add_comment_rounded),
              ),
            ),
            body: StreamBuilder(
                stream: Apis.getUsersId(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    case ConnectionState.active:
                    case ConnectionState.done:
                  }
                  return StreamBuilder(
                    stream: Apis.getAllUser(
                      snapshot.data?.docs.map((e) => e.id).toList() ?? [],
                    ),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        // return Center(
                        //   child: CircularProgressIndicator(),
                        // );
                        case ConnectionState.active:
                        case ConnectionState.done:
                          list = snapshot.data?.docs
                                  .map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (list.isNotEmpty) {
                            return ListView.builder(
                                physics: BouncingScrollPhysics(),
                                padding: EdgeInsets.only(top: mq.height * .01),
                                itemCount: _issearching == false
                                    ? list.length
                                    : _searchList.length,
                                itemBuilder: (context, index) {
                                  return UserCard(
                                    user: _issearching == false
                                        ? list[index]
                                        : _searchList[index],
                                  );
                                });
                          } else {
                            return Center(
                                child: Text(
                              "No Connection Found...",
                              style: TextStyle(fontSize: 20),
                            ));
                          }
                      }
                    },
                  );
                }),
          ),
        ));
  }

  void addUserPanel() {
    String email = "";
    final FocusNode _focusNode = FocusNode();
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
                child: Padding(
                  padding: EdgeInsets.only(
                      left: mq.width * .05, top: mq.width * .05),
                  child: Row(
                    children: [
                      Icon(Icons.person_add),
                      SizedBox(
                        width: mq.width * .05,
                      ),
                      Text(
                        "Add New Connection",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: mq.width * .07, vertical: mq.width * .025),
                child: TextFormField(
                  focusNode: _focusNode,
                  autofocus: true,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: Icon(Icons.email),
                  ),
                  onChanged: (value) {
                    email = value;
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
                      onPressed: () async {
                        await Apis().AddUser(email)
                            ? null
                            : Dialogs.showWarning(
                                context, "User Does not Exist");
                        print(email);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Add',
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
