package org.xtext.example.mydsl.generator.ClientAppGenerators

import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.emf.ecore.resource.Resource
import org.xtext.example.mydsl.bookingDSL.Customer
import org.xtext.example.mydsl.bookingDSL.Attribute
import org.xtext.example.mydsl.bookingDSL.Declaration
import org.xtext.example.mydsl.bookingDSL.Entity
import org.xtext.example.mydsl.bookingDSL.Schedule
import org.xtext.example.mydsl.bookingDSL.Booking
import org.xtext.example.mydsl.bookingDSL.Relation
import org.xtext.example.mydsl.bookingDSL.Member

class ModelGenerator {
	
	private IFileSystemAccess2 fsa;
	private Resource resource;
	private String modelsRoot;
	private String requestModelsRoot;
	
	new(IFileSystemAccess2 fsa, Resource resource, String srcRoot) {
		this.fsa = fsa;
		this.resource = resource;
		this.modelsRoot = srcRoot + "/api/models";
		this.requestModelsRoot = srcRoot + "/api/requestModels";
	}
	
	def generate() {
		this.resource.allContents.filter(Declaration).forEach[generateModels]
		this.resource.allContents.filter(Declaration).forEach[generateRequestModels]
	}
	
	def generateModels(Declaration declaration) {
		switch declaration {
			Customer: generateModels(declaration , "customers")
			org.xtext.example.mydsl.bookingDSL.Resource: generateModels(declaration , "resources")
			Entity: generateModels(declaration , "entities")
			Schedule: generateModels(declaration , "schedules")
			Booking: generateModels(declaration , "bookings")
				
		}
	}
	
	def generateModels(Declaration decleration , String root) {
		this.fsa.generateFile(this.modelsRoot +"/" + root + "/" +  decleration.name +".ts" , decleration.generateAttributes)
	}
	
	def generateRequestModels(Declaration declaration) {
		
		this.fsa.generateFile(this.requestModelsRoot + "/Create" + declaration.name + "RequestModel.ts", 
			'''
			«FOR mem:declaration.members.filter(Relation)»
			import {«mem.relationType.name.toFirstUpper»} from "../models/«getDeclarationType(mem.relationType)»/«mem.relationType.name.toFirstUpper»"
			«ENDFOR»
			export type Create«declaration.name.toFirstUpper»RequestModel = {
				«FOR mem : declaration.members»
					«generateMember(mem)»
				«ENDFOR»
			} 
			'''
		)
		
		this.fsa.generateFile(this.requestModelsRoot + "/Update" + declaration.name + "RequestModel.ts",
			'''
			«FOR mem:declaration.members.filter(Relation)»
			import {«mem.relationType.name.toFirstUpper»} from "../models/«getDeclarationType(mem.relationType)»/«mem.relationType.name.toFirstUpper»"	
			«ENDFOR»
			export type Update«declaration.name.toFirstUpper»RequestModel = {
				id: string
				«FOR mem : declaration.members»
					«generateMember(mem)»
				«ENDFOR»
			} 
			'''
		)
	}
	
	def CharSequence generateAttributes(Declaration declaration) {

		'''
		«FOR mem:declaration.members.filter(Relation)»
		import {«mem.relationType.name.toFirstUpper»} from "../«getDeclarationType(mem.relationType)»/«mem.relationType.name.toFirstUpper»"
		«ENDFOR»
		export type «declaration.name.toFirstUpper» = {
			id: string
			«FOR mem : declaration.members»
				«generateMember(mem)»
			«ENDFOR»
		} 
		'''
	}
	
	def dispatch generateMember(Attribute mem) {
		return '''
		«this.generateAttribute(mem, ManagementPagesGenerator.attributeTypeToString(mem.type))»
		'''
	}
	
	def dispatch generateMember(Relation mem) {
		return '''
		«mem.name»: «mem.relationType.name»«mem.plurality == "many" ? "[]" : null»
		'''
	}
	
	def generateAttribute(Attribute attri, String type) {
		return attri.name + ": " + type + (attri.array ? "[]" : "");
	}
	
	def getDeclarationType(Declaration declaration) {
		return switch declaration {
			Customer: "customers"
			org.xtext.example.mydsl.bookingDSL.Resource: "resources"
			Entity: "entities"
			Schedule: "schedules"
			Booking: "bookings"
		}
	}
}