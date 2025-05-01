import 'dart:io';
import 'dart:math';
import 'package:ecom_startup/utility/snack_bar_helper.dart';

import '../../../models/api_response.dart';
import '../../../services/http_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addCategoryFormKey = GlobalKey<FormState>();
  TextEditingController categoryNameCtrl = TextEditingController();
  Category? categoryForUpdate;

  File? selectedImage;
  XFile? imgXFile;

  CategoryProvider(this._dataProvider);

  //addCategory
  addCategory() async {
    try {
      if (selectedImage == null) {
        SnackBarHelper.showErrorSnackBar("Please Choose A Image!");
        return;
      }
      Map<String, dynamic> formDataMap = {
        'name': categoryNameCtrl.text,
        'image': 'no_data', //? Image path will add from server side
      };
      // form data because image in here, if not image or file uploaded, use body data (postman)

      final FormData form =
          await createFormData(imgXFile: imgXFile, formData: formDataMap);

      final response =
          await service.addItem(endpointUrl: 'categories', itemData: form);

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body,
            null); // three main messages, success, message , [data]
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          log('Category added' as num); // change log('Category added')
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to add Category: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('An error occurred: $e}');
      rethrow;
    }
  }

  //TODO: should complete updateCategory

  //TODO: should complete submitCategory

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      imgXFile = image;
      notifyListeners();
    }
  }

  //TODO: should complete deleteCategory

  //TODO: should complete setDataForUpdateCategory

  //? to create form data for sending image with body
  Future<FormData> createFormData(
      {required XFile? imgXFile,
      required Map<String, dynamic> formData}) async {
    if (imgXFile != null) {
      MultipartFile multipartFile;
      if (kIsWeb) {
        String fileName = imgXFile.name;
        Uint8List byteImg = await imgXFile.readAsBytes();
        multipartFile = MultipartFile(byteImg, filename: fileName);
      } else {
        String fileName = imgXFile.path.split('/').last;
        multipartFile = MultipartFile(imgXFile.path, filename: fileName);
      }
      formData['img'] = multipartFile;
    }
    final FormData form = FormData(formData);
    return form;
  }

  //? set data for update on editing
  setDataForUpdateCategory(Category? category) {
    if (category != null) {
      clearFields();
      categoryForUpdate = category;
      categoryNameCtrl.text = category.name ?? '';
    } else {
      clearFields();
    }
  }

  //? to clear text field and images after adding or update category
  clearFields() {
    categoryNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    categoryForUpdate = null;
  }
}
