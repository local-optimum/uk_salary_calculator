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


class PersonalAllowance {
  Future getPersonalAllowance(salary) async {
    double baseallowance = 12570;
    if (salary>100000){
      return baseallowance - ((salary-100000)/2);
    } else { return baseallowance;
    }
  }
}

