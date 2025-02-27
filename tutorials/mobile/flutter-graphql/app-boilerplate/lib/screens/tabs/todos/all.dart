import 'package:app_boilerplate/components/add_task.dart';
import 'package:app_boilerplate/components/todo_item_tile.dart';
import 'package:app_boilerplate/data/online_fetch.dart';
import 'package:app_boilerplate/data/todo_fetch.dart';
import 'package:app_boilerplate/model/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class All extends StatefulWidget {
  All({Key key}) : super(key: key);

  @override
  _AllState createState() => _AllState();
}

class _AllState extends State<All> {
  VoidCallback refetchQuery;

  static GraphQLClient _client;
  runOnlineMutation(context) {
    _client = GraphQLProvider.of(context).value;
    Future.doWhile(
      () async {
        _client.mutate(
          MutationOptions(
            documentNode: gql(OnlineFetch.updateStatus),
            variables: {
              'now': DateTime.now().toUtc().toIso8601String(),
            },
          ),
        );
        await Future.delayed(Duration(seconds: 30));
        return true;
      },
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => runOnlineMutation(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("All tab");
    return Column(
      children: <Widget>[
        Mutation(
            options: MutationOptions(
              documentNode: gql(TodoFetch.addTodo),
              update: (Cache cache, QueryResult result) {
                return cache;
              },
              onCompleted: (dynamic resultData) {
                refetchQuery();
              },
            ),
            builder: (
              RunMutation runMutation,
              QueryResult result,
            ) {
              return AddTask(
                onAdd: (value) {
                  // todoList.addTodo(value);
                  runMutation({'title': value, 'isPublic': false});
                },
              );
            }),
        Expanded(
          child: Query(
              options: QueryOptions(
                documentNode: gql(TodoFetch.fetchAll),
                variables: {"is_public": false},
              ),
              builder: (QueryResult result,
                  {VoidCallback refetch, FetchMore fetchMore}) {
                refetchQuery = refetch;
                if (result.hasException) {
                  return Text(result.exception.toString());
                }
                if (result.loading) {
                  return Text('Loading');
                }
                final List<LazyCacheMap> todos =
                    (result.data['todos'] as List<dynamic>)
                        .cast<LazyCacheMap>();
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    dynamic responseData = todos[index];
                    return TodoItemTile(
                      item: TodoItem.fromElements(responseData["id"],
                          responseData['title'], responseData['is_completed']),
                      deleteDocument: TodoFetch.deleteTodo,
                      deleteRunMutaion: {
                        'id': responseData["id"],
                      },
                      refetchQuery: refetchQuery,
                      toggleDocument: TodoFetch.toggleTodo,
                      toggleRunMutaion: {
                        'id': responseData["id"],
                        'isCompleted': !responseData['is_completed']
                      },
                    );
                  },
                );
              }),
        ),
      ],
    );
  }
}
