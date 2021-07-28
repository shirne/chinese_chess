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

import 'dart:math' as Math;
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'util.dart';

class Position {
  static const int MATE_VALUE = 10000;
  static const int BAN_VALUE = MATE_VALUE - 100;
  static const int WIN_VALUE = MATE_VALUE - 200;
  static const int NULL_SAFE_MARGIN = 400;
  static const int NULL_OKAY_MARGIN = 200;
  static const int DRAW_VALUE = 20;
  static const int ADVANCED_VALUE = 3;

  static const int MAX_MOVE_NUM = 256;
  static const int MAX_GEN_MOVES = 128;
  static const int MAX_BOOK_SIZE = 16384;

  static const int PIECE_KING = 0;
  static const int PIECE_ADVISOR = 1;
  static const int PIECE_BISHOP = 2;
  static const int PIECE_KNIGHT = 3;
  static const int PIECE_ROOK = 4;
  static const int PIECE_CANNON = 5;
  static const int PIECE_PAWN = 6;

  static const int RANK_TOP = 3;
  static const int RANK_BOTTOM = 12;
  static const int FILE_LEFT = 3;
  static const int FILE_RIGHT = 11;

  static final List<int> IN_BOARD = [
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

  static final List<int> IN_FORT = [
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

  static final List<int> LEGAL_SPAN = [
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

  static final List<int> KNIGHT_PIN = [
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

  static final List<int> KING_DELTA = [-16, -1, 1, 16];
  static final List<int> ADVISOR_DELTA = [-17, -15, 15, 17];
  static final List<List<int>> KNIGHT_DELTA = [
    [-33, -31],
    [-18, 14],
    [-14, 18],
    [31, 33],
  ];
  static final List<List<int>> KNIGHT_CHECK_DELTA = [
    [-33, -18],
    [-31, -14],
    [14, 31],
    [18, 33],
  ];
  static final List<int> MVV_VALUE = [50, 10, 10, 30, 40, 30, 20, 0];

  static final List<List<int>> PIECE_VALUE = [
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

  static final List<String> STARTUP_FEN = [
    "rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",
    "rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/R1BAKABNR w - - 0 1",
    "rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/R1BAKAB1R w - - 0 1",
    "rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/9/1C5C1/9/RN2K2NR w - - 0 1",
  ];

  static bool isIN_BOARD(int sq) {
    return IN_BOARD[sq] != 0;
  }

  static bool isIN_FORT(int sq) {
    return IN_FORT[sq] != 0;
  }

  static int RANK_Y(int sq) {
    return sq >> 4;
  }

  static int FILE_X(int sq) {
    return sq & 15;
  }

  static int COORD_XY(int x, int y) {
    return x + (y << 4);
  }

  static int SQUARE_FLIP(int sq) {
    return 254 - sq;
  }

  static int FILE_FLIP(int x) {
    return 14 - x;
  }

  static int RANK_FLIP(int y) {
    return 15 - y;
  }

  static int MIRROR_SQUARE(int sq) {
    return COORD_XY(FILE_FLIP(FILE_X(sq)), RANK_Y(sq));
  }

  static int SQUARE_FORWARD(int sq, int sd) {
    return sq - 16 + (sd << 5);
  }

  static bool KING_SPAN(int sqSrc, int sqDst) {
    return LEGAL_SPAN[sqDst - sqSrc + 256] == 1;
  }

  static bool ADVISOR_SPAN(int sqSrc, int sqDst) {
    return LEGAL_SPAN[sqDst - sqSrc + 256] == 2;
  }

  static bool BISHOP_SPAN(int sqSrc, int sqDst) {
    return LEGAL_SPAN[sqDst - sqSrc + 256] == 3;
  }

  static int BISHOP_PIN(int sqSrc, int sqDst) {
    return (sqSrc + sqDst) >> 1;
  }

  static int getKNIGHT_PIN(int sqSrc, int sqDst) {
    return sqSrc + KNIGHT_PIN[sqDst - sqSrc + 256];
  }

  static bool HOME_HALF(int sq, int sd) {
    return (sq & 0x80) != (sd << 7);
  }

  static bool AWAY_HALF(int sq, int sd) {
    return (sq & 0x80) == (sd << 7);
  }

  static bool SAME_HALF(int sqSrc, int sqDst) {
    return ((sqSrc ^ sqDst) & 0x80) == 0;
  }

  static bool SAME_RANK(int sqSrc, int sqDst) {
    return ((sqSrc ^ sqDst) & 0xf0) == 0;
  }

  static bool SAME_FILE(int sqSrc, int sqDst) {
    return ((sqSrc ^ sqDst) & 0x0f) == 0;
  }

  static int SIDE_TAG(int sd) {
    return 8 + (sd << 3);
  }

  static int OPP_SIDE_TAG(int sd) {
    return 16 - (sd << 3);
  }

  static int SRC(int mv) {
    return mv & 255;
  }

  static int DST(int mv) {
    return mv >> 8;
  }

  static int MOVE(int sqSrc, int sqDst) {
    return sqSrc + (sqDst << 8);
  }

  static int MIRROR_MOVE(int mv) {
    return MOVE(MIRROR_SQUARE(SRC(mv)), MIRROR_SQUARE(DST(mv)));
  }

  static int MVV_LVA(int pc, int lva) {
    return MVV_VALUE[pc & 7] - lva;
  }

  static final String FEN_PIECE = "        KABNRCP kabnrcp ";

  static int CHAR_TO_PIECE(String c) {
    switch (c) {
      case 'K':
        return PIECE_KING;
      case 'A':
        return PIECE_ADVISOR;
      case 'B':
      case 'E':
        return PIECE_BISHOP;
      case 'H':
      case 'N':
        return PIECE_KNIGHT;
      case 'R':
        return PIECE_ROOK;
      case 'C':
        return PIECE_CANNON;
      case 'P':
        return PIECE_PAWN;
      default:
        return -1;
    }
  }

  static late int PreGen_zobristKeyPlayer;
  static late int PreGen_zobristLockPlayer;
  static List<List<int>> PreGen_zobristKeyTable =
      List.filled(14, List.filled(256, 0));
  static List<List<int>> PreGen_zobristLockTable =
      List.filled(14, List.filled(256, 0));

  static Math.Random random = Math.Random();

  static int bookSize = 0;
  static List<int> bookLock = List.filled(MAX_BOOK_SIZE, 0);
  static List<int> bookMoveList = List.filled(MAX_BOOK_SIZE, 0);
  static List<int> bookValue = List.filled(MAX_BOOK_SIZE, 0);
  static ByteData? input;

  static Future<bool> init() async {
    RC4 rc4 = new RC4(Uint8List.fromList([0]));
    PreGen_zobristKeyPlayer = rc4.nextLong();
    rc4.nextLong(); // Skip ZobristLock0
    PreGen_zobristLockPlayer = rc4.nextLong();
    for (int i = 0; i < 14; i++) {
      for (int j = 0; j < 256; j++) {
        PreGen_zobristKeyTable[i][j] = rc4.nextLong();
        rc4.nextLong(); // Skip ZobristLock0
        PreGen_zobristLockTable[i][j] = rc4.nextLong();
      }
    }

    if (input == null) {
      //InputStream input = rc4.getClass().getResourceAsStream("/book/BOOK.DAT");
      input = await rootBundle.load('assets/engines/BOOK.DAT');
    }
    if (input != null) {
      try {
        while (bookSize < MAX_BOOK_SIZE) {
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

  List<int> mvList = List.filled(MAX_MOVE_NUM, 0);
  List<int> pcList = List.filled(MAX_MOVE_NUM, 0);
  List<int> keyList = List.filled(MAX_MOVE_NUM, 0);
  List<bool> chkList = List.filled(MAX_MOVE_NUM, false);

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
      vlWhite += del ? -PIECE_VALUE[pcAdjust][sq] : PIECE_VALUE[pcAdjust][sq];
    } else {
      pcAdjust = pc - 16;
      vlBlack += del
          ? -PIECE_VALUE[pcAdjust][SQUARE_FLIP(sq)]
          : PIECE_VALUE[pcAdjust][SQUARE_FLIP(sq)];
      pcAdjust += 7;
    }
    zobristKey ^= PreGen_zobristKeyTable[pcAdjust][sq];
    zobristLock ^= PreGen_zobristLockTable[pcAdjust][sq];
  }

  void delPiece(int sq, int pc) {
    addPiece(sq, pc, true);
  }

  void movePiece() {
    int sqSrc = SRC(mvList[moveNum]);
    int sqDst = DST(mvList[moveNum]);
    pcList[moveNum] = squares[sqDst];
    if (pcList[moveNum] > 0) {
      delPiece(sqDst, pcList[moveNum]);
    }
    int pc = squares[sqSrc];
    delPiece(sqSrc, pc);
    addPiece(sqDst, pc);
  }

  void undoMovePiece() {
    int sqSrc = SRC(mvList[moveNum]);
    int sqDst = DST(mvList[moveNum]);
    int pc = squares[sqDst];
    delPiece(sqDst, pc);
    addPiece(sqSrc, pc);
    if (pcList[moveNum] > 0) {
      addPiece(sqDst, pcList[moveNum]);
    }
  }

  void changeSide() {
    sdPlayer = 1 - sdPlayer;
    zobristKey ^= PreGen_zobristKeyPlayer;
    zobristLock ^= PreGen_zobristLockPlayer;
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
    int y = RANK_TOP;
    int x = FILE_LEFT;
    int index = 0;
    if (index == fen.length) {
      setIrrev();
      return;
    }
    String c = fen[index];
    while (c != ' ') {
      if (c == '/') {
        x = FILE_LEFT;
        y++;
        if (y > RANK_BOTTOM) {
          break;
        }
      } else if (c.codeUnitAt(0) >= '1'.codeUnitAt(0) &&
          c.codeUnitAt(0) <= '9'.codeUnitAt(0)) {
        x += (c.codeUnitAt(0) - '0'.codeUnitAt(0));
      } else if (c.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
          c.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) {
        if (x <= FILE_RIGHT) {
          int pt = CHAR_TO_PIECE(c);
          if (pt >= 0) {
            addPiece(COORD_XY(x, y), pt + 8);
          }
          x++;
        }
      } else if (c.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
          c.codeUnitAt(0) <= 'z'.codeUnitAt(0)) {
        if (x <= FILE_RIGHT) {
          int pt = CHAR_TO_PIECE(String.fromCharCode(
              c.codeUnitAt(0) + 'A'.codeUnitAt(0) - 'a'.codeUnitAt(0)));
          if (pt >= 0) {
            addPiece(COORD_XY(x, y), pt + 16);
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
    StringBuffer fen = new StringBuffer();
    for (int y = RANK_TOP; y <= RANK_BOTTOM; y++) {
      int k = 0;
      for (int x = FILE_LEFT; x <= FILE_RIGHT; x++) {
        int pc = squares[COORD_XY(x, y)];
        if (pc > 0) {
          if (k > 0) {
            fen.write(String.fromCharCode('0'.codeUnitAt(0) + k));
            k = 0;
          }
          fen.write(FEN_PIECE[pc]);
        } else {
          k++;
        }
      }
      if (k > 0) {
        fen.write(String.fromCharCode('0'.codeUnitAt(0) + k));
      }
      if (y == RANK_BOTTOM) {
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
    int pcSelfSide = SIDE_TAG(sdPlayer);
    int pcOppSide = OPP_SIDE_TAG(sdPlayer);
    for (int sqSrc = 0; sqSrc < 256; sqSrc++) {
      int pcSrc = squares[sqSrc];
      if ((pcSrc & pcSelfSide) == 0) {
        continue;
      }
      switch (pcSrc - pcSelfSide) {
        case PIECE_KING:
          for (int i = 0; i < 4; i++) {
            int sqDst = sqSrc + KING_DELTA[i];
            if (!isIN_FORT(sqDst)) {
              continue;
            }
            int pcDst = squares[sqDst];
            if (vls == null) {
              if ((pcDst & pcSelfSide) == 0) {
                mvs[moves] = MOVE(sqSrc, sqDst);
                moves++;
              }
            } else if ((pcDst & pcOppSide) != 0) {
              mvs[moves] = MOVE(sqSrc, sqDst);
              vls[moves] = MVV_LVA(pcDst, 5);
              moves++;
            }
          }
          break;
        case PIECE_ADVISOR:
          for (int i = 0; i < 4; i++) {
            int sqDst = sqSrc + ADVISOR_DELTA[i];
            if (!isIN_FORT(sqDst)) {
              continue;
            }
            int pcDst = squares[sqDst];
            if (vls == null) {
              if ((pcDst & pcSelfSide) == 0) {
                mvs[moves] = MOVE(sqSrc, sqDst);
                moves++;
              }
            } else if ((pcDst & pcOppSide) != 0) {
              mvs[moves] = MOVE(sqSrc, sqDst);
              vls[moves] = MVV_LVA(pcDst, 1);
              moves++;
            }
          }
          break;
        case PIECE_BISHOP:
          for (int i = 0; i < 4; i++) {
            int sqDst = sqSrc + ADVISOR_DELTA[i];
            if (!(isIN_BOARD(sqDst) &&
                HOME_HALF(sqDst, sdPlayer) &&
                squares[sqDst] == 0)) {
              continue;
            }
            sqDst += ADVISOR_DELTA[i];
            int pcDst = squares[sqDst];
            if (vls == null) {
              if ((pcDst & pcSelfSide) == 0) {
                mvs[moves] = MOVE(sqSrc, sqDst);
                moves++;
              }
            } else if ((pcDst & pcOppSide) != 0) {
              mvs[moves] = MOVE(sqSrc, sqDst);
              vls[moves] = MVV_LVA(pcDst, 1);
              moves++;
            }
          }
          break;
        case PIECE_KNIGHT:
          for (int i = 0; i < 4; i++) {
            int sqDst = sqSrc + KING_DELTA[i];
            if (squares[sqDst] > 0) {
              continue;
            }
            for (int j = 0; j < 2; j++) {
              sqDst = sqSrc + KNIGHT_DELTA[i][j];
              if (!isIN_BOARD(sqDst)) {
                continue;
              }
              int pcDst = squares[sqDst];
              if (vls == null) {
                if ((pcDst & pcSelfSide) == 0) {
                  mvs[moves] = MOVE(sqSrc, sqDst);
                  moves++;
                }
              } else if ((pcDst & pcOppSide) != 0) {
                mvs[moves] = MOVE(sqSrc, sqDst);
                vls[moves] = MVV_LVA(pcDst, 1);
                moves++;
              }
            }
          }
          break;
        case PIECE_ROOK:
          for (int i = 0; i < 4; i++) {
            int delta = KING_DELTA[i];
            int sqDst = sqSrc + delta;
            while (isIN_BOARD(sqDst)) {
              int pcDst = squares[sqDst];
              if (pcDst == 0) {
                if (vls == null) {
                  mvs[moves] = MOVE(sqSrc, sqDst);
                  moves++;
                }
              } else {
                if ((pcDst & pcOppSide) != 0) {
                  mvs[moves] = MOVE(sqSrc, sqDst);
                  if (vls != null) {
                    vls[moves] = MVV_LVA(pcDst, 4);
                  }
                  moves++;
                }
                break;
              }
              sqDst += delta;
            }
          }
          break;
        case PIECE_CANNON:
          for (int i = 0; i < 4; i++) {
            int delta = KING_DELTA[i];
            int sqDst = sqSrc + delta;
            while (isIN_BOARD(sqDst)) {
              int pcDst = squares[sqDst];
              if (pcDst == 0) {
                if (vls == null) {
                  mvs[moves] = MOVE(sqSrc, sqDst);
                  moves++;
                }
              } else {
                break;
              }
              sqDst += delta;
            }
            sqDst += delta;
            while (isIN_BOARD(sqDst)) {
              int pcDst = squares[sqDst];
              if (pcDst > 0) {
                if ((pcDst & pcOppSide) != 0) {
                  mvs[moves] = MOVE(sqSrc, sqDst);
                  if (vls != null) {
                    vls[moves] = MVV_LVA(pcDst, 4);
                  }
                  moves++;
                }
                break;
              }
              sqDst += delta;
            }
          }
          break;
        case PIECE_PAWN:
          int sqDst = SQUARE_FORWARD(sqSrc, sdPlayer);
          if (isIN_BOARD(sqDst)) {
            int pcDst = squares[sqDst];
            if (vls == null) {
              if ((pcDst & pcSelfSide) == 0) {
                mvs[moves] = MOVE(sqSrc, sqDst);
                moves++;
              }
            } else if ((pcDst & pcOppSide) != 0) {
              mvs[moves] = MOVE(sqSrc, sqDst);
              vls[moves] = MVV_LVA(pcDst, 2);
              moves++;
            }
          }
          if (AWAY_HALF(sqSrc, sdPlayer)) {
            for (int delta = -1; delta <= 1; delta += 2) {
              sqDst = sqSrc + delta;
              if (isIN_BOARD(sqDst)) {
                int pcDst = squares[sqDst];
                if (vls == null) {
                  if ((pcDst & pcSelfSide) == 0) {
                    mvs[moves] = MOVE(sqSrc, sqDst);
                    moves++;
                  }
                } else if ((pcDst & pcOppSide) != 0) {
                  mvs[moves] = MOVE(sqSrc, sqDst);
                  vls[moves] = MVV_LVA(pcDst, 2);
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
    int sqSrc = SRC(mv);
    int pcSrc = squares[sqSrc];
    int pcSelfSide = SIDE_TAG(sdPlayer);
    if ((pcSrc & pcSelfSide) == 0) {
      return false;
    }

    int sqDst = DST(mv);
    int pcDst = squares[sqDst];
    if ((pcDst & pcSelfSide) != 0) {
      return false;
    }
    int sqPin;
    switch (pcSrc - pcSelfSide) {
      case PIECE_KING:
        return isIN_FORT(sqDst) && KING_SPAN(sqSrc, sqDst);
      case PIECE_ADVISOR:
        return isIN_FORT(sqDst) && ADVISOR_SPAN(sqSrc, sqDst);
      case PIECE_BISHOP:
        return SAME_HALF(sqSrc, sqDst) &&
            BISHOP_SPAN(sqSrc, sqDst) &&
            squares[BISHOP_PIN(sqSrc, sqDst)] == 0;
      case PIECE_KNIGHT:
        sqPin = getKNIGHT_PIN(sqSrc, sqDst);
        return sqPin != sqSrc && squares[sqPin] == 0;
      case PIECE_ROOK:
      case PIECE_CANNON:
        int delta;
        if (SAME_RANK(sqSrc, sqDst)) {
          delta = (sqDst < sqSrc ? -1 : 1);
        } else if (SAME_FILE(sqSrc, sqDst)) {
          delta = (sqDst < sqSrc ? -16 : 16);
        } else {
          return false;
        }
        sqPin = sqSrc + delta;
        while (sqPin != sqDst && squares[sqPin] == 0) {
          sqPin += delta;
        }
        if (sqPin == sqDst) {
          return pcDst == 0 || pcSrc - pcSelfSide == PIECE_ROOK;
        }
        if (pcDst == 0 || pcSrc - pcSelfSide == PIECE_ROOK) {
          return false;
        }
        sqPin += delta;
        while (sqPin != sqDst && squares[sqPin] == 0) {
          sqPin += delta;
        }
        return sqPin == sqDst;
      case PIECE_PAWN:
        if (AWAY_HALF(sqDst, sdPlayer) &&
            (sqDst == sqSrc - 1 || sqDst == sqSrc + 1)) {
          return true;
        }
        return sqDst == SQUARE_FORWARD(sqSrc, sdPlayer);
      default:
        return false;
    }
  }

  bool checked() {
    int pcSelfSide = SIDE_TAG(sdPlayer);
    int pcOppSide = OPP_SIDE_TAG(sdPlayer);
    for (int sqSrc = 0; sqSrc < 256; sqSrc++) {
      if (squares[sqSrc] != pcSelfSide + PIECE_KING) {
        continue;
      }
      if (squares[SQUARE_FORWARD(sqSrc, sdPlayer)] == pcOppSide + PIECE_PAWN) {
        return true;
      }
      for (int delta = -1; delta <= 1; delta += 2) {
        if (squares[sqSrc + delta] == pcOppSide + PIECE_PAWN) {
          return true;
        }
      }
      for (int i = 0; i < 4; i++) {
        if (squares[sqSrc + ADVISOR_DELTA[i]] != 0) {
          continue;
        }
        for (int j = 0; j < 2; j++) {
          int pcDst = squares[sqSrc + KNIGHT_CHECK_DELTA[i][j]];
          if (pcDst == pcOppSide + PIECE_KNIGHT) {
            return true;
          }
        }
      }
      for (int i = 0; i < 4; i++) {
        int delta = KING_DELTA[i];
        int sqDst = sqSrc + delta;
        while (isIN_BOARD(sqDst)) {
          int pcDst = squares[sqDst];
          if (pcDst > 0) {
            if (pcDst == pcOppSide + PIECE_ROOK ||
                pcDst == pcOppSide + PIECE_KING) {
              return true;
            }
            break;
          }
          sqDst += delta;
        }
        sqDst += delta;
        while (isIN_BOARD(sqDst)) {
          int pcDst = squares[sqDst];
          if (pcDst > 0) {
            if (pcDst == pcOppSide + PIECE_CANNON) {
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
    List<int> mvs = List.filled(MAX_GEN_MOVES, 0);
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
    return distance - MATE_VALUE;
  }

  int banValue() {
    return distance - BAN_VALUE;
  }

  int drawValue() {
    return (distance & 1) == 0 ? -DRAW_VALUE : DRAW_VALUE;
  }

  int evaluate() {
    int vl = (sdPlayer == 0 ? vlWhite - vlBlack : vlBlack - vlWhite) +
        ADVANCED_VALUE;
    return vl == drawValue() ? vl - 1 : vl;
  }

  bool nullOkay() {
    return (sdPlayer == 0 ? vlWhite : vlBlack) > NULL_OKAY_MARGIN;
  }

  bool nullSafe() {
    return (sdPlayer == 0 ? vlWhite : vlBlack) > NULL_SAFE_MARGIN;
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
    Position pos = new Position();
    pos.clearBoard();
    for (int sq = 0; sq < 256; sq++) {
      int pc = squares[sq];
      if (pc > 0) {
        pos.addPiece(MIRROR_SQUARE(sq), pc);
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
    List<int> mvs = List.filled(MAX_GEN_MOVES, 0);
    List<int> vls = List.filled(MAX_GEN_MOVES, 0);
    int value = 0;
    int moves = 0;
    index++;
    while (index < bookSize && bookLock[index] == lock) {
      int mv = 0xffff & bookMoveList[index];
      mv = (isMirror ? MIRROR_MOVE(mv) : mv);
      if (legalMove(mv)) {
        mvs[moves] = mv;
        vls[moves] = bookValue[index];
        value += vls[moves];
        moves++;
        if (moves == MAX_GEN_MOVES) {
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
    return ((squares[SRC(mv)] - 8) << 8) + DST(mv);
  }
}
