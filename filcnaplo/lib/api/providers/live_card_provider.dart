// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:io';

import 'package:filcnaplo/helpers/subject.dart';
import 'package:filcnaplo/models/settings.dart';
import 'package:filcnaplo_kreta_api/models/lesson.dart';
import 'package:filcnaplo_kreta_api/models/week.dart';
import 'package:filcnaplo/utils/format.dart';
import 'package:filcnaplo_kreta_api/providers/timetable_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:live_activities/live_activities.dart';

enum LiveCardState { empty, duringLesson, duringBreak, morning, afternoon, night }

class LiveCardProvider extends ChangeNotifier {
  Lesson? currentLesson;
  Lesson? nextLesson;
  Lesson? prevLesson;
  List<Lesson>? nextLessons;

  LiveCardState currentState = LiveCardState.empty;
  late Timer _timer;
  late final TimetableProvider _lessonProvider;
  late final SettingsProvider _settingsProvider;

  late Duration _delay;

  final _liveActivitiesPlugin = LiveActivities();
  String? _latestActivityId;
  Map<String, String> _lastActivity = {};

  LiveCardProvider({
    required TimetableProvider lessonProvider,
    required SettingsProvider settingsProvider,
  })  : _lessonProvider = lessonProvider,
        _settingsProvider = settingsProvider {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => update());
    lessonProvider.restore().then((_) => update());
    _delay = settingsProvider.bellDelayEnabled ? Duration(seconds: settingsProvider.bellDelay) : Duration.zero;
  }

  @override
  void dispose() {
    _timer.cancel();
    if (_latestActivityId != null && Platform.isIOS) _liveActivitiesPlugin.endActivity(_latestActivityId!);
    super.dispose();
  }

  // Debugging
  static DateTime _now() {
    return DateTime.now();
  }

  String getFloorDifference() {
    final prevFloor = prevLesson!.getFloor();
    final nextFloor = nextLesson!.getFloor();
    if (prevFloor == null || nextFloor == null || prevFloor == nextFloor) {
      return "to room";
    }
    if (nextFloor == 0) {
      return "ground floor";
    }
    if (nextFloor > prevFloor) {
      return "up floor";
    } else {
      return "down floor";
    }
  }

  Map<String, String> toMap() {
    switch (currentState) {
      case LiveCardState.duringLesson:
        return {
          "icon": currentLesson != null ? SubjectIcon.resolve(subject: currentLesson?.subject).name : "book",
          "index": currentLesson != null ? '${currentLesson!.lessonIndex}. ' : "",
          "title": currentLesson != null ? ShortSubject.resolve(subject: currentLesson?.subject).capital() : "",
          "subtitle": currentLesson?.room.replaceAll("_", " ") ?? "",
          "description": currentLesson?.description ?? "",
          "startDate": ((currentLesson?.start.millisecondsSinceEpoch ?? 0) - _delay.inMilliseconds).toString(),
          "endDate": ((currentLesson?.end.millisecondsSinceEpoch ?? 0) - _delay.inMilliseconds).toString(),
          "nextSubject": nextLesson != null ? ShortSubject.resolve(subject: nextLesson?.subject).capital() : "",
          "nextRoom": nextLesson?.room.replaceAll("_", " ") ?? "",
        };
      case LiveCardState.duringBreak:
        final iconFloorMap = {
          "to room": "chevron.right.2",
          "up floor": "arrow.up.right",
          "down floor": "arrow.down.left",
          "ground floor": "arrow.down.left",
        };

        final diff = getFloorDifference();

        return {
          "icon": iconFloorMap[diff] ?? "cup.and.saucer",
          "title": "Szünet",
          "description": "Maradj ebben a teremben.",
          "startDate": ((prevLesson?.end.millisecondsSinceEpoch ?? 0) - _delay.inMilliseconds).toString(),
          "endDate": ((nextLesson?.start.millisecondsSinceEpoch ?? 0) - _delay.inMilliseconds).toString(),
          "nextSubject": nextLesson != null ? ShortSubject.resolve(subject: nextLesson?.subject) : "",
          "nextRoom": nextLesson?.room.replaceAll("_", " ") ?? "",
          "index": "",
          "subtitle": "",
        };
      default:
        return {};
    }
  }

  void update() async {
    if (Platform.isIOS) {
      final cmap = toMap();
      if (cmap != _lastActivity) {
        _lastActivity = cmap;

        if (_lastActivity != {}) {
          if (_latestActivityId == null) {
            _liveActivitiesPlugin.createActivity(_lastActivity).then((value) => _latestActivityId = value);
          } else {
            _liveActivitiesPlugin.updateActivity(_latestActivityId!, _lastActivity);
          }
        } else {
          if (_latestActivityId != null) _liveActivitiesPlugin.endActivity(_latestActivityId!);
        }
      }
    }

    List<Lesson> today = _today(_lessonProvider);

    if (today.isEmpty) {
      await _lessonProvider.fetch(week: Week.current());
      today = _today(_lessonProvider);
    }

    _delay = _settingsProvider.bellDelayEnabled ? Duration(seconds: _settingsProvider.bellDelay) : Duration.zero;

    final now = _now().add(_delay);

    // Filter cancelled lessons #20
    today = today.where((lesson) => lesson.status?.name != "Elmaradt").toList();

    if (today.isNotEmpty) {
      // sort
      today.sort((a, b) => a.start.compareTo(b.start));

      final _lesson = today.firstWhere((l) => l.start.isBefore(now) && l.end.isAfter(now), orElse: () => Lesson.fromJson({}));

      if (_lesson.start.year != 0) {
        currentLesson = _lesson;
      } else {
        currentLesson = null;
      }

      final _next = today.firstWhere((l) => l.start.isAfter(_now()), orElse: () => Lesson.fromJson({}));
      nextLessons = today.where((l) => l.start.isAfter(_now())).toList();

      if (_next.start.year != 0) {
        nextLesson = _next;
      } else {
        nextLesson = null;
      }

      final _prev = today.lastWhere((l) => l.end.isBefore(now), orElse: () => Lesson.fromJson({}));

      if (_prev.start.year != 0) {
        prevLesson = _prev;
      } else {
        prevLesson = null;
      }
    }

    if (currentLesson != null) {
      currentState = LiveCardState.duringLesson;
    } else if (nextLesson != null && prevLesson != null) {
      currentState = LiveCardState.duringBreak;
    } else if (now.hour >= 12 && now.hour < 20) {
      currentState = LiveCardState.afternoon;
    } else if (now.hour >= 20) {
      currentState = LiveCardState.night;
    } else if (now.hour >= 5 && now.hour <= 10) {
      currentState = LiveCardState.morning;
    } else {
      currentState = LiveCardState.empty;
    }

    notifyListeners();
  }

  bool get show => currentState != LiveCardState.empty;

  Duration get delay => _delay;

  bool _sameDate(DateTime a, DateTime b) => (a.year == b.year && a.month == b.month && a.day == b.day);

  List<Lesson> _today(TimetableProvider p) => p.lessons.where((l) => _sameDate(l.date, _now())).toList();
}