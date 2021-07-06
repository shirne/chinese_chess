import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../models/game_setting.dart';

import 'position.dart';
import 'search.dart';

class IsoMessage {
  final String fen;
  final SendPort sendPort;
  final ByteData data;
  static ByteData bookData;

  IsoMessage(this.fen, this.sendPort) : data = bookData;
}

class XQIsoSearch {
  static Position position;
  static Search search;

  static init() async {
    if (search == null) {
      position = Position();
      GameSetting setting = await GameSetting.getInstance();
      search = Search(position, setting.robotLevel);
      await Position.init();
    }
  }

  static Future<String> getMove(IsoMessage message) async {
    Position.input = message.data;
    await init();
    position.fromFen(message.fen);
    int mvLast = search.searchMain(1000 << (0 << 1));
    print('$mvLast => ${Util.move2Iccs(mvLast)}');
    String move = Util.move2Iccs(mvLast);
    if (message.sendPort != null) message.sendPort.send(move);
    return move;
  }
}

class RC4 {
  List<int> state = List.generate(256, (i) => i);
  int x;
  int y;

  void swap(int i, int j) {
    int t = state[i];
    state[i] = state[j];
    state[j] = t;
  }

  RC4(Uint8List key) {
    x = 0;
    y = 0;
    int j = 0;
    for (int i = 0; i < 256; i++) {
      j = (j + state[i] + key[i % key.length]) & 0xff;
      swap(i, j);
    }
  }

  int nextByte() {
    x = (x + 1) & 0xff;
    y = (y + state[x]) & 0xff;
    swap(x, y);
    int t = (state[x] + state[y]) & 0xff;
    return state[t];
  }

  int nextLong() {
    int n0, n1, n2, n3;
    n0 = nextByte();
    n1 = nextByte();
    n2 = nextByte();
    n3 = nextByte();
    return n0 + (n1 << 8) + (n2 << 16) + (n3 << 24);
  }
}

class Util {
  static int MIN_MAX(int min, int mid, int max) {
    return mid < min
        ? min
        : mid > max
            ? max
            : mid;
  }

  static Uint8List POP_COUNT_16_LIST =
      Uint8List.fromList(List.generate(65536, (i) {
    int n = ((i >> 1) & 0x5555) + (i & 0x5555);
    n = ((n >> 2) & 0x3333) + (n & 0x3333);
    n = ((n >> 4) & 0x0f0f) + (n & 0x0f0f);
    return ((n >> 8) + (n & 0x00ff));
  }));

  static int POP_COUNT_16(int data) {
    return POP_COUNT_16_LIST[data];
  }

  @deprecated
  static int readShort(ByteData input) {
    int b0 = input.getInt8(0);
    int b1 = input.getInt8(1);
    if (b0 == -1 || b1 == -1) {
      throw Exception();
    }
    return b0 | (b1 << 8);
  }

  @deprecated
  static int readInt(ByteData input) {
    int b0 = input.getInt8(0);
    int b1 = input.getInt8(1);
    int b2 = input.getInt8(2);
    int b3 = input.getInt8(3);
    if (b0 == -1 || b1 == -1 || b2 == -1 || b3 == -1) {
      throw Exception();
    }
    return b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
  }

  static int binarySearch(int vl, List<int> vls, int from, int to) {
    int low = from;
    int high = to - 1;
    while (low <= high) {
      int mid = (low + high) ~/ 2;
      if (vls[mid] < vl) {
        low = mid + 1;
      } else if (vls[mid] > vl) {
        high = mid - 1;
      } else {
        return mid;
      }
    }
    return -1;
  }

  static final List<int> SHELL_STEP = [0, 1, 4, 13, 40, 121, 364, 1093];

  static void shellSort(List<int> mvs, List<int> vls, int from, int to) {
    int stepLevel = 1;
    while (SHELL_STEP[stepLevel] < to - from) {
      stepLevel++;
    }
    stepLevel--;
    while (stepLevel > 0) {
      int step = SHELL_STEP[stepLevel];
      for (int i = from + step; i < to; i++) {
        int mvBest = mvs[i];
        int vlBest = vls[i];
        int j = i - step;
        while (j >= from && vlBest > vls[j]) {
          mvs[j + step] = mvs[j];
          vls[j + step] = vls[j];
          j -= step;
        }
        mvs[j + step] = mvBest;
        vls[j + step] = vlBest;
      }
      stepLevel--;
    }
  }

  static String move2Iccs(int mv) {
    var sqSrc = mv & 255;
    var sqDst = mv >> 8;
    return String.fromCharCode("a".codeUnitAt(0) + (sqSrc & 15) - 3) +
        String.fromCharCode("9".codeUnitAt(0) - (sqSrc >> 4) + 3) +
        String.fromCharCode("a".codeUnitAt(0) + (sqDst & 15) - 3) +
        String.fromCharCode("9".codeUnitAt(0) - (sqDst >> 4) + 3);
  }

  static int iccs2Move(String iccs) {
    int sqSrc1 = iccs.codeUnitAt(0) + 3 - "a".codeUnitAt(0);
    int sqSrc2 = 3 + "9".codeUnitAt(0) - iccs.codeUnitAt(1);
    int sqDst1 = iccs.codeUnitAt(2) + 3 - "a".codeUnitAt(0);
    int sqDst2 = 3 + "9".codeUnitAt(0) - iccs.codeUnitAt(3);

    return sqSrc1 | (sqSrc2 << 4) | ((sqDst1 | (sqDst2 << 4)) << 8);
  }
}
