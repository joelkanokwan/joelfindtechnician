import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joelfindtechnician/widgets/show_image.dart';
import 'package:joelfindtechnician/widgets/show_text.dart';

class ConfirmJob extends StatefulWidget {
  const ConfirmJob({Key? key}) : super(key: key);

  @override
  _ConfirmJobState createState() => _ConfirmJobState();
}

class _ConfirmJobState extends State<ConfirmJob> {
  DateTime? date;
  TimeOfDay? time;

  String getTime() {
    if (time == null) {
      return 'Appointment Time';
    } else {
      final hours = time!.hour.toString().padLeft(2, '0');
      final minutes = time!.minute.toString().padLeft(2, '0');
      return '$hours:$minutes';
    }
  }

  String getDate() {
    if (date == null) {
      return 'Appointment Date';
    } else {
      return '${date!.day}/${date!.month}/${date!.year}';
    }
  }

  Future pickDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2023),
    );
    if (newDate == null) return;
    setState(() => date = newDate);
  }

  Future pickTime(BuildContext context) async {
    final initialTime = TimeOfDay(hour: 9, minute: 0);
    final newTime = await showTimePicker(
      context: context,
      initialTime: time ?? initialTime,
    );
    if (newTime == null) return;
    setState(() {
      time = newTime;
    });
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
        title: Text('Confirm Job'),
      ),
      body: Container(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shop name :',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Customer name :',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Phone Number :',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Order number :',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Private key :',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Appointment Date :',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(thickness: 3),
                      SizedBox(height: 8),
                      Text(
                        'Address :',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(thickness: 3),
                      SizedBox(height: 8),
                      Text(
                        'Detail of work :',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(thickness: 3),
                      Text(
                        'Total Price :',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(thickness: 3),
                      Text(
                        'Payment method :',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                       Divider(thickness: 3),
                      
                      TextButton(
                          onPressed: () {},
                          child: Text(
                            'QR Code :',
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      Divider(thickness: 3),
                      Row(
                        children: [
                          FlatButton.icon(
                            onPressed: () {
                              pickDate(context);
                            },
                            icon: Icon(
                              Icons.date_range_outlined,
                              size: 30,
                              color: Colors.orange,
                            ),
                            label: Text(getDate()),
                          ),
                          FlatButton.icon(
                            padding: EdgeInsets.only(right: 10),
                            onPressed: () {
                              pickTime(context);
                            },
                            icon: Icon(
                              Icons.watch_later_outlined,
                              size: 30,
                              color: Colors.orange,
                            ),
                            label: Text(getTime()),
                          ),
                        ],
                      ),
                      Container(
                        height: 50,
                        width: 150,
                        child: FlatButton(
                          textColor: Colors.white,
                          color: Colors.blueAccent,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: ListTile(
                                  leading: ShowImage(),
                                  title: ShowText(
                                      title: 'Confirm Change Appointment ?'),
                                  subtitle: ShowText(
                                      title:
                                          'Do you want to confirm appointment ?'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {},
                                    child: Text('OK'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Cancel'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text(
                            'submit',
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      Divider(thickness: 3),
                      Text(
                        '(ชื่อคนขอเลื่อนนัดหมาย)ขอทำการเลื่อนนัดหมาย',
                        style: GoogleFonts.lato(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'วันนัดหมายเดิม :',
                        style: GoogleFonts.lato(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'วันนัดหมายใหม่ :',
                        style: GoogleFonts.lato(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'สถานะ :',
                        style: GoogleFonts.lato(
                          fontSize: 15,
                        ),
                      ),
                      Divider(thickness: 3),
                      Text(
                        'รายละเอียดการดำเนินงาน :',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'เข้างาน :',
                        style: GoogleFonts.lato(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'เลิกงาน :',
                        style: GoogleFonts.lato(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'รายละเอียดงานที่คืบหน้า / สำเร็จแล้ว :',
                        style: GoogleFonts.lato(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'อัตราเปอร์เซ็นงานที่คืบหน้า / สำเร็จแล้ว :',
                        style: GoogleFonts.lato(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'รูปภาพ :',
                        style: GoogleFonts.lato(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // SizedBox(height: 15),
            // Padding(
            // padding: const EdgeInsets.all(8.0),
            // child: Text(
            // 'Shop Name/Customer Name',
            // style: GoogleFonts.lato(
            // fontWeight: FontWeight.bold,
            // color: Colors.red,
            // fontSize: 18),
            // ),
            // ),
            // Padding(
            // padding: const EdgeInsets.all(8.0),
            // child: Text(
            // 'Want to change appointmet to :',
            // style: GoogleFonts.lato(color: Colors.red),
            // ),
            // ),
            // Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            // children: [
            // ElevatedButton(
            // onPressed: () {
            // showDialog(
            // context: context,
            // builder: (context) => AlertDialog(
            // title: ListTile(
            // leading: ShowImage(),
            // title:
            // ShowText(title: 'Confirm Change Appointment ?'),
            // subtitle: ShowText(
            // title:
            // 'If press OK the will change to new appointment time'),
            // ),
            // actions: [
            // TextButton(
            // onPressed: () {},
            // child: Text('OK'),
            // ),
            // TextButton(
            // onPressed: () {
            // Navigator.pop(context);
            // },
            // child: Text('Cancel'),
            // ),
            // ],
            // ),
            // );
            // },
            // child: Text('Confirm'),
            // ),
            // SizedBox(width: 10),
            // ElevatedButton(
            // onPressed: () {
            // showDialog(
            // context: context,
            // builder: (context) => AlertDialog(
            // title: ListTile(
            // leading: ShowImage(),
            // title: ShowText(title: 'Confirm to cancel ?'),
            // subtitle: ShowText(title: 'Appointment still same'),
            // ),
            // actions: [
            // TextButton(
            // onPressed: () {},
            // child: Text('OK'),
            // ),
            // TextButton(
            // onPressed: () {
            // Navigator.pop(context);
            // },
            // child: Text('Cancel'),
            // ),
            // ],
            // ),
            // );
            // },
            // child: Text('Cancel'),
            // ),
            // ],
            // ),
          ],
        ),
      ),
    );
  }
}
