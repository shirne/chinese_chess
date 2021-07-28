/*
Search.java - Source Code for XiangQi Wizard Light, Part II

XiangQi Wizard Light - a Chinese Chess Program for Java ME
Designed by Morning Yellow, Version: 1.70, Last Modified: Mar. 2013
Copyright (C) 2004-2013 www.xqbase.com

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

import 'dart:math' as Math;

import 'position.dart';
import 'util.dart';

class Integer {
  static const MAX_VALUE = 2147483647;
  static const MIN_VALUE = -2147483648;
}

class HashItem {
  int depth; // byte
  int flag;
  int vl; //short
  int mv, zobristLock;
  HashItem({
    this.depth = 0,
    this.flag = 0,
    this.vl = 0,
    this.mv = 0,
    this.zobristLock = 0,
  });
}

class SortItem {
  static const int PHASE_HASH = 0;
  static const int PHASE_KILLER_1 = 1;
  static const int PHASE_KILLER_2 = 2;
  static const int PHASE_GEN_MOVES = 3;
  static const int PHASE_REST = 4;

  late int index, moves, phase;
  late int mvHash, mvKiller1, mvKiller2;
  late List<int> mvs, vls;

  bool singleReply = false;

  Search search;

  SortItem(int mvHash, this.search) {
    if (!search.pos.inCheck()) {
      phase = PHASE_HASH;
      this.mvHash = mvHash;
      mvKiller1 = search.mvKiller[search.pos.distance][0];
      mvKiller2 = search.mvKiller[search.pos.distance][1];
      return;
    }
    phase = PHASE_REST;
    this.mvHash = mvKiller1 = mvKiller2 = 0;
    mvs = List.filled(Search.MAX_GEN_MOVES, 0);
    vls = List.filled(Search.MAX_GEN_MOVES, 0);
    moves = 0;
    List<int> mvsAll = List.filled(Search.MAX_GEN_MOVES, 0);
    int numAll = search.pos.generateAllMoves(mvsAll);
    for (int i = 0; i < numAll; i++) {
      int mv = mvsAll[i];
      if (!search.pos.makeMove(mv)) {
        continue;
      }
      search.pos.undoMakeMove();
      mvs[moves] = mv;
      vls[moves] = mv == mvHash
          ? Integer.MAX_VALUE
          : search.historyTable[search.pos.historyIndex(mv)];
      moves++;
    }
    Util.shellSort(mvs, vls, 0, moves);
    index = 0;
    singleReply = moves == 1;
  }

  int next() {
    if (phase == PHASE_HASH) {
      phase = PHASE_KILLER_1;
      if (mvHash > 0) {
        return mvHash;
      }
    }
    if (phase == PHASE_KILLER_1) {
      phase = PHASE_KILLER_2;
      if (mvKiller1 != mvHash &&
          mvKiller1 > 0 &&
          search.pos.legalMove(mvKiller1)) {
        return mvKiller1;
      }
    }
    if (phase == PHASE_KILLER_2) {
      phase = PHASE_GEN_MOVES;
      if (mvKiller2 != mvHash &&
          mvKiller2 > 0 &&
          search.pos.legalMove(mvKiller2)) {
        return mvKiller2;
      }
    }
    if (phase == PHASE_GEN_MOVES) {
      phase = PHASE_REST;
      mvs = List.filled(Search.MAX_GEN_MOVES, 0);
      vls = List.filled(Search.MAX_GEN_MOVES, 0);
      moves = search.pos.generateAllMoves(mvs);
      for (int i = 0; i < moves; i++) {
        vls[i] = search.historyTable[search.pos.historyIndex(mvs[i])];
      }
      Util.shellSort(mvs, vls, 0, moves);
      index = 0;
    }
    while (index < moves) {
      int mv = mvs[index];
      index++;
      if (mv != mvHash && mv != mvKiller1 && mv != mvKiller2) {
        return mv;
      }
    }
    return 0;
  }
}

class Search {
  // private
  static const int HASH_ALPHA = 1;
  static const int HASH_BETA = 2;
  static const int HASH_PV = 3;
  static const int LIMIT_DEPTH = 64;
  static const int NULL_DEPTH = 2;
  static const int RANDOM_MASK = 7;
  static final int MAX_GEN_MOVES = Position.MAX_GEN_MOVES;
  static final int MATE_VALUE = Position.MATE_VALUE;
  static final int BAN_VALUE = Position.BAN_VALUE;
  static final int WIN_VALUE = Position.WIN_VALUE;

  int hashMask, mvResult = 0, allNodes = 0, allMillis = 0;
  List<HashItem> hashTable;

  // public
  Position pos;
  List<int> historyTable = List.filled(4096, 0);
  List<List<int>> mvKiller = List.filled(LIMIT_DEPTH, List.filled(2, 0));

  Search(this.pos, int hashLevel)
      : hashMask = (1 << hashLevel) - 1,
        hashTable = List.filled(1 << hashLevel, HashItem());

  HashItem getHashItem() {
    return hashTable[pos.zobristKey & hashMask];
  }

  int probeHash(int vlAlpha, int vlBeta, int depth, List<int> mv) {
    HashItem hash = getHashItem();
    if (hash.zobristLock != pos.zobristLock) {
      mv[0] = 0;
      return -MATE_VALUE;
    }
    mv[0] = hash.mv;
    bool mate = false;
    if (hash.vl > WIN_VALUE) {
      if (hash.vl <= BAN_VALUE) {
        return -MATE_VALUE;
      }
      hash.vl -= pos.distance;
      mate = true;
    } else if (hash.vl < -WIN_VALUE) {
      if (hash.vl >= -BAN_VALUE) {
        return -MATE_VALUE;
      }
      hash.vl += pos.distance;
      mate = true;
    } else if (hash.vl == pos.drawValue()) {
      return -MATE_VALUE;
    }
    if (hash.depth >= depth || mate) {
      if (hash.flag == HASH_BETA) {
        return (hash.vl >= vlBeta ? hash.vl : -MATE_VALUE);
      } else if (hash.flag == HASH_ALPHA) {
        return (hash.vl <= vlAlpha ? hash.vl : -MATE_VALUE);
      }
      return hash.vl;
    }
    return -MATE_VALUE;
  }

  void recordHash(int flag, int vl, int depth, int mv) {
    HashItem hash = getHashItem();
    if (hash.depth > depth) {
      return;
    }
    hash.flag = flag;
    hash.depth = depth;
    if (vl > WIN_VALUE) {
      if (mv == 0 && vl <= BAN_VALUE) {
        return;
      }
      hash.vl = (vl + pos.distance);
    } else if (vl < -WIN_VALUE) {
      if (mv == 0 && vl >= -BAN_VALUE) {
        return;
      }
      hash.vl = (vl - pos.distance);
    } else if (vl == pos.drawValue() && mv == 0) {
      return;
    } else {
      hash.vl = vl;
    }
    hash.mv = mv;
    hash.zobristLock = pos.zobristLock;
  }

  void setBestMove(int mv, int depth) {
    historyTable[pos.historyIndex(mv)] += depth * depth;
    List<int> killers = mvKiller[pos.distance];
    if (killers[0] != mv) {
      killers[1] = killers[0];
      killers[0] = mv;
    }
  }

  int searchQuiesc(int vlAlpha_, int vlBeta) {
    int vlAlpha = vlAlpha_;
    allNodes++;
    int vl = pos.mateValue();
    if (vl >= vlBeta) {
      return vl;
    }
    int vlRep = pos.repStatus();
    if (vlRep > 0) {
      return pos.repValue(vlRep);
    }
    if (pos.distance == LIMIT_DEPTH) {
      return pos.evaluate();
    }
    int vlBest = -MATE_VALUE;
    int genMoves;
    List<int> mvs = List.filled(MAX_GEN_MOVES, 0);
    if (pos.inCheck()) {
      genMoves = pos.generateAllMoves(mvs);
      List<int> vls = List.filled(MAX_GEN_MOVES, 0);
      for (int i = 0; i < genMoves; i++) {
        vls[i] = historyTable[pos.historyIndex(mvs[i])];
      }
      Util.shellSort(mvs, vls, 0, genMoves);
    } else {
      vl = pos.evaluate();
      if (vl > vlBest) {
        if (vl >= vlBeta) {
          return vl;
        }
        vlBest = vl;
        vlAlpha = Math.max(vl, vlAlpha);
      }
      List<int> vls = List.filled(MAX_GEN_MOVES, 0);
      genMoves = pos.generateMoves(mvs, vls);
      Util.shellSort(mvs, vls, 0, genMoves);
      for (int i = 0; i < genMoves; i++) {
        if (vls[i] < 10 ||
            (vls[i] < 20 &&
                Position.HOME_HALF(Position.DST(mvs[i]), pos.sdPlayer))) {
          genMoves = i;
          break;
        }
      }
    }
    for (int i = 0; i < genMoves; i++) {
      if (!pos.makeMove(mvs[i])) {
        continue;
      }
      vl = -searchQuiesc(-vlBeta, -vlAlpha);
      pos.undoMakeMove();
      if (vl > vlBest) {
        if (vl >= vlBeta) {
          return vl;
        }
        vlBest = vl;
        vlAlpha = Math.max(vl, vlAlpha);
      }
    }
    return vlBest == -MATE_VALUE ? pos.mateValue() : vlBest;
  }

  int searchNoNull(int vlAlpha, int vlBeta, int depth) {
    return searchFull(vlAlpha, vlBeta, depth, true);
  }

  int searchFull(int vlAlpha_, int vlBeta, int depth, [bool noNull = false]) {
    int vlAlpha = vlAlpha_;
    int vl;
    if (depth <= 0) {
      return searchQuiesc(vlAlpha, vlBeta);
    }
    allNodes++;
    vl = pos.mateValue();
    if (vl >= vlBeta) {
      return vl;
    }
    int vlRep = pos.repStatus();
    if (vlRep > 0) {
      return pos.repValue(vlRep);
    }
    List<int> mvHash = [0];
    vl = probeHash(vlAlpha, vlBeta, depth, mvHash);
    if (vl > -MATE_VALUE) {
      return vl;
    }
    if (pos.distance == LIMIT_DEPTH) {
      return pos.evaluate();
    }
    if (!noNull && !pos.inCheck() && pos.nullOkay()) {
      pos.nullMove();
      vl = -searchNoNull(-vlBeta, 1 - vlBeta, depth - NULL_DEPTH - 1);
      pos.undoNullMove();
      if (vl >= vlBeta &&
          (pos.nullSafe() ||
              searchNoNull(vlAlpha, vlBeta, depth - NULL_DEPTH) >= vlBeta)) {
        return vl;
      }
    }
    int hashFlag = HASH_ALPHA;
    int vlBest = -MATE_VALUE;
    int mvBest = 0;
    SortItem sort = new SortItem(mvHash[0], this);
    int mv;
    while ((mv = sort.next()) > 0) {
      if (!pos.makeMove(mv)) {
        continue;
      }
      int newDepth = pos.inCheck() || sort.singleReply ? depth : depth - 1;
      if (vlBest == -MATE_VALUE) {
        vl = -searchFull(-vlBeta, -vlAlpha, newDepth);
      } else {
        vl = -searchFull(-vlAlpha - 1, -vlAlpha, newDepth);
        if (vl > vlAlpha && vl < vlBeta) {
          vl = -searchFull(-vlBeta, -vlAlpha, newDepth);
        }
      }
      pos.undoMakeMove();
      if (vl > vlBest) {
        vlBest = vl;
        if (vl >= vlBeta) {
          hashFlag = HASH_BETA;
          mvBest = mv;
          break;
        }
        if (vl > vlAlpha) {
          vlAlpha = vl;
          hashFlag = HASH_PV;
          mvBest = mv;
        }
      }
    }
    if (vlBest == -MATE_VALUE) {
      return pos.mateValue();
    }
    recordHash(hashFlag, vlBest, depth, mvBest);
    if (mvBest > 0) {
      setBestMove(mvBest, depth);
    }
    return vlBest;
  }

  int searchRoot(int depth) {
    int vlBest = -MATE_VALUE;
    SortItem sort = new SortItem(mvResult, this);
    int mv;
    while ((mv = sort.next()) > 0) {
      if (!pos.makeMove(mv)) {
        continue;
      }
      int newDepth = pos.inCheck() ? depth : depth - 1;
      int vl;
      if (vlBest == -MATE_VALUE) {
        vl = -searchNoNull(-MATE_VALUE, MATE_VALUE, newDepth);
      } else {
        vl = -searchFull(-vlBest - 1, -vlBest, newDepth);
        if (vl > vlBest) {
          vl = -searchNoNull(-MATE_VALUE, -vlBest, newDepth);
        }
      }
      pos.undoMakeMove();
      if (vl > vlBest) {
        vlBest = vl;
        mvResult = mv;
        if (vlBest > -WIN_VALUE && vlBest < WIN_VALUE) {
          vlBest += (Position.random.nextInt(1024) & RANDOM_MASK) -
              (Position.random.nextInt(1024) & RANDOM_MASK);
          vlBest = (vlBest == pos.drawValue() ? vlBest - 1 : vlBest);
        }
      }
    }
    setBestMove(mvResult, depth);
    return vlBest;
  }

  bool searchUnique(int vlBeta, int depth) {
    SortItem sort = new SortItem(mvResult, this);
    sort.next();
    int mv;
    while ((mv = sort.next()) > 0) {
      if (!pos.makeMove(mv)) {
        continue;
      }
      int vl =
          -searchFull(-vlBeta, 1 - vlBeta, pos.inCheck() ? depth : depth - 1);
      pos.undoMakeMove();
      if (vl >= vlBeta) {
        return false;
      }
    }
    return true;
  }

  int searchMain(int millis, [int depth = LIMIT_DEPTH]) {
    mvResult = pos.bookMove();
    if (mvResult > 0) {
      pos.makeMove(mvResult);
      if (pos.repStatus(3) == 0) {
        pos.undoMakeMove();
        return mvResult;
      }
      pos.undoMakeMove();
    }
    for (int i = 0; i <= hashMask; i++) {
      HashItem hash = hashTable[i];
      hash.depth = hash.flag = 0;
      hash.vl = 0;
      hash.mv = hash.zobristLock = 0;
    }
    for (int i = 0; i < LIMIT_DEPTH; i++) {
      mvKiller[i][0] = mvKiller[i][1] = 0;
    }
    for (int i = 0; i < 4096; i++) {
      historyTable[i] = 0;
    }
    mvResult = 0;
    allNodes = 0;
    pos.distance = 0;
    int t = DateTime.now().millisecondsSinceEpoch;
    for (int i = 1; i <= depth; i++) {
      int vl = searchRoot(i);
      allMillis = DateTime.now().millisecondsSinceEpoch - t;
      if (allMillis > millis) {
        break;
      }
      if (vl > WIN_VALUE || vl < -WIN_VALUE) {
        break;
      }
      if (searchUnique(1 - WIN_VALUE, i)) {
        break;
      }
    }
    return mvResult;
  }

  int getKNPS() {
    return allNodes ~/ allMillis;
  }
}
