import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'sudoku_globals.dart';
import 'package:google_fonts/google_fonts.dart';

class SudokuRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return (Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      SmallSquare(_sz, _row, 0, _func),
      SmallSquare(_sz, _row, 1, _func),
      SmallSquare(_sz, _row, 2, _func),
      SmallSquare(_sz, _row, 3, _func),
      SmallSquare(_sz, _row, 4, _func),
      SmallSquare(_sz, _row, 5, _func),
      SmallSquare(_sz, _row, 6, _func),
      SmallSquare(_sz, _row, 7, _func),
      SmallSquare(_sz, _row, 8, _func),
    ]));
  }

  Function _func = () {};
  double _sz = 0;
  int _row = 0;

  SudokuRow(size, row, func) {
    _sz = size;
    _func = func;
    _row = row;
  }
}

class SmallSquare extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (_choices != '') {
      return Container(
        height: sz,
        width: sz,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: Colors.blueAccent,
            width: 0,
          ),
        ),
        child: Text(
          _formattedChoices,
          maxLines: 3,
          style: GoogleFonts.spaceMono(
              fontSize: _fontSize - 2,
              color: Colors.lightGreen,
              height: 1,
              letterSpacing: 4),
        ),
      );
    } else {
      return Container(
        height: sz,
        width: sz,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: Colors.blueAccent,
            width: 0,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () {
              _func(_row, _col);
            },
            child: Text(
              _txt,
              style: new TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 100,
                color: _color,
              ),
            ),
          ),
        ),
      );
    }
  }

  double sz = 0;
  String _choices = '';
  int _row = 0;
  int _col = 0;
  String _txt = "";
  Function _func = () {};
  Color _color = Colors.black38;
  double _fontSize = 10;
  String _formattedChoices = "";

  SmallSquare(size, row, col, func) {
    sz = size;
    _txt = solved[row][col];
    _choices = choices[row][col];
    _row = row;
    _col = col;
    _func = func;
    if (orig[row][col] == '')
      _color = Colors.blueAccent;
    else
      _color = Colors.black38;

    double _squareArea = sz * sz;
    double _letterArea = _squareArea / 9;
    double _pixelOfLetter = math.sqrt(_letterArea);
    _fontSize = _pixelOfLetter - (_pixelOfLetter) / 100;

    List<String> _row1 = ['1', '2', '3'];
    List<String> _row2 = ['1', '2', '3'];
    List<String> _row3 = ['1', '2', '3'];

    if (_choices.contains('1'))
      _row1[0] = '1';
    else
      _row1[0] = '.';
    if (_choices.contains('2'))
      _row1[1] = '2';
    else
      _row1[1] = '.';
    if (_choices.contains('3'))
      _row1[2] = '3';
    else
      _row1[2] = '.';

    if (_choices.contains('4'))
      _row2[0] = '4';
    else
      _row2[0] = '.';
    if (_choices.contains('5'))
      _row2[1] = '5';
    else
      _row2[1] = '.';
    if (_choices.contains('6'))
      _row2[2] = '6';
    else
      _row2[2] = '.';

    if (_choices.contains('7'))
      _row3[0] = '7';
    else
      _row3[0] = '.';
    if (_choices.contains('8'))
      _row3[1] = '8';
    else
      _row3[1] = '.';
    if (_choices.contains('9'))
      _row3[2] = '9';
    else
      _row3[2] = '.';

    _formattedChoices = _row1[0] +
        _row1[1] +
        _row1[2] +
        _row2[0] +
        _row2[1] +
        _row2[2] +
        _row3[0] +
        _row3[1] +
        _row3[2];
  }
}

class OpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _func();
      },
      child: Text(
        _txt,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
      ),
      style: ElevatedButton.styleFrom(
        primary: _color,
      ),
//      backgroundColor: _color,
//      shape: RoundedRectangleBorder(
//          borderRadius: BorderRadius.all(Radius.circular(15.0))),
    );
  }

  Function _func = () {};
  String _txt = "";
  Color _color = Colors.white10;
  OpButton(val, func) {
    _txt = val;
    _func = func;
    if (val == "Clear")
      _color = Colors.deepOrangeAccent;
    else if (val == 'Step')
      _color = Colors.lightGreen;
    else
      _color = Colors.blue;
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.black;
    paint.strokeWidth = 2;

    double line2 = size.width / 3;
    double line3 = line2 + line2;
    double line4 = line3 + line2;

    // vertical line 1
    canvas.drawLine(
      Offset(0, 0),
      Offset(0, size.width),
      paint,
    );

    // vertical line 2
    canvas.drawLine(
      Offset(line2, 0),
      Offset(line2, size.width),
      paint,
    );

    // vertical line 3
    canvas.drawLine(
      Offset(line3, 0),
      Offset(line3, size.width),
      paint,
    );

    // vertical line 4
    canvas.drawLine(
      Offset(line4, 0),
      Offset(line4, size.width),
      paint,
    );

    // horizontal line 1
    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, 0),
      paint,
    );

    // horizontal line 2
    canvas.drawLine(
      Offset(0, line2),
      Offset(size.width, line2),
      paint,
    );

    // horizontal line 3
    canvas.drawLine(
      Offset(0, line3),
      Offset(size.width, line3),
      paint,
    );

    // horizontal line 4
    canvas.drawLine(
      Offset(0, line4),
      Offset(size.width, line4),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
