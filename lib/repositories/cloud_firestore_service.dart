import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';

class CloudFirestoreService {

  final cf.FirebaseFirestore _cloudFirestore;
  cf.CollectionReference _collectionUtenti;
  cf.CollectionReference _collectionEventi;
  cf.Query _collectionSubStoricoEventi;
  cf.CollectionReference _collectionStoricoEliminati;
  cf.CollectionReference _collectionStoricoTerminati;
  cf.CollectionReference _collectionStoricoRifiutati;
  cf.CollectionReference _collectionCostanti;

  Map<String,dynamic> categories;

  CloudFirestoreService({cf.FirebaseFirestore cloudFirestore})
      : _cloudFirestore = cloudFirestore ??  cf.FirebaseFirestore.instance {
    _collectionUtenti = _cloudFirestore.collection(Constants.tabellaUtenti) ;
    _collectionEventi = _cloudFirestore.collection(Constants.tabellaEventi);
    _collectionSubStoricoEventi = _cloudFirestore.collectionGroup(Constants.subtabellaStorico);
    _collectionStoricoEliminati = _cloudFirestore.collection(Constants.tabellaEventiEliminati);
    _collectionStoricoTerminati = _cloudFirestore.collection(Constants.tabellaEventiTerminati);
    _collectionStoricoRifiutati = _cloudFirestore.collection(Constants.tabellaEventiRifiutati);
    _collectionCostanti = _cloudFirestore.collection(Constants.tabellaCostanti);
  }

  static Future<CloudFirestoreService> create({cf.FirebaseFirestore cloudFirestore}) async {
    CloudFirestoreService instance = CloudFirestoreService(cloudFirestore:cloudFirestore);
    instance.categories = await instance._getCategories();
    return instance;
  }

  /// Function to retrieve from the database the information associated with the
  /// user logged in. The Firebase AuthUser uid must be the same as the id of the
  /// document in the "Utenti" [Constants.tabellaUtenti] collection.
  /// However the mail is also an unique field.
  Future<Account> getAccount(String email) async {
    return _collectionUtenti.where('Email', isEqualTo: email).get().then((snapshot) => snapshot.docs.map((document) => Account.fromMap(document.id, document.data())).first);
  }

  Stream<Account> subscribeAccount(String id)  {
    return _collectionUtenti.doc(id).snapshots().map((user) {
      return Account.fromMap(user.id, user.data());
    });
  }

  Future<List<Account>> getOperatorsFree(String eventIdToIgnore, DateTime startFrom, DateTime endTo) async {
    List<Account> accounts = await this.getOperators();

    final List<Event> listEvents = await this.getEvents();

    listEvents.forEach((event) {
      if (event.id != eventIdToIgnore) {
        if (event.isBetweenDate(startFrom, endTo)) {
          [event.operator, ...event.suboperators].map((e) => e["id"]).forEach((idOperator) {
            bool checkDelete = false;
            for (int i = 0; i < accounts.length && !checkDelete; i++) {
              if (accounts.elementAt(i).id == idOperator) {
                checkDelete = true;
                accounts.removeAt(i);
              }
            }
          });
        }
      }
    });
    return accounts;
  }

  Future<List<Account>> getOperators() async {
    return _collectionUtenti.get().then((snapshot) => snapshot.docs.map((document) => Account.fromMap(document.id, document.data())).toList());
  }

  void addOperator(Account u) {
    _collectionUtenti.doc(u.id).set(u.toDocument());
  }

  void deleteOperator(String id) {
    _collectionUtenti.doc(id).delete();
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  Future<Map<String, dynamic>> _getCategories() async {
    return _collectionCostanti.doc(Constants.tabellaCostanti_Categorie).get().then((document) => document.data());
  }

  Future<Map<String, dynamic>> getPhoneNumbers() async {
    return _collectionCostanti.doc(Constants.tabellaCostanti_Telefoni).get().then((document) => document.data());
  }

  Future<Event> getEvent(String id) async {
    return _collectionEventi.doc(id).get().then((document) =>
        Event.fromMap(document.id, categories[document.get(Constants.tabellaEventi_categoria)??"default"], document.data()));
  }

  Future<List<Event>> getEvents() async {
    return _collectionEventi.get().then((snapshot) => snapshot.docs.map((document) =>
        Event.fromMap(document.id, categories[document.get(Constants.tabellaEventi_categoria)??"default"], document.data())).toList());
  }

  Stream<List<Event>> subscribeEvents() {
    return _collectionEventi.snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, categories[document.get(Constants.tabellaEventi_categoria)??"default"], document.data()));
    });
  }

  Stream<List<Event>> subscribeEventsByOperator(String idOperator) {
    return _collectionEventi.where(Constants.tabellaEventi_idOperatori, arrayContains: idOperator).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, categories[document.get(Constants.tabellaEventi_categoria)??"default"], document.data())).toList();
    });
  }

  Stream<List<Event>> subscribeEventsByOperatorAcceptedOrBelow(String idOperator) {
    return _collectionEventi.where(Constants.tabellaEventi_idOperatori, arrayContains: idOperator).where(Constants.tabellaEventi_stato, isLessThanOrEqualTo: Status.Accepted).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, categories[document.get(Constants.tabellaEventi_categoria)??"default"], document.data())).toList();
    });
  }

  Stream<List<Event>> subscribeEventsByOperatorWaiting(String idOperator) {
    return _collectionEventi.where(Constants.tabellaEventi_idOperatori, arrayContains: idOperator).where(Constants.tabellaEventi_stato, isLessThanOrEqualTo: Status.Seen).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, categories[document.get(Constants.tabellaEventi_categoria)??"default"], document.data())).toList();
    });
  }

  // TODO check that it (still, since is just a refactored code) fetch all the dictionaries.
  // expected -> snapshot per tutti gli eventi nello storico
  Stream<List<Event>> eventsHistory() {
    return _collectionSubStoricoEventi.snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, categories[document.get(Constants.tabellaEventi_categoria)??"default"], document.data())).toList();
    });
  }

  /*TODO i would like to know if the stream need to update (only the change come from into the stream)
         the data or refresh (every time a change occour the full data list come into the stream) */
  Stream<List<Event>> subscribeEventsDeleted() {
    return _collectionStoricoEliminati.snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, categories[document.get(Constants.tabellaEventi_categoria)??"default"], document.data())).toList();
    });
  }

  Stream<List<Event>> subscribeEventsEnded() {
    return _collectionStoricoTerminati.snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, categories[document.get(Constants.tabellaEventi_categoria)??"default"], document.data())).toList();
    });
  }

  Stream<List<Event>> subscribeEventsRefuse() {
    return _collectionStoricoRifiutati.snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, categories[document.get(Constants.tabellaEventi_categoria)??"default"], document.data())).toList();
    });
  }

  Future<String> addEvent(dynamic data) async {
    var docRef = await _collectionEventi.add(data);
    return docRef.id;
  }

  void updateEvent(String id, dynamic data) {
    _collectionEventi.doc(id).update(data);
  }

  void updateEventField(String id, String field, dynamic data) {
    _collectionEventi.doc(id).update(Map.of({field:data}));
  }

  Future<void> updateAccountField(String id, String field, dynamic data) async {
    return _collectionUtenti.doc(id).update(Map.of({field:data}));
  }

  void deleteEvent(Event e) async {
    final dynamic createTransaction = (dynamic tx) async {
      dynamic dc = _collectionEventi.doc(e.id);
      e.status = Status.Deleted; //this set is preventive (if all is done right it SHOULDN'T be necessary)
      await tx.set(_collectionStoricoTerminati.doc(e.id).update(e.toDocument()));
      await tx.update(dc, {Constants.tabellaEventi_stato:e.status});
    };
    _cloudFirestore.runTransaction(createTransaction);
  }

  void endEvent(Event e) {
    final dynamic createTransaction = (dynamic tx) async {
      dynamic dc = _collectionEventi.doc(e.id);
      e.status = Status.Ended; //this set is preventive (if all is done right it SHOULDN'T be necessary)
      await tx.set(_collectionStoricoTerminati.doc(e.id).update(e.toDocument()));
      await tx.update(dc, {Constants.tabellaEventi_stato:e.status});
    };
    _cloudFirestore.runTransaction(createTransaction);
  }

  void refuseEvent(Event e) async {
    final dynamic createTransaction = (dynamic tx) async {
      dynamic dc = _collectionEventi.doc(e.id);
      await tx.set(_collectionStoricoRifiutati.doc(e.id).update(e.toDocument()));
      await tx.delete(dc);
    };
    _cloudFirestore.runTransaction(createTransaction);
  }

  String getUserEmailByPhone(String phoneNumber) {
    //TODO
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

}

//  AuthUser _userFromFirebase(fb.User user) {
//
//    if (user == null) {
//      return null;
//    }
//    return AuthUser (
//      uid: user.uid,
//      email: user.email,
//      displayName: user.displayName,
//      photoUrl: user.photoURL,
//    );
//  }
//
//  Stream<AuthUser> get onAuthStateChanged {
//    return _firebaseAuth.onAuthStateChanged.map(_userFromFirebase);
//  }
