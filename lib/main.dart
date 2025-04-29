// main.dart - 應用入口點
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/timer_provider.dart';
import 'providers/workout_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TimerProvider()),
        ChangeNotifierProvider(create: (context) => WorkoutProvider()),
      ],
      child: MaterialApp(
        title: 'FitTimer',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.dark(
            primary: Color(0xFFBB86FC),
            secondary: Color(0xFF03DAC6),
            surface: Color(0xFF121212),
            background: Color(0xFF121212),
            error: Color(0xFFCF6679),
          ),
          scaffoldBackgroundColor: Color(0xFF121212),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          cardTheme: CardTheme(
            color: Color(0xFF1E1E1E),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFBB86FC),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Color(0xFFBB86FC)),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            titleLarge: TextStyle(color: Colors.white),
            titleMedium: TextStyle(color: Colors.white),
            titleSmall: TextStyle(color: Colors.white),
          ),
          fontFamily: 'NotoSansTC',
        ),
        home: HomeScreen(),
      ),
    );
  }
}
