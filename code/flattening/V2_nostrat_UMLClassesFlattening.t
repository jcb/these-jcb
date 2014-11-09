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

import tom.library.emf.*;

/* VERSION1: recursive version, no %strategy, no %transformation */
public class V2_nostrat_UMLClassesFlattening {

  %include{ emf/ecore.tom }
  %include{ mappings/ClassflatteningPackage.tom }

  %typeterm V2_nostrat_UMLClassesFlattening { implement { V2_nostrat_UMLClassesFlattening }}
  private static classflattening.VirtualRoot virtR = null;

  public static classflattening.VirtualRoot v1_processClass(classflattening.VirtualRoot root) {
    org.eclipse.emf.common.util.EList<classflattening.Class> children = root.getChildren();
    org.eclipse.emf.common.util.EList<classflattening.Class> newChildren = `cfClassEList();
    %match(children) {
      cfClassEList(_*,cl@cfClass(_,_,_,cfClassEList(),_),_*) -> {
        newChildren = `cfClassEList(flattening(cl),newChildren*); 
      }
    }
    return `cfVirtualRoot(newChildren);
  }

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
    V2_nostrat_UMLClassesFlattening translator = new V2_nostrat_UMLClassesFlattening();
    try {
      //init virtual root
      translator.virtR = `cfVirtualRoot(cfClassEList());

      System.out.println("\nSource:");
      `TopDown(Print()).visit(source_root, new EcoreContainmentIntrospector());

      System.out.print("\nFlattening");
      //VERSION1
      System.out.println(" (VERSION1) ...");
      translator.virtR = v1_processClass(source_root);

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
        if (!(`attr.isEmpty())) {
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
