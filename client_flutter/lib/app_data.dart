import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:web_socket_channel/io.dart';

// Access appData globaly with:
// AppData appData = Provider.of<AppData>(context);
// AppData appData = Provider.of<AppData>(context, listen: false)

enum ConnectionStatus {
  disconnected,
  connected,
}

class AppData with ChangeNotifier {
  String ip = "localhost";
  String port = "8888";
  String usu = "";
  bool tuTurno = false;
  int puntuacionRival = 0;
  int miPuntuacion = 0;
  List<dynamic> board = ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"];

  List<dynamic> boardColors = [];

  IOWebSocketChannel? _channel;
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;

  String? mySocketId;
  List<String> clients = [];
  String selectedClient = "";
  int? selectedClientIndex;
  String messages = "";
  int tiradas = 0;

  AppData() {
    _getLocalIpAddress();
  }

  void _getLocalIpAddress() async {
    try {
      final List<NetworkInterface> interfaces = await NetworkInterface.list(
          type: InternetAddressType.IPv4, includeLoopback: false);
      if (interfaces.isNotEmpty) {
        final NetworkInterface interface = interfaces.first;
        final InternetAddress address = interface.addresses.first;
        ip = address.address;
        notifyListeners();
      }
    } catch (e) {
      // ignore: avoid_print
      print("Can't get local IP address : $e");
    }
  }

  void connectToServer() async {
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));

    _channel = IOWebSocketChannel.connect("ws://$ip:$port");
    _channel!.stream.listen(
      (message) {
        final data = jsonDecode(message);

        if (connectionStatus != ConnectionStatus.connected) {
          connectionStatus = ConnectionStatus.connected;
        }

        switch (data['type']) {
          case "turno":
                tuTurno = true;
                print("lo recibi");
                
                break;
            case "board":
                board.clear();
                board = data["list"];
                puntuacionRival=data["puntuacion"];

                board.remove(mySocketId);
                print("board recibido");
                
            
                
            break;
          case 'list':
            boardColors = data["list"];
            break;
          case 'disconnected':
            String removeId = data['id'];
            if (selectedClient == removeId) {
              selectedClient = "";
            }
            clients.remove(data['id']);
            messages += "Disconnected client: ${data['id']}\n";
            break;
          default:
            break;
        }

        notifyListeners();
      },
      onError: (error) {
        connectionStatus = ConnectionStatus.disconnected;
        mySocketId = "";
        selectedClient = "";
        clients = [];
        messages = "";
        notifyListeners();
      },
      onDone: () {
        connectionStatus = ConnectionStatus.disconnected;
        mySocketId = "";
        selectedClient = "";
        clients = [];
        messages = "";
        notifyListeners();
      },
    );
  }

  disconnectFromServer() async {
    notifyListeners();

    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 1));

    _channel!.sink.close();
  }

  int contarRepeticionesTotales(List<dynamic> lista) {
    int contador = 0;

    for (int i = 0; i < lista.length; i++) {
      String elementoActual = lista[i];

      if (elementoActual != "-") {
        for (int j = i + 1; j < lista.length; j++) {
          String otroElemento = lista[j];

          if (otroElemento != "-" && elementoActual == otroElemento) {
            contador++;
          }
        }
      }
    }

    print("Se repite $contador veces.");
    return contador;
  }

  messageBoard() {
    final message = {
      'type': 'board',
      'from': 'cliente',
      'puntuacion': miPuntuacion,
      'value': board,
      'desti' : mySocketId
    };
    _channel!.sink.add(jsonEncode(message));
  }
  List modificarSinRepeticiones(List<dynamic> lista) {
  for (int i = 0; i < lista.length; i++) {
    String elementoActual = lista[i];

    // Añadimos una condición para asegurarnos de que elementoActual no sea "-"
    if (elementoActual != "-") {
      bool seRepite = false;

      for (int j = i + 1; j < lista.length; j++) {
        String otroElemento = lista[j];

        // Añadimos una condición para asegurarnos de que otroElemento no sea "-"
        if (otroElemento != "-" && elementoActual == otroElemento) {
          seRepite = true;
          break;
        }
      }

      if (!seRepite) {
        // Si no se repite, modificamos la lista original para hacer que sea "-"
        lista[i] = "-";
      }
    }
  }
  return lista;
}
}
