import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PaySlip extends StatefulWidget {
  const PaySlip({Key? key}) : super(key: key);

  @override
  State<PaySlip> createState() => _PaySlipState();
}

class _PaySlipState extends State<PaySlip> {
  Future<Uint8List> generatePdf() async {
    var pdf = pw.Document();

    final tableHeaders = [
      'Earnings',
      'Deductions',
    ];

    final tableData = [
      [
        'Wage :                              10000',
        'Withholding Tax :                              250',
      ],
    ];

    final imageLogo = pw.MemoryImage(
        (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(imageLogo),
                pw.Text(
                  'PAYSLIP',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Company name',
                      style: pw.TextStyle(
                        fontStyle: pw.FontStyle.italic,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    pw.Text(
                      '163/31 Myhipcondo2',
                      style: pw.TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    pw.Text(
                      'Nongpakung Mung district',
                      style: pw.TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    pw.Text(
                      'ChiangMai 50000',
                      style: pw.TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    pw.SizedBox(height: 30),
                    pw.Text(
                      'Employee details :',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Paid : 1 July 2022',
                      style: pw.TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    pw.Text(
                      'Period day : 15-30 June 2022',
                      style: pw.TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Joel Yeo',
                      style: pw.TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    pw.Text(
                      '673 Woodlands',
                      style: pw.TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    pw.Text(
                      'Singapore 730673',
                      style: pw.TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Table.fromTextArray(
                      headers: tableHeaders,
                      data: tableData,
                      // border: null,
                      // border: pw.TableBorder(verticalInside: pw.BorderSide(width: 0.5)),
                      defaultColumnWidth: const pw.FixedColumnWidth(240),
                      headerStyle: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                      headerDecoration:
                          const pw.BoxDecoration(color: PdfColors.grey300),
                      cellHeight: 30.0,
                      cellAlignments: {
                        0: pw.Alignment.centerLeft,
                        1: pw.Alignment.centerLeft,
                      },
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text('Pay Slip'),
      ),
      body: Container(
        child: PdfPreview(
          build: (format) => generatePdf(),
        ),
      ),
    );
  }
}
