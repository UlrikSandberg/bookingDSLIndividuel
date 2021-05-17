package org.xtext.example.mydsl.ui;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.documentation.IEObjectDocumentationProvider;

 
public class MyDslEObjectDocumentationProvider implements IEObjectDocumentationProvider {
 
    @Override
    public String getDocumentation(EObject o) {
        return null;
    }
 
}