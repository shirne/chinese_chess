/*
Position.java - Source Code for XiangQi Wizard Light, Part I

XiangQi Wizard Light - a Chinese Chess Program for Java ME
Designed by Morning Yellow, Version: 1.25, Last Modified: Mar. 2008
Copyright (C) 2004-2008 www.elephantbase.net

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

import 'dart:core';

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'util.dart';

class Position {
  static const int gMateValue = 10000;
  static const int gBanValue = gMateValue - 100;
  static const int gWinValue = gMateValue - 200;
  static const int nullSafeMargin = 400;
  static const int nullOkayMargin = 200;
  static const int gDrawValue = 20;
  static const int gAdvancedValue = 3;

  static const int maxMoveNum = 256;
  static const int maxGenMoves = 128;
  static const int maxBookSize = 16384;

  static const int pieceKing = 0;
  static const int pieceAdvisor = 1;
  static const int pieceBishop = 2;
  static const int pieceKnight = 3;
  static const int pieceRook = 4;
  static const int pieceCannon = 5;
  static const int piecePawn = 6;

  static const int rankTop = 3;
  static const int rankBottom = 12;
  static const int fileLeft = 3;
  static const int fileRight = 11;

  static const inBoard = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, //
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  ];

  static const inFort = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, //
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  ];

  static const legalSpan = [
    0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, //
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 2, 1, 2, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 2, 1, 2, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0,
  ];

  static const knightPin = [
    0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, //
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, -16, 0, -16, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 16, 0, 16, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0
  ];

  static const kingDelta = [-16, -1, 1, 16];
  static const advisorDelta = [-17, -15, 15, 17];
  static const knightDelta = [
    [-33, -31],
    [-18, 14],
    [-14, 18],
    [31, 33],
  ];
  static const knightCheckDelta = [
    [-33, -18],
    [-31, -14],
    [14, 31],
    [18, 33],
  ];
  static const mvvValue = [50, 10, 10, 30, 40, 30, 20, 0];

  static const pieceValue = [
    [
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, //
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 9, 9, 9, 11, 13, 11, 9, 9, 9, 0, 0, 0, 0,
      0, 0, 0, 19, 24, 34, 42, 44, 42, 34, 24, 19, 0, 0, 0, 0,
      0, 0, 0, 19, 24, 32, 37, 37, 37, 32, 24, 19, 0, 0, 0, 0,
      0, 0, 0, 19, 23, 27, 29, 30, 29, 27, 23, 19, 0, 0, 0, 0,
      0, 0, 0, 14, 18, 20, 27, 29, 27, 20, 18, 14, 0, 0, 0, 0,
      0, 0, 0, 7, 0, 13, 0, 16, 0, 13, 0, 7, 0, 0, 0, 0,
      0, 0, 0, 7, 0, 7, 0, 15, 0, 7, 0, 7, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 11, 15, 11, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ],
    [
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, //
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 20, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 18, 0, 0, 20, 23, 20, 0, 0, 18, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 23, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 20, 20, 0, 20, 20, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ],
    [
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, //
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 20, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 18, 0, 0, 20, 23, 20, 0, 0, 18, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 23, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 20, 20, 0, 20, 20, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ],
    [
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, //
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 90, 90, 90, 96, 90, 96, 90, 90, 90, 0, 0, 0, 0,
      0, 0, 0, 90, 96, 103, 97, 94, 97, 103, 96, 90, 0, 0, 0, 0,
      0, 0, 0, 92, 98, 99, 103, 99, 103, 99, 98, 92, 0, 0, 0, 0,
      0, 0, 0, 93, 108, 100, 107, 100, 107, 100, 108, 93, 0, 0, 0, 0,
      0, 0, 0, 90, 100, 99, 103, 104, 103, 99, 100, 90, 0, 0, 0, 0,
      0, 0, 0, 90, 98, 101, 102, 103, 102, 101, 98, 90, 0, 0, 0, 0,
      0, 0, 0, 92, 94, 98, 95, 98, 95, 98, 94, 92, 0, 0, 0, 0,
      0, 0, 0, 93, 92, 94, 95, 92, 95, 94, 92, 93, 0, 0, 0, 0,
      0, 0, 0, 85, 90, 92, 93, 78, 93, 92, 90, 85, 0, 0, 0, 0,
      0, 0, 0, 88, 85, 90, 88, 90, 88, 90, 85, 88, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ],
    [
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, //
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 206, 208, 207, 213, 214, 213, 207, 208, 206, 0, 0, 0, 0,
      0, 0, 0, 206, 212, 209, 216, 233, 216, 209, 212, 206, 0, 0, 0, 0,
      0, 0, 0, 206, 208, 207, 214, 216, 214, 207, 208, 206, 0, 0, 0, 0,
      0, 0, 0, 206, 213, 213, 216, 216, 216, 213, 213, 206, 0, 0, 0, 0,
      0, 0, 0, 208, 211, 211, 214, 215, 214, 211, 211, 208, 0, 0, 0, 0,
      0, 0, 0, 208, 212, 212, 214, 215, 214, 212, 212, 208, 0, 0, 0, 0,
      0, 0, 0, 204, 209, 204, 212, 214, 212, 204, 209, 204, 0, 0, 0, 0,
      0, 0, 0, 198, 208, 204, 212, 212, 212, 204, 208, 198, 0, 0, 0, 0,
      0, 0, 0, 200, 208, 206, 212, 200, 212, 206, 208, 200, 0, 0, 0, 0,
      0, 0, 0, 194, 206, 204, 212, 200, 212, 204, 206, 194, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ],
    [
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, //
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 100, 100, 96, 91, 90, 91, 96, 100, 100, 0, 0, 0, 0,
      0, 0, 0, 98, 98, 96, 92, 89, 92, 96, 98, 98, 0, 0, 0, 0,
      0, 0, 0, 97, 97, 96, 91, 92, 91, 96, 97, 97, 0, 0, 0, 0,
      0, 0, 0, 96, 99, 99, 98, 100, 98, 99, 99, 96, 0, 0, 0, 0,
      0, 0, 0, 96, 96, 96, 96, 100, 96, 96, 96, 96, 0, 0, 0, 0,
      0, 0, 0, 95, 96, 99, 96, 100, 96, 99, 96, 95, 0, 0, 0, 0,
      0, 0, 0, 96, 96, 96, 96, 96, 96, 96, 96, 96, 0, 0, 0, 0,
      0, 0, 0, 97, 96, 100, 99, 101, 99, 100, 96, 97, 0, 0, 0, 0,
      0, 0, 0, 96, 97, 98, 98, 98, 98, 98, 97, 96, 0, 0, 0, 0,
      0, 0, 0, 96, 96, 97, 99, 99, 99, 97, 96, 96, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ],
    [
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, //
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 9, 9, 9, 11, 13, 11, 9, 9, 9, 0, 0, 0, 0,
      0, 0, 0, 19, 24, 34, 42, 44, 42, 34, 24, 19, 0, 0, 0, 0,
      0, 0, 0, 19, 24, 32, 37, 37, 37, 32, 24, 19, 0, 0, 0, 0,
      0, 0, 0, 19, 23, 27, 29, 30, 29, 27, 23, 19, 0, 0, 0, 0,
      0, 0, 0, 14, 18, 20, 27, 29, 27, 20, 18, 14, 0, 0, 0, 0,
      0, 0, 0, 7, 0, 13, 0, 16, 0, 13, 0, 7, 0, 0, 0, 0,
      0, 0, 0, 7, 0, 7, 0, 15, 0, 7, 0, 7, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 11, 15, 11, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ],
  ];

  static const startupFen = [
    "rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",
    "rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/R1BAKABNR w - - 0 1",
    "rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/R1BAKAB1R w - - 0 1",
    "rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/9/1C5C1/9/RN2K2NR w - - 0 1",
  ];

  static bool isInBoard(int sq) => inBoard[sq] != 0;

  static bool isInFort(int sq) => inFort[sq] != 0;

  static int rankY(int sq) => sq >> 4;

  static int fileX(int sq) => sq & 15;

  static int coordXY(int x, int y) => x + (y << 4);

  static int squareFlip(int sq) => 254 - sq;

  static int fileFlip(int x) => 14 - x;

  static int rankFlip(int y) => 15 - y;

  static int mirrotSquare(int sq) => coordXY(fileFlip(fileX(sq)), rankY(sq));

  static int squareForward(int sq, int sd) => sq - 16 + (sd << 5);

  static bool kingSpan(int sqSrc, int sqDst) =>
      legalSpan[sqDst - sqSrc + 256] == 1;

  static bool advisorSpan(int sqSrc, int sqDst) =>
      legalSpan[sqDst - sqSrc + 256] == 2;

  static bool bishopSpan(int sqSrc, int sqDst) =>
      legalSpan[sqDst - sqSrc + 256] == 3;

  static int bishopPin(int sqSrc, int sqDst) => (sqSrc + sqDst) >> 1;

  static int getKnightPin(int sqSrc, int sqDst) =>
      sqSrc + knightPin[sqDst - sqSrc + 256];

  static bool homeHalf(int sq, int sd) => (sq & 0x80) != (sd << 7);

  static bool awayHalf(int sq, int sd) => (sq & 0x80) == (sd << 7);

  static bool sameHalf(int sqSrc, int sqDst) => ((sqSrc ^ sqDst) & 0x80) == 0;

  static bool sameRank(int sqSrc, int sqDst) => ((sqSrc ^ sqDst) & 0xf0) == 0;

  static bool sameFile(int sqSrc, int sqDst) => ((sqSrc ^ sqDst) & 0x0f) == 0;

  static int sideTag(int sd) => 8 + (sd << 3);

  static int oppSideTag(int sd) => 16 - (sd << 3);

  static int src(int mv) => mv & 255;

  static int dst(int mv) => mv >> 8;

  static int move(int sqSrc, int sqDst) => sqSrc + (sqDst << 8);

  static int mirrorMove(int mv) =>
      move(mirrotSquare(src(mv)), mirrotSquare(dst(mv)));

  static int mvvLva(int pc, int lva) => mvvValue[pc & 7] - lva;

  static const fenPiece = "        KABNRCP kabnrcp ";

  static int charToPiece(String c) {
    switch (c) {
      case 'K':
        return pieceKing;
      case 'A':
        return pieceAdvisor;
      case 'B':
      case 'E':
        return pieceBishop;
      case 'H':
      case 'N':
        return pieceKnight;
      case 'R':
        return pieceRook;
      case 'C':
        return pieceCannon;
      case 'P':
        return piecePawn;
      default:
        return -1;
    }
  }

  static late int preGenZobristKeyPlayer;
  static late int preGenZobristLockPlayer;
  static final preGenZobristKeyTable = List.filled(14, List.filled(256, 0));
  static final preGenZobristLockTable = List.filled(14, List.filled(256, 0));

  static final random = math.Random();

  static int bookSize = 0;
  static final bookLock = List.filled(maxBookSize, 0);
  static final bookMoveList = List.filled(maxBookSize, 0);
  static final bookValue = List.filled(maxBookSize, 0);
  static ByteData? input;

  static Future<bool> init() async {
    RC4 rc4 = RC4(Uint8List.fromList([0]));
    preGenZobristKeyPlayer = rc4.nextLong();
    rc4.nextLong(); // Skip ZobristLock0
    preGenZobristLockPlayer = rc4.nextLong();
    for (int i = 0; i < 14; i++) {
      for (int j = 0; j < 256; j++) {
        preGenZobristKeyTable[i][j] = rc4.nextLong();
        rc4.nextLong(); // Skip ZobristLock0
        preGenZobristLockTable[i][j] = rc4.nextLong();
      }
    }

    input ??= await rootBundle.load('assets/engines/BOOK.DAT');
    if (input != null) {
      try {
        while (bookSize < maxBookSize) {
          bookLock[bookSize] =
              input!.getUint32(bookSize * 8, Endian.little) >> 1;
          bookMoveList[bookSize] =
              input!.getUint16(bookSize * 8 + 4, Endian.little);
          bookValue[bookSize] =
              input!.getUint16(bookSize * 8 + 6, Endian.little);
          bookSize++;
        }
      } catch (e) {
        // Exit "while" when IOException occurs
      }
    }
    return true;
  }

  int sdPlayer = 0;
  List<int> squares = List.filled(256, 0);

  int zobristKey = 0;
  int zobristLock = 0;
  int vlWhite = 0, vlBlack = 0;
  int moveNum = 0, distance = 0;

  List<int> mvList = List.filled(maxMoveNum, 0);
  List<int> pcList = List.filled(maxMoveNum, 0);
  List<int> keyList = List.filled(maxMoveNum, 0);
  List<bool> chkList = List.filled(maxMoveNum, false);

  void clearBoard() {
    sdPlayer = 0;
    for (int sq = 0; sq < 256; sq++) {
      squares[sq] = 0;
    }
    zobristKey = zobristLock = 0;
    vlWhite = vlBlack = 0;
  }

  void setIrrev() {
    mvList[0] = pcList[0] = 0;
    chkList[0] = checked();
    moveNum = 1;
    distance = 0;
  }

  void addPiece(int sq, int pc, [bool del = false]) {
    int pcAdjust;
    squares[sq] = (del ? 0 : pc);
    if (pc < 16) {
      pcAdjust = pc - 8;
      vlWhite += del ? -pieceValue[pcAdjust][sq] : pieceValue[pcAdjust][sq];
    } else {
      pcAdjust = pc - 16;
      vlBlack += del
          ? -pieceValue[pcAdjust][squareFlip(sq)]
          : pieceValue[pcAdjust][squareFlip(sq)];
      pcAdjust += 7;
    }
    zobristKey ^= preGenZobristKeyTable[pcAdjust][sq];
    zobristLock ^= preGenZobristLockTable[pcAdjust][sq];
  }

  void delPiece(int sq, int pc) {
    addPiece(sq, pc, true);
  }

  void movePiece() {
    int sqSrc = src(mvList[moveNum]);
    int sqDst = dst(mvList[moveNum]);
    pcList[moveNum] = squares[sqDst];
    if (pcList[moveNum] > 0) {
      delPiece(sqDst, pcList[moveNum]);
    }
    int pc = squares[sqSrc];
    delPiece(sqSrc, pc);
    addPiece(sqDst, pc);
  }

  void undoMovePiece() {
    int sqSrc = src(mvList[moveNum]);
    int sqDst = dst(mvList[moveNum]);
    int pc = squares[sqDst];
    delPiece(sqDst, pc);
    addPiece(sqSrc, pc);
    if (pcList[moveNum] > 0) {
      addPiece(sqDst, pcList[moveNum]);
    }
  }

  void changeSide() {
    sdPlayer = 1 - sdPlayer;
    zobristKey ^= preGenZobristKeyPlayer;
    zobristLock ^= preGenZobristLockPlayer;
  }

  bool makeMove(int mv) {
    keyList[moveNum] = zobristKey;
    mvList[moveNum] = mv;
    movePiece();
    if (checked()) {
      undoMovePiece();
      return false;
    }
    changeSide();
    chkList[moveNum] = checked();
    moveNum++;
    distance++;
    return true;
  }

  void undoMakeMove() {
    moveNum--;
    distance--;
    changeSide();
    undoMovePiece();
  }

  void nullMove() {
    keyList[moveNum] = zobristKey;
    changeSide();
    mvList[moveNum] = pcList[moveNum] = 0;
    chkList[moveNum] = false;
    moveNum++;
    distance++;
  }

  void undoNullMove() {
    moveNum--;
    distance--;
    changeSide();
  }

  void fromFen(String fen) {
    clearBoard();
    int y = rankTop;
    int x = fileLeft;
    int index = 0;
    if (index == fen.length) {
      setIrrev();
      return;
    }
    String c = fen[index];
    while (c != ' ') {
      if (c == '/') {
        x = fileLeft;
        y++;
        if (y > rankBottom) {
          break;
        }
      } else if (c.codeUnitAt(0) >= '1'.codeUnitAt(0) &&
          c.codeUnitAt(0) <= '9'.codeUnitAt(0)) {
        x += (c.codeUnitAt(0) - '0'.codeUnitAt(0));
      } else if (c.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
          c.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) {
        if (x <= fileRight) {
          int pt = charToPiece(c);
          if (pt >= 0) {
            addPiece(coordXY(x, y), pt + 8);
          }
          x++;
        }
      } else if (c.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
          c.codeUnitAt(0) <= 'z'.codeUnitAt(0)) {
        if (x <= fileRight) {
          int pt = charToPiece(String.fromCharCode(
              c.codeUnitAt(0) + 'A'.codeUnitAt(0) - 'a'.codeUnitAt(0)));
          if (pt >= 0) {
            addPiece(coordXY(x, y), pt + 16);
          }
          x++;
        }
      }
      index++;
      if (index == fen.length) {
        setIrrev();
        return;
      }
      c = fen[index];
    }
    index++;
    if (index == fen.length) {
      setIrrev();
      return;
    }
    if (sdPlayer == (fen[index] == 'b' ? 0 : 1)) {
      changeSide();
    }
    setIrrev();
  }

  String toFen() {
    StringBuffer fen = StringBuffer();
    for (int y = rankTop; y <= rankBottom; y++) {
      int k = 0;
      for (int x = fileLeft; x <= fileRight; x++) {
        int pc = squares[coordXY(x, y)];
        if (pc > 0) {
          if (k > 0) {
            fen.write(String.fromCharCode('0'.codeUnitAt(0) + k));
            k = 0;
          }
          fen.write(fenPiece[pc]);
        } else {
          k++;
        }
      }
      if (k > 0) {
        fen.write(String.fromCharCode('0'.codeUnitAt(0) + k));
      }
      if (y == rankBottom) {
        fen.write(' ');
      } else {
        fen.write('/');
      }
    }
    fen.write(sdPlayer == 0 ? 'w' : 'b');
    return fen.toString();
  }

  int generateAllMoves(List<int> mvs) {
    return generateMoves(mvs, null);
  }

  int generateMoves(List<int> mvs, List<int>? vls) {
    int moves = 0;
    int pcSelfSide = sideTag(sdPlayer);
    int pcOppSide = oppSideTag(sdPlayer);
    for (int sqSrc = 0; sqSrc < 256; sqSrc++) {
      int pcSrc = squares[sqSrc];
      if ((pcSrc & pcSelfSide) == 0) {
        continue;
      }
      switch (pcSrc - pcSelfSide) {
        case pieceKing:
          for (int i = 0; i < 4; i++) {
            int sqDst = sqSrc + kingDelta[i];
            if (!isInFort(sqDst)) {
              continue;
            }
            int pcDst = squares[sqDst];
            if (vls == null) {
              if ((pcDst & pcSelfSide) == 0) {
                mvs[moves] = move(sqSrc, sqDst);
                moves++;
              }
            } else if ((pcDst & pcOppSide) != 0) {
              mvs[moves] = move(sqSrc, sqDst);
              vls[moves] = mvvLva(pcDst, 5);
              moves++;
            }
          }
          break;
        case pieceAdvisor:
          for (int i = 0; i < 4; i++) {
            int sqDst = sqSrc + advisorDelta[i];
            if (!isInFort(sqDst)) {
              continue;
            }
            int pcDst = squares[sqDst];
            if (vls == null) {
              if ((pcDst & pcSelfSide) == 0) {
                mvs[moves] = move(sqSrc, sqDst);
                moves++;
              }
            } else if ((pcDst & pcOppSide) != 0) {
              mvs[moves] = move(sqSrc, sqDst);
              vls[moves] = mvvLva(pcDst, 1);
              moves++;
            }
          }
          break;
        case pieceBishop:
          for (int i = 0; i < 4; i++) {
            int sqDst = sqSrc + advisorDelta[i];
            if (!(isInBoard(sqDst) &&
                homeHalf(sqDst, sdPlayer) &&
                squares[sqDst] == 0)) {
              continue;
            }
            sqDst += advisorDelta[i];
            int pcDst = squares[sqDst];
            if (vls == null) {
              if ((pcDst & pcSelfSide) == 0) {
                mvs[moves] = move(sqSrc, sqDst);
                moves++;
              }
            } else if ((pcDst & pcOppSide) != 0) {
              mvs[moves] = move(sqSrc, sqDst);
              vls[moves] = mvvLva(pcDst, 1);
              moves++;
            }
          }
          break;
        case pieceKnight:
          for (int i = 0; i < 4; i++) {
            int sqDst = sqSrc + kingDelta[i];
            if (squares[sqDst] > 0) {
              continue;
            }
            for (int j = 0; j < 2; j++) {
              sqDst = sqSrc + knightDelta[i][j];
              if (!isInBoard(sqDst)) {
                continue;
              }
              int pcDst = squares[sqDst];
              if (vls == null) {
                if ((pcDst & pcSelfSide) == 0) {
                  mvs[moves] = move(sqSrc, sqDst);
                  moves++;
                }
              } else if ((pcDst & pcOppSide) != 0) {
                mvs[moves] = move(sqSrc, sqDst);
                vls[moves] = mvvLva(pcDst, 1);
                moves++;
              }
            }
          }
          break;
        case pieceRook:
          for (int i = 0; i < 4; i++) {
            int delta = kingDelta[i];
            int sqDst = sqSrc + delta;
            while (isInBoard(sqDst)) {
              int pcDst = squares[sqDst];
              if (pcDst == 0) {
                if (vls == null) {
                  mvs[moves] = move(sqSrc, sqDst);
                  moves++;
                }
              } else {
                if ((pcDst & pcOppSide) != 0) {
                  mvs[moves] = move(sqSrc, sqDst);
                  if (vls != null) {
                    vls[moves] = mvvLva(pcDst, 4);
                  }
                  moves++;
                }
                break;
              }
              sqDst += delta;
            }
          }
          break;
        case pieceCannon:
          for (int i = 0; i < 4; i++) {
            int delta = kingDelta[i];
            int sqDst = sqSrc + delta;
            while (isInBoard(sqDst)) {
              int pcDst = squares[sqDst];
              if (pcDst == 0) {
                if (vls == null) {
                  mvs[moves] = move(sqSrc, sqDst);
                  moves++;
                }
              } else {
                break;
              }
              sqDst += delta;
            }
            sqDst += delta;
            while (isInBoard(sqDst)) {
              int pcDst = squares[sqDst];
              if (pcDst > 0) {
                if ((pcDst & pcOppSide) != 0) {
                  mvs[moves] = move(sqSrc, sqDst);
                  if (vls != null) {
                    vls[moves] = mvvLva(pcDst, 4);
                  }
                  moves++;
                }
                break;
              }
              sqDst += delta;
            }
          }
          break;
        case piecePawn:
          int sqDst = squareForward(sqSrc, sdPlayer);
          if (isInBoard(sqDst)) {
            int pcDst = squares[sqDst];
            if (vls == null) {
              if ((pcDst & pcSelfSide) == 0) {
                mvs[moves] = move(sqSrc, sqDst);
                moves++;
              }
            } else if ((pcDst & pcOppSide) != 0) {
              mvs[moves] = move(sqSrc, sqDst);
              vls[moves] = mvvLva(pcDst, 2);
              moves++;
            }
          }
          if (awayHalf(sqSrc, sdPlayer)) {
            for (int delta = -1; delta <= 1; delta += 2) {
              sqDst = sqSrc + delta;
              if (isInBoard(sqDst)) {
                int pcDst = squares[sqDst];
                if (vls == null) {
                  if ((pcDst & pcSelfSide) == 0) {
                    mvs[moves] = move(sqSrc, sqDst);
                    moves++;
                  }
                } else if ((pcDst & pcOppSide) != 0) {
                  mvs[moves] = move(sqSrc, sqDst);
                  vls[moves] = mvvLva(pcDst, 2);
                  moves++;
                }
              }
            }
          }
          break;
      }
    }
    return moves;
  }

  bool legalMove(int mv) {
    int sqSrc = src(mv);
    int pcSrc = squares[sqSrc];
    int pcSelfSide = sideTag(sdPlayer);
    if ((pcSrc & pcSelfSide) == 0) {
      return false;
    }

    int sqDst = dst(mv);
    int pcDst = squares[sqDst];
    if ((pcDst & pcSelfSide) != 0) {
      return false;
    }
    int sqPin;
    switch (pcSrc - pcSelfSide) {
      case pieceKing:
        return isInFort(sqDst) && kingSpan(sqSrc, sqDst);
      case pieceAdvisor:
        return isInFort(sqDst) && advisorSpan(sqSrc, sqDst);
      case pieceBishop:
        return sameHalf(sqSrc, sqDst) &&
            bishopSpan(sqSrc, sqDst) &&
            squares[bishopPin(sqSrc, sqDst)] == 0;
      case pieceKnight:
        sqPin = getKnightPin(sqSrc, sqDst);
        return sqPin != sqSrc && squares[sqPin] == 0;
      case pieceRook:
      case pieceCannon:
        int delta;
        if (sameRank(sqSrc, sqDst)) {
          delta = (sqDst < sqSrc ? -1 : 1);
        } else if (sameFile(sqSrc, sqDst)) {
          delta = (sqDst < sqSrc ? -16 : 16);
        } else {
          return false;
        }
        sqPin = sqSrc + delta;
        while (sqPin != sqDst && squares[sqPin] == 0) {
          sqPin += delta;
        }
        if (sqPin == sqDst) {
          return pcDst == 0 || pcSrc - pcSelfSide == pieceRook;
        }
        if (pcDst == 0 || pcSrc - pcSelfSide == pieceRook) {
          return false;
        }
        sqPin += delta;
        while (sqPin != sqDst && squares[sqPin] == 0) {
          sqPin += delta;
        }
        return sqPin == sqDst;
      case piecePawn:
        if (awayHalf(sqDst, sdPlayer) &&
            (sqDst == sqSrc - 1 || sqDst == sqSrc + 1)) {
          return true;
        }
        return sqDst == squareForward(sqSrc, sdPlayer);
      default:
        return false;
    }
  }

  bool checked() {
    int pcSelfSide = sideTag(sdPlayer);
    int pcOppSide = oppSideTag(sdPlayer);
    for (int sqSrc = 0; sqSrc < 256; sqSrc++) {
      if (squares[sqSrc] != pcSelfSide + pieceKing) {
        continue;
      }
      if (squares[squareForward(sqSrc, sdPlayer)] == pcOppSide + piecePawn) {
        return true;
      }
      for (int delta = -1; delta <= 1; delta += 2) {
        if (squares[sqSrc + delta] == pcOppSide + piecePawn) {
          return true;
        }
      }
      for (int i = 0; i < 4; i++) {
        if (squares[sqSrc + advisorDelta[i]] != 0) {
          continue;
        }
        for (int j = 0; j < 2; j++) {
          int pcDst = squares[sqSrc + knightCheckDelta[i][j]];
          if (pcDst == pcOppSide + pieceKnight) {
            return true;
          }
        }
      }
      for (int i = 0; i < 4; i++) {
        int delta = kingDelta[i];
        int sqDst = sqSrc + delta;
        while (isInBoard(sqDst)) {
          int pcDst = squares[sqDst];
          if (pcDst > 0) {
            if (pcDst == pcOppSide + pieceRook ||
                pcDst == pcOppSide + pieceKing) {
              return true;
            }
            break;
          }
          sqDst += delta;
        }
        sqDst += delta;
        while (isInBoard(sqDst)) {
          int pcDst = squares[sqDst];
          if (pcDst > 0) {
            if (pcDst == pcOppSide + pieceCannon) {
              return true;
            }
            break;
          }
          sqDst += delta;
        }
      }
      return false;
    }
    return false;
  }

  bool isMate() {
    List<int> mvs = List.filled(maxGenMoves, 0);
    int moves = generateAllMoves(mvs);
    for (int i = 0; i < moves; i++) {
      if (makeMove(mvs[i])) {
        undoMakeMove();
        return false;
      }
    }
    return true;
  }

  int mateValue() {
    return distance - gMateValue;
  }

  int banValue() {
    return distance - gBanValue;
  }

  int drawValue() {
    return (distance & 1) == 0 ? -gDrawValue : gDrawValue;
  }

  int evaluate() {
    int vl = (sdPlayer == 0 ? vlWhite - vlBlack : vlBlack - vlWhite) +
        gAdvancedValue;
    return vl == drawValue() ? vl - 1 : vl;
  }

  bool nullOkay() {
    return (sdPlayer == 0 ? vlWhite : vlBlack) > nullOkayMargin;
  }

  bool nullSafe() {
    return (sdPlayer == 0 ? vlWhite : vlBlack) > nullSafeMargin;
  }

  bool inCheck() {
    return chkList[moveNum - 1];
  }

  bool captured() {
    return pcList[moveNum - 1] > 0;
  }

  int repValue(int vlRep) {
    int vlReturn = ((vlRep & 2) == 0 ? 0 : banValue()) +
        ((vlRep & 4) == 0 ? 0 : -banValue());
    return vlReturn == 0 ? drawValue() : vlReturn;
  }

  int repStatus([int recur_ = 1]) {
    int recur = recur_;
    bool selfSide = false;
    bool perpCheck = true;
    bool oppPerpCheck = true;
    int index = moveNum - 1;
    while (mvList[index] > 0 && pcList[index] == 0) {
      if (selfSide) {
        perpCheck = perpCheck && chkList[index];
        if (keyList[index] == zobristKey) {
          recur--;
          if (recur == 0) {
            return 1 + (perpCheck ? 2 : 0) + (oppPerpCheck ? 4 : 0);
          }
        }
      } else {
        oppPerpCheck = oppPerpCheck && chkList[index];
      }
      selfSide = !selfSide;
      index--;
    }
    return 0;
  }

  Position mirror() {
    Position pos = Position();
    pos.clearBoard();
    for (int sq = 0; sq < 256; sq++) {
      int pc = squares[sq];
      if (pc > 0) {
        pos.addPiece(mirrotSquare(sq), pc);
      }
    }
    if (sdPlayer == 1) {
      pos.changeSide();
    }
    return pos;
  }

  int bookMove() {
    if (bookSize == 0) {
      return 0;
    }
    bool isMirror = false;
    int lock = zobristLock >> 1; // Convert into Unsigned
    int index = Util.binarySearch(lock, bookLock, 0, bookSize);
    if (index < 0) {
      isMirror = true;
      lock = mirror().zobristLock >> 1; // Convert into Unsigned
      index = Util.binarySearch(lock, bookLock, 0, bookSize);
    }
    if (index < 0) {
      return 0;
    }
    index--;
    while (index >= 0 && bookLock[index] == lock) {
      index--;
    }
    List<int> mvs = List.filled(maxGenMoves, 0);
    List<int> vls = List.filled(maxGenMoves, 0);
    int value = 0;
    int moves = 0;
    index++;
    while (index < bookSize && bookLock[index] == lock) {
      int mv = 0xffff & bookMoveList[index];
      mv = (isMirror ? mirrorMove(mv) : mv);
      if (legalMove(mv)) {
        mvs[moves] = mv;
        vls[moves] = bookValue[index];
        value += vls[moves];
        moves++;
        if (moves == maxGenMoves) {
          break;
        }
      }
      index++;
    }
    if (value == 0) {
      return 0;
    }
    value = random.nextInt(value);
    for (index = 0; index < moves; index++) {
      value -= vls[index];
      if (value < 0) {
        break;
      }
    }
    return mvs[index];
  }

  int historyIndex(int mv) {
    return ((squares[src(mv)] - 8) << 8) + dst(mv);
  }
}
