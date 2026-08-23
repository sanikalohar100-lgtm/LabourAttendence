import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:labourattendence/app_language.dart';
import 'package:labourattendence/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class ReportScreen extends StatelessWidget {

  final int selectedMonth;
  final int selectedYear;
  final Map<int, String> attendanceData;
  final Map<int, double> overtimeData;

  const ReportScreen({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.attendanceData,
    required this.overtimeData,
  });


  double get totalPresent =>
      attendanceData.values.where((e) => e == "P").length.toDouble();

  double get totalAbsent =>
      attendanceData.values.where((e) => e == "A").length.toDouble();

  double get totalOTHours =>
      overtimeData.values.fold(0, (a, b) => a + b);

  double get salary {
    return double.tryParse(
      Hive.box('labours').get("salary", defaultValue: "0"),
    ) ??
        0;
  }

  double get perDaySalary => salary;

  double get totalPresentAmount => totalPresent * perDaySalary;

  double get totalOTAmount {
    double hourlyRate = salary / 8;
    return totalOTHours * hourlyRate;
  }

  double get grandTotal =>
      totalPresentAmount + totalOTAmount;

  Widget summaryBox(String title, String sub, String value) {

    return Container(
      width: 100,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            sub,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 6,
          )
        ],
      ),
      child: child,
    );
  }

  Future<void> generatePdf(BuildContext context) async {

    final pdf = pw.Document();

    final now = DateTime.now();

    String monthName = DateFormat(
      "MMMM yyyy",
    ).format(
      DateTime(
        selectedYear,
        selectedMonth,
      ),
    );

    pdf.addPage(

      pw.Page(

        pageFormat: PdfPageFormat.a4,

        margin: const pw.EdgeInsets.all(25),

        build: (context) {

          return pw.Column(

            crossAxisAlignment:
            pw.CrossAxisAlignment.start,

            children: [

              // ==========================
              // HEADER
              // ==========================

              pw.Container(

                width: double.infinity,

                padding: const pw.EdgeInsets.all(22),

                decoration: pw.BoxDecoration(

                  color: PdfColors.blue800,

                  borderRadius:
                  pw.BorderRadius.circular(12),

                ),

                child: pw.Column(

                  children: [

                    pw.Text(

                      "LABOUR ATTENDANCE",

                      style: pw.TextStyle(

                        color: PdfColors.white,

                        fontSize: 24,

                        fontWeight:
                        pw.FontWeight.bold,

                      ),

                    ),

                    pw.SizedBox(height: 8),

                    pw.Text(

                      "Monthly Attendance Report",

                      style: pw.TextStyle(

                        color: PdfColors.white,

                        fontSize: 14,

                      ),

                    ),

                    pw.SizedBox(height: 15),

                    pw.Container(

                      padding:
                      const pw.EdgeInsets.symmetric(

                        horizontal: 16,

                        vertical: 8,

                      ),

                      decoration: pw.BoxDecoration(

                        color: PdfColors.white,

                        borderRadius:
                        pw.BorderRadius.circular(30),

                      ),

                      child: pw.Text(

                        monthName,

                        style: pw.TextStyle(

                          fontSize: 16,

                          fontWeight:
                          pw.FontWeight.bold,

                          color: PdfColors.blue800,

                        ),

                      ),

                    ),

                  ],

                ),

              ),

              pw.SizedBox(height: 30),

              // ==========================
              // ATTENDANCE SUMMARY TITLE
              // ==========================

              pw.Text(

                "Attendance Summary",

                style: pw.TextStyle(

                  fontSize: 18,

                  fontWeight:
                  pw.FontWeight.bold,

                ),

              ),

              pw.SizedBox(height: 15),

              // ==========================
// ATTENDANCE SUMMARY
// ==========================

              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 1,
                ),
                children: [

                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.blue50,
                    ),
                    children: [

                      pw.Padding(
                        padding: const pw.EdgeInsets.all(12),
                        child: pw.Text(
                          "Description",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),

                      pw.Padding(
                        padding: const pw.EdgeInsets.all(12),
                        child: pw.Text(
                          "Value",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),

                    ],
                  ),

                  tableRow(
                    "Present Days",
                    totalPresent.toInt().toString(),
                  ),

                  tableRow(
                    "Absent Days",
                    totalAbsent.toInt().toString(),
                  ),

                  tableRow(
                    "Overtime",
                    "${totalOTHours.toStringAsFixed(1)} hrs",
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

// ==========================
// SALARY SUMMARY
// ==========================

              pw.Text(
                "Salary Summary",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 15),

              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 1,
                ),
                children: [

                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.green50,
                    ),
                    children: [

                      pw.Padding(
                        padding: const pw.EdgeInsets.all(12),
                        child: pw.Text(
                          "Description",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),

                      pw.Padding(
                        padding: const pw.EdgeInsets.all(12),
                        child: pw.Text(
                          "Amount",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),

                    ],
                  ),

                  tableRow(
                    "Present Salary",
                    "$totalPresentAmount",
                  ),

                  tableRow(
                    "OT Amount",
                    "$totalOTAmount",
                  ),

                  tableRow(
                    "Grand Total",
                    "$grandTotal",
                  ),

                ],
              ),

              pw.SizedBox(height: 35),

// ==========================
// TOTAL PAYABLE CARD
// ==========================

              pw.Container(

                width: double.infinity,

                padding: const pw.EdgeInsets.all(22),

                decoration: pw.BoxDecoration(

                  color: PdfColors.blue800,

                  borderRadius: pw.BorderRadius.circular(12),

                ),

                child: pw.Column(

                  children: [

                    pw.Text(

                      "TOTAL PAYABLE",

                      style: pw.TextStyle(

                        color: PdfColors.white,

                        fontSize: 16,

                        fontWeight: pw.FontWeight.bold,

                      ),

                    ),

                    pw.SizedBox(height: 12),

                    pw.Text(

                      "${grandTotal.toStringAsFixed(0)}",

                      style: pw.TextStyle(

                        color: PdfColors.white,

                        fontSize: 28,

                        fontWeight: pw.FontWeight.bold,

                      ),

                    ),

                  ],

                ),

              ),

              pw.Spacer(),

// ==========================
// FOOTER
// ==========================

              pw.Divider(),

              pw.Row(

                mainAxisAlignment:
                pw.MainAxisAlignment.spaceBetween,

                children: [

                  pw.Text(
                    "Labour Attendance App",
                    style: const pw.TextStyle(
                      color: PdfColors.grey700,
                    ),
                  ),

                  pw.Text(
                    DateFormat(
                      "dd MMM yyyy hh:mm a",
                    ).format(now),
                    style: const pw.TextStyle(
                      color: PdfColors.grey700,
                    ),
                  ),

                ],

              ),

            ],

          );

        },

      ),

    );
    final dir = await getApplicationDocumentsDirectory();

    final file = File("${dir.path}/Attendance_Report.pdf");

    await file.writeAsBytes(await pdf.save());

    await OpenFilex.open(file.path);

  }

  pw.TableRow tableRow(String title, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(12),
          child: pw.Text(title),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(12),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage.values[
    Provider.of<LanguageProvider>(context).locale.languageCode]!;

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lang["report"]!,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            whiteCard(
              child: Column(
                children: [
                  Text(
                    Provider.of<LanguageProvider>(context, listen: false)
                        .locale
                        .languageCode ==
                        "mr"
                        ? DateFormat(
                      "MMMM yyyy",
                      "mr",
                    ).format(
                      DateTime(
                        selectedYear,
                        selectedMonth,
                      ),
                    )
                        : DateFormat(
                      "MMMM yyyy",
                      "en",
                    ).format(
                      DateTime(
                        selectedYear,
                        selectedMonth,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                   Text(
                    lang["monthlyReport"]!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            whiteCard(
              child: ValueListenableBuilder(
                valueListenable: Hive.box('labours').listenable(),
                builder: (context, box, _) {
                  String staffName = box.get(
                    "name",
                    defaultValue: "No Name",
                  );

                  String mobile = box.get(
                    "mobile",
                    defaultValue: "No Mobile",
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        lang["staffInfo"]!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.blue,
                            size: 27,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "${lang["name"]}: $staffName",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const Icon(Icons.call, size: 27),
                          const SizedBox(width: 10),
                          Text(
                            "${lang["phone"]}: $mobile",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

            whiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    lang["attendanceSummary"]!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      summaryBox(lang["present"]!,"P", totalPresent.toStringAsFixed(0)),
                      summaryBox(
                          lang["overtime"]!,
                        "OT",
                        "${totalOTHours.toStringAsFixed(1)}h",
                      ),
                      summaryBox(lang["absent"]!, "A", totalAbsent.toStringAsFixed(0)),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      summaryBox(lang["presentTotal"]!,
                        "",
                        "₹${totalPresentAmount.toStringAsFixed(0)}",),
                      summaryBox(lang["otTotal"]!,
                        "",
                        "₹$totalOTAmount",),
                      summaryBox(lang["total"]!,
                        "",
                        "₹$grandTotal",),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15),
        child: SizedBox(
          height: 45,
          child: ElevatedButton.icon(
            icon: const Icon(
              Icons.picture_as_pdf,
              color: Colors.white,
            ),
            label: Text(
              lang["sharePdf"]!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white, // Icon + Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () async {
              await generatePdf(context);
            },
          ),
        ),
      ),
    );
  }
}