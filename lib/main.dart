import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'step_solve_1.dart';
import 'step_solve_2.dart';
import 'backtrack.dart';
import 'sudoku_widgets.dart';
import 'sudoku_globals.dart';
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

  clearFunc() {
    _errorMsg = '';
    solveStarted = false;
    starting = true;
    setState(() {
      for (int i = 0; i <= 8; i++)
        for (int j = 0; j <= 8; j++) {
          solved[i][j] = '';
          choices[i][j] = '';
          orig[i][j] = '';
        }
    });
  }

  void copySudoku(f, t) {
    for (int i = 0; i < 9; i++) for (int j = 0; j < 9; j++) t[i][j] = f[i][j];
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
    solveStarted = true;
    _errorMsg = '';

    setState(() {
      _errorMsg = checkSudoku();
    });
    if (_errorMsg == '') {
      await stepSolve1();
      await stepSolve2();
      await forceSolveFunc();
    }
    solveStarted = false;
  }

  stepSolve1() async {
    bool stepSolveDone = false;
    while (stepSolveDone == false) {
      setState(() {
        _errorMsg = checkSudoku();
        if (_errorMsg != '') {
          _errorMsg = 'No Solutions';
          stepSolveDone = true;
          return;
        }
        if (solveForSingles() == false) {
          stepSolveDone = true;
          return;
        }
      });
      if (animate) await new Future.delayed(const Duration(milliseconds: 200));
    }
  }

  stepSolve2() async {
    bool stepSolveDone = false;
    while (stepSolveDone == false) {
      setState(() {
        _errorMsg = checkSudoku();
        if (_errorMsg != '') {
          _errorMsg = 'No Solutions';
          stepSolveDone = true;
          return;
        }
        if (solveForNakedPairs() == false) {
          stepSolveDone = true;
          return;
        }
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
    while (_errorMsg == "") {
      setState(() {
        _errorMsg = checkSudoku();
        if (_errorMsg != '') {
          return;
        }
        _errorMsg = SolveSudoku();
      });
      if (animate) await new Future.delayed(const Duration(microseconds: 1));
    }
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
