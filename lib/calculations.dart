//NATIONAL INSURANCE CONTRIBUTIONS https://www.gov.uk/national-insurance-rates-letters

class NIcontributions {
  Future getNIcontributions(salary) async {
    var weeklysalary = salary / 52;
    var weeklyfirstcharge = (weeklysalary - 190) * 0.1325;
    if (weeklyfirstcharge >= (967-190) * 0.1325) {
      weeklyfirstcharge = (967-190) * 0.1325;
    } else if (weeklyfirstcharge < 0) {
      weeklyfirstcharge = 0;
    }
    double weeklysecondcharge = (weeklysalary - 967) * 0.0325;
    if (weeklysecondcharge < 0) {
      weeklysecondcharge = 0;
    }
    return (weeklyfirstcharge + weeklysecondcharge)*52;
  }
}


//https://www.gov.uk/income-tax-rates/income-over-100000


class PersonalAllowance {
  Future getPersonalAllowance(salary) async {
    double baseallowance = 12570;
    if(salary>100000+2*baseallowance){
      return 0;
    }
    else if (salary>100000){
      return baseallowance - ((salary-100000)/2);
    } else { return baseallowance;
    }
  }
}



///https://www.gov.uk/income-tax-rates
//
//Band 	Taxable income 	Tax rate
//Personal Allowance 	Up to £12,570 	 0%
//Basic rate 	£12,571 to £50,270 	    20%
//Higher rate 	£50,271 to £150,000 	40%
//Additional rate 	over £150,000 	  45%"

//https://www.gov.uk/government/publications/rates-and-allowances-income-tax/income-tax-rates-and-allowances-current-and-past#tax-rates-and-bands

class IncomeTax{
  Future getIncomeTax(salary, personalallowance) async{
    double taxable = salary-personalallowance;
    double toprate=0;
    double highrate=0;
    double basicrate=0;

    if(taxable>150000){
      toprate = 0.05*(taxable-150000);
    }
    if(taxable>37700){
      highrate = 0.2*(taxable - 37700); 
    }
    if (taxable>0){
      basicrate = 0.2*taxable;
    }

    return basicrate+highrate+toprate;

  }
}

class Takehome{
  Future getTakeHome(salary, incometax,nationalinsurance)async{
    double takehome = salary-incometax-nationalinsurance;
    return takehome;
  }
}