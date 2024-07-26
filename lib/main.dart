import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;
  Map<String, String> _dummyUsers = {};

  @override
  void initState() {
    super.initState();
    _loadDummyUsers();
  }

  Future<String> get _dummyFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/dummy_users.csv';
  }

  Future<void> _loadDummyUsers() async {
    final path = await _dummyFilePath;
    final file = File(path);

    if (await file.exists()) {
      final csvString = await file.readAsString();
      final csvList = const CsvToListConverter().convert(csvString);

      final Map<String, String> loadedUsers = {};
      for (var row in csvList) {
        if (row.isNotEmpty) {
          loadedUsers[row[0]] = row[1];
        }
      }
      setState(() {
        _dummyUsers = loadedUsers;
      });
    } else {
      file.createSync();
    }
  }

  Future<void> _saveDummyUsers() async {
    final path = await _dummyFilePath;
    final file = File(path);

    final csvList = _dummyUsers.entries
        .map((entry) => [entry.key, entry.value])
        .toList();
    final csvString = const ListToCsvConverter().convert(csvList);

    await file.writeAsString(csvString);
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _submit() {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (_isLogin) {
      if (_dummyUsers[email] == password) {
        _showAlert('Login successful!');
      } else {
        _showAlert('Invalid email or password.');
      }
    } else {
      if (_dummyUsers.containsKey(email)) {
        _showAlert('Email already registered.');
      } else {
        _dummyUsers[email] = password;
        _saveDummyUsers();
        _showAlert('Registration successful!');
      }
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isLogin ? 'Login' : 'Registration'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _forgotPassword() {
    final email = _emailController.text;
    if (_dummyUsers.containsKey(email)) {
      _showAlert('Your password is: ${_dummyUsers[email]}');
    } else {
      _showAlert('Email not registered.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text(_isLogin ? 'Login' : 'Register'),
            ),
            if (_isLogin)
              TextButton(
                onPressed: _forgotPassword,
                child: const Text('Forgot Password?'),
              ),
            TextButton(
              onPressed: _toggleAuthMode,
              child: Text(
                _isLogin ? 'Create an account' : 'I already have an account',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
