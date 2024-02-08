import 'package:isar/isar.dart';

part 'habit.g.dart';
@Collection()
class Habit{

  // auto incrementing ids for a habits
  Id id = Isar.autoIncrement;

  // prop for the habit name as string
  late String name;

  //completed days
List<DateTime> completedDays = [
  //DateTime(year,month,day);
];

}