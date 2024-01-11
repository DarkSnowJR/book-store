import 'package:flutter/material.dart';
import './screens/main_screen.dart';
import './models/book.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/shopping_cart.dart';
import 'package:provider/provider.dart';
import './widgets/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './adaptors/book_adaptor.dart';

void main() async {
  // await Hive.initFlutter();
  // Hive.registerAdapter(BookAdapter());
  // await Hive.openBox<Book>('shopping_cart');

  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences
      .getInstance(); // Ensure that SharedPreferences is initialized before runApp

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/cart': (context) => const ShoppingCartPage(),
      },
    );
  }
}
