/*
 * generated by Xtext 2.24.0
 */
package org.xtext.example.mydsl.ui.contentassist

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor
import org.eclipse.xtext.CrossReference
import org.xtext.example.mydsl.bookingDSL.Member
import org.xtext.example.mydsl.bookingDSL.Customer
import org.eclipse.xtext.Assignment
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.Assignment;
import org.eclipse.xtext.CrossReference;
import org.eclipse.xtext.RuleCall;
import org.eclipse.xtext.common.ui.contentassist.TerminalsProposalProvider;
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext;
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor;
import org.xtext.example.mydsl.bookingDSL.Attribute
import org.xtext.example.mydsl.bookingDSL.Resource
import org.xtext.example.mydsl.bookingDSL.Schedule
import org.xtext.example.mydsl.bookingDSL.Booking
import org.xtext.example.mydsl.bookingDSL.Entity
import java.util.HashSet

/** 
 * See https://www.eclipse.org/Xtext/documentation/310_eclipse_support.html#content-assist
 * on how to customize the content assistant.
 */
class BookingDSLProposalProvider extends AbstractBookingDSLProposalProvider {
	
	public override void completeVar_Name(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		lookupCrossReference(assignment.terminal as CrossReference, context, acceptor, [description |
			
			val proxy = description.EObjectOrProxy as Attribute;
			val container = model.eContainer;

			if(container instanceof Customer) {
				val visited = new HashSet<Customer>
				var current = container
				while(current !== null) {
					if(visited.contains(current)) return false; // terminate search to prevent getting stuck in infinite loop
					visited.add(container)
					if(current.members.filter[e | e.equals(proxy)].length > 0) {
						println(proxy)
						return true
					}
					current = current.superType
				}
			}

			if(container instanceof Resource) {
				val visited = new HashSet<Resource>
				var current = container
				while(current !== null) {
					if(visited.contains(current)) return false; // Terminate search to prevent getting stuck in infinite loop
					visited.add(container)
					if(current.members.filter[e | e.equals(proxy)].length > 0) {
						return true;
					}
					current = current.superType
				}
			}
			
			if(container instanceof Schedule) {
				if(container.members.filter[e | e.equals(proxy)].length > 0) {
					return true;
				}
			}
			
			if(container instanceof Booking) {
				if(container.members.filter[e | e.equals(proxy)].length > 0) {
					return true;
				}
			}
			
			if(container instanceof Entity) {
				if(container.members.filter[e | e.equals(proxy)].length > 0) {
					return true;
				}
			}
			return false
		])
	}
}
