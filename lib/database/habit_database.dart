import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tracker/models/app_settings.dart';
import 'package:tracker/models/habit.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  //INITIALIZE - DATABASE
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema],
      directory: dir.path,
    );
  }

  //Save first date of app startup (for heatmap)
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  //Get first date of app startup(for heatmap)
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

//CRUD
  //List of habits
  final List<Habit> currentHabits = [];

  //CREATE- add a new habit
  Future<void> addHabit(String habitName) async {
    final newHabit = Habit()..name = habitName;

    //save to db
    await isar.writeTxn(() => isar.habits.put(newHabit));
    //re-read from database
    readHabits();
  }

  //READ -read saved habits from db
  Future<void> readHabits() async {
    //fetch all habits
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    //give to current habits
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);
    //update UI
    notifyListeners();
  }

  //Update --
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    //get specific habit by id
    final habit = await isar.habits.get(id);
    //update completion status
    if (habit != null) {
      await isar.writeTxn(() async {
        // if the habit is completed -> add the current date to the completed days list
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          // take todays date
          final today = DateTime.now();
          // and add the current date if its  not on the list
          habit.completedDays.add(
            DateTime(
              today.year,
              today.month,
              today.day,
            ),
          );
        }
        //if habit is not completed -> remove the current date from the list
        else {
          habit.completedDays.removeWhere(
            (date) =>
                date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day,
          );
        }

        //save the updated habits to the database
        await isar.habits.put(habit);
      });
    }
    //re-read from db
    readHabits();
  }
  //UPDATE -Edit name of the habit
  Future<void> updateHabitName (int id, String newName) async {
    //take specific habit
    final habit  = await isar.habits.get(id);

    //update habit name
    if(habit != null){
      //update habit name
      await isar.writeTxn(() async{
        habit.name = newName;
        //save updated habit back to the db
        await isar.habits.put(habit);
      });
    }
    //re-read from db
    readHabits();
  }
  //DELETE - Delete habit from db
  Future<void> deleteHabit(int id) async{
    //perform the delete
    await isar.writeTxn(() async{
      await isar.habits.delete(id);
    });
    readHabits();
  }

}
