import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:labourattendence/app_language.dart';
import 'package:labourattendence/language_provider.dart';
import 'package:labourattendence/report_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  DateTime selectedDate = DateTime.now();
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  Map<int, String> attendanceData = {}; // A or P
  Map<int, bool> otStatus = {}; // OT selected or not
  Map<int, double> overtimeData = {};

  Map<int, String> notesData = {};


  @override
  void initState() {
    super.initState();
    loadAttendanceData();
  }

  double get totalPresent =>
      attendanceData.values.where((e) => e == "P").length.toDouble();

  double get totalAbsent =>
      attendanceData.values.where((e) => e == "A").length.toDouble();

  double get totalOvertimeHours =>
      overtimeData.values.fold(0, (a, b) => a + b);

  void loadAttendanceData() {
    var box = Hive.box('labours');

    attendanceData.clear();
    otStatus.clear();
    overtimeData.clear();
    notesData.clear();

    int days = DateTime(
      selectedYear,
      selectedMonth + 1,
      0,
    ).day;

    for (int i = 1; i <= days; i++) {
      attendanceData[i] =
          box.get("attendance_${selectedYear}_${selectedMonth}_$i", defaultValue: "");

      otStatus[i] =
          box.get("ot_status_${selectedYear}_${selectedMonth}_$i", defaultValue: false);

      overtimeData[i] =
          (box.get("ot_${selectedYear}_${selectedMonth}_$i", defaultValue: 0) as num)
              .toDouble();

      notesData[i] =
          box.get("note_${selectedYear}_${selectedMonth}_$i", defaultValue: "");
    }

    setState(() {});
  }

  void openNoteSheet(int date) {

    final lang = AppLanguage.values[
    Provider.of<LanguageProvider>(context, listen: false)
        .locale
        .languageCode]!;

    TextEditingController noteController = TextEditingController(
      text: notesData[date] ?? "",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setBottomState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                           Text(
                            lang["addNote"]!,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            Provider.of<LanguageProvider>(context, listen: false)
                                .locale
                                .languageCode ==
                                "mr"
                                ? DateFormat(
                              "MMM dd, yyyy",
                              "mr",
                            ).format(
                              DateTime(
                                selectedYear,
                                selectedMonth,
                                date,
                              ),
                            )
                                : DateFormat(
                              "MMM dd, yyyy",
                              "en",
                            ).format(
                              DateTime(
                                selectedYear,
                                selectedMonth,
                                date,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      TextField(
                        controller: noteController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: lang["enterNote"]!,
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          notesData[date] = noteController.text;
                        });

                        await Hive.box('labours').put(
                          "note_${selectedYear}_${selectedMonth}_$date",
                          noteController.text,
                        );

                        Navigator.pop(context);
                      },
                      child: Text(
                        lang["save"]!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  String toMarathiNumber(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const marathi = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];

    for (int i = 0; i < english.length; i++) {
      text = text.replaceAll(english[i], marathi[i]);
    }
    return text;
  }

  void openMonthYearPicker(BuildContext context) {
    final lang = AppLanguage.values[
    Provider.of<LanguageProvider>(context, listen: false)
        .locale
        .languageCode]!;

    int selectedMonth = selectedDate.month;
    int selectedYear = selectedDate.year;

    List<String> months = List<String>.from(lang["months"]!);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomState) {
            return Container(
              height: 340,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    // Top handle
                    Container(
                      width: 55,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          lang["selectMonthYear"]!,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: const Icon(Icons.close, size: 24),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Month & Year Row
                    Row(
                      children: [
                        // Month box
                        Expanded(
                          child: Container(
                            height: 55,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_outlined,
                                  size: 30,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButton<int>(
                                    value: selectedMonth,
                                    underline: const SizedBox(),
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 28,
                                      color: Colors.black,
                                    ),
                                    items: List.generate(
                                      12,
                                          (index) => DropdownMenuItem(
                                        value: index + 1,
                                        child: Text(
                                          months[index],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setBottomState(() {
                                        selectedMonth = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Year box
                        Expanded(
                          child: Container(
                            height: 55,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child: DropdownButton<int>(
                              value: selectedYear,
                              underline: const SizedBox(),
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                size: 28,
                                color: Colors.black,
                              ),
                              items: List.generate(
                                10,
                                    (index) {
                                  final year = "${2020 + index}";

                                  return DropdownMenuItem(
                                    value: 2020 + index,
                                    child: Text(
                                      Provider.of<LanguageProvider>(context, listen: false)
                                          .locale
                                          .languageCode ==
                                          "mr"
                                          ? toMarathiNumber(year)
                                          : year,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              onChanged: (value) {
                                setBottomState(() {
                                  selectedYear = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedDate = DateTime(
                              selectedYear,
                              selectedMonth,
                            );
                            this.selectedMonth = selectedMonth;
                            this.selectedYear = selectedYear;
                          });

                          loadAttendanceData();
                          Navigator.pop(context);
                        },
                        child: Text(
                          lang["save"]!,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget attendanceBtn(
      String text,
      Color color, {
        bool selected = false,
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void openEditSheet(BuildContext context) {
    final lang = AppLanguage.values[
    Provider.of<LanguageProvider>(context, listen: false)
        .locale
        .languageCode]!;
    var box = Hive.box('labours');

    final nameController = TextEditingController(
      text: box.get("name", defaultValue: ""),
    );

    final salaryController = TextEditingController(
      text: box.get("salary", defaultValue: ""),
    );

    bool isChanged = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    lang["editProfile"]!,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 25),

                  Text(
                    lang["staffName"]!,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: nameController,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    onChanged: (value) {
                      setState(() {
                        isChanged = true;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    lang["enterSalary"]!,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: salaryController,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        isChanged = true;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isChanged
                            ? Colors.blue
                            : Colors.grey.shade400,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: isChanged
                          ? () async {
                        await box.put("name", nameController.text);
                        await box.put(
                            "salary", salaryController.text);

                        Navigator.pop(context);
                      }
                          : null,
                      child: Text(
                        lang["save"]!,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            ),
            );
          },
        );
      },
    );
  }

  Widget textBox(String hint) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xffe7e5e5),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.grey.shade400,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child: Text(
        hint,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  void openOvertimeSheet(int date) {
    final lang = AppLanguage.values[
    Provider.of<LanguageProvider>(context, listen: false)
        .locale
        .languageCode]!;


    double selectedHours = overtimeData[date] ?? 0;

    TextEditingController hourController = TextEditingController(
      text: selectedHours > 0
          ? "${selectedHours.floor().toString().padLeft(2, '0')}:${((selectedHours % 1) * 60).round().toString().padLeft(2, '0')} ${lang["hrs"]!}"
          : "",
    );

    double salary = double.tryParse(
      Hive.box('labours').get("salary", defaultValue: "0"),
    ) ??
        0;

    double totalAmount = selectedHours * (salary / 8);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setBottomState) {
            return Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        lang["overtime"]!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        DateFormat(
                          "MMM dd, yyyy",
                          Provider.of<LanguageProvider>(context, listen: false)
                              .locale
                              .languageCode,
                        ).format(
                          DateTime(selectedYear, selectedMonth, date),
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (_) {
                          Duration duration = Duration(
                            hours: selectedHours.floor(),
                            minutes: ((selectedHours % 1) * 60).round(),
                          );

                          return Container(
                            height: 320,
                            color: Colors.white,
                            child: Column(
                              children: [

                                SizedBox(
                                  height: 250,
                                  child: CupertinoTimerPicker(
                                    mode: CupertinoTimerPickerMode.hm,
                                    initialTimerDuration: duration,
                                    onTimerDurationChanged: (Duration value) {

                                      selectedHours =
                                          value.inHours + (value.inMinutes % 60) / 60;

                                      double salary = double.tryParse(
                                        Hive.box('labours').get(
                                          "salary",
                                          defaultValue: "0",
                                        ),
                                      ) ??
                                          0;

                                      double hourlyRate = salary / 8;

                                      totalAmount = selectedHours * hourlyRate;

                                      setBottomState(() {
                                        hourController.text =
                                        "${value.inHours.toString().padLeft(2, '0')}:${(value.inMinutes % 60).toString().padLeft(2, '0')} ${lang["hrs"]!}";
                                      });
                                    },
                                  ),
                                ),

                                SizedBox(
                                  width: double.infinity,
                                  child: CupertinoButton(
                                    child: Text(lang["done"]!),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },

                    child: AbsorbPointer(
                      child: TextField(
                        controller: hourController,
                        decoration: InputDecoration(
                          hintText: "Select Hours",
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        lang["totalovertimeamount"]!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "₹$totalAmount",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        await Hive.box('labours').put(
                          "ot_${selectedYear}_${selectedMonth}_$date",
                          selectedHours,
                        );

                        setState(() {
                          overtimeData[date] = selectedHours;
                        });

                        loadAttendanceData();

                        Navigator.pop(context);
                      },
                      child: Text(
                        lang["save"]!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void openInfoSheet(int date) {
    final lang = AppLanguage.values[
    Provider.of<LanguageProvider>(context, listen: false)
        .locale
        .languageCode]!;
    String status = attendanceData[date] ?? "No Mark";
    bool isOT = (overtimeData[date] ?? 0) > 0;
    double otHours = overtimeData[date] ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${lang["attendanceInfo"]!} - ${DateFormat(
                  'dd MMMM yyyy',
                  Provider.of<LanguageProvider>(context, listen: false)
                      .locale
                      .languageCode,
                ).format(
                  DateTime(selectedYear, selectedMonth, date),
                )}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              infoRow(
                lang["status"]!,
                status == "P"
                    ? lang["present"]!
                    : status == "A"
                    ? lang["absent"]!
                    : lang["notMarked"]!,
              ),

              const SizedBox(height: 15),

              infoRow(
                lang["overtime"]!,
                isOT ? lang["yes"]! : lang["no"]!,
              ),

              const SizedBox(height: 15),

              infoRow(
                  lang["otHours"]!,
                "${otHours.toStringAsFixed(1)} ${lang["hrs"]!}",
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget infoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget rowItem(int date, String day) {
    final lang = AppLanguage.values[
    Provider.of<LanguageProvider>(context, listen: false)
        .locale
        .languageCode]!;

    bool isMarathi =
        Provider.of<LanguageProvider>(context, listen: false)
            .locale
            .languageCode ==
            "mr";

    final today = DateTime.now();

    bool isToday =
        date == today.day &&
            selectedMonth == today.month &&
            selectedYear == today.year;

    String status = attendanceData[date] ?? "";
    bool isOT = (overtimeData[date] ?? 0) > 0;

    bool isAbsent = status == "A";
    bool isPresent = status == "P";

    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isMarathi
                      ? toMarathiNumber(date.toString().padLeft(2, "0"))
                      : date.toString().padLeft(2, "0"),
                  style: TextStyle(
                    fontSize: 20,
                    color: isToday ? Colors.blue : Colors.black,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  day,
                  style: TextStyle(
                    color: isToday ? Colors.blue : Colors.black,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                  children: [
                    // A button
                    if (!isPresent)
                      attendanceBtn(
                        "A",
                        Colors.red,
                        selected: isAbsent,
                        onTap: () async {
                          if (attendanceData[date] == "A") {
                            // Remove Absent
                            setState(() {
                              attendanceData[date] = "";
                            });

                            await Hive.box('labours').put(
                              "attendance_${selectedYear}_${selectedMonth}_$date",
                              "",
                            );
                          } else {
                            // Mark Absent
                            setState(() {
                              attendanceData[date] = "A";
                            });

                            await Hive.box('labours').put(
                              "attendance_${selectedYear}_${selectedMonth}_$date",
                              "A",
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(lang["absentMarked"]!),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),

                    if (!isPresent) const SizedBox(width: 8),

                    // P button
                    if (!isAbsent)
                      attendanceBtn(
                        "P",
                        Colors.green,
                        selected: isPresent,
                        onTap: () async {
                          if (attendanceData[date] == "P") {
                            // Remove Present
                            setState(() {
                              attendanceData[date] = "";
                            });

                            await Hive.box('labours').put(
                              "attendance_${selectedYear}_${selectedMonth}_$date",
                              "",
                            );
                          } else {
                            // Mark Present
                            setState(() {
                              attendanceData[date] = "P";
                            });

                            await Hive.box('labours').put(
                              "attendance_${selectedYear}_${selectedMonth}_$date",
                              "P",
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(lang["presentMarked"]!),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),

                    if (!isAbsent) const SizedBox(width: 8),

                    // OT button (always visible)
                    attendanceBtn(
                      "OT",
                      Colors.purple,
                      selected: isOT,
                      onTap: () async {
                        // setState(() {
                        //   otStatus[date] = true;
                        // });
                        //
                        // await Hive.box('labours').put(
                        //   "ot_status_${selectedYear}_${selectedMonth}_$date",
                        //   true,
                        // );

                        openOvertimeSheet(date);

                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                            content: Text(lang["overtimeMarked"]!),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),

                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        openInfoSheet(date);
                      },
                      child: const Icon(Icons.more_vert),
                    ),
                  ],
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              openNoteSheet(date);
            },
            child: Container(
              width: 95,
              alignment: Alignment.center,
              child: const Icon(Icons.arrow_forward_ios,size: 18),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage.values[
    Provider.of<LanguageProvider>(context).locale.languageCode]!;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 18),
          child: ValueListenableBuilder(
            valueListenable: Hive.box('labours').listenable(),
            builder: (context, box, _) {
              String staffName = box.get(
                "name",
                defaultValue: "No Name",
              );

              return Text(
                staffName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => openEditSheet(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 3,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(
                color: Colors.grey.shade800,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.black,
                ),
                const SizedBox(width: 4),
                Text(
                  lang["edit"]!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.delete_outline, color: Colors.red, size: 30),
          const SizedBox(width: 12),
        ],
      ),

      body: Column(
        children: [
          // Overview
          Container(
            width: double.infinity,
            color: Colors.grey.shade100,
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        lang["overview"]!,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          openMonthYearPicker(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat(
                                  'MMM yyyy',
                                  lang == AppLanguage.values["mr"] ? "mr" : "en",
                                ).format(selectedDate),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Full width white strip
                Container(
                  width: double.infinity,
                  height: 60,
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      infoBox(
                        Provider.of<LanguageProvider>(context, listen: false)
                            .locale
                            .languageCode ==
                            "mr"
                            ? toMarathiNumber(totalPresent.toStringAsFixed(0))
                            : totalPresent.toStringAsFixed(0),
                        lang["totalPresent"]!,
                        Colors.green,
                      ),

                      infoBox(
                        Provider.of<LanguageProvider>(context, listen: false)
                            .locale
                            .languageCode ==
                            "mr"
                            ? toMarathiNumber(totalAbsent.toStringAsFixed(0))
                            : totalAbsent.toStringAsFixed(0),
                        lang["totalAbsent"]!,
                        Colors.red,
                      ),

                      infoBox(
                        Provider.of<LanguageProvider>(context, listen: false)
                            .locale
                            .languageCode ==
                            "mr"
                            ? "${toMarathiNumber(totalOvertimeHours.toStringAsFixed(1))}${lang["h"]!}"
                            : "${totalOvertimeHours.toStringAsFixed(1)}${lang["h"]!}",
                        lang["overtime"]!,
                        Colors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Open Report
          Transform.translate(
            offset: const Offset(0, -8),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportScreen(
                      selectedMonth: selectedMonth,
                      selectedYear: selectedYear,
                      attendanceData: attendanceData,
                      overtimeData: overtimeData,
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                color: const Color(0xffedf4ff),
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Center(
                  child: Text(
                    lang["openReport"]!,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Header
          Container(
            height: 45,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                headerBox(lang["date"]!,90),
                headerBox(lang["attendance"]!,null,flex:2),
                headerBox(lang["notes"]!,95)
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: DateTime(
                selectedYear,
                selectedMonth + 1,
                0,
              ).day,
              itemBuilder: (context, index) {
                DateTime currentDate = DateTime(
                  selectedYear,
                  selectedMonth,
                  index + 1,
                );

                final lang = AppLanguage.values[
                Provider.of<LanguageProvider>(context, listen: false)
                    .locale
                    .languageCode]!;

                List<String> dayNames = lang["dayNames"]!;

                String dayName = dayNames[currentDate.weekday - 1];

                return rowItem(index + 1, dayName);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class infoBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const infoBox(this.title, this.subtitle, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}

Widget headerBox(String text, double? width, {int? flex}) {
  Widget child = Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 18),
    decoration: BoxDecoration(
      border: Border(
        right: BorderSide(color: Colors.grey.shade300),
      ),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  if (width != null) {
    return SizedBox(width: width, child: child);
  }
  return Expanded(flex: flex ?? 1, child: child);
}