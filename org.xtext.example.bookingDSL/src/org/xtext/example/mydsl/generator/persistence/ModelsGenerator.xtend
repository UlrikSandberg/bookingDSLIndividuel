package org.xtext.example.mydsl.generator.persistence

import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.emf.ecore.resource.Resource
import org.xtext.example.mydsl.bookingDSL.*;

class ModelsGenerator {
	static def void generateModels(IFileSystemAccess2 fsa,
		Resource resource)
	{
		var systemName = resource.allContents.toList.filter(System).get(0).getName();
		var declarations = resource.allContents.toList.filter(Declaration);
		for(dec : declarations){
			genFile(fsa, dec, systemName)
		}
		
		fsa.generateFile('''«systemName»/«systemName»/Persistence/Models/IEntity.cs''', 
			'''
			using System;
			using System.Collections.Generic;
			
			namespace «systemName».Persistence.Models
			{
			    public interface IEntity
			    {
			        Guid Id { get; }
			    }
			}
			''')
	}
	
	static def dispatch void genFile(IFileSystemAccess2 fsa, Customer cust, String systemName){
		var name = cust.name
		fsa.generateFile('''«systemName»/«systemName»/Persistence/Models/«name».cs''', 
			'''
			using System;
			using System.Collections.Generic;
			
			namespace «systemName».Persistence.Models
			{
				«IF(cust.superType === null)»
				public class «name» : IEntity
				{
					public Guid Id {get; set;}
			    «ELSE»
				public class «name» : «cust.superType.name», IEntity
				{
			    «ENDIF»
			        «FOR mem : cust.members»
			        «attribute(mem)»
			        «ENDFOR»
			    }
			}
			''')
	}
	
	static def dispatch void genFile(IFileSystemAccess2 fsa, org.xtext.example.mydsl.bookingDSL.Resource res, String systemName){
		var name = res.name
		fsa.generateFile('''«systemName»/«systemName»/Persistence/Models/«name».cs''', 
			'''
			using System;
			using System.Collections.Generic;
			
			namespace «systemName».Persistence.Models
			{
				«IF(res.superType === null)»
				public class «name» : IEntity
				{
					public Guid Id {get; set;}
			    «ELSE»
				public class «name» : «res.superType.name», IEntity
				{
			    «ENDIF»
			        «FOR mem : res.members»
			        «attribute(mem)»
			        «ENDFOR»
			    }
			}
			''')
	}
	
	static def dispatch void genFile(IFileSystemAccess2 fsa, Declaration dec, String systemName){
		fsa.generateFile('''«systemName»/«systemName»/Persistence/Models/«dec.name».cs''', 
			'''
			using System;
			using System.Collections.Generic;
			
			namespace «systemName».Persistence.Models
			{
			    public class «dec.name» : IEntity
			    {
			    	public Guid Id {get; set;}
			        «FOR mem : dec.members»
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