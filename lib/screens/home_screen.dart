import 'package:echo_chat/main.dart';
import 'package:echo_chat/models/chat_user.dart';
import 'package:echo_chat/screens/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                onPressed: () {},
                child: Icon(Icons.add_comment_rounded),
              ),
            ),
            body: StreamBuilder(
              stream: Apis.getAllUser(),
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
                    list =
                        data!.map((e) => ChatUser.fromJson(e.data())).toList();

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
            )),
      ),
    );
  }
}
