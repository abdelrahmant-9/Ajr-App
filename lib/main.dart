import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:ajr/views/splash_view.dart';
import 'package:flutter/foundation.dart';
import 'package:ajr/views/debug_dashboard.dart';
import 'firebase_options.dart';
import 'viewmodels/home_viewmodel.dart';
import 'services/sync_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set Hijri calendar to Arabic
  HijriCalendar.setLocal('ar');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Anonymous Sign-In
  await FirebaseAuth.instance.signInAnonymously();

  await Hive.initFlutter();
  await Hive.openBox('ajrBox');
  await NotificationService().init();

  SyncService().start();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Navigator key to access navigator from anywhere
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
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
            bodyLarge: TextStyle(fontFamily: 'Tajawal'),
          ),
        ),
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => Scaffold(
                    body: Stack(
                      children: [
                        if (child != null) child,
                        if (kDebugMode) const DebugFloatingButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        home: const SplashView(),
      ),
    );
  }
}

class DebugFloatingButton extends StatefulWidget {
  const DebugFloatingButton({super.key});

  @override
  State<DebugFloatingButton> createState() => _DebugFloatingButtonState();
}

class _DebugFloatingButtonState extends State<DebugFloatingButton> {
  Offset position = const Offset(20, 150);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        feedback: _buildButton(isDragging: true),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          setState(() {
            position = details.offset;
          });
        },
        child: _buildButton(),
      ),
    );
  }

  Widget _buildButton({bool isDragging = false}) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          MyApp.navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => const DebugDashboard()),
          );
        },
        child: Opacity(
          opacity: isDragging ? 0.5 : 0.8,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.greenAccent, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
            ),
            child: const Icon(Icons.bug_report, color: Colors.greenAccent, size: 28),
          ),
        ),
      ),
    );
  }
}
