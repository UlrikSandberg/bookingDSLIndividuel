package org.xtext.example.mydsl.ui;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.ui.editor.hover.html.DefaultEObjectHoverProvider;
import org.xtext.example.mydsl.bookingDSL.Comparison;
import org.xtext.example.mydsl.bookingDSL.Conjunction;
import org.xtext.example.mydsl.bookingDSL.Constraint;
import org.xtext.example.mydsl.bookingDSL.Disjunction;
import org.xtext.example.mydsl.bookingDSL.Expression;
import org.xtext.example.mydsl.bookingDSL.Logic;
import org.xtext.example.mydsl.bookingDSL.Plus;
import org.xtext.example.mydsl.generator.ExpressionGenerator;

import com.google.inject.Inject;

 
public class MyDslEObjectHoverProvider extends DefaultEObjectHoverProvider {
 
	@Inject
	private ExpressionGenerator interpreter;
	
    @Override
    protected String getHoverInfoAsHtml(EObject o) {
    	
    	if(o instanceof Disjunction) {
    		return ExpressionGenerator.computeDisjunction((Disjunction)o) + "";
    	}
    	
    	if(o instanceof Conjunction) {
    		return ExpressionGenerator.computeConjunction((Conjunction)o) + "";
    	}
    	
    	if(o instanceof Constraint) {
    		return "A constraint)";
    	}
    	
    	if(o instanceof Logic) {
    		return "A logic";
    	}
    	
    	if(o instanceof Plus) {
    		return "A Plus";
    	}
    	
    	if(o instanceof Comparison) {
    		return "A comparison";
    	}
    	
    	if(o instanceof Expression) {
    		return ExpressionGenerator.compute((Expression)o) + "";
    	}
    	
        
        return super.getHoverInfoAsHtml(o);
    }
 
}