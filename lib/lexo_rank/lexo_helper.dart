void arrayCopy<T>(
  List<T> sourceArray,
  int sourceIndex,
  List<T> destinationArray,
  int destinationIndex,
  int length,
) {
  int destination = destinationIndex;
  final int finalLength = sourceIndex + length;
  for (int i = sourceIndex; i < finalLength; i++) {
    destinationArray[destination] = sourceArray[i];
    ++destination;
  }
}
