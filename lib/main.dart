import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
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
      debugShowCheckedModeBanner: false,
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
                  height: 20.0,
                ),
                const CircleAvatar(
                  radius: 75.0,
                  backgroundColor: Colors.black,
                  backgroundImage: AssetImage('images/thomas_sowell.png'),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                SizedBox(
                  width: 400,
                  child: Text(
                    '"First you take people\'s money away quietly, and then you give some of it back to them flamboyantly."',
                    style: Theme.of(context).textTheme.subtitle2,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: Divider(
                    thickness: 2,
                  ),
                ),
                Text(
                  'Thomas Sowell',
                  style: Theme.of(context).textTheme.caption,
                ),
                const SizedBox(
                  height: 40.0,
                  width: 300.0,
                  child: Divider(
                    thickness: 2.0,
                  ),
                ),
                SizedBox(
                  width: 400,
                  child: Text(
                    'Enter your annual salary to return a breakdown of your take-home pay aftar tax and National Insurance contributions.\n\nCalculations based on the 22-23 tax year.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
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
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        //BOTTOM SHEET TO ADD CONTACT DETAILS - ADD STATISTA LINK
        bottomSheet: Container(
          height: 40.0,
          color: Colors.black26,
          child: Center(
              child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Created by Local Optimum   //'),
                  TextButton(
                    onPressed: () async {
                      try{
                        await launchUrlString('https://github.com/local-optimum/uk_salary_calculator');
                      }catch(err){debugPrint('could not reach site.');}
                    },
                    child: const Text(
                      'Github',
                    ),
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
  double nationalinsurance = 0;
  double personalallowance = 0;
  double incometax = 0;
  double takehome = 0;

  String salaryf = '';
  String nif = '';
  String paf = '';
  String itf = '';
  String thf = '';

  //formatting for numbers

  void initStartDate() {
    salaryinput.text = NumberFormat.currency(symbol: '£ ', decimalDigits: 2)
        .format(salary); //set the initial value of text field
    super.initState();
  }

  //primary calculating function

  void getData() async {
    var ni = await NIcontributions().getNIcontributions(salary);
    setState(() {
      nationalinsurance = ni;
    });

    var pa = await PersonalAllowance().getPersonalAllowance(salary);
    setState(() {
      personalallowance = pa;
    });

    var it = await IncomeTax().getIncomeTax(salary, personalallowance);
    setState(() {
      incometax = it;
    });

    var th = await Takehome().getTakeHome(salary, incometax, nationalinsurance);
    setState(() {
      takehome = th;
    });

    salaryf =
        NumberFormat.currency(symbol: '£ ', decimalDigits: 2).format(salary);
    nif = NumberFormat.currency(symbol: '£ ', decimalDigits: 2)
        .format(nationalinsurance);
    paf = NumberFormat.currency(symbol: '£ ', decimalDigits: 2)
        .format(personalallowance);
    itf =
        NumberFormat.currency(symbol: '£ ', decimalDigits: 2).format(incometax);
    thf =
        NumberFormat.currency(symbol: '£ ', decimalDigits: 2).format(takehome);
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 120),
            child: TextFormField(
              controller: salaryinput,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.currency_pound_sharp),
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
              onFieldSubmitted: (value) {
                if (_formKey.currentState!.validate()) getData();
              },
            ),
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
                                  child: const Text('Annual Salary:')),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(salaryf)),
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
                                  child: Text(paf)),
                            ),
                          ],
                        ),
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
                                child: Text(nif),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: const Text('Income Tax:')),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: Text(itf),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text('Take Home Pay:',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: Text(thf,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                              ),
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
