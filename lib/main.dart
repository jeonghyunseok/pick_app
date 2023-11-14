import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(PickApp());
}

class PickApp extends StatelessWidget {
  const PickApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));

    // Perform any other asynchronous initialization tasks here

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Text(
          'PICK!',
          style: TextStyle(fontSize: 42, color: Colors.white),
        ),
      ),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({Key? key}) : super(key: key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  String? _sharedText;
  late InAppWebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();

    ReceiveSharingIntent.getTextStream().listen((String? value) {
      print("shared text: $value");
      setState(() {
        _sharedText = value;
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening URLs/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      setState(() {
        _sharedText = value;
        print('shared info: $value');
      });
    });
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      print("Location permission granted");
    } else if (status.isDenied || status.isPermanentlyDenied) {
      print("Location permission denied");
      showDeniedDialog(context);
    }
  }

  void showDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text(
              'Location permission is denied. You can enable it in settings.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () async {
                await openAppSettings();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse("http://naver.com")),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
      ),
    );
  }
}
