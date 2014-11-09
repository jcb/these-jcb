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

/* VERSION3: %strategy version, no %transformation */
public class V3_stratnotransfo_UMLClassesFlattening {

  %include{ sl.tom }
  %include{ emf/ecore.tom }

  %include{ mappings/ClassflatteningPackage.tom }

  %typeterm V3_stratnotransfo_UMLClassesFlattening { implement { V3_stratnotransfo_UMLClassesFlattening }}

  private static classflattening.VirtualRoot virtR = null;

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

  %strategy FlatteningStrat(translator:V3_stratnotransfo_UMLClassesFlattening) extends Identity() {
    visit cfVirtualRoot {
      cfVirtualRoot(cfClassEList(_*,cl@cfClass(n,_,_,cfClassEList(),_),_*)) -> {
        org.eclipse.emf.common.util.EList<classflattening.Class> newChildren = translator.virtR.getChildren();
        translator.virtR = `cfVirtualRoot(cfClassEList(flattening(cl),newChildren*));
      }
    }
  }

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
    V3_stratnotransfo_UMLClassesFlattening translator = new V3_stratnotransfo_UMLClassesFlattening();
    try {
      //init virtual root
      translator.virtR = `cfVirtualRoot(cfClassEList());

      System.out.println("\nSource:");
      `TopDown(Print()).visit(source_root, new EcoreContainmentIntrospector());

      System.out.print("\nFlattening");
      //VERSION3
      System.out.println(" (VERSION2) ...");
      Strategy transformer = `BottomUp(FlatteningStrat(translator));
      transformer.visit(source_root, new EcoreContainmentIntrospector());

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
