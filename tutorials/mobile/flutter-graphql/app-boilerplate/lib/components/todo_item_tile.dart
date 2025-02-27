import 'package:app_boilerplate/model/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class TodoItemTile extends StatelessWidget {
  final TodoItem item;
  final String deleteDocument;
  final Map<String, dynamic> deleteRunMutaion;
  final String toggleDocument;
  final Map<String, dynamic> toggleRunMutaion;
  final Function refetchQuery;
  TodoItemTile({
    Key key,
    @required this.item,
    @required this.deleteDocument,
    @required this.deleteRunMutaion,
    this.refetchQuery,
    @required this.toggleDocument,
    @required this.toggleRunMutaion,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
      child: ListTile(
          contentPadding: EdgeInsets.all(0),
          title: Text(item.task,
              style: TextStyle(
                  decoration: item.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none)),
          leading: Mutation(
            options: MutationOptions(
              document: toggleDocument,
              update: (Cache cache, QueryResult result) {
                if (result.hasException) {
                  print(result.exception);
                } else {
                  final Map<String, Object> updated =
                      Map<String, Object>.from(item.toJson())
                        ..addAll(extractTodoData(result.data));
                  cache.write(typenameDataIdFromObject(updated), updated);
                }
                return cache;
              },
              onCompleted: (onValue) {
                refetchQuery();
              },
            ),
            builder: (
              RunMutation runMutation,
              QueryResult result,
            ) {
              return InkWell(
                onTap: () {
                  runMutation(
                    toggleRunMutaion,
                    optimisticResult: {
                      "action": {
                        "returning": [
                          {"is_completed": !item.isCompleted}
                        ]
                      }
                    },
                  );
                },
                child: Container(
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(!item.isCompleted
                      ? Icons.radio_button_unchecked
                      : Icons.radio_button_checked),
                ),
              );
            },
          ),
          trailing: Mutation(
            options: MutationOptions(document: deleteDocument),
            builder: (
              RunMutation runMutation,
              QueryResult result,
            ) {
              return InkWell(
                onTap: () {
                  runMutation(deleteRunMutaion);
                },
                child: Container(
                    decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: Colors.grey))),
                    width: 60,
                    height: double.infinity,
                    child: Icon(Icons.delete)),
              );
            },
          )),
    ));
  }

  Map<String, Object> extractTodoData(Object data) {
    final Map<String, Object> returning =
        (data as Map<String, Object>)['action'] as Map<String, Object>;
    if (returning == null) {
      return null;
    }
    List<Object> list = returning['returning'];
    return list[0] as Map<String, Object>;
  }
}
