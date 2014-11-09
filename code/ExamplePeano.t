import tom.library.sl.*;

public class ExamplePeano{
  %include { sl.tom }
  //-------- Java classes -----------
  static class JNat { }
  static class JNatList { }

  static class Jzero extends JNat {
    public Jzero() {}
    public boolean equals(Object o) {
      if(o instanceof Jzero) {
        return true;
      }
      return false;
    }
  }

  static class Jsuc extends JNat {
    public JNat n;
    public Jsuc() { }
    public Jsuc(JNat n) { this.n = n; }
    public boolean equals(Object o) {
      if(o instanceof Jsuc) {
        Jsuc obj = (Jsuc) o;
        return n.equals(obj.n);
      }
      return false;
    }
  } 

  static class Jplus extends JNat {
    public JNat n1;
    public JNat n2;
    public Jplus() { }
    public Jplus(JNat n1, JNat n2) { 
      this.n1 = n1;
      this.n2 = n2;
    }
    public boolean equals(Object o) {
      if(o instanceof Jplus) {
        Jplus obj = (Jplus) o;
        return n1.equals(obj.n1) && n2.equals(obj.n2);
      }
      return false;
    }
  }

  static class JconcJNat extends JNatList {
    public JNat head;
    public JNatList tail;
    public JconcJNat() { head = null; tail = null; }
    public JconcJNat(JNat h, JNatList ntail) {
      head = h;
      tail = ntail;
    }
    public boolean isEmpty() {
      return (head == null && tail == null);
    }
    public boolean equals(Object o) {
      if (o instanceof JconcJNat) {
        JconcJNat obj = (JconcJNat) o;
        if (this.isEmpty() && obj.isEmpty()) {
          return true;
        } else if (!this.isEmpty() && !obj.isEmpty()) {
          return 
            head.equals(obj.head) && tail.equals(obj.tail);
        }
      }
      return false;
    }
  }
  //-------- Tom mappings -----------
  %typeterm Nat {
    implement     { JNat }
    is_sort(s)    { (s instanceof JNat) }
    equals(t1,t2) { (t1.equals(t2)) }
  }

  %typeterm NatList {
    implement     { JNatList }
    is_sort(s)    { (s instanceof JNatList) }
    equals(t1,t2) { (t1.equals(t2)) }
  }

  %op Nat zero() {
    is_fsym(s)  { (s instanceof Jzero) }
    make()      { new Jzero() }
  }

  %op Nat suc(n:Nat) {
    is_fsym(s)    { (s instanceof Jsuc) }
    get_slot(n,s) { ((Jsuc)s).n }
    make(t0)      { new Jsuc(t0) }
  }

  %op Nat plus(n1:Nat,n2:Nat) {
    is_fsym(s)     { (s instanceof Jplus) }
    get_slot(n1,s) { ((Jplus)s).n1 }
    get_slot(n2,s) { ((Jplus)s).n2 }
    make(t0,t1)    { new Jplus(t0,t1) }
  }

  %oplist NatList concNat(Nat*) {
    is_fsym(s)         { (s instanceof JconcJNat) }
    get_head(l)        { ((JconcJNat)l).head }
    get_tail(l)        { ((JconcJNat)l).tail }
    is_empty(l)        { ((JconcJNat)l).isEmpty() }
    make_empty()       { new JconcJNat() }
    make_insert(t,l)   { new JconcJNat(t,l) }
  }
  //---------------------------------
  public static void main(String[] args) {
    ExamplePeano exPeano = new ExamplePeano();
    exPeano.run();
  }

  public void run() {
    JNat one = `suc(zero());
    JNat zero = `zero();
    JNat result = peanoPlus(one,zero);
    System.out.print("one + zero = " + printJNat(result) + "\n");

    JNatList nList = `concNat(zero(),suc(zero()),suc(suc(zero())));
    printSolutions(nList);

    try {
      JNat number = `plus(one,zero);
      Strategy addition = `addition();
      JNat reducedNumber1 = addition.visit(number, new LocalIntrospector()); 
      System.out.println("By addition: Term '" + printJNat(number) + "' reduces to '" +
          printJNat(reducedNumber1) +"'.");

      Strategy recursiveAddition = `TopDown(addition());
      JNat reducedNumber2 = recursiveAddition.visit(number, new LocalIntrospector()); 
      System.out.println("By recursiveAddition: Term '" + printJNat(number) + "' reduces to '" +
          printJNat(reducedNumber2) +"'.");
    } catch (VisitFailure e) {
      System.out.println("strategy failed");
    }

    int total = variadicPlus(nList);
    System.out.println("Total = " + total);
    
    printPositiveIntegers(nList);
  }

  public JNat peanoPlus(JNat t1, JNat t2) {
    %match(Nat t1, Nat t2) {
      zero(), x -> { return `x; }
      suc(y), x -> { return `suc(peanoPlus(y,x)); }
    }
    return null; 
  }

  public int variadicPlus(JNatList nList) {
    %match {
      !concNat(x*,suc(y),z*) << nList || concNat() << nList -> { 
        return 0;
      }
      concNat(x*,suc(y),z*) << nList -> {
        return variadicPlus(`concNat(y,x*,z*)) + 1;
      }
    }
    return -1; 
  }

  public void printPositiveIntegers(JNatList nList) {
    int counter = 0;
    %match {
      concNat(x*,pnat@suc(y),z*) << NatList nList -> {
        counter++;
        System.out.println("Positive integer #" + counter + " = " + `pnat);
      }
    }
  }

  public String printFirstElement(JNat t) {
    %match {
      plus[n1=x] << t -> { return printJNat(`x); }
    }
    return "";
  }

  %strategy addition() extends Identity() {
    visit Nat {
      plus(zero(), x) -> { return `x; }
      plus(suc(y), x) -> { return `suc(plus(y,x)); }
    }
  }

  public void printSolutions(JNatList nList) {
    %match(nList) {
      concNat(x*,y*) -> { 
        System.out.print("x = " + printJNatList(`x) + "\t\t");
        System.out.println("y = " + printJNatList(`y));
      }
    }
  }

  public String printJNat(JNat n) {
    %match(n) {
      zero() -> { return "0"; }
      suc(x) -> { return ("suc(" + printJNat(`x) + ")"); }
      plus(x1,x2) -> { return ("plus(" + printJNat(`x1) + "," + printJNat(`x2) + ")"); }
    }
    return "";
  }

  public String printJNatList(JNatList nList) {
    String result = "(";
    %match(nList) {
      concNat(x) -> { return (result + printJNat(`x) + ")"); } 
      concNat(head,tail*) -> { result += (printJNat(`head) + "," + printJNatList(`tail)); }
    }
    // CASE concNat()
    return (result += ")");
  }
}

/* Corresponding java code generated by tom
  public JNat peanoPlus(JNat t1, JNat t2) {
    if (t1 instanceof JNat) {
      if (t1 instanceof Jzero) {
        if (t2 instanceof JNat) { return ((JNat ) t2); }
      }
    }

    if (t1 instanceof JNat) {
      if (t1 instanceof Jsuc) {
        if (t2 instanceof JNat) {
          return new Jsuc(peanoPlus(((Jsuc)t1).n,(( JNat ) t2))); 

        }
      }
    }
    return null; 
  }
 */
