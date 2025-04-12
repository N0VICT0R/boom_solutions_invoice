import 'dart:io';
import 'package:boom_solutions_invoice/widgets/SOA/SOApdfScreen.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

class PdfController extends GetxController {
  var isLoading = false.obs;

  // Store the API token as a variable.
  String apiToken = '';

  @override
  void onInit() {
    super.onInit();
    // Initialize the token from GetStorage.
    // You can update this token later if needed.
    apiToken = GetStorage().read('token') ?? '';
  }

  Future<void> downloadAndOpenPdf(int partnerId, String dateFrom, String dateTo) async {
    try {
      isLoading(true);
      
      // Build the API URL using the variable apiToken
      final url = 'http://137.184.205.67:2710/api/v1/partners/$partnerId/statement/pdf'
          '?api_token=$apiToken&date_from=$dateFrom&date_to=$dateTo';
      print("Downloading from: $url");

      // Get directory to save the PDF file
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/statement.pdf';

      // Download the PDF file using Dio
      final response = await Dio().download(
        url,
        filePath,
        options: Options(responseType: ResponseType.bytes),
      );
      print("Status: ${response.statusCode}, saved at $filePath");

      final file = File(filePath);
      // Validate the file (must exist and be larger than an arbitrary 100 bytes)
      if (await file.exists() && await file.length() > 100) {
        // Navigate to the PDF viewer screen
        Get.to(() => PdfViewerScreen(path: filePath));
      } else {
        Get.snackbar("Error", "Downloaded file is empty or corrupted.");
      }
    } catch (e) {
     
      Get.snackbar("Error", "Failed to download PDF");
    } finally {
      isLoading(false);
    }
  }
}
