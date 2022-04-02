class Allocator {}

class Opaque {}

class Pointer<T> {}

Pointer<T> malloc<T>(int byteCount, {int? alignment}) {
  return Pointer<T>();
}

class Utf16 extends Opaque {}

extension StringUtf16Pointer on String {
  Pointer<Utf16> toNativeUtf16({Allocator? allocator}) {
    return Pointer<Utf16>();
  }
}
