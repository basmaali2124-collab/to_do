import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/core/app_theme.dart';
import 'package:to_do_app/core/servicses/notification_service.dart';
import 'package:to_do_app/data/database_helper.dart';
import 'package:to_do_app/logic/task_cubit/task_cubit.dart';
import 'package:to_do_app/presentation/home/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await NotificationService.instance.init();
  runApp(
    BlocProvider(
      create: (_) => TasksCubit(DatabaseHelper())..loadTasks(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const Home(),
    );
  }
}