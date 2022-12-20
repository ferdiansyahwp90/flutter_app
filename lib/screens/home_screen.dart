import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/models/category_model.dart';
import 'package:flutter_app/screens/add_screen.dart';
import 'package:flutter_app/screens/colours.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/screens/edit_screen.dart';
import 'package:flutter_app/screens/login_screen.dart';
import 'package:flutter_app/urls/uri_network.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var categoryList = <Category>[];

  Future<List<Category>?> getList() async {
    final prefs = await _prefs;
    var token = prefs.getString('token');
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    try {
      var url = Uri.parse(UriNetwork().baseUrl + UriNetwork().uriCategory);

      final response = await http.get(url, headers: headers);

      print(response.statusCode);
      print(categoryList.length);
      print(jsonDecode(response.body));

      if (response.statusCode == 200) {
        var jsonString = response.body;
        return categoryFromJson(jsonString);
      }
    } catch (error) {
      print('Testing');
    }
    return null;
  }

  Future<void> httpLogout() async {
    final SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token');
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    try {
      var url = Uri.parse(UriNetwork().baseUrl + UriNetwork().uriLogout);
      http.Response response = await http.post(url, headers: headers);
      // print(response.statusCode);
      // print(response.body);
      print(token);
      prefs.clear();
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const LoginScreen()));
    } catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const AddScreen()));
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: const BoxDecoration(color: primary),
                ),
                const Positioned(
                    top: 70,
                    left: 25,
                    child: Text(
                      'Starter App',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          color: light),
                    )),
                Positioned(
                  right: 25,
                  top: 65,
                  child: Container(
                    height: 35,
                    width: 120,
                    decoration: BoxDecoration(
                        color: light, borderRadius: BorderRadius.circular(5)),
                    child: TextButton(
                      onPressed: () {
                        httpLogout();
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: primary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'List Kategori',
                        style: TextStyle(fontSize: 16),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  FutureBuilder<List<Category>?>(
                    future: getList(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          padding: const EdgeInsets.all(0),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                title: Text(snapshot.data![index].name),
                                trailing: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                EditScreen(
                                                    categoryId: snapshot
                                                        .data![index].id,
                                                    category: snapshot
                                                        .data![index].name)));
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: primary,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
