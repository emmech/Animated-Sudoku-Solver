import 'sudoku_globals.dart';
import 'step_solve_1.dart';

const int N = 9;
const String UNASSIGNED = '';
const int MAX_ITERATIONS = 3000000;

bool DupInRow(row, colToAvoid, val) {
  for (int col = 0; col < N; col++) {
    if (col == colToAvoid) continue;
    if (solved[row][col] == val.toString()) return true;
  }
  return false;
}

bool DupInCol(rowToAvoid, col, val) {
  for (int row = 0; row < N; row++) {
    if (row == rowToAvoid) continue;
    if (solved[row][col] == val.toString()) return true;
  }
  return false;
}

bool DupInBox(int boxStartRow, int boxStartCol, rowToAvoid, colToAvoid, val) {
  for (int row = 0; row < 3; row++)
    for (int col = 0; col < 3; col++) {
      int bsr = row + boxStartRow;
      int bsc = col + boxStartCol;
      if (bsr == rowToAvoid && bsc == colToAvoid) continue;
      if (solved[bsr][bsc] == val.toString()) return true;
    }
  return false;
}

bool UsedInRow(row, val) {
  for (int col = 0; col < N; col++)
    if (solved[row][col] == val.toString()) return true;
  return false;
}

bool UsedInCol(col, val) {
  for (int row = 0; row < N; row++)
    if (solved[row][col] == val.toString()) return true;
  return false;
}

bool UsedInBox(int boxStartRow, int boxStartCol, val) {
  for (int row = 0; row < 3; row++)
    for (int col = 0; col < 3; col++) {
      int bsr = row + boxStartRow;
      int bsc = col + boxStartCol;
      if (solved[bsr][bsc] == val.toString()) return true;
    }
  return false;
}

bool isSafe(row, col, val) {
  int bsr = row - row % 3;
  int bsc = col - col % 3;
  return !UsedInRow(row, val) &&
      !UsedInCol(col, val) &&
      !UsedInBox(bsr, bsc, val) &&
      solved[row][col] == UNASSIGNED;
}

bool isValid(row, col) {
  int bsr = row - row % 3;
  int bsc = col - col % 3;
  String val = solved[row][col];
  return !DupInRow(row, col, val) &&
      !DupInCol(row, col, val) &&
      !DupInBox(bsr, bsc, row, col, val);
}

bool FindUnassignedLocation(rowcol) {
  for (rowcol.row = 0; rowcol.row < N; rowcol.row++)
    for (rowcol.col = 0; rowcol.col < N; rowcol.col++)
      if (solved[rowcol.row][rowcol.col] == UNASSIGNED) {
        return true;
      }
  return false;
}

String checkSudoku() {
  for (int r = 0; r <= 8; r++)
    for (int c = 0; c <= 8; c++)
      if (solved[r][c] != UNASSIGNED && !isValid(r, c)) {
        return 'cell ${r + 1},${c + 1} has duplicate number ' +
            solved[r][c].toString();
      }
  return '';
}

String SolveSudoku() {
  while (true) {
    iterations++;
    if (!FindUnassignedLocation(rowcol)) {
      return 'Solved';
//      if (iterations == 1)
//        return 'Solved';
//      else
//        return 'Solved in $iterations iterations and $bt backtracks'; // success!
    }
    if (iterations >= MAX_ITERATIONS)
      return 'Could not solve in $iterations iterations';

    bool added = false;
    for (int val = currentVal + 1; val <= 9; val++) {
      if (choices[rowcol.row][rowcol.col].isNotEmpty &&
          !choices[rowcol.row][rowcol.col].contains(val.toString())) continue;
      if (isSafe(rowcol.row, rowcol.col, val)) {
        solved[rowcol.row][rowcol.col] = val.toString();
        orig[rowcol.row][rowcol.col] = choices[rowcol.row][rowcol.col];
        choices[rowcol.row][rowcol.col] = "";
        added = true;
        rq.addFirst(rowcol.row.toString());
        cq.addFirst(rowcol.col.toString());
        vq.addFirst(val.toString());
        break;
      }
    }
    if (added) {
      currentVal = 0;
      if (animate) return "";
      continue;
    } else if (rq.length == 0) {
      return "Could not solve sudoku! it: $iterations, bt: $bt";
    } else {
      rowcol.row = int.parse(rq.first);
      rowcol.col = int.parse(cq.first);
      solved[rowcol.row][rowcol.col] = UNASSIGNED;
      choices[rowcol.row][rowcol.col] = orig[rowcol.row][rowcol.col];
      currentVal = int.parse(vq.first);
      rq.removeFirst();
      cq.removeFirst();
      vq.removeFirst();
      bt++;
      if (animate) return "";
    }
  }
}
