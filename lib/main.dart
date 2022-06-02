import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';
import 'package:intl/intl.dart';

//import calculations
import 'calculations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var theme = yaruDark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UK Salary Calculator',
      theme: theme,
      home: const MyHomePage(title: 'UK Salary Tax Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                const SizedBox(
                  width: 450,
                  child: Text(
                      'Welcome to the UK Salary Tax Calculator, put in your salary to return your take-home pay and a breakdown of Tax and National Insurance contributions'),
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: 600,
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 25.0),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          MyCustomForm(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        //BOTTOM SHEET TO ADD CONTACT DETAILS - ADD STATISTA LINK
        bottomSheet: Container(
          height: 50.0,
          color: Colors.black26,
          child: Center(
              child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Padding(
                    padding: EdgeInsets.all(14.0),
                    child: Text('Created by Local Optimum'),
                  ),
                ],
              ),
            ],
          )),
        ));
  }
}

// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  double salary = 0;
  dynamic nationalinsurance;
  dynamic personalallowance;

  void getData() async {
    var ni = await NIcontributions().getNIcontributions(salary);
    setState(() {
      nationalinsurance = ni;
    });

    var pa = await PersonalAllowance().getPersonalAllowance(salary);
    setState(() {
      personalallowance = pa;
    });
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController salaryinput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextFormField(
            controller: salaryinput,
            decoration: const InputDecoration(
              icon: Icon(Icons.currency_pound_sharp),
              hintText: 'Salary before deductions',
              labelText: 'Annual Salary',
              border: OutlineInputBorder(),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              filled: true,
            ),
            keyboardType: TextInputType.number,
            onSaved: (String? value) {
              salary = double.parse(value!);
            },
            // The validator receives the text that the user has entered.
            validator: (String? value) {
              if (value!.isEmpty || double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
            onChanged: (value) => salary = double.parse(value),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) getData();
              },
              child: const Text('Submit'),
            ),
          ),

          //RESULTS APPEAR AFTER
          if (salary > 0) ...[
            SizedBox(
              width: 600,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Take Home Pay',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Table(
                      border: TableBorder.all(color: Colors.grey),
                      children: [
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: const Text('National Insurance:')),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Text('$nationalinsurance')),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: const Text('Personal Allowance:')),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Text('$personalallowance')),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
