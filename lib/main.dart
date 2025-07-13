// SmartQR – Full Professional Flutter App with QR Scan, Generate, History + PDF Export + Ads
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartQR - Scan & Generate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade100,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade700,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/scan_qr.json', height: 120),
            const SizedBox(height: 20),
            const Text(
              'SmartQR',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scan • Generate • History',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    QRScannerPage(),
    QRGeneratorPage(),
    HistoryPage(),
  ];

  void _onTabTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartQR'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onTabTapped,
        height: 65,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.qr_code_scanner_outlined), selectedIcon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.qr_code_2_outlined), selectedIcon: Icon(Icons.qr_code_2), label: 'Generate'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String? result;
  bool scanned = false;

  void _onDetect(BarcodeCapture capture) async {
    if (scanned) return;
    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) return;

    final code = barcode.rawValue!;
    setState(() {
      result = code;
      scanned = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList('history') ?? [];
    history.add(code);
    await prefs.setStringList('history', history);

    Future.delayed(const Duration(seconds: 2), () => setState(() => result = null));
    Future.delayed(const Duration(seconds: 3), () => setState(() => scanned = false));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: MobileScannerController(),
          onDetect: _onDetect,
        ),
        if (result != null)
          GestureDetector(
            onTap: () async {
              if (Uri.tryParse(result!)?.hasAbsolutePath ?? false) {
                final uri = Uri.parse(result!);
                if (await canLaunchUrl(uri)) {
                  launchUrl(uri,mode: LaunchMode.externalApplication);
                }
              }
            },
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child: Text('Scanned: $result', style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
      ],
    );
  }
}

class QRGeneratorPage extends StatefulWidget {
  const QRGeneratorPage({super.key});

  @override
  State<QRGeneratorPage> createState() => _QRGeneratorPageState();
}

class _QRGeneratorPageState extends State<QRGeneratorPage> {
  final TextEditingController _controller = TextEditingController();
  String? _qrData;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3521181840570110/6953111457',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }
  BannerAd? _bannerAd;

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3521181840570110/2450759661',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: const BannerAdListener(),
    )..load();
  }
  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    setState(() => _qrData = _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Enter data to generate QR',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.qr_code),
            label: const Text('Generate'),
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {

                _showInterstitialAd();
              }
            },
          ),
          const SizedBox(height: 24),
          if (_qrData != null)
            QrImageView(
              data: _qrData!,
              version: QrVersions.auto,
              size: 200,
            ),

          if (_bannerAd != null)
            SizedBox(height: 50, child: AdWidget(ad: _bannerAd!)),
        ],
      ),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> history = [];
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadBannerAd();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      history = prefs.getStringList('history') ?? [];
    });
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3521181840570110/2450759661',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: const BannerAdListener(),
    )..load();
  }

  Future<void> _exportToTextFile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export History'),
        content: const Text('Do you want to export history to text file?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Export')),
        ],
      ),
    );

    if (confirm == true) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/qr_history.txt');
      await file.writeAsString(history.join('\n'));
      Share.shareXFiles([XFile(file.path)], text: 'My QR Scan History');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: history.length,
            itemBuilder: (context, index) => Card(
              child: ListTile(
                title: Text(history[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: history[index]));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        if (_bannerAd != null)
          SizedBox(height: 50, child: AdWidget(ad: _bannerAd!)),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton.icon(
            onPressed: _exportToTextFile,
            icon: const Icon(Icons.share),
            label: const Text('Export History'),
          ),
        ),
      ],
    );
  }
}