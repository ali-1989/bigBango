
class TwoStateReturn<R1, R2> {
  R1? result1;
  R2? result2;

  TwoStateReturn({R1? r1, R2? r2}){
    result1 = r1;
    result2 = r2;
  }

  void setResult1(R1? r1){
    result1 = r1;
  }

  void setResult2(R2? r2){
    result2 = r2;
  }

  bool hasResult1(){
    return result1 != null;
  }

  bool hasResult2(){
    return result2 != null;
  }
}