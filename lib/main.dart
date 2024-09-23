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
  final daoCategory = TodoCategoryDao(database);
  final daoItems = TodoItemsDao(database);

  final category = await daoCategory.insert('useless');

  await daoItems.addItems([
    TodoItemsCompanion.insert(title: 'useless1', content: 'useless1', category: Value<int>(category.id)),
    TodoItemsCompanion.insert(title: 'useless2', content: 'useless1', category: Value<int>(category.id)),
    TodoItemsCompanion.insert(title: 'useless3', content: 'useless1', category: Value<int>(category.id)),
  ]);

  print('\n\n${await database.allTodoCategory} \n\n ${await database.allTodoItems}\n\n');

  await daoCategory.deleteCategoryWithDescription('useless', whenComplete: (){
    print('deleted category');
  });

  final deletedItems = await daoItems.deleteItemsWithTitles(['useless1', 'useless2', 'useless3'], whenComplete: (){
    print('deleted items');
  });
  print(deletedItems);
  print('\n\n${await database.allTodoCategory} \n\n ${await database.allTodoItems}\n\n');
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
