part of '../main.dart';

class ShahpurApp extends StatefulWidget {
  const ShahpurApp({super.key});

  @override
  State<ShahpurApp> createState() => _ShahpurAppState();
}

class _ShahpurAppState extends State<ShahpurApp> {
  final auth = AuthStore();

  @override
  void initState() {
    super.initState();
    auth.load();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      auth: auth,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'শাহপুর দরবার শরীফ',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primary,
            primary: primary,
            secondary: gold,
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: paper,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: primaryDark,
            centerTitle: false,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.black.withValues(alpha: .05)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: primary, width: 1.5),
            ),
          ),
        ),
        home: const MainShell(),
      ),
    );
  }
}
