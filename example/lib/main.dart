import 'package:flutter/material.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final ZM3UHandler _handler = ZM3UHandler.instance;
  CategorizedM3UData? _display;
  int val = 0;
  Future n() async {
    print("DOWN");
    await _handler.network(
        // "https://iptv-org.github.io/iptv/countries/fr.m3u",
        // "/data/user/0/com.example.example/files/M3UDATA/data.m3u",
        "http://infinity-ott.com:8080/get.php?username=RY05xSsev4z7BRQc&password=qSwUcugDcsgxQQ9s&type=m3u_plus&output=mpegts",
        (value) {
      print("DOWNLOADING $value%");
      val = value.toInt();
      if (mounted) setState(() {});
    }, onExtractionCallback: (d) {
      print("EXTRACTED : $d%");
    }).then((value) {
      print("M3u VLAUE: $value");
      val = 0;
      if (mounted) setState(() {});
    }).onError((error, stackTrace) {
      print("ERROR : $error");
      print("Stacktrace : $stackTrace");
    });
  }

  Future<void> _r() async {
    await _handler.savedData.then((v) => setState(() => _display = v));
    print(_display);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(child: Text("$val%")),
      floatingActionButton: SafeArea(
        child: Row(
          children: [
            FloatingActionButton(
              onPressed: () async {
                await n();
              },
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: () async {
                await _r();
              },
              tooltip: 'Increment',
              child: const Icon(Icons.minimize),
            ),
          ],
        ),
      ),
    );
  }
}
