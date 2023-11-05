import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(PickApp());
}

class PickApp extends StatelessWidget {
  const PickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Text(
          'PICK!',
          style: TextStyle(fontSize: 42, color: Colors.white), // 흰색 글씨
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

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();

    ReceiveSharingIntent.getTextStream().listen((String? value) {
      setState(() {
        _sharedText = value;
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      setState(() {
        _sharedText = value;
        print('공유된 정보 $value');
      });
    });
  }

  Future<void> _requestLocationPermission() async {
    // 위치 권한 요청 함수 정의]
    final status = await Permission.location.request(); // 위치 권한 요청

    if (status.isGranted) {
      print("Location permission granted"); // 승인
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
          title: const Text('권한 거부됨'),
          content: const Text('위치 권한이 거부되었습니다. 설정에서 권한을 활성화할 수 있습니다.'),
          actions: <Widget>[
            TextButton(
              child: const Text('설정 열기'),
              onPressed: () async {
                await openAppSettings(); // 앱 설정 화면 열기
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('취소'),
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
    return const Scaffold(
      body: WebView(
        initialUrl: "http://naver.com",
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
