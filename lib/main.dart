import 'package:compra/core/diseno.dart';
import 'package:compra/features/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart' as provider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es', null);

  runApp(
    provider.ChangeNotifierProvider<ThemeController>(
      create: (_) => ThemeController(),
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = provider.Provider.of<ThemeController>(context);

    return MaterialApp(
      title: 'Coffee Control',
      debugShowCheckedModeBanner: false,
      theme: themeController.themeData.copyWith(
        extensions: <ThemeExtension<dynamic>>[themeController.extensionData],
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppEspaciado.radioLg),
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
