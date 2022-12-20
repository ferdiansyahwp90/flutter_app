import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/screens/colours.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/screens/home_screen.dart';
import 'package:flutter_app/screens/register_screen.dart';
import 'package:flutter_app/urls/uri_network.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  TextEditingController emailController =
      TextEditingController(text: 'superadmin@gmail.com');
  TextEditingController passwordController =
      TextEditingController(text: 'password');

  void httpLogin() async {
    final headers = {'Content-Type': 'application/json'};

    Map body = {
      'email': emailController.text.trim(),
      'password': passwordController.text,
      //'device_name': 'mobile'
    };

    final url = Uri.parse(UriNetwork().baseUrl + UriNetwork().uriLogin);

    try {
      final response =
          await http.post(url, body: jsonEncode(body), headers: headers);
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final preferences = await prefs;
        preferences.setString('token', json['token']);

        emailController.clear();
        passwordController.clear();
        print(response.body);
        print('Berhasil Login');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const HomeScreen()));
      } else if (response.statusCode == 422) {
        throw jsonDecode(response.body)['data'] ?? 'Unknown Error Occured';
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(right: 25, left: 25),
          child: Column(
            children: [
              const SizedBox(
                height: 80,
              ),
              const Center(
                child: Text(
                  'Login Screen',
                  style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'San Serif',
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              const Align(
                  alignment: Alignment.centerLeft, child: Text('Email : ')),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                width: double.infinity,
                padding: const EdgeInsets.only(left: 30, right: 30),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xffeeeeee)),
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      hintText: 'Email',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Align(
                  alignment: Alignment.centerLeft, child: Text('Password : ')),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                width: double.infinity,
                padding: const EdgeInsets.only(left: 30, right: 30),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xffeeeeee)),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      hintText: 'Password',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 50,
                width: double.infinity,
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), color: primary),
                child: TextButton(
                  onPressed: () {
                    httpLogin();
                  },
                  child: const Text(
                    'Login Now',
                    style: TextStyle(
                      color: Color(0xffffffff),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun? '),
                  InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const RegisterScreen()));
                      },
                      child: const Text(
                        'Daftar',
                        style: TextStyle(color: warning),
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
