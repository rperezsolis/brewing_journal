/// How many instruction rows the share card can show before it summarizes.
const kShareCardInstructionRows = 4;

/// The first rows to draw, and how many steps were left off.
///
/// Zero instructions give `([], 0)`. One to four give every row and `0`.
/// More than four give the first three and `length - 3`.
({List<String> rows, int moreCount}) visibleInstructions(
  List<String> instructions,
) {
  if (instructions.length <= kShareCardInstructionRows) {
    return (rows: instructions.toList(), moreCount: 0);
  }
  return (
    rows: instructions.sublist(0, 3),
    moreCount: instructions.length - 3,
  );
}
