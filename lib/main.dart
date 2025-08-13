import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence_app/theme.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/clock_provider.dart';
import 'services/firestore_service.dart';
import 'pages/sign_in_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    return MultiProvider(
      providers: [
        Provider.value(value: firestoreService),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => AttendanceProvider(firestoreService),
        ),
        ChangeNotifierProvider(create: (_) => ClockProvider()),
      ],
      child: MaterialApp(
        title: 'Presence App',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: primaryColor500,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: const SignInPage(),
      ),
    );
  }
}
