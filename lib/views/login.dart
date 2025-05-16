import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:battleships/util/api.dart';
import 'package:battleships/util/session_manager.dart';
import 'package:battleships/views/first_page.dart';
import 'package:http/http.dart' as http;

// login and logout implementation

bool isLoading = false;

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override 
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.blueAccent.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter, 
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: "Username",
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16.0),
                    (isLoading) 
                      ? const CircularProgressIndicator()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => _login(context),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0, 
                                  vertical: 12.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: const Text("Log In"),
                            ),
                            OutlinedButton(
                              onPressed: () => _register(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                  vertical: 12.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                side: BorderSide(
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              child: const Text("Register"),
                            ),
                          ],
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<http.Response> callApi(String route, data, {String token=''}) async {
    Map<String, String> headers = {};
    headers["Content-Type"] = "application/json";
    if (token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }

    return http.post(
      Uri.parse("https://battleships-app.onrender.com/$route"),
      headers: headers,
      body: data,
    );
  }

  Future<void> _login(BuildContext context) async {
    try {
      final username = usernameController.text;
      final password = passwordController.text;

      String data  = jsonEncode(
        <String, String>{"username": username, "password": password});

        setState(() {
          isLoading = true;
        });

        final response = await ApiHelper.callApi('/login', data);
        final jsonRes = jsonDecode(response.body);
        
        if (response.statusCode == 200) {
          final sessionToken = jsonRes['access_token'];
          await SessionManager.setSessionToken(sessionToken, username);

          if (!mounted) return;

          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => const FirstPage(),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login Failed")),
          );
        }
    } catch(e) {
      print("An error ocurred: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _register(BuildContext context) async {
    try {
      final username = usernameController.text;
      final password = passwordController.text;

      String data = jsonEncode(
        <String, String>{"username": username, "password": password});
      
      setState(() {
        isLoading = true;
      });

      final response = await ApiHelper.callApi('/register', data);
      final jsonRes = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final sessionToken = jsonRes['access_token'];
        await SessionManager.setSessionToken(sessionToken, username);

        if (!mounted) return;

        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const FirstPage(),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Failed")),
        );
      }
    } catch (e) {
      print("An error has occurred: $e");
    }

    setState(() {
      isLoading = false;
    });
  }
}