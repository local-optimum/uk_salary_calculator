import 'package:flutter/material.dart';
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
                  backgroundImage: AssetImage('images/adamsmith.png'),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                SizedBox(
                  width: 350,
                  child: Text(
                    '"There is no art which one government sooner learns of another than that of draining money from the pockets of the people."',
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
                  'Adam Smith',
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
                  width: 450,
                  child: Text(
                    'Enter your salary to return a breakdown of your take-home pay\nafter tax and National Insurance contributions.\n\nCalculations based on the 22-23 tax year using data from HMRC.',
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
                      try {
                        await launchUrlString(
                            'https://github.com/local-optimum/uk_salary_calculator');
                      } catch (err) {
                        debugPrint('could not reach site.');
                      }
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
  //user input variables

  double initsalary = 0;
  double salarytime = 1; //1 = annual, 12 = monthly, 52 = weekly, 365 = daily, hourly is then daily multiplied by hours tracked in next var
  double hoursperday = 8;

  double salary = 0;

  //calculated variables

  double nationalinsurance = 0;
  double personalallowance = 0;
  double incometax = 0;
  double takehome = 0;
  double timeunit =
      1.0; //1 = annual, 12 = monthly, 52 = weekly, 365 = daily, hourly is then daily multiplied by hours tracked in next var

  double out_salary = 0;
  double out_nationalinsurance = 0;
  double out_personalallowance = 0;
  double out_incometax = 0;
  double out_takehome = 0;

  String salaryf = '';
  String nif = '';
  String paf = '';
  String itf = '';
  String thf = '';

  //primary calculating function

  void getData(timeunit) async {

    //convert to annual salary from inputs

    if(salarytime>500){
      salarytime = 365*hoursperday;
    }
    
    salary = initsalary * salarytime;


    //run calculations


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

    //convert to monthly/weekly/hourly based on output selection

    if(timeunit>500){
      timeunit = 365*hoursperday;
    }

    out_salary = salary / timeunit;
    out_nationalinsurance = nationalinsurance / timeunit;
    out_personalallowance = personalallowance / timeunit;
    out_incometax = incometax / timeunit;
    out_takehome = takehome / timeunit;

    //format data

    salaryf = NumberFormat.currency(symbol: '£ ', decimalDigits: 2)
        .format(out_salary);
    nif = NumberFormat.currency(symbol: '£ ', decimalDigits: 2)
        .format(out_nationalinsurance);
    paf = NumberFormat.currency(symbol: '£ ', decimalDigits: 2)
        .format(out_personalallowance);
    itf = NumberFormat.currency(symbol: '£ ', decimalDigits: 2)
        .format(out_incometax);
    thf = NumberFormat.currency(symbol: '£ ', decimalDigits: 2)
        .format(out_takehome);
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController salaryinput = TextEditingController();
  TextEditingController hoursinput = TextEditingController(text: '40');

  @override
  Widget build(BuildContext context) {
    // USER submissions

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 120),
            child: TextFormField(
              controller: salaryinput,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.currency_pound_sharp),
                hintText: 'Salary before deductions',
                labelText: 'Salary',
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
              onChanged: (value) {
                if (_formKey.currentState!.validate()) {
                  initsalary = double.parse(value);
                }
              },
              onFieldSubmitted: (value) {
                if (_formKey.currentState!.validate()) {
                  initsalary = double.parse(value);
                }
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 120),
            child: DropdownButtonFormField(
                alignment: Alignment.center,
                value: 1.0,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_month),
                  labelText: 'Paid',
                  border: OutlineInputBorder(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: true,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 1.0,
                    child: Text("Annually"),
                  ),
                  DropdownMenuItem(
                    value: 12.0,
                    child: Text("Monthly"),
                  ),
                  DropdownMenuItem(
                    value: 52.0,
                    child: Text("Weekly"),
                  ),
                  DropdownMenuItem(
                    value: 365.0,
                    child: Text("Daily"),
                  ),
                  DropdownMenuItem(
                    value: 1000.0,
                    child: Text("Hourly"),
                  ),
                ],
                onChanged: (double? value) {
                  setState(() {
                    
                      salarytime = value!;
                    
                  },);
                },),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 120),
            child: TextFormField(
              controller: hoursinput,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.punch_clock),
                hintText: 'Hours worked per week',
                labelText: 'Hours per week',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                filled: true,
              ),
              keyboardType: TextInputType.number,
              onSaved: (String? value) {
                hoursperday = double.parse(value!) / 7;
              },
              // The validator receives the text that the user has entered.
              validator: (String? value) {
                if (value!.isEmpty || double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              onChanged: (value) {
                if (_formKey.currentState!.validate()) {
                  hoursperday = double.parse(value) / 7;
                }
              },
              onFieldSubmitted: (value) {
                if (_formKey.currentState!.validate()) {
                  hoursperday = double.parse(value) / 7;
                }
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  getData(timeunit);
                }
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
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_month),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text('Paid per: '),
                        const SizedBox(
                          width: 10,
                        ),
                        DropdownButton(
                          alignment: Alignment.center,
                          value: timeunit,
                          items: const [
                            DropdownMenuItem(
                              value: 1.0,
                              child: Text("Year"),
                            ),
                            DropdownMenuItem(
                              value: 12.0,
                              child: Text("Month"),
                            ),
                            DropdownMenuItem(
                              value: 52.0,
                              child: Text("Week"),
                            ),
                            DropdownMenuItem(
                              value: 365.0,
                              child: Text("Day"),
                            ),
                            DropdownMenuItem(
                              value: 1000.0, //FIX THIS
                              child: Text("Hour"),
                            ),
                          ],
                          onChanged: (double? value) {
                            setState(
                              () {
                                
                                  timeunit = value!;
                                

                                getData(timeunit);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
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
                                  child: const Text('Gross Salary:')),
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
