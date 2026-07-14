// Smoke test: garante que a navegação principal constrói sem excepções.
// Usa runAsync porque os ecrãs despoletam chamadas de rede reais (Dio) no
// arranque; fora do runAsync o binding de testes rejeita temporizadores reais
// pendentes.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/main.dart';
import 'package:flutter_app/providers/app_providers.dart';

void main() {
  testWidgets('MainNavigation mostra as quatro secções principais', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => MarketProvider()),
            ChangeNotifierProvider(create: (_) => OrderProvider()),
            ChangeNotifierProvider(create: (_) => RatingsProvider()),
            ChangeNotifierProvider(create: (_) => NotificationsProvider()),
            ChangeNotifierProvider(create: (_) => ExtensionistProvider()),
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
            ChangeNotifierProvider(create: (_) => NavigationProvider()),
          ],
          child: const MaterialApp(home: MainNavigation()),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
    });

    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Mercado'), findsOneWidget);
    expect(find.text('Carrinho'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });
}
