import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../models/app_models.dart';
import '../data/geography.dart';

class ExtensionistDashboardScreen extends StatefulWidget {
  const ExtensionistDashboardScreen({super.key});

  @override
  State<ExtensionistDashboardScreen> createState() => _ExtensionistDashboardScreenState();
}

class _ExtensionistDashboardScreenState extends State<ExtensionistDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MarketProvider>(context, listen: false).fetchMarketData();
      Provider.of<ExtensionistProvider>(context, listen: false).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketProvider>(context);
    final extensionist = Provider.of<ExtensionistProvider>(context);
    final producers = market.profilesByRole(UserRole.seller);

    return Scaffold(
      appBar: AppBar(title: const Text('Painel do Extensionista', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showVisitForm(context, producers),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Registar Visita', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Produtores Registados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const SizedBox(height: 12),
          if (producers.isEmpty)
            const Text('Sem produtores registados.', style: TextStyle(color: AppTheme.secondaryText))
          else
            ...producers.map((p) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.agriculture_outlined, color: AppTheme.primaryGreen),
                    title: Text(p.fullName),
                    subtitle: Text('${p.province ?? ""} ${p.district ?? ""}'),
                  ),
                )),
          const SizedBox(height: 24),
          const Text('Visitas Técnicas Registadas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const SizedBox(height: 12),
          if (extensionist.visits.isEmpty)
            const Text('Ainda não registou nenhuma visita.', style: TextStyle(color: AppTheme.secondaryText))
          else
            ...extensionist.visits.map((v) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.assignment_turned_in_outlined, color: AppTheme.primaryGreen),
                    title: Text('${v.producerName} · ${v.type}'),
                    subtitle: Text('${v.district} — ${v.notes}'),
                    trailing: Text('${v.date.day}/${v.date.month}', style: const TextStyle(fontSize: 11, color: AppTheme.secondaryText)),
                  ),
                )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showVisitForm(BuildContext context, List<Profile> producers) {
    final notesController = TextEditingController();
    String? producerName;
    String type = 'Assistência Técnica';
    String? district;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Registar Visita Técnica', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: producerName,
                  decoration: const InputDecoration(labelText: 'Produtor'),
                  items: producers.map((p) => DropdownMenuItem(value: p.fullName, child: Text(p.fullName))).toList(),
                  onChanged: (val) => setSheetState(() => producerName = val),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: district,
                  decoration: const InputDecoration(labelText: 'Distrito'),
                  items: mozGeography.values.expand((d) => d).toSet().map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) => setSheetState(() => district = val),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Notas da visita'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: producerName == null || district == null
                        ? null
                        : () async {
                            await Provider.of<ExtensionistProvider>(context, listen: false).addVisit(AssistanceVisit(
                              id: DateTime.now().microsecondsSinceEpoch.toString(),
                              producerName: producerName!,
                              type: type,
                              district: district!,
                              notes: notesController.text.trim(),
                              date: DateTime.now(),
                            ));
                            if (sheetContext.mounted) Navigator.pop(sheetContext);
                          },
                    child: const Text('Guardar Visita'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
