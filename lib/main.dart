import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Calculator(),
      theme: ThemeData(
        fontFamily: 'Helvetica',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(20),
          ),
        ),
      ),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String text = '0';
  String history = '';
  double numOne = 0;
  double numTwo = 0;
  String result = '';
  String finalResult = '0';
  String opr = '';
  String preOpr = '';
  int equalsCount = 0;
  String? savedPassword;

  Widget calcButton(String btnText, Color btnColor, Color txtColor, {bool isIcon = false}) {
    return ElevatedButton(
      onPressed: () => calculation(btnText),
      style: ElevatedButton.styleFrom(
        backgroundColor: btnColor,
        foregroundColor: txtColor,
        shape: CircleBorder(),
        padding: EdgeInsets.all(20),
        minimumSize: Size(80, 80),
      ),
      child: Text(
        btnText,
        style: TextStyle(
          fontSize: isIcon ? 40 : 35,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(20),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      history,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        text,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 80,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        calcButton('AC', Colors.grey, Colors.black),
                        calcButton('+/-', Colors.grey, Colors.black),
                        calcButton('%', Colors.grey, Colors.black),
                        calcButton('÷', Colors.amber[700]!, Colors.white, isIcon: true),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        calcButton('7', Colors.grey[850]!, Colors.white),
                        calcButton('8', Colors.grey[850]!, Colors.white),
                        calcButton('9', Colors.grey[850]!, Colors.white),
                        calcButton('×', Colors.amber[700]!, Colors.white, isIcon: true),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        calcButton('4', Colors.grey[850]!, Colors.white),
                        calcButton('5', Colors.grey[850]!, Colors.white),
                        calcButton('6', Colors.grey[850]!, Colors.white),
                        calcButton('-', Colors.amber[700]!, Colors.white),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        calcButton('1', Colors.grey[850]!, Colors.white),
                        calcButton('2', Colors.grey[850]!, Colors.white),
                        calcButton('3', Colors.grey[850]!, Colors.white),
                        calcButton('+', Colors.amber[700]!, Colors.white),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => calculation('0'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[850],
                            foregroundColor: Colors.white,
                            shape: StadiumBorder(),
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                            minimumSize: Size(180, 80),
                          ),
                          child: Text('0', style: TextStyle(fontSize: 35, fontWeight: FontWeight.w500)),
                        ),
                        calcButton('.', Colors.grey[850]!, Colors.white),
                        calcButton('=', Colors.amber[700]!, Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void calculation(String btnText) {
    if (btnText == 'AC') {
      text = '0';
      numOne = 0;
      numTwo = 0;
      result = '';
      finalResult = '0';
      opr = '';
      preOpr = '';
      history = '';
      equalsCount = 0;
    } else if (['+', '-', '×', '÷'].contains(btnText) && opr == '=') {
      numOne = double.parse(finalResult);
      opr = btnText;
      preOpr = '';
      history = formatResult(finalResult) + ' ' + btnText;
      result = '';
      equalsCount = 0;
    } else if (['+', '-', '×', '÷', '='].contains(btnText)) {
      if (result.isNotEmpty) { // Pastikan result tidak kosong sebelum parsing
        if (numOne == 0) {
          numOne = double.parse(result);
        } else {
          numTwo = double.parse(result);
        }
      }

      if (opr == '+') finalResult = add();
      else if (opr == '-') finalResult = sub();
      else if (opr == '×') finalResult = mul();
      else if (opr == '÷') finalResult = div();

      if (btnText == '=') {
        equalsCount++;
        if (equalsCount == 3) {
          _handlePasswordFlow(context);
          equalsCount = 0;
          return;
        }
        history = '';
        if (finalResult.isNotEmpty) { // Pastikan finalResult tidak kosong
          numOne = double.parse(finalResult);
        }
        numTwo = 0;
        opr = '=';
        preOpr = '';
        result = '';
      } else {
        String formattedNumOne = formatResult(numOne.toString());
        history = formattedNumOne + (opr.isNotEmpty ? ' $opr ' : ' ') + btnText;
        preOpr = opr;
        opr = btnText;
        result = '';
        equalsCount = 0;
      }
    } else if (btnText == '%') {
      if (numOne != 0) { // Pastikan numOne ada sebelum menghitung persen
        result = (numOne / 100).toStringAsFixed(6);
        finalResult = formatResult(result);
      }
      equalsCount = 0;
    } else if (btnText == '.') {
      if (!result.contains('.')) result += '.';
      finalResult = result;
      equalsCount = 0;
    } else if (btnText == '+/-') {
      if (result.isNotEmpty) { // Pastikan result tidak kosong
        result = result.startsWith('-') ? result.substring(1) : '-$result';
        finalResult = result;
      }
      equalsCount = 0;
    } else {
      result = result == '0' ? btnText : result + btnText;
      finalResult = result;
      equalsCount = 0;
    }

    setState(() {
      text = finalResult;
    });
  }

  void _handlePasswordFlow(BuildContext context) {
    if (savedPassword == null) {
      _showCreatePasswordDialog(context);
    } else {
      _showVerifyPasswordDialog(context);
    }
  }

  void _showCreatePasswordDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(hintText: 'Enter your password'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (passwordController.text.isNotEmpty) {
                  setState(() {
                    savedPassword = passwordController.text;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password saved!')),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showVerifyPasswordDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(hintText: 'Enter your password'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (passwordController.text == savedPassword) {
                  Navigator.pop(context);
                  _launchURL();
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Incorrect password!')),
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _launchURL() async {
    const url = 'https://example.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  String add() {
    double res = numOne + numTwo;
    result = res.toStringAsFixed(6);
    numOne = res;
    return formatResult(result);
  }

  String sub() {
    double res = numOne - numTwo;
    result = res.toStringAsFixed(6);
    numOne = res;
    return formatResult(result);
  }

  String mul() {
    double res = numOne * numTwo;
    result = res.toStringAsFixed(6);
    numOne = res;
    return formatResult(result);
  }

  String div() {
    double res = numOne / numTwo;
    result = res.toStringAsFixed(6);
    numOne = res;
    return formatResult(result);
  }

  String formatResult(String result) {
    double value = double.parse(result);
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    if (result.endsWith('.000000')) {
      return result.substring(0, result.length - 7);
    }
    while (result.endsWith('0') && result.contains('.')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }
}