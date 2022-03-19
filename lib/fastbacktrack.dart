import "sudoku_globals.dart";

int N = 9;

var row = [0, 0, 0, 0, 0, 0, 0, 0, 0];
var col = [0, 0, 0, 0, 0, 0, 0, 0, 0];
var box = [0, 0, 0, 0, 0, 0, 0, 0, 0];

bool seted = false;

int iter = 0;

int getBox(int i, int j) {
  return i ~/ 3 * 3 + j ~/ 3;
}

bool isSafe(int i, int j, int number) {
  bool rv = false;
  if ((((row[i] >> number) & 1) == 0) &&
      (((col[j] >> number) & 1) == 0) &&
      (((box[getBox(i, j)] >> number) & 1) == 0))
    return true;
  else
    return false;
}

void setInitialValues() {
  for (int i = 0; i < N; i++)
    for (int j = 0; j < N; j++) {
      row[i] |= 1 << bts[i][j];
      col[j] |= 1 << bts[i][j];
      box[getBox(i, j)] |= 1 << bts[i][j];
    }
}

bool solveSudoku(int i, int j) {
  iter++;

  if (!seted) {
    seted = true;
    setInitialValues();
  }

  if (i == N - 1 && j == N) return true;

  if (j == N) {
    j = 0;
    i++;
  }

  if (bts[i][j] > 0) return solveSudoku(i, j + 1);

  for (int nr = 1; nr <= N; nr++) {
    if (isSafe(i, j, nr)) {
      bts[i][j] = nr;
      row[i] |= 1 << nr;
      col[j] |= 1 << nr;
      box[getBox(i, j)] |= 1 << nr;

      if (solveSudoku(i, j + 1)) return true;

      row[i] &= ~(1 << nr);
      col[j] &= ~(1 << nr);
      box[getBox(i, j)] &= ~(1 << nr);
    }

    bts[i][j] = 0;
  }

  return false;
}

String fastBacktrack() {
  iter = 0;
  seted = false;
  var startTime = DateTime.now().millisecondsSinceEpoch;
  bool solved = solveSudoku(0, 0);
  var timeUsed = DateTime.now().millisecondsSinceEpoch - startTime;
//  print("time: $timeUsed iterations: $iter");
  if (solved)
    return ("Solved");
  else
    return ("No solutions");
}
