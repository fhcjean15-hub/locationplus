import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/presentation/theme/colors.dart';
import '../theme/colors.dart';
import 'package:file_picker/file_picker.dart';

class UploadDocumentWidget extends StatefulWidget {
  final String title;
  final String description;
  final Function(File?) onFileSelected;
  final File? initialFile;
  final String? initialFileName; // ← nom du fichier déjà enregistré

  const UploadDocumentWidget({
    super.key,
    required this.title,
    required this.description,
    required this.onFileSelected,
    this.initialFile,
    this.initialFileName,
  });

  @override
  State<UploadDocumentWidget> createState() => _UploadDocumentWidgetState();
}

class _UploadDocumentWidgetState extends State<UploadDocumentWidget> {
  File? selectedFile;
  String? selectedFileName;

  @override
  void initState() {
    super.initState();
    selectedFile = widget.initialFile;
    selectedFileName = widget.initialFileName;
  }

  // Future<void> pickFile() async {
  //   final picker = ImagePicker();
  //   final result = await picker.pickImage(source: ImageSource.gallery);

  //   if (result != null) {
  //     setState(() {
  //       selectedFile = File(result.path);
  //       selectedFileName = null; // si on choisit un fichier local, on ignore le nom existant
  //     });
  //     widget.onFileSelected(selectedFile);
  //   }
  // }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => selectedFile = File(result.files.single.path!));
      widget.onFileSelected(selectedFile);
    }
  }

  String extractFileName(String path) {
    return path.split('/').last;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              )),
          const SizedBox(height: 6),
          Text(widget.description,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 16),

          // Cadre pointillé
          GestureDetector(
            onTap: pickFile,
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.file_upload_outlined, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    selectedFile == null && selectedFileName == null
                        ? "Déposez ou choisissez un fichier"
                        : "Appuyer pour remplacer le fichier",
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Aperçu fichier
          if (selectedFile != null || selectedFileName != null)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedFile != null
                          ? selectedFile!.path.split('/').last
                          : extractFileName(selectedFileName!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}




// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mobile/presentation/theme/colors.dart';
// import '../theme/colors.dart';

// class UploadDocumentWidget extends StatefulWidget {
//   final String title;
//   final String description;
//   final Function(File?) onFileSelected;
//   final File? initialFile;

//   const UploadDocumentWidget({
//     super.key,
//     required this.title,
//     required this.description,
//     required this.onFileSelected,
//     this.initialFile,
//   });

//   @override
//   State<UploadDocumentWidget> createState() => _UploadDocumentWidgetState();
// }

// class _UploadDocumentWidgetState extends State<UploadDocumentWidget> {
//   File? selectedFile;

//   @override
//   void initState() {
//     super.initState();
//     selectedFile = widget.initialFile;
//   }

//   Future<void> pickFile() async {
//     final picker = ImagePicker();

//     final result = await picker.pickImage(source: ImageSource.gallery);

//     if (result != null) {
//       setState(() => selectedFile = File(result.path));
//       widget.onFileSelected(selectedFile);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.grey.shade300, width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(widget.title,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               )),

//           const SizedBox(height: 6),
//           Text(widget.description,
//               style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),

//           const SizedBox(height: 16),

//           // Cadre pointillé
//           GestureDetector(
//             onTap: pickFile,
//             child: Container(
//               width: double.infinity,
//               height: 150,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(
//                   color: Colors.grey,
//                   width: 1,
//                   style: BorderStyle.solid,
//                 ),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.file_upload_outlined, size: 40),

//                   const SizedBox(height: 8),
//                   Text(
//                     selectedFile == null
//                         ? "Déposez ou choisissez un fichier"
//                         : "Appuyer pour remplacer le fichier",
//                     style: const TextStyle(fontSize: 13),
//                   ),

//                   const SizedBox(height: 12),

//                   // bouton +
//                   Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                       color: AppColors.primary,
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                     child: const Icon(Icons.add, color: Colors.white, size: 20),
//                   )
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 10),

//           // Aperçu fichier
//           if (selectedFile != null)
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.insert_drive_file, color: Colors.black54),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       selectedFile!.path.split('/').last,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   )
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
