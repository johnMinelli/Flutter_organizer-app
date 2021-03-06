import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugins/firebase/firebase_messaging.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';

part 'waiting_event_list_state.dart';

class WaitingEventListCubit extends Cubit<WaitingEventListState> {
  final CloudFirestoreService _databaseRepository;
  final Account _account;

  WaitingEventListCubit( CloudFirestoreService databaseRepository, Account account) :
        assert(databaseRepository != null && account != null),
        _databaseRepository = databaseRepository, _account = account,
        super(LoadingEvents()) {
    databaseRepository.subscribeEventsByOperatorWaiting(account.id).listen((waitingEventsList) {
      waitingEventsList.sort((a, b) => a.start.compareTo(b.start));
      emit(ReadyEvents(waitingEventsList));
    });
    Future.delayed(
      Duration(seconds: 2), (){if(state is LoadingEvents) emit(ReadyEvents(List()));},
    );
  }

  void cardActionConfirm(Event event) {
    event.status = Status.Accepted;
    _databaseRepository.updateEventField(event.id, Constants.tabellaEventi_stato, Status.Accepted);
    FirebaseMessagingService.sendNotifications(tokens: event.supervisor.tokens, title: "${_account.surname} ${_account.name} ha accettato il lavoro \"${event.title}\"");
  }

  void cardActionRefuse(Event event, String justification) {
    event.motivazione = justification;
    _databaseRepository.refuseEvent(event);
    FirebaseMessagingService.sendNotifications(tokens: event.supervisor.tokens, title: "${_account.surname} ${_account.name} ha rifiutato il lavoro \"${event.title}\"");
  }

}
