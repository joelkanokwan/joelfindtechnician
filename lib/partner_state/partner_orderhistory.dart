import 'package:flutter/material.dart';
import 'package:joelfindtechnician/state/event.dart';
import 'package:table_calendar/table_calendar.dart';

class PartnerOrderHistory extends StatefulWidget {
  const PartnerOrderHistory({Key? key}) : super(key: key);

  @override
  State<PartnerOrderHistory> createState() => _PartnerOrderHistoryState();
}

class _PartnerOrderHistoryState extends State<PartnerOrderHistory> {
  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Partner OrderHistory'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          buildCalendar(),
          SizedBox(height: 20),
          buildtransaction(),
        ],
      ),
    );
  }

  TableCalendar<dynamic> buildCalendar() {
    return TableCalendar(
      focusedDay: selectedDay,
      firstDay: DateTime(2022),
      lastDay: DateTime(2032),
      onFormatChanged: (CalendarFormat _format) {
        setState(() {
          format = _format;
        });
      },
      calendarFormat: format,
      startingDayOfWeek: StartingDayOfWeek.monday,
      daysOfWeekVisible: true,
      onDaySelected: (DateTime selectDay, DateTime focusDay) {
        setState(() {
          selectedDay = selectDay;
          focusedDay = focusDay;
        });
        print(focusedDay);
      },
      selectedDayPredicate: (DateTime date) {
        return isSameDay(selectedDay, date);
      },
      headerStyle: HeaderStyle(
        leftChevronIcon: const Icon(
          Icons.chevron_left,
          size: 24,
          color: Colors.black54,
        ),
        rightChevronIcon: const Icon(
          Icons.chevron_right,
          size: 24,
          color: Colors.black54,
        ),

        formatButtonVisible: true,
        formatButtonShowsNext: false,

        formatButtonDecoration: BoxDecoration(
          color: Colors.lightBlueAccent,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5),
        ),
        formatButtonTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 87, 80, 80),
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
        // titleCentered: true,
      ),
      calendarStyle: CalendarStyle(
        isTodayHighlighted: true,
        selectedDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5.0),
        ),
        selectedTextStyle: TextStyle(color: Colors.white),
        todayDecoration: BoxDecoration(
          color: Colors.purpleAccent,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5.0),
        ),
        defaultDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }

  Container buildtransaction() {
    return Container(
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Card(
            color: Colors.redAccent,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Order number : xxxxxxx'),
            ),
          ),
        ],
      ),
    );
  }

  
}
