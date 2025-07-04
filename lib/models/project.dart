import 'package:hive/hive.dart';

part 'project.g.dart';

@HiveType(typeId: 0)
class Project extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int elapsedSeconds;

  @HiveField(2)
  DateTime? startTime;

  // ✅ Main constructor (for normal use)
  Project({
    required this.name,
    required Duration elapsed,
    this.startTime,
  }) : elapsedSeconds = elapsed.inSeconds;

  // ✅ Factory constructor used by Hive when deserializing
  factory Project.fromFields({
    required String name,
    required int elapsedSeconds,
    DateTime? startTime,
  }) {
    return Project._internal(name, elapsedSeconds, startTime);
  }

  // ✅ Internal constructor to be used by the factory
  Project._internal(this.name, this.elapsedSeconds, this.startTime);

  Duration get elapsed => Duration(seconds: elapsedSeconds);

  set elapsed(Duration value) => elapsedSeconds = value.inSeconds;
}
