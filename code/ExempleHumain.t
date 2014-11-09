import tom.library.sl.*;

public class ExampleIndividu{
  %include { sl.tom }
  //-------- Java classes -----------
  static class JIndividu { }
  static class JIndividuList { }

  static class Jzombie extends JIndividu {
    public Jzombie() {}
    public boolean equals(Object o) {
      if(o instanceof Jzombie) {
        return true;
      }
      return false;
    }
  }

  static class Jpersonne extends JIndividu {
    public String nom;
    public String prenom;
    public int age;
    public Jpersonne() { }
    public Jpersonne(String n, String p, int a) { 
      this.nom = n; 
      this.prenom = p;
      this.age = a; 
    }
    public boolean equals(Object o) {
      if(o instanceof Jpersonne) {
        Jpersonne obj = (Jpersonne) o;
        return (nom.equals(obj.nom) 
                && prenom.equals(obj.prenom) 
                && obj.age==age);
      }
      return false;
    }
  } 

  static class JconcJIndividu extends JIndividuList {
    private JIndividu head;
    private JIndividuList tail;
    public JconcJIndividu() { head = null; tail = null; }
    public JconcJIndividu(JIndividu h, JIndividuList t) {
      this.head = h;
      this.tail = t;
    }
    public boolean isEmpty() {
      return (head == null && tail == null);
    }

    public boolean equals(Object o) {
      if (o instanceof JconcJIndividu) {
        JconcJIndividu obj = (JconcJIndividu) o;
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
  %typeterm Individu {
    implement     { JIndividu }
    is_sort(s)    { (s instanceof JIndividu) }
    equals(t1,t2) { (t1.equals(t2)) }
  }

  %typeterm IndividuList {
    implement     { JIndividuList }
    is_sort(s)    { (s instanceof JIndividuList) }
    equals(t1,t2) { (t1.equals(t2)) }
  }

  %op Individu zombie() {
    is_fsym(s)  { (s instanceof Jzombie) }
    make()      { new Jzombie() }
  }

  %op Individu personne(n:Individu) {
    is_fsym(s)    { (s instanceof Jpersonne) }
    get_slot(n,s) { ((Jpersonne)s).n }
    make(t0)      { new Jpersonne(t0) }
  }

  %op Individu plus(n1:Individu,n2:Individu) {
    is_fsym(s)     { (s instanceof Jplus) }
    get_slot(n1,s) { ((Jplus)s).n1 }
    get_slot(n2,s) { ((Jplus)s).n2 }
    make(t0,t1)    { new Jplus(t0,t1) }
  }

  %oplist IndividuList concIndividu(Individu*) {
    is_fsym(s)         { (s instanceof JconcJIndividu) }
    get_head(l)        { ((JconcJIndividu)l).head }
    get_tail(l)        { ((JconcJIndividu)l).tail }
    is_empty(l)        { ((JconcJIndividu)l).isEmpty() }
    make_empty()       { new JconcJIndividu() }
    make_insert(t,l)   { new JconcJIndividu(t,l) }
  }
  //---------------------------------
  public static void main(String[] args) {
    ExempleIndividu exIndividu = new ExempleIndividu();
    exIndividu.run();
  }

  public void run() {
    JIndividu one = `personne(zombie());
    JIndividu zombie = `zombie();
    JIndividu result = peanoPlus(one,zombie);
    System.out.print("one + zombie = " + printJIndividu(result) + "\n");

    JIndividuList nList = `concIndividu(zombie(),personne(zombie()),personne(personne(zombie())));
    printSolutions(nList);

    try {
      JIndividu number = `plus(one,zombie);
      Strategy addition = `addition();
      JIndividu reducedNumber1 = addition.visit(number, new LocalIntrospector()); 
      System.out.println("By addition: Term '" + printJIndividu(number) + "' reduces to '" +
          printJIndividu(reducedNumber1) +"'.");

      Strategy recursiveAddition = `TopDown(addition());
      JIndividu reducedNumber2 = recursiveAddition.visit(number, new LocalIntrospector()); 
      System.out.println("By recursiveAddition: Term '" + printJIndividu(number) + "' reduces to '" +
          printJIndividu(reducedNumber2) +"'.");
    } catch (VisitFailure e) {
      System.out.println("strategy failed");
    }

    int total = variadicPlus(nList);
    System.out.println("Total = " + total);
    
    printPositiveIntegers(nList);
  }

  public JIndividu peanoPlus(JIndividu t1, JIndividu t2) {
    %match(Individu t1, Individu t2) {
      zombie(), x -> { return `x; }
      personne(y), x -> { return `personne(peanoPlus(y,x)); }
    }
    return null; 
  }

  public int variadicPlus(JIndividuList nList) {
    %match {
      !concIndividu(x*,personne(y),z*) << nList || concIndividu() << nList -> { 
        return 0;
      }
      concIndividu(x*,personne(y),z*) << nList -> {
        return variadicPlus(`concIndividu(y,x*,z*)) + 1;
      }
    }
    return -1; 
  }

  public void printPositiveIntegers(JIndividuList nList) {
    int counter = 0;
    %match {
      concIndividu(x*,pnat@personne(y),z*) << IndividuList nList -> {
        counter++;
        System.out.println("Positive integer #" + counter + " = " + `pnat);
      }
    }
  }

  public String printFirstElement(JIndividu t) {
    %match {
      plus[n1=x] << t -> { return printJIndividu(`x); }
    }
    return "";
  }

  %strategy addition() extends Identity() {
    visit Individu {
      plus(zombie(), x) -> { return `x; }
      plus(personne(y), x) -> { return `personne(plus(y,x)); }
    }
  }

  public void printSolutions(JIndividuList nList) {
    %match(nList) {
      concIndividu(x*,y*) -> { 
        System.out.print("x = " + printJIndividuList(`x) + "\t\t");
        System.out.println("y = " + printJIndividuList(`y));
      }
    }
  }

  public String printJIndividu(JIndividu n) {
    %match(n) {
      zombie() -> { return "0"; }
      personne(x) -> { return ("personne(" + printJIndividu(`x) + ")"); }
      plus(x1,x2) -> { return ("plus(" + printJIndividu(`x1) + "," + printJIndividu(`x2) + ")"); }
    }
    return "";
  }

  public String printJIndividuList(JIndividuList nList) {
    String result = "(";
    %match(nList) {
      concIndividu(x) -> { return (result + printJIndividu(`x) + ")"); } 
      concIndividu(head,tail*) -> { result += (printJIndividu(`head) + "," + printJIndividuList(`tail)); }
    }
    // CASE concIndividu()
    return (result += ")");
  }
}

/* Corresponding java code generated by tom
  public JIndividu peanoPlus(JIndividu t1, JIndividu t2) {
    if (t1 instanceof JIndividu) {
      if (t1 instanceof Jzombie) {
        if (t2 instanceof JIndividu) { return ((JIndividu ) t2); }
      }
    }

    if (t1 instanceof JIndividu) {
      if (t1 instanceof Jpersonne) {
        if (t2 instanceof JIndividu) {
          return new Jpersonne(peanoPlus(((Jpersonne)t1).n,(( JIndividu ) t2))); 

        }
      }
    }
    return null; 
  }
 */


//autre version
  static class JconcJIndividu extends JIndividuList {
    private LinkedList<JIndividu> list;
    public JconcJIndividu() { list = new LinkedList<JIndividu>(); }
    public JconcJIndividu(JIndividu i, LinkedList<JIndividu> l) {
      if (l!=null) {
        this.list = l;
      } else {
        JconcJIndividu();
      }
      list.addFirst(i);
    }
    public boolean isEmpty() {
      return list.isEmpty();
    }
    public List<JIndividu> getTail() {
      LinkedList<JIndividu> tail = null;
      if (list.size()>1) { 
        tail = list.subList(1,list.size()-1);
      }
      return tail;
    }
  }
