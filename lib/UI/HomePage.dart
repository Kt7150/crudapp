import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_crud_app/Database/DBHelper.dart';
import 'package:task_crud_app/FCM/firebase_messaging.dart';
import 'package:task_crud_app/UI/Constants/AppText.dart';
import 'package:task_crud_app/model/UserModel.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  int? _selectedUserId;

  Future<void> _insertUser() async {
    String email = _emailController.text;
    String name = _nameController.text;

    if (email.isNotEmpty && name.isNotEmpty) {
      await DatabaseHelper.instance.insertUser({'email': email, 'name': name});
      _emailController.clear();
      _nameController.clear();
      await FirebaseMessagingService().subscribeToTopic('new_users'); // Subscribe user to topic
      setState(() {});
    }
  }


  Future<void> _updateUser() async {
    if (_selectedUserId != null) {
      String email = _emailController.text;
      String name = _nameController.text;

      if (email.isNotEmpty && name.isNotEmpty) {
        await DatabaseHelper.instance.updateUser(
          {'id': _selectedUserId, 'email': email, 'name': name},
        );
        _emailController.clear();
        _nameController.clear();
        _selectedUserId = null;
        setState(() {});
      }
    }
  }

  Future<void> _deleteUser(int userId) async {
    await DatabaseHelper.instance.deleteUser(userId);
    setState(() {});
  }

  void _selectUserToUpdate(int userId, String email, String name) {
    setState(() {
      _selectedUserId = userId;
      _emailController.text = email;
      _nameController.text = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        centerTitle: true,
        title: Text('CRUD OPARATION',style: GoogleFonts.acme(textStyle: Appbartext),),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _insertUser,
                      child: Text('Add User'),
                    ),
                    ElevatedButton(
                      onPressed: _selectedUserId != null ? _updateUser : null,
                      child: Text('Update User'),
                    ),
                  ],
                ),
                Divider(color: Colors.black12,),
                SizedBox(height: 16),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper.instance.queryAllUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No users found.');
                    } else {
                      List<User> userList = snapshot.data!
                          .map((user) => User.fromMap(user))
                          .toList();
                      return Column(
                        children: userList.map((user) {
                          return ListTile(
                            title: Text(user.name,style: GoogleFonts.acme(textStyle: username),),
                            subtitle: Text(user.email,style: GoogleFonts.acme(textStyle: email),),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _selectUserToUpdate(
                                      user.id!,
                                      user.email,
                                      user.name,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteUser(user.id!);
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}