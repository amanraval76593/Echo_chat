import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:echo_chat/helper/dialogs.dart';
import 'package:echo_chat/main.dart';
import 'package:echo_chat/models/chat_user.dart';
import 'package:echo_chat/screens/auth/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../api/apis.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formkey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profile Screen"),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            icon: Icon(Icons.logout),
            backgroundColor: Colors.red.shade400,
            label: Text("LOGOUT"),
            onPressed: () async {
              Apis.updateActiveStatus(false);
              Dialogs.ShowProgress(context);
              await Apis.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => LoginScreen()));
                });
              });
            },
          ),
        ),
        body: Form(
          key: _formkey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.height * .03),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: mq.height * .03,
                  ),
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: Image.file(
                                File(_image!),
                                fit: BoxFit.cover,
                                height: mq.height * .2,
                                width: mq.height * .2,
                              ),
                            )
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                height: mq.height * .2,
                                width: mq.height * .2,
                                imageUrl: widget.user.image,
                                // placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(
                                  child: Icon(CupertinoIcons.person),
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                          color: Colors.white,
                          shape: CircleBorder(),
                          onPressed: () async {
                            _showBottomSheet();
                          },
                          child: Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: mq.width * .03,
                  ),
                  Text(widget.user.email),
                  SizedBox(
                    height: mq.width * .1,
                  ),
                  TextFormField(
                    onSaved: (val) {
                      Apis.me.name = val ?? "";
                    },
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : "Required field",
                    initialValue: widget.user.name,
                    decoration: InputDecoration(
                      label: Text("Name"),
                      hintText: "eg-Aman Raval",
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: mq.width * .05,
                  ),
                  TextFormField(
                    onSaved: (val) {
                      Apis.me.about = val ?? "";
                    },
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : "Required fields",
                    initialValue: widget.user.about,
                    decoration: InputDecoration(
                      label: Text("About"),
                      prefixIcon: Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: mq.width * .07,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        minimumSize: Size(mq.width * .4, mq.height * .06)),
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        _formkey.currentState!.save();
                        Apis().updateUserInfo().then((value) {
                          return Dialogs.showWarning(
                              context, "Profile Updated Successfully");
                        });
                      }
                    },
                    label: Text(
                      "UPDATE",
                      style: TextStyle(fontSize: 16),
                    ),
                    icon: Icon(Icons.edit),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
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
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              Text(
                "Pick Profile picture",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
              ),
              SizedBox(
                height: mq.height * .03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        fixedSize: Size(mq.width * .3, mq.height * .12)),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        print(image.path);
                        setState(() {
                          _image = image.path;
                        });
                        Apis.updateProfilePic(File(_image!));
                        Navigator.pop(context);
                      }
                    },
                    child: Icon(
                      Icons.image,
                      size: mq.height * .10,
                      color: Colors.black54,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        fixedSize: Size(mq.width * .3, mq.height * .12)),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? photo =
                          await picker.pickImage(source: ImageSource.camera);
                      if (photo != null) {
                        print(photo.path);
                        setState(() {
                          _image = photo.path;
                        });
                        Apis.updateProfilePic(File(_image!));
                        Navigator.pop(context);
                      }
                    },
                    child: Icon(
                      Icons.camera_alt,
                      size: mq.height * .10,
                      color: Colors.black54,
                    ),
                  )
                ],
              )
            ],
          );
        });
  }
}
