// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Chinese Chess`
  String get app_title {
    return Intl.message(
      'Chinese Chess',
      name: 'app_title',
      desc: '',
      args: [],
    );
  }

  /// `Menu`
  String get menu {
    return Intl.message(
      'Menu',
      name: 'menu',
      desc: '',
      args: [],
    );
  }

  /// `Open Menu`
  String get open_menu {
    return Intl.message(
      'Open Menu',
      name: 'open_menu',
      desc: '',
      args: [],
    );
  }

  /// `Copy Chess Code`
  String get copy_code {
    return Intl.message(
      'Copy Chess Code',
      name: 'copy_code',
      desc: '',
      args: [],
    );
  }

  /// `Parse Chess Code`
  String get parse_code {
    return Intl.message(
      'Parse Chess Code',
      name: 'parse_code',
      desc: '',
      args: [],
    );
  }

  /// `Edit Chess`
  String get edit_code {
    return Intl.message(
      'Edit Chess',
      name: 'edit_code',
      desc: '',
      args: [],
    );
  }

  /// `New Game`
  String get new_game {
    return Intl.message(
      'New Game',
      name: 'new_game',
      desc: '',
      args: [],
    );
  }

  /// `Load Chess Manual`
  String get load_manual {
    return Intl.message(
      'Load Chess Manual',
      name: 'load_manual',
      desc: '',
      args: [],
    );
  }

  /// `Save Chess Manual`
  String get save_manual {
    return Intl.message(
      'Save Chess Manual',
      name: 'save_manual',
      desc: '',
      args: [],
    );
  }

  /// `Setting`
  String get setting {
    return Intl.message(
      'Setting',
      name: 'setting',
      desc: '',
      args: [],
    );
  }

  /// `Feature is not available`
  String get feature_not_available {
    return Intl.message(
      'Feature is not available',
      name: 'feature_not_available',
      desc: '',
      args: [],
    );
  }

  /// `Robot Mode`
  String get mode_robot {
    return Intl.message(
      'Robot Mode',
      name: 'mode_robot',
      desc: '',
      args: [],
    );
  }

  /// `Online Mode`
  String get mode_online {
    return Intl.message(
      'Online Mode',
      name: 'mode_online',
      desc: '',
      args: [],
    );
  }

  /// `Free Mode`
  String get mode_free {
    return Intl.message(
      'Free Mode',
      name: 'mode_free',
      desc: '',
      args: [],
    );
  }

  /// `Clear All`
  String get clear_all {
    return Intl.message(
      'Clear All',
      name: 'clear_all',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get save {
    return Intl.message(
      'Apply',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Trusteeship to Robots`
  String get trusteeship_to_robots {
    return Intl.message(
      'Trusteeship to Robots',
      name: 'trusteeship_to_robots',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Trusteeship`
  String get cancel_robots {
    return Intl.message(
      'Cancel Trusteeship',
      name: 'cancel_robots',
      desc: '',
      args: [],
    );
  }

  /// `Thinking...`
  String get thinking {
    return Intl.message(
      'Thinking...',
      name: 'thinking',
      desc: '',
      args: [],
    );
  }

  /// `Current`
  String get current_info {
    return Intl.message(
      'Current',
      name: 'current_info',
      desc: '',
      args: [],
    );
  }

  /// `Manual`
  String get manual {
    return Intl.message(
      'Manual',
      name: 'manual',
      desc: '',
      args: [],
    );
  }

  /// `Event: `
  String get the_event {
    return Intl.message(
      'Event: ',
      name: 'the_event',
      desc: '',
      args: [],
    );
  }

  /// `Site: `
  String get the_site {
    return Intl.message(
      'Site: ',
      name: 'the_site',
      desc: '',
      args: [],
    );
  }

  /// `Date: `
  String get the_date {
    return Intl.message(
      'Date: ',
      name: 'the_date',
      desc: '',
      args: [],
    );
  }

  /// `Round: `
  String get the_round {
    return Intl.message(
      'Round: ',
      name: 'the_round',
      desc: '',
      args: [],
    );
  }

  /// `Red: `
  String get the_red {
    return Intl.message(
      'Red: ',
      name: 'the_red',
      desc: '',
      args: [],
    );
  }

  /// `Black: `
  String get the_black {
    return Intl.message(
      'Black: ',
      name: 'the_black',
      desc: '',
      args: [],
    );
  }

  /// `==Start==`
  String get step_start {
    return Intl.message(
      '==Start==',
      name: 'step_start',
      desc: '',
      args: [],
    );
  }

  /// `Exit Now ?`
  String get exit_now {
    return Intl.message(
      'Exit Now ?',
      name: 'exit_now',
      desc: '',
      args: [],
    );
  }

  /// `Wait a moment`
  String get dont_exit {
    return Intl.message(
      'Wait a moment',
      name: 'dont_exit',
      desc: '',
      args: [],
    );
  }

  /// `Yes exit`
  String get yes_exit {
    return Intl.message(
      'Yes exit',
      name: 'yes_exit',
      desc: '',
      args: [],
    );
  }

  /// `Click again to Exit`
  String get click_again_to_exit {
    return Intl.message(
      'Click again to Exit',
      name: 'click_again_to_exit',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get apply {
    return Intl.message(
      'Apply',
      name: 'apply',
      desc: '',
      args: [],
    );
  }

  /// `Chess Code`
  String get situation_code {
    return Intl.message(
      'Chess Code',
      name: 'situation_code',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Chess Code`
  String get invalid_code {
    return Intl.message(
      'Invalid Chess Code',
      name: 'invalid_code',
      desc: '',
      args: [],
    );
  }

  /// `Copy Success`
  String get copy_success {
    return Intl.message(
      'Copy Success',
      name: 'copy_success',
      desc: '',
      args: [],
    );
  }

  /// `Save Success`
  String get save_success {
    return Intl.message(
      'Save Success',
      name: 'save_success',
      desc: '',
      args: [],
    );
  }

  /// `Select a Directory to Save`
  String get select_directory_save {
    return Intl.message(
      'Select a Directory to Save',
      name: 'select_directory_save',
      desc: '',
      args: [],
    );
  }

  /// `Filename to Save`
  String get save_filename {
    return Intl.message(
      'Filename to Save',
      name: 'save_filename',
      desc: '',
      args: [],
    );
  }

  /// `Select .PGN file`
  String get select_pgn_file {
    return Intl.message(
      'Select .PGN file',
      name: 'select_pgn_file',
      desc: '',
      args: [],
    );
  }

  /// `Recommend Move`
  String get recommend_move {
    return Intl.message(
      'Recommend Move',
      name: 'recommend_move',
      desc: '',
      args: [],
    );
  }

  /// `Remark`
  String get remark {
    return Intl.message(
      'Remark',
      name: 'remark',
      desc: '',
      args: [],
    );
  }

  /// `No remark`
  String get no_remark {
    return Intl.message(
      'No remark',
      name: 'no_remark',
      desc: '',
      args: [],
    );
  }

  /// `Check`
  String get check {
    return Intl.message(
      'Check',
      name: 'check',
      desc: '',
      args: [],
    );
  }

  /// `Checkmate`
  String get checkmate {
    return Intl.message(
      'Checkmate',
      name: 'checkmate',
      desc: '',
      args: [],
    );
  }

  /// `The same move 3 round to Lose`
  String get long_recheck_loose {
    return Intl.message(
      'The same move 3 round to Lose',
      name: 'long_recheck_loose',
      desc: '',
      args: [],
    );
  }

  /// `60 round with no eat to Draw`
  String get no_eat_to_draw {
    return Intl.message(
      '60 round with no eat to Draw',
      name: 'no_eat_to_draw',
      desc: '',
      args: [],
    );
  }

  /// `Checkmate`
  String get trapped {
    return Intl.message(
      'Checkmate',
      name: 'trapped',
      desc: '',
      args: [],
    );
  }

  /// `Loose`
  String get red_loose {
    return Intl.message(
      'Loose',
      name: 'red_loose',
      desc: '',
      args: [],
    );
  }

  /// `Win`
  String get red_win {
    return Intl.message(
      'Win',
      name: 'red_win',
      desc: '',
      args: [],
    );
  }

  /// `Draw`
  String get red_draw {
    return Intl.message(
      'Draw',
      name: 'red_draw',
      desc: '',
      args: [],
    );
  }

  /// `Asked for a draw`
  String get request_draw {
    return Intl.message(
      'Asked for a draw',
      name: 'request_draw',
      desc: '',
      args: [],
    );
  }

  /// `Agree to draw`
  String get agree_to_draw {
    return Intl.message(
      'Agree to draw',
      name: 'agree_to_draw',
      desc: '',
      args: [],
    );
  }

  /// `Asked for a Retract`
  String get request_retract {
    return Intl.message(
      'Asked for a Retract',
      name: 'request_retract',
      desc: '',
      args: [],
    );
  }

  /// `Agree to retract`
  String get agree_retract {
    return Intl.message(
      'Agree to retract',
      name: 'agree_retract',
      desc: '',
      args: [],
    );
  }

  /// `Disagree to retract`
  String get disagree_retract {
    return Intl.message(
      'Disagree to retract',
      name: 'disagree_retract',
      desc: '',
      args: [],
    );
  }

  /// `You can't send Check`
  String get cant_send_check {
    return Intl.message(
      'You can\'t send Check',
      name: 'cant_send_check',
      desc: '',
      args: [],
    );
  }

  /// `Please parry the Check`
  String get pls_parry_check {
    return Intl.message(
      'Please parry the Check',
      name: 'pls_parry_check',
      desc: '',
      args: [],
    );
  }

  /// `New Game`
  String get one_more_game {
    return Intl.message(
      'New Game',
      name: 'one_more_game',
      desc: '',
      args: [],
    );
  }

  /// `Let me see`
  String get let_me_see {
    return Intl.message(
      'Let me see',
      name: 'let_me_see',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get setting_title {
    return Intl.message(
      'Settings',
      name: 'setting_title',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}