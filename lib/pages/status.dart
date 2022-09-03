import 'package:flutter/material.dart';
import 'package:flutter_brandname/services/socket_service.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.message),
          onPressed: () {
            print('Sended');
            socketService.socket.emit('flutter-test',
                {'name': 'Flutter', 'message': 'Hello from Flutter'});
          },
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Server Status: ${socketService.serverStatus}'),
            ],
          ),
        ));
  }
}
