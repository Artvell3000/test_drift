import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:test_drift/core/data/datasources/dao.dart';

import 'core/data/datasources/database.dart';

// void main() {
//   runApp(const MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  //final daoPriority = TodoPriorityDao(database);
  final daoItems = TodoItemsDao(database);
  //final items = await database.allTodoItems;

  //final priority = await daoPriority.findByDescription('Done');

  // final item1 = await daoItems.findById(12);
  // final item2 = await daoItems.findById(13);
  //
  // daoItems.updateWhereId(12, item1.copyWith(priority: const Value<int?>(3)));
  // daoItems.updateWhereId(13, item2.copyWith(priority: const Value<int?>(3)));

  // for(int i=0;i<items.length;i++){
  //   print(items[i]);
  // }
  final items2 = await daoItems.getItemsWithCertainCategoryAndPriority('Done', 'important');

  for(int i=0;i<items2.length;i++){
    print('${items2[i].priority} = ${items2[i].category} = ${items2[i].item}');
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Drift test'),
//     );
//   }
// }
//
// class MyHomePage extends StatelessWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//       ),
//     );
//   }
// }
