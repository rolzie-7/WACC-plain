package wacc

import scala.collection.mutable.Map
import ast.Functions.ParamList
import SemanticTypes._
import wacc.backEnd.Location
import wacc.ast._

object SymbolTable {
  var counter = 0

  case class FunctionInfo(val returnType: SemanticType, val params: ParamList)

  case class VariableInfo(
      val semanticType: SemanticType,
      var location: Option[Location] = None,
      var isLive: Boolean = false,
      var constantValue: Option[Rvalue] = None, // add this for constant folding
      var value: Option[Any] = None // added this for runtime values
  )

  private val functionTable: Map[String, FunctionInfo] =
    Map.empty[String, FunctionInfo]

  def getCurrentScope: Scope = currentScope // Add this public getter

  def addFunction(
      name: String,
      returnType: SemanticType,
      params: ParamList
  ): Unit = {
    functionTable += (name -> FunctionInfo(returnType, params))
  }

  def functionLookup(name: String): Option[FunctionInfo] =
    functionTable.get(name)

  private val globalTable: Map[String, VariableInfo] =
    Map.empty[String, VariableInfo]

  class Scope(val parent: Option[Scope] = None) {
    // private val table: Map[String, SemanticType] = Map.empty[String, SemanticType]
    private var returnType: Option[SemanticType] = None
    val scopeId: Int = counter
    counter += 1

    def add(name: String, t: SemanticType): Unit = {
      globalTable += ((name + scopeId.toString) -> VariableInfo(t))
    }

    def set(name: String, t: SemanticType, value: Option[Expr] = None): Unit = {
      // require that the variable is already in the table
      if (globalTable.contains(name + scopeId.toString)) {
        globalTable.update(
          name + scopeId.toString,
          VariableInfo(t, constantValue = value)
        )
      } else
        throw new RuntimeException(s"Variable $name not found in any scope")
      // else {
      //   parent match {
      //     case Some(p) => p.set(name, t)
      //     case None => throw new RuntimeException(s"Variable $name not found in any scope")
      //   }
      // }
    }

    def localLookup(name: String): Option[SemanticType] = {
      globalTable.get(name + scopeId.toString).map(_.semanticType)
    }

    def lookup(name: String): Option[SemanticType] = {
      globalTable
        .get(name + scopeId.toString)
        .map(_.semanticType)
        .orElse(parent.flatMap(_.lookup(name)))
    }

    def lookupConstant(name: String): Option[Rvalue] = {
      var scope: Option[Scope] = Some(this)

      while (scope.isDefined) {
        val key = name + scope.get.scopeId.toString
        if (globalTable.contains(key)) {
          val result = globalTable.get(key).flatMap(_.constantValue)
          if (result.isDefined) {
            println(s"DEBUG: Found constant value for $name -> $result") // ✅ Debug log
            return result
          }
        }
        scope = scope.get.parent // Move up the scope chain
      }

      println(s"DEBUG: No constant value found for $name in any scope") // ❌ Debug log
      None
    }   


    def lookupPairElement(name: String, element: String): Option[Rvalue] = {
      val result = globalTable
        .get(name + scopeId.toString)
        .flatMap(_.constantValue) // Retrieve from stored constants
        .collect {
          case pair: Pairs.NewPair if element == "fst" =>
            println(s"DEBUG: Returning Fst of $name -> ${pair.fst}")
            pair.fst
          case pair: Pairs.NewPair if element == "snd" =>
            println(s"DEBUG: Returning Snd of $name -> ${pair.snd}")
            pair.snd
        }
        .orElse(parent.flatMap(_.lookupPairElement(name, element))) // Check parent scopes

      println(s"DEBUG: lookupPairElement($name, $element) -> $result") // Debug log
      result
    }

    
    def setRvalue(
        name: String,
        typ: SemanticType,
        value: Option[Rvalue]
    ): Unit = {
      if (globalTable.contains(name + scopeId.toString)) {
        val storedValue = value match {
          case Some(arrLit: Arrays.ArrayLit) =>
            Some(arrLit)
          case Some(pair: Pairs.NewPair) =>
            println(s"DEBUG: Storing NewPair for $name in SymbolTable -> ($pair)")
            Some(pair)  // Allow storing the whole pair
          case Some(expr: Expr) =>
            println(
              s"DEBUG: Storing Expr for $name in SymbolTable"
            ) // ✅ Debug log
            Some(expr)
          case _ =>
            println(
              s"DEBUG: No valid constant found for $name, skipping storage"
            ) // ✅ Debug log
            None
        }
        globalTable.update(
          name + scopeId.toString,
          VariableInfo(typ, constantValue = storedValue)
        )
      } else {
        throw new RuntimeException(s"Variable $name not found in scope")
      }
    }
    def setReturnType(t: SemanticType): Unit = {
      returnType = Some(t)
    }

    def getReturnType(): Option[SemanticType] = {
      returnType.orElse(parent.flatMap(_.getReturnType()))
    }

    def getTrueName(name: String): String = {
      if (globalTable.contains(name + scopeId.toString)) {
        name + scopeId.toString
      } else {
        parent match {
          case Some(p) =>
            // println(s"2. Could not find ${name} in current scope ${scopeId} with parent ${parent.map(_.scopeId).getOrElse("None")}")
            // println(s"3. but found parent with scopeid ${p.scopeId} with parent ${parent.map(_.scopeId).getOrElse("None")} and attempt to find ${name} in parent scope:")
            // println(s"4. parent scope: ${p.getTrueName(name)}")
            p.getTrueName(name)
          case None => "Undeclared variable"
        }
      }
    }
  }

  var currentScope: Scope = new Scope()

  def enterScope(): Unit = {
    currentScope = new Scope(Some(currentScope))
  }

  def isGlobalScope: Boolean = !currentScope.parent.isDefined

  def exitScope(): Unit = {
    currentScope = currentScope.parent.getOrElse(new Scope())
  }

  def clear(): Unit = {
    functionTable.clear()
    globalTable.clear()
    counter = 0
    currentScope = new Scope()
  }

  def add(name: String, t: SemanticType): Unit = {
    currentScope.add(name, t)
  }

  def set(name: String, t: SemanticType): Unit = {
    currentScope.set(name, t)
  }

  def lookup(name: String): Option[SemanticType] = {
    currentScope.lookup(name)
  }

  def localLookup(name: String): Option[SemanticType] = {
    currentScope.localLookup(name)
  }

  def getTrueName(name: String): String = {
    currentScope.getTrueName(name)
  }

  def globalLookup(name: String): Option[VariableInfo] = {
    globalTable.get(name)
  }

  def getLocation(name: String): Option[Location] = {
    globalTable
      .getOrElse(name, VariableInfo(DebugT("Variable not found")))
      .location
  }

  def updateLocation(name: String, location: Location): Unit = {
    val trueName = getTrueName(name)
    globalTable.get(trueName) match {
      case Some(varInfo) =>
        varInfo.location = Some(location)
      case None =>
      // Do nothing if variable doesn't exist
    }
  }

  def getScopeNumber(): Int = {
    currentScope.scopeId
  }

  def getReturnType(): Option[SemanticType] = currentScope.getReturnType()

  def setReturnType(t: SemanticType): Unit = currentScope.setReturnType(t)
}
