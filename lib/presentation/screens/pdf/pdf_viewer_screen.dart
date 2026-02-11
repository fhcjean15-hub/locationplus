import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:mobile/presentation/theme/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;

  const PdfViewerScreen({super.key, required this.pdfUrl});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();

        final file = File("${dir.path}/document.pdf");
        await file.writeAsBytes(bytes);

        setState(() {
          localPath = file.path;
          isLoading = false;
        });
      } else {
        throw Exception("Impossible de télécharger le PDF");
      }
    } catch (e) {
      print("Erreur PDF: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Document PDF"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary,))
          : localPath == null
              ? const Center(child: Text("Erreur lors de l'ouverture du PDF"))
              : PDFView(
                  filePath: localPath!,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: true,
                  pageFling: true,
                ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// class PdfViewerScreen extends StatelessWidget {
//   final String pdfUrl;

//   const PdfViewerScreen({super.key, required this.pdfUrl});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Document"),
//       ),
//       body: SfPdfViewer.network(pdfUrl),
//     );
//   }
// }
