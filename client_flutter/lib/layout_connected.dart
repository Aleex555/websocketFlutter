import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';

class LayoutConnected extends StatefulWidget {
  const LayoutConnected({Key? key}) : super(key: key);

  @override
  State<LayoutConnected> createState() => _LayoutConnectedState();
}

class _LayoutConnectedState extends State<LayoutConnected> {

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    String usuario = appData.usu;
    int puntuRival = appData.puntuacionRival;
    int miPuntuacion = appData.miPuntuacion;

    return Scaffold(
      appBar: AppBar(
        title: Text('Memory'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Espacio arriba con un texto
          Padding(
            padding: EdgeInsets.only(top: 40.0),
            child: Text(
              
              'En Espera $usuario : $miPuntuacion.   , Le toca a Cristian : $puntuRival.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          // Separación entre el texto y la cuadrícula
          const SizedBox(height: 20.0),
          // Cuadrícula centrada en el medio dentro de un Container
          Center(
            child: Container(
              width: 400, 
              height: 400, 
              child: ImageGridView(),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageGridView extends StatefulWidget {
  const ImageGridView({Key? key}) : super(key: key);

  @override
  _ImageGridViewState createState() => _ImageGridViewState();
}

class _ImageGridViewState extends State<ImageGridView> {
  late List<String> imagePaths;
  late List<bool> clickedStatus;

  @override
  void initState() {
    super.initState();
    imagePaths = List.generate(16, (index) => 'assets/imagen_inicial.jpg');
    clickedStatus = List.generate(16, (index) => false);
  }

  updateImagesAutomatically(AppData appData){
    setState(() {
      for (int i = 0; i < appData.board.length; i++) {
        if (appData.board[i] == '-') {
          imagePaths[i] = 'assets/imagen_inicial.jpg';
        } else {
          // Actualiza la ruta de la imagen según el nuevo estado del tablero
          imagePaths[i] = 'assets/${appData.board[i]}.png';
        }
      }
    });
  }

  // Nueva función que realiza la lógica de onTap
  void onTapLogic(AppData appData, int index) {
    String color = appData.boardColors[index];
    print(appData.board);

    setState(() {
      if (appData.tuTurno == true) {
        clickedStatus[index] = !clickedStatus[index];
        if (clickedStatus[index]) {
          imagePaths[index] = 'assets/$color.png';
          appData.board[index] = color;
        }
        int contador = appData.contarRepeticionesTotales(appData.board);
        print(appData.board);
        if (contador == appData.miPuntuacion + 1) {
          print("---has acertado una ----");
          appData.miPuntuacion++;
          appData.tiradas = 0;
        } else {
          appData.tiradas++;
        }

        if (appData.tiradas == 2) {
          appData.board = appData.modificarSinRepeticiones(appData.board);
          appData.messageBoard();

          Future.delayed(const Duration(seconds:2), () {
          

            for (int i = 0; i < appData.board.length; i++) {
              if (appData.board[i] == '-') {
                imagePaths[i] = 'assets/imagen_inicial.jpg';
              }
            }
            setState(() {});
            appData.tuTurno = false;
          });
          
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    if (appData.tuTurno == false){
      print('hola');
      updateImagesAutomatically(appData);
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: 16,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            // Llamar a la nueva función onTapLogic
            onTapLogic(appData, index);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              imagePaths[index],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}

