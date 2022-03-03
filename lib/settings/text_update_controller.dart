import 'package:hapi/getx_hapi.dart';

/// Used to detect things like profile text updates on the UI so we can disable
/// UI elements like update to server, when not needed.
class TextUpdateController extends GetxHapi {
  /// We assume and UI MUST init with DB values matching what UI shows:
  bool _isTextSame = true;

  get isTextSame => _isTextSame;
  get isTextDiff => !_isTextSame;

  /// Sometimes we need to force a reset
  setTextSame(bool value) {
    // Only notify UI of update if the value toggles
    if (_isTextSame != value) {
      _isTextSame = value;
      print('ProfileUpdateController isTextSame=$isTextSame');
      update();
    }
  }

  handleTextUpdate(List<String> a, List<String> b, {bool trim = true}) {
    assert(a.length == b.length);

    bool textIsSame = true;
    if (trim) {
      for (var idx = 0; idx < a.length; idx++) {
        if (a[idx].trim() != b[idx].trim()) {
          textIsSame = false;
          break;
        }
      }
    } else {
      for (var idx = 0; idx < a.length; idx++) {
        if (a[idx] != b[idx]) {
          textIsSame = false;
          break;
        }
      }
    }

    setTextSame(textIsSame);
  }
}
