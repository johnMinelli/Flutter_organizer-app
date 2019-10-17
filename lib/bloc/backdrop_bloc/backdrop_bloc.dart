import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fb_auth/fb_auth.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/repository/events_repository.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/view/daily_calendar_view.dart';
import 'package:venturiautospurghi/view/details_event_view.dart';
import 'package:venturiautospurghi/view/form_event_creator_view.dart';
import 'package:venturiautospurghi/view/monthly_calendar_view.dart';
import 'package:venturiautospurghi/view/operator_list_view.dart';
import 'package:venturiautospurghi/view/waiting_event_view.dart';

part 'backdrop_event.dart';

part 'backdrop_state.dart';

class BackdropBloc extends Bloc<BackdropEvent, BackdropState> {
  AuthUser user;
  bool isSupervisor;
  final EventsRepository eventsRepository = EventsRepository();

  BackdropBloc(this.user, this.isSupervisor);

  @override
  BackdropState get initialState => NotReady();

  @override
  Stream<BackdropState> mapEventToState(BackdropEvent event) async* {
    if (event is NavigateEvent) {
      yield* _mapUpdateViewToState(event);
    }
  }

  Stream<BackdropState> _mapUpdateViewToState(NavigateEvent event) async* {
    //TODO all queries
    dynamic content;
    var subscription;
    int subtype;
    switch(event.route) {
      case global.Constants.homeRoute: {
        if(isSupervisor) {
          content = OperatorList();
          subscription = eventsRepository.events;
          subtype = global.Constants.OPERATORS_SUB;
        }else{
          content = DailyCalendar(null);
          subscription = eventsRepository.events;
          subtype = global.Constants.EVENTS_SUB;
        }};
      break;
      case global.Constants.monthlyCalendarRoute: {
        content = MonthlyCalendar(event.arg);
        subscription = eventsRepository.events;
        subtype = global.Constants.EVENTS_SUB;
      }
      break;
      case global.Constants.dailyCalendarRoute: {
        //arg 1: operator
        //arg 2: day
        content = DailyCalendar(event.arg[1]);
        //TODO use here arg 1
        subscription = eventsRepository.events;
        subtype = global.Constants.EVENTS_SUB;
      }
      break;
      case global.Constants.profileRoute: {
        //content = Profile;
      }
      break;
      case global.Constants.operatorListRoute: {
        content = OperatorList;
      }
      break;
      case global.Constants.formEventCreatorRoute: {
        content = EventCreator(event.arg);
      }
      break;
      case global.Constants.waitingEventListRoute: {
        content = waitingEvent();
        //choose the query
        subscription = eventsRepository.events;
        subtype = global.Constants.EVENTS_SUB;
      }
      break;
      default: {content = DailyCalendar(null);}
      break;
    }
    yield Ready(event.route, content, subscription, subtype); //cambia lo stato

  }

}