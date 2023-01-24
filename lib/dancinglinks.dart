import "sudoku_globals.dart";

int searchCount = 0;
int coverCount = 0;
int uncoverCount = 0;

void dlxCover(Node? c) {
  coverCount++;
  c?.right?.left = c.left;
  c?.left?.right = c.right;
  Node? i = c?.down;
  while (i != c) {
    Node? j = i?.right;
    while (j != i) {
      j?.down?.up = j.up;
      j?.up?.down = j.down;
      j?.column?.size--;
      j = j?.right;
    }
    i = i?.down;
  }
}

void dlxUncover(Node? c) {
  uncoverCount++;
  Node? i = c?.up;
  while (i != c) {
    Node? j = i?.left;
    while (j != i) {
      j?.column?.size++;
      j?.down?.up = j;
      j?.up?.down = j;
      j = j?.left;
    }
    i = i?.up;
  }
  c?.right?.left = c;
  c?.left?.right = c;
}

List<List<int>>? dlxSearch(Node head, List<int> solution, int k,
    List<List<int>> solutions, int maxsolutions) {
  searchCount++;
  if (head.right == head) {
    solutions.add(solution.sublist(0));
    if (solutions.length >= maxsolutions) {
      return solutions;
    }
    return null;
  }
  Node? c;
  int s = 99999;
  Node? j = head.right;
  int lc = 0;
  while (j != head) {
    lc++;
    if (j?.size == 0) {
      return null;
    }
    if (j != null) {
      if (j.size < s) {
        s = j.size;
        c = j;
      }
    }
    j = j?.right;
  }
  dlxCover(c);
  Node? r = c?.down;
  while (r != c) {
    solution.add(r!.row);
    Node? j = r.right;
    while (j != r) {
      dlxCover(j?.column);
      j = j?.right;
    }
    var s = dlxSearch(head, solution, k + 1, solutions, maxsolutions);
    if (s != null) {
      return s;
    }
    j = r.left;
    while (j != r) {
      dlxUncover(j?.column);
      j = j?.left;
    }
    r = r.down;
  }
  dlxUncover(c);
  return null;
}

class Node {
  int index = 0;
  int size = 0;
  int row = 0;
  Node? up;
  Node? down;
  Node? left;
  Node? right;
  Node? column;
}

List<Node> nodeList(int length) {
  return List.generate(length, (index) => new Node());
}

List<List<int>> dlxSolve(List<List<int>> matrix, int skip, int maxsolutions) {
  List<Node> columns = nodeList(matrix[0].length);
  for (int i = 0; i < columns.length; i++) {
    columns[i].index = i;
    columns[i].up = columns[i];
    columns[i].down = columns[i];
    if (i >= skip) {
      if (i - 1 >= skip) {
        columns[i].left = columns[i - 1];
      }
      if (i + 1 < columns.length) {
        columns[i].right = columns[i + 1];
      }
    } else {
      columns[i].left = columns[i];
      columns[i].right = columns[i];
    }
    columns[i].size = 0;
  }
  for (int i = 0; i < matrix.length; i++) {
    Node? last = null;
    for (int j = 0; j < matrix[i].length; j++) {
      if (matrix[i][j] != 0) {
        Node node = Node();
        node.row = i;
        node.column = columns[j];
        node.up = columns[j].up;
        node.down = columns[j];
        if (last != null) {
          node.left = last;
          node.right = last.right;
          last.right?.left = node;
          last.right = node;
        } else {
          node.left = node;
          node.right = node;
        }
        columns[j].up?.down = node;
        columns[j].up = node;
        columns[j].size++;
        last = node;
      }
    }
  }
  Node head = Node();
  head.right = columns[skip];
  head.left = columns[columns.length - 1];
  columns[skip].left = head;
  columns[columns.length - 1].right = head;
  List<List<int>> solutions = [];
  dlxSearch(head, [], 0, solutions, maxsolutions);
  return solutions;
}

int solveSudoku(List<List<int>> grid) {
  List<List<int>> mat = [];
  List<Map<String, dynamic>> rinfo = [];
  for (var i = 0; i < 9; i++) {
    for (var j = 0; j < 9; j++) {
      var g = grid[i][j] - 1;
      if (g >= 0) {
        List<int> row = List.filled(324, 0);
        row[i * 9 + j] = 1;
        row[9 * 9 + i * 9 + g] = 1;
        row[9 * 9 * 2 + j * 9 + g] = 1;
        row[9 * 9 * 3 + ((i / 3).floor() * 3 + (j / 3).floor()) * 9 + g] = 1;
        mat.add(row);
        rinfo.add({'row': i, 'col': j, 'n': g + 1});
      } else {
        for (var n = 0; n < 9; n++) {
          List<int> row = List.filled(324, 0);
          row[i * 9 + j] = 1;
          row[9 * 9 + i * 9 + n] = 1;
          row[9 * 9 * 2 + j * 9 + n] = 1;
          row[9 * 9 * 3 + ((i / 3).floor() * 3 + (j / 3).floor()) * 9 + n] = 1;
          mat.add(row);
          rinfo.add({'row': i, 'col': j, 'n': n + 1});
        }
      }
    }
  }

  var solutions = dlxSolve(mat, 0, 2);
  if (solutions.length > 0) {
    var r = solutions[0];
    for (var i = 0; i < r.length; i++) {
      grid[rinfo[r[i]]['row']][rinfo[r[i]]['col']] = rinfo[r[i]]['n'];
    }
    return solutions.length;
  }
  return 0;
}

String dancingLinks() {
  var r = solveSudoku(bts);
  if (r > 1) {
    return "Solved, more than one solutions exist";
  } else if (r > 0) {
    return "Solved";
  } else
    return "No solutions";
}
