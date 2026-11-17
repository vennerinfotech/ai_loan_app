import 'dart:typed_data';
import 'package:get/get.dart';

/// Controller managing user profile data, avatar image, and updates
class ProfileController extends GetxController {
  final firstName = 'Aarav'.obs;
  final lastName = 'Mehta'.obs;
  final email = 'aarav@example.com'.obs;
  final phone = '+91 98765 •••10'.obs;
  final address = '123, MG Road, Bengaluru 560001'.obs;

  // Saved profile image
  final profileImageBytes = Rxn<Uint8List>();
  final profileImagePath = ''.obs;

  // Staged profile image during editing in Edit Profile screen
  final tempImageBytes = Rxn<Uint8List>();
  final tempImagePath = ''.obs;

  String get fullName => '${firstName.value} ${lastName.value}'.trim();

  String get initials {
    final f = firstName.value.isNotEmpty ? firstName.value[0].toUpperCase() : '';
    final l = lastName.value.isNotEmpty ? lastName.value[0].toUpperCase() : '';
    return '$f$l'.isEmpty ? 'AM' : '$f$l';
  }

  void setTempImage(Uint8List bytes, String path) {
    tempImageBytes.value = bytes;
    tempImagePath.value = path;
  }

  void saveProfile({
    required String first,
    required String last,
    required String emailAddress,
    required String addr,
  }) {
    if (first.isNotEmpty) firstName.value = first;
    if (last.isNotEmpty) lastName.value = last;
    if (emailAddress.isNotEmpty) email.value = emailAddress;
    if (addr.isNotEmpty) address.value = addr;

    if (tempImageBytes.value != null) {
      profileImageBytes.value = tempImageBytes.value;
      profileImagePath.value = tempImagePath.value;
      tempImageBytes.value = null;
      tempImagePath.value = '';
    }
  }

  void clearTempImage() {
    tempImageBytes.value = null;
    tempImagePath.value = '';
  }
}
