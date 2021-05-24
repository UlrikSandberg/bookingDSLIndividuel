package org.xtext.example.mydsl.generator

import org.xtext.example.mydsl.bookingDSL.Logic
import org.xtext.example.mydsl.bookingDSL.Plus
import org.xtext.example.mydsl.bookingDSL.Minus
import org.xtext.example.mydsl.bookingDSL.PrimitiveExpression
import org.xtext.example.mydsl.bookingDSL.Mult
import org.xtext.example.mydsl.bookingDSL.Div
import org.xtext.example.mydsl.bookingDSL.Var
import org.xtext.example.mydsl.bookingDSL.Expression
import org.xtext.example.mydsl.bookingDSL.Comparison
import org.xtext.example.mydsl.bookingDSL.Disjunction
import org.xtext.example.mydsl.bookingDSL.Conjunction
import org.xtext.example.mydsl.bookingDSL.PrimitiveLogic

class ExpressionGenerator {
	
	
	def static boolean completeLogic(Logic logic) {
		return computeDisjunction(logic.disjunction);
	}
	
	def static boolean computeDisjunction(Disjunction disjunction) {
		if(disjunction.right !== null) {
			return computeConjunction(disjunction.left) || computeConjunction(disjunction.right)
		} else {
			return computeConjunction(disjunction.left)
		}
	}
	
	def static boolean computeConjunction(Conjunction conjunction) {
		if(conjunction.right !== null) {
			return computePrimitiveLogic(conjunction.left) && computePrimitiveLogic(conjunction.right)
		} else {
			return computePrimitiveLogic(conjunction.left)
		}
	}
	
	def static boolean computePrimitiveLogic(PrimitiveLogic primitive) {
		if(primitive.comparison !== null) {
			return comparrison(primitive.comparison)
		}
		
		if(primitive.logic !== null) {
			return completeLogic(primitive.logic)
		}
		
		throw new Exception("Error in primitive logic")
	}
	
	
	def static boolean comparrison(Comparison comparison) {
		
		val leftResult = comparison.left.compute
		val rightResult = comparison.right.compute
		
		if(comparison.operator == "<") {
			return leftResult < rightResult
		}
		if(comparison.operator == ">") {
			return leftResult > rightResult
		}
		if(comparison.operator == "==") {
			return leftResult == rightResult
		}
		if(comparison.operator == "<=") {
			return leftResult <= rightResult
		}
		if(comparison.operator == ">=") {
			return leftResult >= rightResult
		}
		
		throw new Exception("Error in comparrison")
	}
	
	def static double compute(Expression exp) {
		switch exp {
			Plus: exp.left.compute + exp.right.compute
			Minus: exp.left.compute - exp.right.compute
			Mult: exp.left.compute * exp.right.compute
			Div: exp.left.compute / exp.right.compute
			org.xtext.example.mydsl.bookingDSL.Number: Double.valueOf(exp.value)
			Var: 0.0
			default: throw new Exception("Error in expressions")
		}
	}
}