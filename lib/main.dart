// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'drawing_board.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await ScreenUtil.ensureScreenSize();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color selectedColor = Colors.pink;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852.0),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Material App',
          debugShowCheckedModeBanner: false,
          showPerformanceOverlay: false,
          showSemanticsDebugger: false,
          debugShowMaterialGrid: false,
          theme: ThemeData.light().copyWith(
            primaryColor: selectedColor,
            iconTheme: const IconThemeData().copyWith(color: selectedColor, size: 24.sp),
            textTheme: const TextTheme()
                .copyWith(bodyMedium: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16.sp)),
          ),
          home: child,
        );
      },
      child: DrawingBoard(
        themeColor: selectedColor,
        onColorChange: (Color value) {
          setState(() {
            selectedColor = value;
          });
        },
      ),
    );
  }
}
