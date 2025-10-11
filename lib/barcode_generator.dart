import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:barcode/barcode.dart' as bc;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

class BarcodeGenerator {
  static Future<void> generateBarcodeSheet(
    Map<String, dynamic> work,
    int instanceCount,
    BuildContext context,
  ) async {
    final workId = work['work_id'] as String;
    final title = work['title'] as String;

    final barcodeData = List.generate(
      instanceCount,
      (index) => '$workId ${index + 1}',
    );

    await generateBarcodeListPdf(
      barcodeData: barcodeData,
      title: null,
      fileName: '$workId.pdf',
      shareText: 'Barcode sheet for $title',
      context: context,
    );
  }

  static Future<void> generateBarcodeListPdf({
    required List<String> barcodeData,
    required String? title,
    required String fileName,
    required String shareText,
    required BuildContext context,
  }) async {
    try {
      final pdf = pw.Document();
      final itemsPerPage = 33;
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
            margin: pw.EdgeInsets.only(top: 8.8 * PdfPageFormat.mm),
            build: (context) {
              final widgets = <pw.Widget>[];

              if (title != null) {
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
              }

              for (int i = startIndex; i < endIndex; i += 3) {
                widgets.add(
                  pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 70 * PdfPageFormat.mm,
                        height: 25.4 * PdfPageFormat.mm,
                        child: _buildSimpleBarcodeWidget(barcodeData[i]),
                      ),
                      if (i + 1 < endIndex)
                        pw.SizedBox(
                          width: 70 * PdfPageFormat.mm,
                          height: 25.4 * PdfPageFormat.mm,
                          child: _buildSimpleBarcodeWidget(barcodeData[i + 1]),
                        )
                      else
                        pw.SizedBox(
                          width: 70 * PdfPageFormat.mm,
                          height: 25.4 * PdfPageFormat.mm,
                        ),
                      if (i + 2 < endIndex)
                        pw.SizedBox(
                          width: 70 * PdfPageFormat.mm,
                          height: 25.4 * PdfPageFormat.mm,
                          child: _buildSimpleBarcodeWidget(barcodeData[i + 2]),
                        )
                      else
                        pw.SizedBox(
                          width: 70 * PdfPageFormat.mm,
                          height: 25.4 * PdfPageFormat.mm,
                        ),
                    ],
                  ),
                );
              }

              return pw.Column(children: widgets);
            },
          ),
        );
      }

      final pdfBytes = await pdf.save();

      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
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
                content: Text(
                  AppLocalizations.of(context)!.pdfSavedTo(outputFile),
                ),
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
            content: Text(
              AppLocalizations.of(context)!.failedToGeneratePdf(e.toString()),
            ),
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
          height: 40,
          child: pw.BarcodeWidget(
            barcode: barcode,
            data: data,
            width: 120,
            height: 40,
            drawText: false,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          data,
          style: pw.TextStyle(fontSize: 8, font: pw.Font.courier()),
        ),
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
      title: null,
      fileName: 'users.pdf',
      shareText: 'User IDs list',
      context: context,
    );
  }
}
