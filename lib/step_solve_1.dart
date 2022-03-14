import 'sudoku_globals.dart';

bool solveForSingles() {
  if (starting) {
    starting = false;
    clearChoices();
    fillChoices();
  }
  return checkSingles();
}

void clearChoices() {
  for (int row = 0; row <= 8; row++)
    for (int col = 0; col <= 8; col++) choices[row][col] = '';
}

void fillChoices() {
  for (int row = 0; row <= 8; row++)
    for (int col = 0; col <= 8; col++) {
      if (solved[row][col].isEmpty) {
        choices[row][col] = getChoices(row, col);
      }
    }
}

bool checkSingles() {
  bool found = false;
  for (int row = 0; row <= 8; row++)
    for (int col = 0; col <= 8; col++) {
      if (choices[row][col].length == 1) {
        solved[row][col] = choices[row][col];
        removeFromChoices(solved[row][col], row, col);
        found = true;
      }
    }
  return found;
}

String getChoices(row, col) {
  String options = '';
  for (int val = 1; val <= 9; val++) {
    if (checkRow(row, val.toString()) &&
        checkCol(col, val.toString()) &&
        checkSquare(row, col, val.toString())) options += val.toString();
  }
  return options;
}

bool checkRow(row, val) {
  for (int col = 0; col <= 8; col++) {
    if (solved[row][col] == val) {
      return false;
    }
  }
  return true;
}

bool checkCol(col, val) {
  for (int row = 0; row <= 8; row++) {
    if (solved[row][col] == val) {
      return false;
    }
  }
  return true;
}

bool checkSquare(row, col, val) {
  int r = row - row % 3;
  int c = col - col % 3;

  for (int i = r; i < r + 3; i++)
    for (int j = c; j < c + 3; j++) {
      if (solved[i][j] == val) return false;
    }
  return true;
}

removeFromChoices(val, row, col) {
  removeFromRow(val, row);
  removeFromCol(val, col);
  removeFromBlock(val, row, col);
}

removeFromRow(val, row) {
  for (int i = 0; i <= 8; i++) {
    String newChoices = "";
    for (int j = 0; j < choices[row][i].length; j++) {
      if (choices[row][i][j] == val)
        continue;
      else
        newChoices += choices[row][i][j];
    }
    choices[row][i] = newChoices;
  }
}

removeFromCol(val, col) {
  for (int i = 0; i <= 8; i++) {
    String newChoices = "";
    for (int j = 0; j < choices[i][col].length; j++) {
      if (choices[i][col][j] == val)
        continue;
      else
        newChoices += choices[i][col][j];
    }
    choices[i][col] = newChoices;
  }
}

removeFromBlock(val, row, col) {
  int r = row - row % 3;
  int c = col - col % 3;

  for (int i = r; i < r + 3; i++) {
    for (int j = c; j < c + 3; j++) {
      String newChoices = "";
      for (int k = 0; k < choices[i][j].length; k++) {
        if (choices[i][j][k] == val)
          continue;
        else
          newChoices += choices[i][j][k];
      }
      choices[i][j] = newChoices;
    }
  }
}
