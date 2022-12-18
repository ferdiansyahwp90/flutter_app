import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/screens/colours.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/screens/home_screen.dart';
import 'package:flutter_app/urls/uri_network.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  TextEditingController categoryController = TextEditingController();
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  void httpAddCategory() async {
    final _prefs = await prefs;
    var token = _prefs.getString('token');
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    Map body = {
      'name': categoryController.text.trim(),
      // 'device_name': 'mobile'
    };

    final url = Uri.parse(UriNetwork().baseUrl + UriNetwork().uriCategory);

    try {
      final response =
          await http.post(url, body: jsonEncode(body), headers: headers);
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 201) {
        categoryController.clear();
        print(response.body);
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const HomeScreen()));
      } else if (response.statusCode == 422) {
        throw jsonDecode(response.body)['message'] ?? 'Unknown Error Occured';
      } else if (response.statusCode == 400) {
        throw jsonDecode(response.body)['errors'] ?? 'Unknown Error Occured';
      }
    } catch (error) {
      dialogMessage('Errors', error.toString());
    }
  }

  void dialogMessage(title, error) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
            contentPadding: const EdgeInsets.all(20),
            children: [Text(error)],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kategori'),
        backgroundColor: primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nama Kategori',
                    style: TextStyle(fontSize: 16),
                  )),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.only(left: 20, right: 20),
                decoration: BoxDecoration(
                    color: greyLight, borderRadius: BorderRadius.circular(10)),
                child: TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                      hintText: 'Nama Kategori',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.only(left: 20, right: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: primary, borderRadius: BorderRadius.circular(10)),
                child: TextButton(
                  onPressed: () {
                    httpAddCategory();
                  },
                  child: const Text(
                    'Tambah',
                    style: TextStyle(color: light, fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
