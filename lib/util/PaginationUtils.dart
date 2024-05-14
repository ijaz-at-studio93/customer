import 'dart:math';

class PaginationUtils {
  static int pageNoFromOffset(int offset, int itemCount) {
    return offset > 0 && offset <= itemCount
        ? 2
        : (offset / itemCount).ceil() + 1;
  }

  static int sizeFromOffset(int offset, int itemCount) {
    if (offset > 0) return min(offset, itemCount);
    return itemCount;
  }
}
