import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_brandname/models/band.dart';
import 'package:flutter_brandname/services/socket_service.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> lstBand = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', (payload) {
      _handleActiveBands(payload);
    });
    super.initState();
  }

  _handleActiveBands(dynamic data) {
    lstBand = (data as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Band Names",
            style: TextStyle(
              color: Colors.black87,
            )),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.Online
                ? const Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                  )
                : const Icon(
                    Icons.offline_bolt,
                    color: Colors.red,
                  ),
          )
        ],
      ),
      body: Column(
        children: [
          Center(
            child: _showGraph(lstBand),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: lstBand.length,
              itemBuilder: (_, int index) => _bandTile(lstBand[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewBand,
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => socketService.socket.emit('removeBand', band.id),
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Delete Band",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            band.name.substring(0, 2).toUpperCase(),
          ),
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: const TextStyle(fontSize: 20),
        ),
        onTap: () => socketService.socket.emit('addVote', band.id),
      ),
    );
  }

  _addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (context) {
            final socketService = Provider.of<SocketService>(context);
            return AlertDialog(
              title: Text("New Band Name"),
              content: TextField(
                controller: textController,
              ),
              actions: <Widget>[
                MaterialButton(
                    elevation: 5,
                    textColor: Colors.blue,
                    onPressed: () =>
                        addBandToList(textController.text, socketService),
                    child: Text("Add"))
              ],
            );
          });
    } else if (Platform.isIOS) {
      return showCupertinoDialog(
          context: context,
          builder: (context) {
            final socketService = Provider.of<SocketService>(context);
            return CupertinoAlertDialog(
              title: Text("New Band Name"),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text("Add"),
                  isDefaultAction: true,
                  onPressed: () =>
                      addBandToList(textController.text, socketService),
                ),
                CupertinoDialogAction(
                    child: Text("Cancel"),
                    isDestructiveAction: true,
                    onPressed: () => Navigator.pop(context)),
              ],
            );
          });
    }
  }

  void addBandToList(String bandName, SocketService socketService) {
    if (bandName.length > 1) {
      socketService.socket.emit('addBand', bandName);
    }

    Navigator.pop(context);
  }
}

Widget _showGraph(List<Band> bands) {
  Map<String, double> dataMap = new Map();
  bands.forEach(
      (band) => {dataMap.putIfAbsent(band.name, () => band.votes.toDouble())});

  return PieChart(
    dataMap: dataMap,
    animationDuration: const Duration(milliseconds: 800),
    initialAngleInDegree: 0,
    chartValuesOptions: const ChartValuesOptions(
      showChartValueBackground: true,
      showChartValues: true,
      showChartValuesInPercentage: false,
      showChartValuesOutside: false,
      decimalPlaces: 1,
    ),
    colorList: const [Colors.blue, Colors.pink, Colors.yellow, Colors.green],
  );
}
