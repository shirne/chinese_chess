// ignore_for_file: non_constant_identifier_names

import 'ffi.dart';

int PlaySound(Pointer<Utf16> pszSound, int hmod, int fdwSound) => 0;

const NULL = 0;

/// play synchronously (default)
const SND_SYNC = 0x0000;

/// play asynchronously
const SND_ASYNC = 0x0001;

/// silence (!default) if sound not found
const SND_NODEFAULT = 0x0002;

/// pszSound points to a memory file
const SND_MEMORY = 0x0004;

/// loop the sound until next sndPlaySound
const SND_LOOP = 0x0008;

/// don't stop any currently playing sound
const SND_NOSTOP = 0x0010;

/// don't wait if the driver is busy
const SND_NOWAIT = 0x00002000;

/// name is a registry alias
const SND_ALIAS = 0x00010000;

/// alias is a predefined ID
const SND_ALIAS_ID = 0x00110000;

/// name is file name
const SND_FILENAME = 0x00020000;

/// name is resource name or atom
const SND_RESOURCE = 0x00040004;

/// purge non-static events for task
const SND_PURGE = 0x0040;

/// look for application specific association
const SND_APPLICATION = 0x0080;

/// Generate a SoundSentry event with this sound
const SND_SENTRY = 0x00080000;

/// Treat this as a "ring" from a communications app - don't duck me
const SND_RING = 0x00100000;

/// Treat this as a system sound
const SND_SYSTEM = 0x00200000;
