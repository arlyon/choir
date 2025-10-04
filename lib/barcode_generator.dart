import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:barcode/barcode.dart' as bc;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class BarcodeGenerator {
  static Future<void> generateBarcodeSheet(
    Map<String, dynamic> work,
    int instanceCount,
    BuildContext context,
  ) async {
    final workId = work['work_id'] as String;
    final title = work['title'] as String;
    final composer = work['composer'] as String? ?? '';

    final barcodeData = List.generate(
      instanceCount,
      (index) => '$workId ${index + 1}',
    );

    final workTitle = composer.isNotEmpty ? '$title - $composer' : title;

    await generateBarcodeListPdf(
      barcodeData: barcodeData,
      title: workTitle,
      fileName: '$workId.pdf',
      shareText: 'Barcode sheet for $title',
      context: context,
    );
  }

  static Future<void> generateBarcodeListPdf({
    required List<String> barcodeData,
    required String title,
    required String fileName,
    required String shareText,
    required BuildContext context,
  }) async {
    try {
      final pdf = pw.Document();
      final itemsPerPage = 14;
      final numPages = (barcodeData.length / itemsPerPage).ceil();

      for (int pageNum = 0; pageNum < numPages; pageNum++) {
        final startIndex = pageNum * itemsPerPage;
        final endIndex = (startIndex + itemsPerPage).clamp(
          0,
          barcodeData.length,
        );

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(20),
            build: (context) {
              final widgets = <pw.Widget>[];

              widgets.add(
                pw.Column(
                  children: [
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Divider(),
                    pw.SizedBox(height: 10),
                  ],
                ),
              );

              for (int i = startIndex; i < endIndex; i += 2) {
                widgets.add(
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _buildSimpleBarcodeWidget(barcodeData[i]),
                      ),
                      pw.SizedBox(width: 10),
                      if (i + 1 < endIndex)
                        pw.Expanded(
                          child: _buildSimpleBarcodeWidget(barcodeData[i + 1]),
                        )
                      else
                        pw.Expanded(child: pw.SizedBox()),
                    ],
                  ),
                );
                widgets.add(pw.SizedBox(height: 15));
              }

              return pw.Column(children: widgets);
            },
          ),
        );
      }

      final pdfBytes = await pdf.save();

      if (Platform.isLinux) {
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save PDF',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsBytes(pdfBytes);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF saved to $outputFile'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        }
      } else {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(pdfBytes);

        await Share.shareXFiles([XFile(file.path)], text: shareText);

        try {
          await file.delete();
        } catch (e) {
          // Ignore cleanup errors
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  static pw.Widget _buildSimpleBarcodeWidget(String data) {
    final barcode = bc.Barcode.code128();

    return pw.Column(
      children: [
        pw.Container(
          height: 60,
          child: pw.BarcodeWidget(
            barcode: barcode,
            data: data,
            width: 200,
            height: 60,
            drawText: false,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(data, style: pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  static Future<void> generateUsersPdf(
    List<Map<String, dynamic>> users,
    BuildContext context,
  ) async {
    final userIds =
        users.map((user) => user['user_id']?.toString() ?? '').toList();
    await generateBarcodeListPdf(
      barcodeData: userIds,
      title: 'User IDs List',
      fileName: 'users.pdf',
      shareText: 'User IDs list',
      context: context,
    );
  }
}