/*
 * generated by Xtext 2.24.0
 */
package org.xtext.example.mydsl.validation

import org.eclipse.xtext.validation.Check
import org.xtext.example.mydsl.bookingDSL.Attribute
import org.xtext.example.mydsl.bookingDSL.Booking
import org.xtext.example.mydsl.bookingDSL.BookingDSLPackage
import org.xtext.example.mydsl.bookingDSL.Declaration
import org.xtext.example.mydsl.bookingDSL.System
import org.xtext.example.mydsl.bookingDSL.Entity
import org.xtext.example.mydsl.bookingDSL.Relation
import org.xtext.example.mydsl.bookingDSL.Schedule
import org.xtext.example.mydsl.bookingDSL.Resource
import org.xtext.example.mydsl.bookingDSL.Customer
import java.util.ArrayList
import java.util.List

/** 
 * This class contains custom validation rules. 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class BookingDSLValidator extends AbstractBookingDSLValidator {
	
	@Check def void warnIfNoDisplayName(Declaration declaration) {
		if (declaration instanceof Booking) {
			return;
		}
		var hasName = false
		var members = declaration.getMembers()
		for (var int i = 0; i < members.size(); i++) {
			var member = members.get(i)
			if (member instanceof Attribute) {
				var attriName = ((member as Attribute)).getName()
				if (attriName.equals("name")) {
					hasName = true
				}
			}
		}
		if (!hasName) {
			
			var alreadyExtended = new ArrayList<String>
			
			// Check if a extended superType has a name
			if(declaration instanceof Customer) {
				if(declaration.superType !== null) {
					alreadyExtended.add(Customer.toString())
					if(searchInheritanceForName(declaration, alreadyExtended) == true) {
						return;
					}
				}
			}
			
			if(declaration instanceof Resource) {
				if(declaration.superType !== null) {
					alreadyExtended.add(Resource.toString())
					if(searchInheritanceForName(declaration, alreadyExtended) == true) {
						return;
					}
				}
			}
			
			
			// Return warning that there are no name attribute
			warning("This declaration has no name attribute", null)
			return;
		}
	}
	
	def dispatch boolean searchInheritanceForName(Customer declaration, List<String> alreadyExtended) {
		if(declaration.superType !== null) {
			if(declaration.superType.members.filter(Attribute).filter[e | e.name.equals("name")].length > 0) {
				return true
			}
			
			if(alreadyExtended.filter[e | e.equals(declaration.superType.toString())].length > 0) {
				return false;
			} else {
				alreadyExtended.add(declaration.superType.toString())
				return searchInheritanceForName(declaration.superType, alreadyExtended)
			}
		}
		return false;
	}
	
	def dispatch boolean searchInheritanceForName(Resource declaration, List<String> alreadyExtended) {
		if(declaration.superType !== null) {
			if(declaration.superType.members.filter(Attribute).filter[e | e.name.equals("name")].length > 0) {
				return true
			}
			
			
			if(alreadyExtended.filter[e | e.equals(declaration.superType.toString())].length > 0) {
				return false;
			} else {
				alreadyExtended.add(declaration.superType.toString())
				return searchInheritanceForName(declaration.superType, alreadyExtended)
			}
		}
		return false;
	}
	

	@Check def void errorIfDisplayNameIsNotString(Attribute attri) {
		var attriName = attri.getName()
		if (attriName.equals(("name"))) {
			var attriType = attri.getType().getLiteral()
			if (!attriType.equals("string")) {
				error("Attribute of type name can only be of type string", null)
				return;
			}
		}
	}

	@Check def void errorIfSystemNameLowerCase(System system) {
		if (!Character::isUpperCase(system.getName().charAt(0))) {
			error("System name must begin with a capital letter", null)
		}
	}

	@Check def void errorIfDeclarationNameLowerCase(Declaration declaration) {
		if (!Character::isUpperCase((declaration.getName().charAt(0)))) {
			error("Declaration name must begin with a capital letter", null)
		}
	}

	@Check  
	def void errorIfBookingMissRelation(Booking booking) {
		// Booking can't have relation to another booking
		// all relations must be one
		
		var missingTypes = new ArrayList<String>()
		
		for(Relation rel: booking.members.filter(Relation)) {
			if(rel.relationType instanceof Booking) {
				error("Booking is not allowed to have a relation to another booking", null)
			}
			if(rel.relationType instanceof Schedule) {
				if(rel.plurality == "many") {
					error("Booking only allows \"has one \" relations to schedules", null)
				}
				missingTypes.add(Schedule.toString())
			}
			if(rel.relationType instanceof Resource) {
				if(rel.plurality == "many") {
					error("Booking only allows \"has one \" relations to resources", null)
				}
				missingTypes.add(Resource.toString())
			}
			if(rel.relationType instanceof Customer) {
				if(rel.plurality == "many") {
					error("Booking only allows \"has one \" relations to customers", null)
				}
				missingTypes.add(Customer.toString())
			}
		}
		
		if(missingTypes.filter[t | t == Resource.toString()].length == 0) {
			error("Booking must specify a \"has one \" relation to a resource", null)
		}
		
		if(missingTypes.filter[t | t == Customer.toString()].length == 0) {
			error("Booking must specify a \"has one \" relation to a customer", null)
		}
		
		if(missingTypes.filter[t | t == Schedule.toString()].length == 0) {
			error("Booking must specify a \"has one \" relation to a schedule", null)
		}
	}
	
	@Check
	def void errorIfOtherThanEntityOwnsResource(Declaration declaration) {
		
		if(declaration instanceof Entity || declaration instanceof Booking) {
			return;
		}
		
		for(Relation rel : declaration.members.filter(Relation)) {
			if(rel.relationType instanceof Resource) {
				error('''Only Customer and booking types can have relations to resources''', null)
			}
		}
	}
	
	@Check
	def void errorIfOtherThanResourceOwnsSchedules(Declaration declaration) {
		if(declaration instanceof Resource || declaration instanceof Booking) {
			return;
		}
		
		for(Relation rel : declaration.members.filter(Relation)) {
			if(rel.relationType instanceof Schedule) {
				error('''Only Resource and booking types can have relations to schedules''', null)
			}
		}
	}
	
	@Check
	def void errorIfCyclicInheritance(Declaration declaration) {
		
		var alreadyExtended = new ArrayList<String>

		if(declaration instanceof Customer) {
			alreadyExtended.add(Customer.toString())
			if(declaration.superType !== null) {
				errorIfCyclicInheritance(declaration.superType, alreadyExtended)
			}
		}
		
		if(declaration instanceof Resource) {
			alreadyExtended.add(Resource.toString())
			if(declaration.superType !== null) {
				errorIfCyclicInheritance(declaration.superType, alreadyExtended)
			}
		}
	}
	
	def dispatch errorIfCyclicInheritance(Customer declaration, ArrayList<String> alreadyExtended) {
		if(declaration.superType !== null) {
			if(alreadyExtended.filter[e | e.equals(declaration.superType.toString())].length > 0) {
				error("Cyclic dependency detected", null)
				return null;
			} else {
				alreadyExtended.add(declaration.superType.toString())
				errorIfCyclicInheritance(declaration.superType, alreadyExtended)
			}
		}
		return null;
	}
	
	def dispatch errorIfCyclicInheritance(Resource declaration, ArrayList<String> alreadyExtended) {
		if(declaration.superType !== null) {
			if(alreadyExtended.filter[e | e.equals(declaration.superType.toString())].length > 0) {
				error("Cyclic dependency detected", null)
				return null;
			} else {
				alreadyExtended.add(declaration.superType.toString())
				errorIfCyclicInheritance(declaration.superType, alreadyExtended)
			}
		}
		return null;
	}
	
	@Check
	def void warningIfInheritedAttributesAreHidden(Declaration declaration) {
		
		var variableNames = declaration.members.map[e | e.name]
		var alreadyExtended = new ArrayList<String>
		
		if(declaration instanceof Customer) {
			alreadyExtended.add(Customer.toString())
			if(declaration.superType !== null) {
				warningIfInheritedAttributesAreHidden(declaration, alreadyExtended, variableNames)
			}
		}
		
		if(declaration instanceof Resource) {
			alreadyExtended.add(Resource.toString())
			if(declaration.superType !== null) {
				warningIfInheritedAttributesAreHidden(declaration, alreadyExtended, variableNames)
			}
		}
	}
	
	def dispatch warningIfInheritedAttributesAreHidden(Customer declaration, List<String> alreadyExtended, List<String> originalVariables) {
		if(declaration.superType !== null) {
			// Seeing as there is a superType we should see if any of the attributes have the same name as the originalVariables
			declaration.superType.members.forEach[e | 
				if(originalVariables.filter[l | l.equals(e.name)].length > 0) {
					if(e instanceof Attribute) {
						warning('''The variable «e.name»:«e.type.toString()» hides an inherited member''', null)	
					}
					if(e instanceof Relation) {
						warning('''The relation «e» hides an inherited member''', null)
					}
				}
			]
			if(alreadyExtended.filter[e | e.equals(declaration.superType.toString())].length > 0) {
				// We need to terminate the attribute search here to not get stuck in an infinite loop
				
				return null;
			} else {
				alreadyExtended.add(declaration.superType.toString())
				warningIfInheritedAttributesAreHidden(declaration.superType, alreadyExtended, originalVariables)
			}
		}
		return null;
	}
	
	def dispatch warningIfInheritedAttributesAreHidden(Resource declaration, List<String> alreadyExtended, List<String> originalVariables) {
		if(declaration.superType !== null) {
			// Seeing as there is a superType we should see if any of the attributes have the same name as the original variables 
			declaration.superType.members.forEach[e | 
				if(originalVariables.filter[l | l.equals(e.name)].length > 0) {
					if(e instanceof Attribute) {
						warning('''The variable «e.name»:«e.type.toString()» hides an inherited member''', null)	
					}
					if(e instanceof Relation) {
						warning('''The relation «e» hides an inherited member''', null)
					}
				}
			]
			
			if(alreadyExtended.filter[e | e.equals(declaration.superType.toString())].length > 0) {
				return null;
			} else {
				alreadyExtended.add(declaration.superType.toString())
				warningIfInheritedAttributesAreHidden(declaration.superType, alreadyExtended, originalVariables)
			}
		}
		return null;
	}
}
