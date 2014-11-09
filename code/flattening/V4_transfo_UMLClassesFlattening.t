import org.eclipse.emf.common.util.*;
import org.eclipse.emf.ecore.*;
import org.eclipse.emf.ecore.util.ECrossReferenceAdapter;
import org.eclipse.emf.ecore.xmi.*;
import org.eclipse.emf.ecore.xmi.impl.*;

import classflattening.*;
import classflattening.impl.*;

import java.util.*;
import java.io.File;
import java.io.FileInputStream;

import tom.library.sl.*;
import tom.library.emf.*;
import tom.library.utils.LinkClass;

public class V4_transfo_UMLClassesFlattening {

  %include{ sl.tom }
  %include{ LinkClass.tom }
  %include{ emf/ecore.tom }

  %include{ mappings/ClassflatteningPackage.tom }

  %typeterm UMLClassesFlattening { implement { UMLClassesFlattening }}

  private static classflattening.VirtualRoot virtR = null;
  private static LinkClass tom__linkClass;

  public UMLClassesFlattening() {
    this.tom__linkClass = new LinkClass();
  }

  /* This function is called by the transformation, like in previous
   * implementations */
  public static classflattening.Class flattening(classflattening.Class toFlatten) {
    classflattening.Class parent = toFlatten.getSuperclass();
    if(parent==null) {
      return toFlatten;
    } else {
      classflattening.Class flattenedParent = flattening(parent);

      org.eclipse.emf.common.util.EList<classflattening.Attribute> head = toFlatten.getAttributes();
      head.addAll(flattenedParent.getAttributes());
      classflattening.Class result = `cfClass(flattenedParent.getName() +
          toFlatten.getName(), head, flattenedParent.getSuperclass(),
          cfClassEList(), null);
      return result;
    }
  }

  /* VERSION4: %transformation version */
    %transformation FlatteningTrans(tom__linkClass:LinkClass,virtR:cfVirtualRoot) : "metamodels/Class.ecore" -> "metamodels/Class.ecore" {
    definition DEF1 traversal `BottomUp(DEF1(tom__linkClass, virtR)) {
      cfVirtualRoot(cfClassEList(_*,cl@cfClass(n,_,_,cfClassEList(),_),_*)) -> {
        org.eclipse.emf.common.util.EList<classflattening.Class> newChildren = virtR.getChildren();
        return `cfVirtualRoot(cfClassEList(flattening(cl),newChildren*));
      }
    }
  }


  /* NOTE: no resolve element needed */
  public static void main(String[] args) {
    System.out.println("\nStarting...\n");

    XMIResourceImpl resource = new XMIResourceImpl();
    classflattening.VirtualRoot source_root = `cfVirtualRoot(cfClassEList());
    Map opts = new HashMap();
    opts.put(XMIResource.OPTION_SCHEMA_LOCATION, java.lang.Boolean.TRUE);

    if (args.length>0) {
      //EMF style source model creation (loading .xmi file)
      classflattening.ClassflatteningPackage packageInstance = classflattening.ClassflatteningPackage.eINSTANCE;
      File input = new File(args[0]);
      try {
        resource.load(new FileInputStream(input),opts);
      } catch (Exception e) {
        e.printStackTrace();
      }
      source_root = (classflattening.VirtualRoot) resource.getContents().get(0);
    } else {
      System.out.println("No model instance given in argument. Using default hardcoded model.");
      //Tom style source model creation
      classflattening.Class clC =
        `cfClass("C",cfAttributeEList(),null,cfClassEList(), null);
      clC = `cfClass("C",cfAttributeEList(cfAttribute("attrC", clC)),null,cfClassEList(), null);

      classflattening.Class clD =
      `cfClass("D",cfAttributeEList(cfAttribute("attrD", clC)), null,
          cfClassEList(), null);

      classflattening.Class clA = `cfClass("A",cfAttributeEList(), clD,
          cfClassEList(), null);

      classflattening.Class clB =
      `cfClass("B",cfAttributeEList(cfAttribute("attrB1", clC),
            cfAttribute("attrB2", clC)), clA, cfClassEList(), null);

      clD = `cfClass("D",cfAttributeEList(cfAttribute("attrD", clC)), null,
          cfClassEList(clA), null);
      clA = `cfClass("A",cfAttributeEList(), clD, cfClassEList(clB), null);

      source_root = `cfVirtualRoot(cfClassEList(clC,clD,clA,clB));
      clA.setRoot(source_root);
      clB.setRoot(source_root); 
      clC.setRoot(source_root);
      clD.setRoot(source_root);

    }
    UMLClassesFlattening translator = new UMLClassesFlattening();

    try {
      //init virtual root
      translator.virtR = `cfVirtualRoot(cfClassEList());

      System.out.println("\nSource:");
      `TopDown(Print()).visit(source_root, new EcoreContainmentIntrospector());

      System.out.print("\nFlattening");
      //VERSION4
      System.out.println(" (VERSION3) ...");
      Strategy transformer = `TopDown(FlatteningTrans(translator.tom__linkClass,translator.virtR));
      translator.virtR = transformer.visit(source_root, new EcoreContainmentIntrospector());
      /* As we do not use any %resolve, there is no Resolve strategy
       * generation, and no call of it. The following line is only the
       * instruction we would write if there were a Resolve strategy:
         `TopDown(tom__StratResolve_FlatteningTrans(translator.tom__linkClass,
            translator.virtR)).visit(translator.virtR, new
            EcoreContainmentIntrospector());
       */

      System.out.println("\nResult:");
      `TopDown(Print()).visit(translator.virtR, new EcoreContainmentIntrospector());
    } catch(VisitFailure e) {
      System.out.println("strategy fail!");
    }
  }

  %strategy Print() extends Identity() {
    visit cfClass {
      cl@cfClass(n,attr,sup,sub,root) -> {
        String strSup = (`sup!=null)?"\n sup="+`sup.getName():"";
        String strAttr = "";
        if(!(`attr.isEmpty())) {
          %match(`attr) {
            cfAttributeEList(head,tail*) -> {
              strAttr = "\n attr="+`head.getName()+":"+`head.getType().getName();
              %match(`tail) {
                cfAttributeEList(_*,a,_*) -> {
                  strAttr += ", "+`a.getName()+":"+`a.getType().getName();
                }
              }
            }
          }
        }
        System.out.println("Class: "+`n+strAttr+strSup/*+strSub*/);
      }
    }
  }

}
