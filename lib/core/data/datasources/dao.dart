import 'package:drift/drift.dart';

import 'database.dart';

part 'dao.g.dart';

class ItemsWithCategoryDescription{
  ItemsWithCategoryDescription(this.item,this.category);
  final TodoItem item;
  final TodoCategoryData category;
}

@DriftAccessor(tables: [TodoItems])
class TodoItemsDao extends DatabaseAccessor<AppDatabase> with _$TodoItemsDaoMixin {
  TodoItemsDao(AppDatabase db) : super(db);

  // ==============================================================================
  // delete
  // ==============================================================================
  Future<List<TodoItem>> deleteAllTodos() async{
    return delete(todoItems).goAndReturn();
  }

  Future<List<TodoItem>> deleteItemWithTitle(String title){
    return (delete(todoItems)..where((t)=>t.title.equals(title))).goAndReturn();
  }

  Future<List<TodoItem>> deleteItemsWithTitles(List<String> titles, {required whenComplete}){
    final List<TodoItem> items = [];
    return transaction<List<TodoItem>>(() async {
      for(int i=0;i<titles.length;i++){
        final deletedItems = await deleteItemWithTitle(titles[i]);
        items.addAll(deletedItems);
      }
      return items;
    });
  }

  // ==============================================================================
  // findBy
  // ==============================================================================
  Future<TodoItem> findById(int id){
    return (select(todoItems)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<List<TodoItem>> findByCategoryId(int id){
    return (select(todoItems)..where((t) => t.category.equals(id))).get();
  }

  Future<TodoItem> findByTitle(String title){
    return (select(todoItems)..where((t)=>t.title.equals(title))).getSingle();
  }

  // ==============================================================================
  // get
  // ==============================================================================
  Future<List<ItemsWithCategoryDescription>> getItemsWithCategory(){
    final query = (select(todoItems).join([
      innerJoin(todoCategory, todoCategory.id.equalsExp(todoItems.category))
    ]));

    return query.map((row){
      return ItemsWithCategoryDescription(row.readTable(todoItems), row.readTable(todoCategory));
    }).get();
  }

  Future<List<ItemsWithCategoryDescription>> getItemsWithCertainCategory(String category){
    final query = (select(todoItems).join([
      innerJoin(todoCategory, todoCategory.id.equalsExp(todoItems.category))
    ]))..where(todoCategory.description.equals(category));

    return query.map((row){
      return ItemsWithCategoryDescription(row.readTable(todoItems), row.readTable(todoCategory));
    }).get();
  }

  // ==============================================================================
  // update
  // ==============================================================================
  Future<List<TodoItem>> updateWhereId(int id, TodoItem target){
    return (update(todoItems)..where((t) => t.id.equals(id))).writeReturning(target);
  }

  // ==============================================================================
  // insert
  // ==============================================================================
  Future<TodoItem> addTodoItem(TodoItemsCompanion item){
    return into(todoItems).insertReturning(item);
  }

  Future<void> addItems(List<TodoItemsCompanion> items,{void Function()? whenComplete}){
    return transaction(() async {
      for(int i=0;i<items.length;i++){
        await into(todoItems).insert(items[i]);
      }
    }).whenComplete((){
      if(whenComplete!=null) whenComplete();
    });
  }
}

@DriftAccessor(tables: [TodoItems])
class TodoCategoryDao extends DatabaseAccessor<AppDatabase> with _$TodoCategoryDaoMixin {
  TodoCategoryDao(AppDatabase db) : super(db);

  // ==============================================================================
  // delete
  // ==============================================================================
  Future<TodoCategoryData> deleteCategoryWithDescription(String description, {void Function()? whenComplete}){
    return transaction<TodoCategoryData>(() async {
      final c = await (select(todoCategory)..where((t)=>t.description.equals(description))).getSingle();
      await (delete(todoCategory)..where((t) => t.id.equals(c.id))).go();
      await (update(todoItems)..where((t) => t.category.equals(c.id))).write(const TodoItemsCompanion(category: Value<int?>(null)));
      return c;
    })..whenComplete((){
      if(whenComplete!=null) whenComplete();
    });
  }

  // ==============================================================================
  // findBy
  // ==============================================================================
  Future<TodoCategoryData> findByDescription(String description){
    return (select(todoCategory)..where((t) => t.description.equals(description))).getSingle();
  }

  // ==============================================================================
  // insert
  // ==============================================================================
  Future<TodoCategoryData> insert(String description){
    return into(todoCategory).insertReturning(TodoCategoryCompanion(description: Value<String>(description)));
  }

  Future<void> insertAll(List<String> descriptions) async{
    await batch(((batch){
      batch.insertAll(todoCategory, List<TodoCategoryCompanion>.generate(
          descriptions.length,
              (i) => TodoCategoryCompanion(description: Value<String>(descriptions[i])))
      );
    }));
  }
}

@DriftAccessor(tables: [TodoPriority])
class TodoPriorityDao extends DatabaseAccessor<AppDatabase> with _$TodoPriorityDaoMixin {
  TodoPriorityDao(AppDatabase db) : super(db);

  // ==============================================================================
  // findBy
  // ==============================================================================
  Future<TodoPriorityData> findByDescription(String description){
    return (select(todoPriority)..where((t) => t.description.equals(description))).getSingle();
  }

  // ==============================================================================
  // insert
  // ==============================================================================
  Future<void> insert(String priority){
    return into(todoPriority).insert(TodoPriorityCompanion(description: Value<String>(priority)));
  }

  Future<void> insertAll(List<String> descriptions) async{
    await batch(((batch){
      batch.insertAll(todoPriority, List<TodoPriorityCompanion>.generate(
          descriptions.length,
              (i) => TodoPriorityCompanion(description: Value<String>(descriptions[i])))
      );
    }));
  }

  // ==============================================================================
  // delete
  // ==============================================================================
  Future<List<TodoPriorityData>> deletePriority(String description) async {
    return await (delete(todoPriority)..where((t) => t.description.equals(description))).goAndReturn();
  }
}