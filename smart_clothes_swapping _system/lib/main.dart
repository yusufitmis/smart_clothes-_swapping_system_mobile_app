import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_ile_kiyafet_yukleme/pages/login_page.dart';
import 'blocs/image_bloc.dart';
import 'blocs/combination_bloc.dart';
import 'services/image_service.dart';
import 'services/combination_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ImageBloc(ImageService()),
        ),
        BlocProvider(
          create: (context) => CombinationBloc(CombinationService()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kombin Uygulaması',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginScreen(), // Ana sayfa olarak MainScreen gösteriliyor
      ),
    );
  }
}
