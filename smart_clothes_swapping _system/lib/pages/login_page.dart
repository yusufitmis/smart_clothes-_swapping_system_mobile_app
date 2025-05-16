import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_ile_kiyafet_yukleme/pages/signup_page.dart';
import 'package:url_ile_kiyafet_yukleme/widgets/main_screen.dart';
import 'dart:convert';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool showPassword = false;

  // Login işlemi için backend'e istek gönderme
  Future<void> login() async {
  final username = _usernameController.text.trim(); // Trimleme eklendi
  final password = _passwordController.text.trim(); // Trimleme eklendi

 
  if (username.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kullanıcı adı ve şifre gerekli.')),
    );
    return;
  }

  final response = await http.post(
    Uri.parse('http://10.0.2.2:3000/login'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'username': username, 'password': password}),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(userId: data['user']['id']),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Giriş başarısız.')),
    );
  }
}


 void navigateToSignup() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SignupScreen()), // SignupScreen sayfasına git
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan resmi
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/model2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.6),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Hoşgeldiniz',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF283A4F),
                      ),
                    ),
                    SizedBox(height: 40),
                    // E-posta girişi
                    TextField(
                      controller: _usernameController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Kullanıcı Adı',
                        prefixIcon: Icon(Icons.verified_user_outlined,
                            color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Şifre girişi
                    TextField(
                      controller: _passwordController, // Bunu ekleyin!
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                        hintText: 'Şifre',
                        prefixIcon:
                            Icon(Icons.lock_outline, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),
                    // Giriş yap butonu
                    ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        backgroundColor: Color(0xFF283A4F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Giriş Yap',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: navigateToSignup,
                          child: Text(
                            'Hesabınız yok mu? Kayıt ol',
                            style: TextStyle(
                              color: Color(0xFF283A4F),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Şifremi unuttum işlemi
                          },
                          child: Text(
                            'Şifremi unuttum',
                            style: TextStyle(
                              color: Color(0xFF283A4F),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
