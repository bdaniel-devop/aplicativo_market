import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<NotificationsProvider>(context, listen: false);
      await provider.load();
      await provider.markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = Provider.of<NotificationsProvider>(context).notifications;

    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: notifications.isEmpty
          ? const Center(child: Text('Sem notificações por agora.', style: TextStyle(color: AppTheme.secondaryText)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.notifications_outlined, color: AppTheme.primaryGreen),
                    title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(n.message),
                    trailing: Text('${n.createdAt.day}/${n.createdAt.month}', style: const TextStyle(fontSize: 11, color: AppTheme.secondaryText)),
                  ),
                );
              },
            ),
    );
  }
}
