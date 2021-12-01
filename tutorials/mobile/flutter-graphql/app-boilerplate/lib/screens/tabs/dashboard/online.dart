import 'package:app_boilerplate/data/online_fetch.dart';
import 'package:app_boilerplate/data/online_list.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Online extends StatelessWidget {
  const Online({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            "Online Users",
            style: TextStyle(fontSize: 28),
          ),
        ),
        // Subscription("", "",
        //     options: SubscriptionOptions(
        //       document: gql(
        //         OnlineFetch.fetchUsers,
        //       ),
        //     ), builder: (result) {
        //   if (result.hasException) {
        //     return Text(result.exception.toString());
        //   }
        //   if (result.isLoading) {
        //     return Center(
        //       child: const CircularProgressIndicator(),
        //     );
        //   }
        //   return Expanded(
        //     child: ListView.builder(
        //       itemCount: onlineList.list.length,
        //       itemCount: payload['online_users'].length,
        //       itemBuilder: (context, index) {
        //         return Card(
        //           child: ListTile(
        //             title: Text(onlineList.list[index]),
        //             title: Text(payload['online_users'][index]['user']['name']),
        //           ),
        //         );
        //       },
        //     ),
        //   );
        // }),
      ],
    );
  }
}
