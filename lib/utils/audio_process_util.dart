import 'package:flutter/foundation.dart';
import 'package:image/image.dart';

class AudioProcessingUtil {
  static List<double> processSinglePackage(
      Uint8List packageData,
      List<List<double>> iPCAMatrix,
      List<List<double>> iDCTMatrix
      ) {

    final byteData = ByteData.sublistView(
        Uint8List.fromList(packageData.sublist(1, 1 + 45 * 2))
    );
    List<double> compressedSpectrum = List.generate(45, (i) {
      return Float16.fromBits(byteData.getUint16(i * 2, Endian.little)).toDouble();
    });

    List<double> spectrum = List.generate(257, (i) {
      return List.generate(45, (j) {
        return iPCAMatrix[j][i] * compressedSpectrum[j].toDouble();
      }).reduce((value, element) => value + element);
    });

    Uint8List signData = packageData.sublist(1 + 45 * 2, 1 + 45 * 2 + 33);
    int k = 0;
    for (int i = 0; i < 33; i++) {
      int num = signData[i].toInt();
      for (int j = 0; j < 8; j++) {
        if ((num & (1 << j)) > 0) {
          spectrum[k] = -spectrum[k];
        }
        k++;
        if (k == 257) {
          break;
        }
      }
      if (k == 257) {
        break;
      }
    }

    List<double> audioClip = List.generate(257, (i) {
      return List.generate(257, (j) {
        return iDCTMatrix[j][i] * spectrum[j];
      }).reduce((value, element) => value + element);
    });

    // print("audioClip: ${audioClip}");
    return audioClip.take(256).toList();
  }
}