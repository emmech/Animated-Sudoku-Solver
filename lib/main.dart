import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'fastbacktrack.dart';
import 'step_solve_1.dart';
import 'step_solve_2.dart';
import 'backtrack.dart';
import 'sudoku_widgets.dart';
import 'sudoku_globals.dart';
import 'dancinglinks.dart';
import 'dart:async';
import 'dart:collection';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sudoku Solver',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Sudoku Solver'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _errorMsg = "";

  tapFunc(row, col) {
    _errorMsg = "";
    setState(() {
      int val = 0;
      if (solved[row][col] != '') val = int.parse(solved[row][col]);
      val += 1;
      if (val > 9)
        solved[row][col] = '';
      else
        solved[row][col] = val.toString();
    });
  }

  clearGrid(g) {
    for (int i = 0; i <= 8; i++) for (int j = 0; j <= 8; j++) g[i][j] = '';
  }

  clearBTS() {
    for (int i = 0; i <= 8; i++) for (int j = 0; j <= 8; j++) bts[i][j] = 0;
  }

  clearFunc() {
    row = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    col = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    box = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    clearBTS();
    _errorMsg = '';
    starting = true;
    setState(() {
      clearGrid(solved);
      clearGrid(choices);
      clearGrid(orig);
    });
  }

  void copySudoku(f, t) {
    for (int i = 0; i < 9; i++) for (int j = 0; j < 9; j++) t[i][j] = f[i][j];
  }

  void copyToBTS() {
    for (int i = 0; i < 9; i++)
      for (int j = 0; j < 9; j++)
        if (solved[i][j] == "")
          bts[i][j] = 0;
        else
          bts[i][j] = int.parse(solved[i][j]);
  }

  void copyFromBTS() {
    for (int i = 0; i < 9; i++)
      for (int j = 0; j < 9; j++)
        if (bts[i][j] == 0)
          solved[i][j] = "";
        else
          solved[i][j] = bts[i][j].toString();
  }

  void saveFunc() {
    copySudoku(solved, saved);
  }

  void restoreFunc() {
    clearFunc();
    setState(() {
      copySudoku(saved, solved);
    });
  }

  solve() async {
    copySudoku(solved, orig);
    _errorMsg = '';

    setState(() {
      _errorMsg = checkSudoku();
    });
    if (_errorMsg == '') {
      if (animate) {
        await stepSolve1();
        await stepSolve2();
        await forceSolveFunc();
      } else {
        await forceSolveFunc2();
      }
    }
  }

  stepSolve1() async {
    bool stepSolving = true;
    while (stepSolving == true) {
      setState(() {
        _errorMsg = checkSudoku();
        if (_errorMsg != '') {
          _errorMsg = 'No Solutions';
          stepSolving = false;
          return;
        }
        stepSolving = solveForSingles();
      });
      if (animate) await new Future.delayed(const Duration(milliseconds: 200));
    }
  }

  stepSolve2() async {
    bool stepSolving = true;
    while (stepSolving == true) {
      setState(() {
        _errorMsg = checkSudoku();
        if (_errorMsg != '') {
          _errorMsg = 'No Solutions';
          stepSolving = false;
          return;
        }
        stepSolving = solveForNakedPairs();
      });
      if (animate) await new Future.delayed(const Duration(milliseconds: 200));
    }
  }

  forceSolveFunc() async {
    currentVal = 0;
    rowcol = new RowCol();
    rq = new Queue();
    cq = new Queue();
    vq = new Queue();
    iterations = 0;
    bt = 0;
    bool prev = animate;
    while (_errorMsg == "") {
      // if animate is turned off, revert to fastbacktrack or dlx
      if (prev != animate) {
        prev = animate;
        copySudoku(orig, solved);
        clearGrid(choices);
        copyToBTS();
        _errorMsg = dancingLinks();
        copyFromBTS();
        return;
      }
      setState(() {
        _errorMsg = checkSudoku();
        if (_errorMsg != '') {
          return;
        }
        _errorMsg = backtrack();
        if ((_errorMsg != 'Solved' && _errorMsg != '') || !animate) {
          copySudoku(orig, solved);
          clearGrid(choices);
          copyToBTS();
          _errorMsg = dancingLinks();
          copyFromBTS();
          return;
        }
      });
      if (animate) await new Future.delayed(const Duration(microseconds: 1));
    }
  }

  forceSolveFunc2() async {
    copyToBTS();
    setState(() {
      _errorMsg = checkSudoku();
      if (_errorMsg != '') {
        return;
      }
//      _errorMsg = fastBacktrack();
      _errorMsg = dancingLinks();
      copyFromBTS();
    });
  }

  checkIfSolved() async {
    setState(() {
      if (IsSolved())
        _errorMsg = "Solved";
      else
        _errorMsg = "Could not solve, try without animation";
    });
    if (animate) await new Future.delayed(const Duration(microseconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData _mq = MediaQuery.of(context);
    double hs = _mq.size.width / 100;
    double vs = _mq.size.height / 100;
    double ah = _mq.size.height - _mq.padding.top;
    double _smallSqSize = _mq.size.width / 9;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          title: Text(widget.title),
        ),
      ),
      body: CustomPaint(
        painter: MyPainter(),
        child: Column(
          children: <Widget>[
            SudokuRow(_smallSqSize, 0, tapFunc),
            SudokuRow(_smallSqSize, 1, tapFunc),
            SudokuRow(_smallSqSize, 2, tapFunc),
            SudokuRow(_smallSqSize, 3, tapFunc),
            SudokuRow(_smallSqSize, 4, tapFunc),
            SudokuRow(_smallSqSize, 5, tapFunc),
            SudokuRow(_smallSqSize, 6, tapFunc),
            SudokuRow(_smallSqSize, 7, tapFunc),
            SudokuRow(_smallSqSize, 8, tapFunc),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
//                    height: 40,
//                    width: hs * 20,
                    child: OpButton("Solve", solve),
                  ),
                  Container(
                    width: hs * 20,
                  ),
                  Container(
//                    height: 40,
//                    width: hs * 20,
                    child: OpButton("Clear", clearFunc),
                  ),
                  Container(height: vs * 9),
                ]),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
//                    height: 40,
//                    width: hs * 20,
                    child: OpButton("Save", saveFunc),
                  ),
                  Container(
//                    height: 40,
//                    width: hs * 20,
                    child: OpButton("Restore", restoreFunc),
                  ),
                  Container(
                    height: 20,
                    width: hs * 20,
                    child: Text(
                      'Animate',
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Container(
//                    width: hs * 15,
                    child: Switch(
                      value: animate,
                      onChanged: (value) {
                        setState(() {
                          animate = value;
                        });
                      },
                      activeTrackColor: Colors.lightGreenAccent,
                      activeColor: Colors.green,
                    ),
                  ),
                  Container(height: vs * 9),
                ]),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: 40,
                    width: hs * 80,
                    child: Text(_errorMsg),
                  ),
                  Container(height: vs * 9),
                ]),
          ],
        ),
      ),
    );
  }
}
