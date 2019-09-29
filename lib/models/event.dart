
class Event {
  String _id="";
  String _title="";
  String _description="";
  DateTime _start=DateTime.now();
  DateTime _end=DateTime.now();
  String _address="";
  int _status=Status.New;
  String _category="";
  String _color="";

  Event(this._id, this._title, this._description, this._start, this._end, this._address, this._status, this._category, this._color);
  Event.empty();
  Event.fromMap(String id, dynamic json){
    _id = (id!=null && id!="e")?id:json.id;
    _title = json["Titolo"];
    _description = json["Descrizione"];
    _start = new DateTime.fromMillisecondsSinceEpoch(json["DataInizio"].seconds*1000);
    _end = new DateTime.fromMillisecondsSinceEpoch(json["DataFine"].seconds*1000);
    _address = json["Indirizzo"];
    _status = json["Stato"];
    _category = json["Categoria"];
    _color = json["color"];
  }

  Map<String, dynamic> toMap(){
    return Map<String, dynamic>.of({
      "id":_id,
      "Title":_title,
      "Description":_description,
      "DataInizio":_start,
      "DataFine":_end,
      "Indirizzo":_address,
      "Status":_status,
      "Categoria":_category,
      "Colore":_color
    });
  }

  String get id => _id;
  String get title => _title;
  String get description => _description;
  DateTime get start => _start;
  DateTime get end => _end;
  String get address => _address;
  int get status => _status;
  String get category => _category;
  String get color => _color;

  set color(String value) {
    _color = value;
  }

  set category(String value) {
    _category = value;
  }

  set status(int value) {
    _status = value;
  }

  set address(String value) {
    _address = value;
  }

  set end(DateTime value) {
    _end = value;
  }

  set start(DateTime value) {
    _start = value;
  }

  set description(String value) {
    _description = value;
  }

  set title(String value) {
    _title = value;
  }

  set id(String value) {
    _id = value;
  }

}

class Status {
  static const int New = 0;
  static const int Delivered = 1;
  static const int Seen = 2;
  static const int Accepted = 3;
  static const int Rejected = 4;
  static const int Ended = 5;
}