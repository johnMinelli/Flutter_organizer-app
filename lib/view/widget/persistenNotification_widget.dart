import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/view/widget/card_event_widget.dart';

class persistenNotification extends StatefulWidget {
  @override
  _persistenNotificationState createState() => _persistenNotificationState();
}

class _persistenNotificationState extends State<persistenNotification> {
  final List<Event> listEvent = [
    new Event(
        '1',
        'evento prova 1',
        'descriozione evento 1',
        DateTime(2019, 10, 12, 10, 0, 0),
        DateTime(2019, 10, 12, 12, 0, 0),
        null,
        2,
        'Intervento',
        '#7B9A4B',
        null,
        null,
        null,null,
      null,
      null,),
    new Event(
        '2',
        'evento prova 2',
        'descriozione evento 2',
        DateTime(2019, 10, 13, 10, 0, 0),
        DateTime(2019, 10, 13, 12, 0, 0),
        null,
        2,
        'Intervento',
        '#F8AD09',
        null,
        null,
        null,null,
      null,
      null,),
  ];
  bool checkMultiEvent;
  Map<String, int> mapWaitingEvent;

  @override
  void initState() {
    super.initState();
    mapWaitingEvent = new Map<String, int>();
    listEvent.forEach((event) => _setMapWaitingEvent(event));
    if (listEvent.length > 1) {
      checkMultiEvent = true;
    } else {
      checkMultiEvent = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: checkMultiEvent
          ? viewPersistentMultiEvent()
          : viewPersistentSingleEvent(),
    );
  }

  Widget viewPersistentMultiEvent() {
    return Card(
      child: Container(
          height: 150,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: Colors.grey),
                      width: 6,
                      height: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 15.0),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'INCARICHI IN SOSPESO',
                            style: button_card,
                          ),
                          SizedBox(height: 5),
                          Text(
                            'NUMERO DI INCARICHI IN SOSPESO',
                            style: Text12WhiteNormal,
                          ),
                          Row(
                            children: rectangleEvent(),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(
                          right: 15,
                        ),
                        child: RaisedButton(
                          child: new Text('VISUALIZZA', style: button_card),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0))),
                          color: Colors.grey,
                          elevation: 5,
                          onPressed: () => _actionVisualizza(),
                        ),
                      ),
                    ])
              ],
            ),
          )),
      elevation: 5,
      color: dark,
    );
  }

  Widget viewPersistentSingleEvent() {
    var formatter = new DateFormat('Hm', 'it_IT');
    String oraInizio = formatter.format(listEvent[0].start);
    String oraFine = formatter.format(listEvent[0].end);
    return cardEvent(
      buttonArea: true,
      dateView: true,
      e: listEvent[0],
      hourHeight: 160,
      actionEvent: (ev)=> Utils.PushViewDetailsEvent(context, listEvent[0]),
    );
    /* */
  }

  List<Widget> rectangleEvent() {
    List<Widget> r = new List<Widget>();
    mapWaitingEvent.forEach((color, text) => r.add(Container(
        width: 30,
        height: 30,
        margin: EdgeInsets.only(right: 15, top: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            color: HexColor(color)),
        child: Center(
          child: Text("$text", style: button_card),
        ))));
    return r;
  }

  void _actionVisualizza() {
    Utils.NavigateTo(context,global.Constants.waitingEventListRoute,null);
  }

  void _setMapWaitingEvent(Event event) {
    if (mapWaitingEvent[event.color] == null) {
      mapWaitingEvent[event.color] = 1;
    } else {
      mapWaitingEvent[event.color] = mapWaitingEvent[event.color] + 1;
    }
  }
}