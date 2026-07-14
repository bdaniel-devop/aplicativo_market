import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/app_models.dart';

/// Gera e partilha uma factura em PDF para uma encomenda, tal como
/// o `pdf-generator.ts` do site fazia com jsPDF, mas do lado do telemóvel.
class PdfService {
  static Future<void> shareOrderInvoice(Order order) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('AgroSuste Market', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Factura de Encomenda', style: const pw.TextStyle(fontSize: 14)),
            pw.Divider(height: 24),
            pw.Text('Encomenda #${order.id}'),
            pw.Text('Data: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}'),
            pw.Text('Cliente: ${order.buyerName}'),
            pw.Text('Telefone: ${order.buyerPhone}'),
            pw.Text('Método de pagamento: ${order.paymentMethod}'),
            pw.Text('Estado: ${order.status}'),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: const {
                0: pw.FlexColumnWidth(3),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(1),
                3: pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _cell('Produto', bold: true),
                    _cell('Qtd', bold: true),
                    _cell('Unid.', bold: true),
                    _cell('Subtotal (MZN)', bold: true),
                  ],
                ),
                ...order.items.map((i) => pw.TableRow(children: [
                      _cell(i.name),
                      _cell('${i.quantity}'),
                      _cell(i.unit),
                      _cell((i.price * i.quantity).toStringAsFixed(2)),
                    ])),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Subtotal: ${order.subtotal.toStringAsFixed(2)} MZN'),
                  pw.Text('Comissão: ${order.commission.toStringAsFixed(2)} MZN'),
                  pw.SizedBox(height: 4),
                  pw.Text('Total: ${order.total.toStringAsFixed(2)} MZN', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    await Printing.sharePdf(bytes: await doc.save(), filename: 'factura_${order.id}.pdf');
  }

  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: 10)),
    );
  }
}
