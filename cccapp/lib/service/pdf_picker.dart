import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<File?> pickPDF() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      return File(result.files.single.path!);
    }
    return null;
  } catch (e) {
    print('Error selecting PDF: $e');
    return null;
  }
}
