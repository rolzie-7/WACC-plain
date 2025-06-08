package wacc

import ast.{Ident}
import SemanticTypes._

object ErrorCollector {
  private var errors: List[Errors.Error] = List()
  private var currentFile: Option[String] = None
  
  def setCurrentFile(file: String): Unit = {
    currentFile = Some(file)
  }
  
  def addError(error: Errors.Error): Unit = {
    errors = error :: errors
  }
  
  def hasErrors: Boolean = errors.nonEmpty
  
  def clear(): Unit = {
    errors = List()
    currentFile = None
  }
  
  def getErrors: List[Errors.Error] = errors.reverse

  def formatErrors(): String = {
    val sb = new StringBuilder()
    currentFile match {
      case Some(file) =>
        val fileLines = scala.io.Source.fromFile(file).getLines().toVector
        errors.reverse.foreach { error =>
          sb.append(s"${error.errorType} in ${file.split("/").last} at position (${error.line}, ${error.column}):\n")
          
          if (error.line > 0 && error.line <= fileLines.length) {
            val lineNumWidth = error.line.toString.length
            for (i <- (error.line - 1) to (error.line + 1) if i > 0 && i <= fileLines.length) {
              sb.append(f"$i%d: |${fileLines(i - 1)}\n")
              if (i == error.line) {
                sb.append(" " * (lineNumWidth + 2) + "|" + " " * (error.column - 1) + "^\n")
              }
            }
          }
          error.log.split("\n").foreach(line => sb.append(s"$line\n"))
          sb.append("\n")
        }
      case None =>
        errors.reverse.foreach { error =>
          sb.append(s"${error.errorType}: ${error.log}\n")
          sb.append(s"at position (${error.line}, ${error.column})\n\n")
        }
    }
    sb.toString()
  }

  def printErrors(): Unit = print(formatErrors())
}

object Errors {
  sealed trait Error {
    val errorType: String
    val log: String
    val exitStatus: Int
    val line: Int
    val column: Int
    
    private def formatPosition: String = s"at line $line, column $column"
    
    def fullLog: String = s"$log\n    ${formatPosition}".replaceAll("\n", "\n  ")
    
    def printErrorMessage(): Unit = 
      println(s"$errorType: ${fullLog}")
  }

  trait PositionedError extends Error {
    def pos: (Int, Int)
    override val line: Int = pos._1
    override val column: Int = pos._2
  }

  case class SyntaxError(msg: String) extends Error {
    override val errorType: String = "Syntax Error"
    override val log: String = msg
    override val line: Int = 0
    override val column: Int = 0
    override val exitStatus: Int = 100
  }

  sealed trait SemanticError extends Error {
    override val errorType: String = "Semantic Error"
    override val exitStatus: Int = 200
  }

  private def formatDetails(details: (String, String)*): String = 
    details.map { case (k, v) => f"    $k%-14s $v" }.mkString("\n")

  private def typeErrorLog(desc: String, expected: Set[SemanticType], found: Set[SemanticType]) = 
    s"""$desc type mismatch
       |${formatDetails(
         "Expected:" -> expected.mkString(" | "), 
         "Received:" -> found.mkString(" | "))
       }""".stripMargin

  private def identErrorLog(entity: String, ident: String) = 
    s"""${entity.capitalize} '$ident' is undefined"""


  case class TypeError(
    description: String,
    expected: Set[SemanticType],
    found: Set[SemanticType],
    pos: (Int, Int)
  ) extends SemanticError with PositionedError {
    override val errorType = "Type Error"
    override val log: String = typeErrorLog(description, expected, found)
  }

  case class UndefinedFunctionError(ident: String, pos: (Int, Int)) extends SemanticError with PositionedError {
    override val errorType = "Undefined Function Error"
    override val log: String = identErrorLog("function", ident)
  }

  case class UndeclaredIdentifierError(ident: String, pos: (Int, Int)) extends SemanticError with PositionedError {
    override val errorType = "Undeclared Identifier Error"
    override val log: String = identErrorLog("identifier", ident)
  }

  case class IllegalUsedFunctionOnNonPairTypeError(
    func: String, 
    pos: (Int, Int)
  ) extends SemanticError with PositionedError {
    override val errorType = "Invalid Function Application"
    override val log = 
      s"""Pair operation on non-pair type
         |${formatDetails(
           "Function:" -> func,
           "Required type:" -> "Pair"
         )}""".stripMargin
  }

  case class NumOfArgumentsError(
    ident: Ident,
    expected: Int,
    found: Int,
    pos: (Int, Int)
  ) extends SemanticError with PositionedError {
    override val errorType = "Argument Count Mismatch"
    override val log = 
      s"""Invalid number of arguments
         |${formatDetails(
           "Function:" -> ident.name,
           "Expected:" -> expected.toString,
           "Received:" -> found.toString)
         }""".stripMargin
  }

  case class ScopeError(place: String, pos: (Int, Int)) extends SemanticError with PositionedError {
    override val errorType = "Invalid Return Context"
    override val log = 
      s"""Return statement in invalid context
         |${formatDetails(
           "Location:" -> place
         )}""".stripMargin
  }

  case class ArrayOutOfBoundsError(
    ident: Ident,
    max: Int,
    found: Int,
    pos: (Int, Int)
  ) extends SemanticError with PositionedError {
    override val errorType = "Array Bounds Exceeded"
    override val log = 
      s"""Invalid array access
         |${formatDetails(
           "Array:" -> ident.name,
           "Maximum index:" -> (max - 1).toString,
           "Attempted index:" -> found.toString)
         }""".stripMargin
  }

  case class MultipleTypesInArrayError(pos: (Int, Int)) extends SemanticError with PositionedError {
    override val errorType = "Array Type Inconsistency"
    override val log = 
      """Invalid array initialization
        |    All elements must share the same type""".stripMargin
  }

  case class ArrayDimensionalError(length: Int, dimensions: Int, pos: (Int, Int)) extends SemanticError with PositionedError {
    override val errorType = "Array Dimension Mismatch"
    override val log = 
      s"""Invalid array dimensions
         |${formatDetails(
           "Required minimum dimensions:" -> dimensions.toString,
           "Received dimensions:" -> length.toString
         )}""".stripMargin
  }

  case class ArrayTypeError(
    arrayName: String,
    pos: (Int, Int)
  ) extends SemanticError with PositionedError {
    override val errorType = "Invalid Array Type"
    override val log = 
      s"""Invalid array access
         |${formatDetails(
           "Array:" -> arrayName,
           "Error:" -> "Not an array type"
         )}""".stripMargin
  }

  case class UndefinedError(pos: (Int, Int)) extends SemanticError with PositionedError {
    override val errorType = "Undefined Behavior"
    override val log = 
      """Operation results in undefined behavior
        |    Cannot guarantee program correctness""".stripMargin
  }

  case class CastingError(
    strong: SemanticType, 
    weak: SemanticType, 
    pos: (Int, Int)
  ) extends SemanticError with PositionedError {
    override val errorType = "Invalid Type Conversion"
    override val log = 
      s"""Illegal type assignment
         |${formatDetails(
           "Stronger type:" -> strong.toString,
           "Weaker type:" -> weak.toString
         )}""".stripMargin
  }

  case class FreeingError(pos: (Int, Int)) extends SemanticError with PositionedError {
    override val errorType = "Invalid Memory Operation"
    override val log = 
      """Attempt to free invalid memory
        |    Target is not heap-allocated""".stripMargin
  }

  case class InvalidPairOperationError(
    operation: String,
    foundType: SemanticType,
    pos: (Int, Int)
  ) extends SemanticError with PositionedError {
    override val errorType = "Invalid Pair Operation"
    override val log = 
      s"""Invalid pair operation
         |${formatDetails(
           "Operation:" -> operation,
           "Found type:" -> foundType.toString,
           "Required:" -> "Pair type"
         )}""".stripMargin
  }

  case class InvalidConditionError(
    statement: String,
    foundType: SemanticType,
    pos: (Int, Int)
  ) extends SemanticError with PositionedError {
    override val errorType = "Invalid Condition Type"
    override val log = 
      s"""Invalid condition type
         |${formatDetails(
           "Statement:" -> statement,
           "Found type:" -> foundType.toString,
           "Required:" -> "Bool"
         )}""".stripMargin
  }

  case class InvalidOperandError(
    operator: String,
    expected: SemanticType,
    found: SemanticType,
    pos: (Int, Int)
  ) extends SemanticError with PositionedError {
    override val errorType = "Invalid Operand Type"
    override val log = 
      s"""Invalid operand type for operator
         |${formatDetails(
           "Operator:" -> operator,
           "Expected:" -> expected.toString,
           "Found:" -> found.toString
         )}""".stripMargin
  }

  case class InvalidPairElementError(
    operation: String,
    foundType: SemanticType,
    pos: (Int, Int)
  ) extends SemanticError with PositionedError {
    override val errorType = "Invalid Pair Element Access"
    override val log = 
      s"""Invalid pair element access
         |${formatDetails(
           "Operation:" -> operation,
           "Found type:" -> foundType.toString,
           "Required:" -> "Pair type"
         )}""".stripMargin
  }

  case class FunctionRedefinitionError(ident: String, pos: (Int, Int)) extends SemanticError with PositionedError {
    override val errorType = "Function Redefinition Error"
    override val log: String = s"Function '$ident' is already defined"
  }

  case class RedeclarationError(ident: String, pos: (Int, Int)) extends SemanticError with PositionedError {
    override val errorType = "Redeclaration Error"
    override val log: String = s"Identifier '$ident' is already defined"
  }
}
