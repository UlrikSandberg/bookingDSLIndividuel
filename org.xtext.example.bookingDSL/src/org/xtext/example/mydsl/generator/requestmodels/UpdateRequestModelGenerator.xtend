package org.xtext.example.mydsl.generator.requestmodels

import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.emf.ecore.resource.Resource
import org.xtext.example.mydsl.bookingDSL.*;
import java.util.ArrayList

class UpdateRequestModelGenerator {
	static def void generateRequestModelsFile(IFileSystemAccess2 fsa,
		Resource resource)
	{
		var systemName = resource.allContents.toList.filter(System).get(0).getName();
		for(dec : resource.allContents.toList.filter(Declaration)){
			genFile(fsa, dec, systemName, dec.name)
		}
	}
	
	private static def dispatch void genFile(IFileSystemAccess2 fsa,
		Customer cust, String systemName, String name){
		fsa.generateFile('''«systemName»/«systemName»/RequestModels/Update«name»RequestModels.cs''', 
		'''
		using «systemName».Persistence.Models;
		using System.Collections.Generic;
		using System;
				
		namespace «systemName».RequestModels
		{
			«IF(cust.superType !== null)»
			public class Update«name»RequestModel : Update«cust.superType.name»RequestModel
			{
		    «ENDIF»
		    «IF (cust.superType === null) »
		    public class Update«name»RequestModel
		    {
		    public Guid Id {get; set;}
		    «ENDIF»
				«FOR mem : cust.members»
				«attribute(mem)»
				«ENDFOR»
		    }
		}
		''')	
	}
	
	private static def dispatch void genFile(IFileSystemAccess2 fsa,
		Declaration dec, String systemName, String name){
		fsa.generateFile('''«systemName»/«systemName»/RequestModels/Update«name»RequestModels.cs''', 
		'''
		using «systemName».Persistence.Models;
		using System.Collections.Generic;
		using System;
				
		namespace «systemName».RequestModels
		{
		    public class Update«name»RequestModel
		    {
		    	public Guid Id {get; set;}
		        «FOR mem : dec.members»
		        «attribute(mem)»
		        «ENDFOR»
		    }
		}
		''')	
	}
	
	private static def dispatch void genFile(IFileSystemAccess2 fsa,
		org.xtext.example.mydsl.bookingDSL.Resource resource, String systemName, String name){
		fsa.generateFile('''«systemName»/«systemName»/RequestModels/Update«name»RequestModels.cs''', 
		'''
		using «systemName».Persistence.Models;
		using System.Collections.Generic;
		using System;
		
		namespace «systemName».RequestModels
		{
			«IF(resource.superType === null)»
			public class Update«name»RequestModel
			{
			public Guid Id {get; set;}
		    «ENDIF»
		    «IF(resource.superType !== null)»
		    public class Update«name»RequestModel : Update«resource.superType.name»RequestModel
		    {
		    «ENDIF»
		        «FOR mem : resource.members»
		        «attribute(mem)»
		        «ENDFOR»
		    }
		}
		''')
	}
	
	static def dispatch attribute(Attribute att){
		return '''
		public «att.array ? '''List<«att.type»>''' : att.type» «att.name» {get; set;}
		'''
	}
	
	static def dispatch attribute(Relation re){
		return '''
		public «re.plurality.equals("one") ? re.relationType.name : '''List<«re.relationType.name»>'''» «re.name» {get; set;} 
		'''
	}
}