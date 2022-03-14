import 'sudoku_globals.dart';
import 'step_solve_1.dart';

bool solveForNakedPairs() {
  checkNakedPairs();
  return checkSingles();
}

// find a square with only two choices
// and find if another such square exists
bool checkNakedPairs() {
  bool removedPair = false;
  for (int row = 0; row <= 8; row++) {
    for (int col = 0; col <= 8; col++) {
      if (choices[row][col].length == 2) {
        if (removePair(choices[row][col], row, col) == true) {
          removedPair = true;
        } else {
          removedPair = false;
        }
      }
    }
  }
  return removedPair;
}

// find if a matching pair exists in row or column or block
bool removePair(pair, row, col) {
  if (findMatchingPairInRow(pair, row, col) == true) return true;
  if (findMatchingPairInCol(pair, row, col) == true) return true;
//  if (findMatchingPairInBlock(pair, row, col) == true) return true;

  return false;
}

// find if one more matching pair exists in this row
bool findMatchingPairInRow(pair, row, col) {
  int numMatches = 0;
  for (int i = 0; i <= 8; i++) {
    if (i == col) continue;
    if (choices[row][i] == pair) numMatches++;
  }
  if (numMatches == 1) {
    removePairFromRow(pair, row);
    return true;
  } else {
    return false;
  }
}

// remove pair values from all other choices in this row
removePairFromRow(pair, row) {
  for (int col = 0; col <= 8; col++) {
    if (choices[row][col] == pair) continue;
    String newChoices = "";
    for (int i = 0;
        i < choices[row][col].length && choices[row][col].isNotEmpty;
        i++) {
      if (pair.contains(choices[row][col][i])) {
        continue;
      } else {
        newChoices += choices[row][col][i];
      }
    }
    if (newChoices.isNotEmpty && newChoices != choices[row][col]) {
      choices[row][col] = newChoices;
    }
  }
}

// find if one more matching pair exists in this col
bool findMatchingPairInCol(pair, row, col) {
  int numMatches = 0;
  for (int i = 0; i <= 8; i++) {
    if (i == row) continue;
    if (choices[i][col] == pair) numMatches++;
  }
  if (numMatches == 1) {
    removePairFromCol(pair, col);
    return true;
  } else {
    return false;
  }
}

// remove pair values from all other choices in this col
removePairFromCol(pair, col) {
  for (int row = 0; row <= 8; row++) {
    if (choices[row][col] == pair) continue;
    String newChoices = "";
    for (int i = 0;
        i < choices[row][col].length && choices[row][col].isNotEmpty;
        i++) {
      if (pair.contains(choices[row][col][i])) {
        continue;
      } else {
        newChoices += choices[row][col][i];
      }
    }
    if (newChoices.isNotEmpty && newChoices != choices[row][col]) {
      choices[row][col] = newChoices;
    }
  }
}
