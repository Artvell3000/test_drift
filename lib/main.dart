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
  final daoItems = TodoItemsDao(database);

  final newItem = await daoItems.addTodoItem(
    TodoItemsCompanion.insert(title: 'new task', content: 'content')
  );

  final foundItem = await daoItems.findByTitle('new task');
  print('new item: $foundItem');

  final updatedItem = await daoItems.updateWhereId(
    foundItem.id,
    foundItem.copyWith(title: 'task with updated title')
  );

  final foundItem2 = await daoItems.findByTitle('task with updated title');
  print('updated item: $foundItem2');

  final deletedItem = await daoItems.deleteItemWithTitle('task with updated title');
  print('deleted item: $deletedItem');

  print('importantItems: ');
  final importantItems = await daoItems.getItemsWithCertainCategory('important');
  for(int i=0;i<importantItems.length;i++){
    print('${importantItems[i].item} - ${importantItems[i].category} ');
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
