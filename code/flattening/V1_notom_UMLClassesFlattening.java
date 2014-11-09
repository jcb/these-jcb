import org.eclipse.emf.common.util.*;
import org.eclipse.emf.ecore.*;
import org.eclipse.emf.ecore.xmi.*;
import org.eclipse.emf.ecore.xmi.impl.*;

import classflattening.*;
import classflattening.impl.*;

import java.util.*;
import java.io.File;
import java.io.FileInputStream;

/* VERSION0: Version without any Tom code -> pure Java EMF */
public class V1_notom_UMLClassesFlattening {
  private static classflattening.VirtualRoot virtR = null;

  public static classflattening.VirtualRoot v0_processClass(classflattening.VirtualRoot root) {
    org.eclipse.emf.common.util.EList<classflattening.Class> newChildren = 
                new org.eclipse.emf.common.util.BasicEList<classflattening.Class>();
    for(classflattening.Class cl : root.getChildren()) {
      if(cl.getSubclass().isEmpty()) {
        newChildren.add(notom_flattening(cl));
      }
    }
    classflattening.VirtualRoot result = (classflattening.VirtualRoot)classflattening.ClassflatteningFactory.eINSTANCE.create(
                                           (EClass)classflattening.ClassflatteningPackage.eINSTANCE.getEClassifier("VirtualRoot"));
    result.eSet(result.eClass().getEStructuralFeature("children"),(Object)newChildren);
    return result;
  }

  public static classflattening.Class notom_flattening(classflattening.Class toFlatten) {
    classflattening.Class parent = toFlatten.getSuperclass();
    if(parent==null) {
      return toFlatten;
    } else {
      classflattening.Class flattenedParent = notom_flattening(parent);
      org.eclipse.emf.common.util.EList<classflattening.Attribute> head =
        toFlatten.getAttributes();
      head.addAll(flattenedParent.getAttributes());
      classflattening.Class result = (classflattening.Class)classflattening.ClassflatteningFactory.eINSTANCE.create(
                                       (EClass)classflattening.ClassflatteningPackage.eINSTANCE.getEClassifier("Class"));

      result.eSet(result.eClass().getEStructuralFeature("name"),(Object)flattenedParent.getName()+toFlatten.getName());
      result.eSet(result.eClass().getEStructuralFeature("attributes"),(Object)head);
      result.eSet(result.eClass().getEStructuralFeature("superclass"),(Object)flattenedParent.getSuperclass());
      result.eSet(result.eClass().getEStructuralFeature("subclass"),(Object)(
                                        new org.eclipse.emf.common.util.BasicEList<classflattening.Class>()) );
      result.eSet(result.eClass().getEStructuralFeature("root"),(Object)virtR);
      return result;
    }
  }

  public static void main(String[] args) {
    System.out.println("\nStarting...\n");

    XMIResourceImpl resource = new XMIResourceImpl();
    classflattening.VirtualRoot source_root = null;
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
      System.out.println("No model instance given in argument. Bye bye.");
      return; 
    }
    V1_notom_UMLClassesFlattening translator = new V1_notom_UMLClassesFlattening();
    try {
      //init virtual root
      translator.virtR = null;
      System.out.println("\nSource:");
      printer(source_root);

      System.out.print("\nFlattening");
      //VERSION0
      System.out.println(" (VERSION0) ...");
      translator.virtR = v0_processClass(source_root);

      System.out.println("\nResult:");
      printer(translator.virtR);
    } catch(Exception e) {
      System.out.println("Ooops!");
    }
  }

  public static void printer(classflattening.VirtualRoot root) {
    for(classflattening.Class cl : root.getChildren()) {
      classflattening.Class sup = cl.getSuperclass();
      String strSup =  (sup!=null)?"\n sup="+sup.getName():"";
      String strAttr = "";
      org.eclipse.emf.common.util.EList<classflattening.Attribute> attr = cl.getAttributes();
      if(!(attr.isEmpty())) {

        classflattening.Attribute head = attr.get(0);
        strAttr += "\n attr="+head.getName()+":"+head.getType().getName();
        if(attr.size()>1) {
          java.util.List<classflattening.Attribute> tail = attr.subList(1,attr.size());
          for(classflattening.Attribute at : tail) {
            strAttr += ", "+at.getName()+":"+at.getType().getName();
          }
        }
      }
      System.out.println("Class: "+cl.getName()+strAttr+strSup/*+strSub*/);
    }
  }

}
