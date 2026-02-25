
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'viewmodels/home_viewmodel.dart';
import 'views/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Tajawal',
          extensions: [
            SkeletonizerConfigData(
              effect: ShimmerEffect(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
              ),
            ),
          ],
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontFamily: 'Tajawal'),
            displayMedium: TextStyle(fontFamily: 'Tajawal'),
            displaySmall: TextStyle(fontFamily: 'Tajawal'),
            headlineLarge: TextStyle(fontFamily: 'Tajawal'),
            headlineMedium: TextStyle(fontFamily: 'Tajawal'),
            headlineSmall: TextStyle(fontFamily: 'Tajawal'),
            titleLarge: TextStyle(fontFamily: 'Tajawal'),
            titleMedium: TextStyle(fontFamily: 'Tajawal'),
            titleSmall: TextStyle(fontFamily: 'Tajawal'),
            bodyLarge: TextStyle(fontFamily: 'Tajawal'),
            bodyMedium: TextStyle(fontFamily: 'Tajawal'),
            bodySmall: TextStyle(fontFamily: 'Tajawal'),
            labelLarge: TextStyle(fontFamily: 'Tajawal'),
            labelMedium: TextStyle(fontFamily: 'Tajawal'),
            labelSmall: TextStyle(fontFamily: 'Tajawal'),
          ),
        ),
        home: const HomeView(),
      ),
    );
  }
}
