package wacc.backEnd

import wacc.ast._
import scala.language.implicitConversions
import TACTypes._
import wacc.SemanticTypes
import scala.collection.mutable
import wacc.backEnd.Constants._

object TACTypes {
  sealed trait TACType
  
  // Primitive types
  case object TACInt extends TACType
  case object TACBool extends TACType  
  case object TACChar extends TACType
  case object TACString extends TACType
  
  // Reference types with type information
  case class TACArray(elemType: TACType, length: Option[Int] = None) extends TACType
  case class TACPair(fstType: TACType, sndType: TACType) extends TACType
  
  // Special types
  case object TACAny extends TACType   // For unknown/polymorphic types
  case object TACVoid extends TACType  // For functions with no return value
  case class TACDebug(msg: String) extends TACType
  
  // Type conversion function
  implicit def fromASTType(astType: wacc.ast.Types.Type): TACType = astType match {
    case wacc.ast.Types.IntType(_) => TACInt
    case wacc.ast.Types.BoolType(_) => TACBool
    case wacc.ast.Types.CharType(_) => TACChar
    case wacc.ast.Types.StringType(_) => TACString
    case wacc.ast.Types.ArrayType(elemType) => TACArray(elemType, None)
    case wacc.ast.Types.PairType(fst, snd) => TACPair(fst, snd)
    case wacc.ast.Types.PairElemType1(_) => TACPair(TACAny, TACAny)
    case wacc.ast.Types.PairElemType2(innerType) => innerType
  }

  implicit def fromSemanticType(semanticType: wacc.SemanticType): TACType = semanticType match {
    case SemanticTypes.IntT => TACInt
    case SemanticTypes.BoolT => TACBool
    case SemanticTypes.CharT => TACChar
    case SemanticTypes.StringT => TACString
    case SemanticTypes.ArrayT(elemType) => TACArray(elemType, None)
    case SemanticTypes.PairT(fst, snd) => TACPair(fst, snd)
    case wacc.Any => TACAny
    case SemanticTypes.Nothing => TACVoid
    case SemanticTypes.DebugT(msg) => TACDebug(msg)
  }
}

// Register allocation classes
sealed trait Location {
  def toString: String
}
case class Register(name: String, index: Int) extends Location {
  override def toString: String = name
}
case class StackLocation(offset: Int) extends Location {
  override def toString: String = s"[fp, #$offset]"
}

case class PushRegisters(registers: List[Register]) extends TACInstruction
case class PopRegisters(registers: List[Register]) extends TACInstruction

object RegisterAllocator {
  // Valid ARM registers - enforces exact representation
  val validRegisters = (INITIAL_COUNTER_VALUE to PC_REGISTER_INDEX).map(i => Register(s"r$i", i)).toArray
  val r0 = validRegisters(R0_INDEX)
  val r1 = validRegisters(R1_INDEX)
  val r2 = validRegisters(R2_INDEX)
  val r3 = validRegisters(R3_INDEX)
  val r4 = validRegisters(TEMP_REG_INDEX)
  val r5 = validRegisters(PRESERVE_REG_INDEX)
  val r6 = validRegisters(R6_INDEX)
  val r7 = validRegisters(R7_INDEX)
  val r8 = validRegisters(R8_INDEX)
  val r9 = validRegisters(R9_INDEX)
  val r10 = validRegisters(GLOBAL_ACCESS_REG_INDEX)
  
  // Define special purpose registers that should not be allocated
  val FP = validRegisters(FP_REGISTER_INDEX) // r11 - Frame Pointer
  val IP = validRegisters(IP_REGISTER_INDEX) // r12 - Intra-Procedure call scratch register
  val SP = validRegisters(SP_REGISTER_INDEX) // r13 - Stack Pointer
  val LR = validRegisters(LR_REGISTER_INDEX) // r14 - Link Register
  val PC = validRegisters(PC_REGISTER_INDEX) // r15 - Program Counter
  
  // List of registers that should never be allocated for general purpose use
  val specialRegisters = Set(FP_REGISTER_INDEX, IP_REGISTER_INDEX, SP_REGISTER_INDEX, LR_REGISTER_INDEX, PC_REGISTER_INDEX)
  
  // Register allocation pools - only use safe registers
  val argRegs = List(r0, r1, r2, r3)
  val callerSaved = List(r0, r1, r2, r3)
  val calleeSaved = List(r4, r5, r6, r7, r8, r9, r10)
  
  // All registers available for general allocation (r0-r10)
  val allocatableRegisters = (INITIAL_COUNTER_VALUE to GLOBAL_ACCESS_REG_INDEX).map(validRegisters(_)).toList
  
  private var tempCounter = INITIAL_COUNTER_VALUE
  private var usedRegisters = Map[String, RegisterVar]()
  private var nextStackOffset = INITIAL_STACK_OFFSET
  
  // Liveness tracking
  private val liveVariables = mutable.Set[String]()
  
  def reset(): Unit = {
    tempCounter = INITIAL_COUNTER_VALUE
    usedRegisters = Map()
    nextStackOffset = INITIAL_STACK_OFFSET
    liveVariables.clear()
  }
  
  // Mark a variable as live (still needed for future operations)
  def markLive(variable: Variable): Unit = {
    variable match {
      case RegisterVar(name, _, _) => liveVariables += name
      case Var(name, _) => liveVariables += name
    }
  }
  
  // Mark a variable as dead (no longer needed)
  def markDead(variable: Variable): Unit = {
    variable match {
      case RegisterVar(name, _, location) => 
        liveVariables -= name
        location match {
          case reg: Register => usedRegisters.get(reg.name).foreach { regVar =>
            if (regVar.name == name) {
              usedRegisters -= reg.name
            }
          }
          case _ => // Do nothing for stack locations
        }
      case Var(name, _) => 
        liveVariables -= name
    }
  }
  
  // Check if a register is holding a live variable
  def isRegisterLive(reg: Register): Boolean = {
    usedRegisters.get(reg.name).exists(regVar => liveVariables.contains(regVar.name))
  }
  
  def allocateRegister(tacType: TACTypes.TACType): RegisterVar = {
    // Find first available register that isn't holding a live variable
    allocatableRegisters.find(reg => !usedRegisters.contains(reg.name) || !isRegisterLive(reg)) match {
      case Some(reg) => 
        allocateSpecificRegister(tacType, reg)
      case None =>
        // All registers are live, need to spill one to stack
        val name = s"t$tempCounter"
        tempCounter += 1
        
        // Find a register to spill - prefer r0 if not live, otherwise find the "least valuable" register
        val regToSpill = if (!isRegisterLive(r0)) r0 else {
          // Simple heuristic - use the first register in the list
          // In a real implementation, you'd use more sophisticated heuristics
          allocatableRegisters.find(r => !specialRegisters.contains(r.index)).getOrElse(r0)
        }
        
        // Spill the old value if it's live
        if (isRegisterLive(regToSpill)) {
          // This would involve generating stack spill instructions
          // For now, we'll just track that the register is reused
          nextStackOffset -= WORD_SIZE
          // We'd generate a store instruction here
        }
        
        // Update register mapping
        usedRegisters -= regToSpill.name
        
        // Create new register var
        val regVar = RegisterVar(name, tacType, regToSpill)
        usedRegisters += (regToSpill.name -> regVar)
        regVar
    }
  }
  
  def allocateSpecificRegister(tacType: TACTypes.TACType, reg: Register): RegisterVar = {
    // Validate register is a legal ARM register for allocation
    val validReg = validateRegister(reg)
    
    val name = s"t$tempCounter"
    tempCounter += 1
    
    // Check if register is already in use and holding a live variable
    usedRegisters.get(validReg.name) match {
      case Some(oldVar) if liveVariables.contains(oldVar.name) => 
        // Register in use by live variable - need to spill
        nextStackOffset -= WORD_SIZE
        // In real implementation, generate spill code here
        
        // Update register mapping
        usedRegisters -= validReg.name
        
        // Create new register var
        val regVar = RegisterVar(name, tacType, validReg)
        usedRegisters += (validReg.name -> regVar)
        regVar
      case Some(_) =>
        // Register in use but variable is dead, can reuse
        usedRegisters -= validReg.name
        val regVar = RegisterVar(name, tacType, validReg)
        usedRegisters += (validReg.name -> regVar)
        regVar
      case None =>
        // Register available
        val regVar = RegisterVar(name, tacType, validReg)
        usedRegisters += (validReg.name -> regVar)
        regVar
    }
  }

  def forceAllocateSpecificRegister(tacType: TACTypes.TACType, reg: Register): RegisterVar = {
    val validReg = validateRegister(reg)
    
    val name = s"t$tempCounter"
    tempCounter += 1

    usedRegisters.get(validReg.name) match {
      case Some(_) =>
        // Register in use but variable is dead, can reuse
        usedRegisters -= validReg.name
        val regVar = RegisterVar(name, tacType, validReg)
        usedRegisters += (validReg.name -> regVar)
        regVar
      case None =>
        // Register available
        val regVar = RegisterVar(name, tacType, validReg)
        usedRegisters += (validReg.name -> regVar)
        regVar
    }
  }
  
  def freeRegister(regVar: RegisterVar): Unit = {
    markDead(regVar)
  }
  
  def getStackSize(): Int = -nextStackOffset - WORD_SIZE
  
  // Validation method to ensure only proper registers are used
  def validateRegister(reg: Register): Register = {
    // Don't allow allocation of special registers
    if (specialRegisters.contains(reg.index)) {
      throw new IllegalArgumentException(
        s"Cannot allocate special register r${reg.index}. Use only r0-r10 for general purpose."
      )
    }
    reg
  }
}

sealed trait TACInstruction

sealed trait Variable {
  def name: String
  def tacType: TACTypes.TACType
}
case class Var(override val name: String, override val tacType: TACTypes.TACType) extends Variable
case class RegisterVar(override val name: String, override val tacType: TACTypes.TACType, location: Location) extends Variable {
  override def toString: String = s"$name:$location"
}

// Keep TempVar for backward compatibility, but implement using RegisterVar
object TempVarGenerator {
  def reset(): Unit = {
    RegisterAllocator.reset()
  }

  def generateTempVar(tacType: TACTypes.TACType): Variable = {
    RegisterAllocator.allocateRegister(tacType)
  }
}

case class TACLabel(name: String) extends TACInstruction
case class Block(label: TACLabel, instructions: List[TACInstruction]) extends TACInstruction
case class TACAssign(lhs: Variable, rhs: Variable) extends TACInstruction

case class ArrayAccess(array: Variable, index: Expr, result: Variable) extends TACInstruction
case class ArrayStore(array: Variable, indices: List[Expr], value: Variable) extends TACInstruction

case class FstStore(pair: Variable, value: Variable) extends TACInstruction
case class SndStore(pair: Variable, value: Variable) extends TACInstruction

case class FstAccess(pair: Variable, dest: Variable) extends TACInstruction
case class SndAccess(pair: Variable, dest: Variable) extends TACInstruction

case class IntLiteral(value: BigInt, dest: Variable) extends TACInstruction
case class BoolLiteral(value: Boolean, dest: Variable) extends TACInstruction
case class CharLiteral(value: Char, dest: Variable) extends TACInstruction
case class StringLiteral(value: String, dest: Variable) extends TACInstruction
case class ArrayLiteral(elements: List[Expr], dest: Variable) extends TACInstruction
case class NullPairLiteral(dest: Variable) extends TACInstruction

// Binary Operations
sealed trait TACBinaryOp
case object TACAdd extends TACBinaryOp
case object TACSubtract extends TACBinaryOp
case object TACMultiply extends TACBinaryOp
case object TACDivide extends TACBinaryOp
case object TACMod extends TACBinaryOp
case object TACGreaterThan extends TACBinaryOp
case object TACGreaterEqualThan extends TACBinaryOp
case object TACLessThan extends TACBinaryOp
case object TACLessEqualThan extends TACBinaryOp
case object TACEqual extends TACBinaryOp
case object TACNotEqual extends TACBinaryOp
case object TACAnd extends TACBinaryOp
case object TACOr extends TACBinaryOp

// Unary Operations
sealed trait TACUnaryOp
case object TACNeg extends TACUnaryOp
case object TACNot extends TACUnaryOp
case object TACLen extends TACUnaryOp
case object TACOrd extends TACUnaryOp
case object TACChr extends TACUnaryOp

case class BinaryOperation(op: TACBinaryOp, left: Variable, right: Variable, dest: Variable) extends TACInstruction
case class UnaryOperation(op: TACUnaryOp, expr: Variable, dest: Variable) extends TACInstruction

// Memory Operations
case class NewArray(size: Variable, dest: Variable) extends TACInstruction
case class NewPairAlloc(fst: Variable, snd: Variable, dest: Variable) extends TACInstruction

// Control Flow
case class Jump(label: String) extends TACInstruction
case class JumpIfZero(cond: Variable, label: String) extends TACInstruction
case class CallInst(func: String, args: List[Variable], dest: Variable) extends TACInstruction
case class ReturnInst(expr: Variable) extends TACInstruction

// I/O Operations
case class PrintInst(value: Variable, isLn: Boolean = false) extends TACInstruction
case class ReadInst(dest: Variable) extends TACInstruction

// Runtime
case class FreeInst(expr: Variable) extends TACInstruction
case class ExitInst(code: Variable) extends TACInstruction


case object NOP extends TACInstruction
case class LoadAddress(dest: Variable, address: Variable) extends TACInstruction
case class LoadContent(dest: Variable, address: Variable, size: Int) extends TACInstruction
case class StoreContent(address: Variable, value: Variable, size: Int) extends TACInstruction
case class BoundsCheck(index: Variable, size: Variable) extends TACInstruction
case class NullCheck(ref: Variable) extends TACInstruction
case class OverflowCheck() extends TACInstruction


object TACFormatter {
  private def formatAssignment(dest: String, value: String): String = s"$dest = $value"
  private def formatFunction(name: String, args: String): String = s"$name($args)"
  
  def formatInstruction(instr: TACInstruction): String = instr match {
    // Control flow
    case TACLabel(name) => s"$name:"
    case Block(label, instructions) => s"${formatInstruction(label)} ${instructions.map(formatInstruction).mkString("\n")}"
    case Jump(label) => s"jump $label"
    case JumpIfZero(cond, label) => s"if ${formatVariable(cond)} == ${BOOL_FALSE} jump $label"
    
    // Assignment & operations
    case TACAssign(lhs, rhs) => 
      formatAssignment(formatVariable(lhs), formatVariable(rhs))
      
    case BinaryOperation(op, left, right, dest) => 
      formatAssignment(
        formatVariable(dest), 
        s"${formatVariable(left)} ${formatBinaryOp(op)} ${formatVariable(right)}"
      )
      
    case UnaryOperation(op, expr, dest) => 
      formatAssignment(
        formatVariable(dest), 
        s"${formatUnaryOp(op)}${formatVariable(expr)}"
      )
    
    // Memory operations
    case LoadAddress(dest, address) => 
      formatAssignment(formatVariable(dest), s"&${formatVariable(address)}")
      
    case LoadContent(dest, address, size) => 
      formatAssignment(formatVariable(dest), s"*${formatVariable(address)}[$size]")
      
    case StoreContent(address, value, size) => 
      s"*${formatVariable(address)}[$size] = ${formatVariable(value)}"
    
    // Array operations
    case ArrayAccess(array, index, result) => 
      formatAssignment(formatVariable(result), s"${formatVariable(array)}[${index.toString}]")
      
    case ArrayStore(array, indices, value) => 
      s"${formatVariable(array)}[${indices.mkString(",")}] = ${formatVariable(value)}"
    
    // Pair operations
    case FstAccess(pair, dest) => 
      formatAssignment(formatVariable(dest), formatFunction("fst", formatVariable(pair)))
      
    case SndAccess(pair, dest) => 
      formatAssignment(formatVariable(dest), formatFunction("snd", formatVariable(pair)))
      
    case FstStore(pair, value) => 
      s"fst(${formatVariable(pair)}) = ${formatVariable(value)}"
      
    case SndStore(pair, value) => 
      s"snd(${formatVariable(pair)}) = ${formatVariable(value)}"
    
    // Literals
    case IntLiteral(value, dest) => formatAssignment(formatVariable(dest), value.toString)
    case BoolLiteral(value, dest) => formatAssignment(formatVariable(dest), value.toString)
    case CharLiteral(value, dest) => formatAssignment(formatVariable(dest), s"'${escapeChar(value)}'")
    case StringLiteral(value, dest) => formatAssignment(formatVariable(dest), s"\"${escapeString(value)}\"")
    case ArrayLiteral(elements, dest) => formatAssignment(formatVariable(dest), s"[${elements.mkString(", ")}]")
    case NullPairLiteral(dest) => formatAssignment(formatVariable(dest), "null")
    
    // Function calls
    case CallInst(func, args, dest) => 
      formatAssignment(
        formatVariable(dest), 
        formatFunction("call " + func, args.map(formatVariable).mkString(", "))
      )
      
    case ReturnInst(expr) => s"return ${formatVariable(expr)}"
    
    // I/O
    case PrintInst(value, isLn) => 
      if (isLn) s"println ${formatVariable(value)}" else s"print ${formatVariable(value)}"
      
    case ReadInst(dest) => s"read ${formatVariable(dest)}"
    
    // Runtime checks
    case BoundsCheck(index, size) => formatFunction("boundsCheck", s"${formatVariable(index)}, ${formatVariable(size)}")
    case NullCheck(ref) => formatFunction("nullCheck", formatVariable(ref))
    case OverflowCheck() => "overflowCheck()"
    
    // Other
    case FreeInst(expr) => formatFunction("free", formatVariable(expr))
    case ExitInst(code) => formatFunction("exit", formatVariable(code))
    case NOP => "nop"
    
    case _ => instr.toString
  }
  
  private def formatVariable(variable: Variable): String = variable match {
    case Var(name, _) => name
    case RegisterVar(name, _, location) => s"$name:$location"
  }
  
  private def formatBinaryOp(op: TACBinaryOp): String = op match {
    case TACAdd => "+"
    case TACSubtract => "-"  
    case TACMultiply => "*"
    case TACDivide => "/"
    case TACMod => "%"
    case TACGreaterThan => ">"
    case TACGreaterEqualThan => ">="
    case TACLessThan => "<"
    case TACLessEqualThan => "<="
    case TACEqual => "=="
    case TACNotEqual => "!="
    case TACAnd => "&&"
    case TACOr => "||"
  }
  
  private def formatUnaryOp(op: TACUnaryOp): String = op match {
    case TACNeg => "-"
    case TACNot => "!"
    case TACLen => "len "
    case TACOrd => "ord "
    case TACChr => "chr "
  }
  
  private def escapeChar(c: Char): String = c match {
    case '\n' => "\\n"
    case '\t' => "\\t"
    case '\r' => "\\r"
    case NULL_CHAR => "\\0"
    case '\\' => "\\\\"
    case '\'' => "\\'"
    case '\"' => "\\\""
    case ')' => ")" 
    case '(' => "("
    case c if c.isControl => s"\\u${c.toInt.toHexString.toUpperCase.padTo(UNICODE_HEX_PADDING, '0')}"
    case _ => c.toString
  }
  
  private def escapeString(s: String): String = s.flatMap(c => escapeChar(c))
    
  // Utility to format a whole program
  def formatProgram(instructions: List[TACInstruction]): String = {
    instructions.map(formatInstruction).mkString("\n")
  }
}


  // Name mangling for functions to avoid namespace clashes
  private def mangleFunctionName(name: String, params: List[Variable] = List()): String = {
    // Simple mangling: prefix with _wacc_ and append parameter type hints
    val paramTypeStr = params.map(p => tacTypeToMangledString(p.tacType)).mkString("")
    s"_wacc_${name}_$paramTypeStr"
  }

  // Helper for type representation in mangled names
  private def tacTypeToMangledString(tacType: TACTypes.TACType): String = tacType match {
    case TACInt => "i"
    case TACBool => "b"
    case TACChar => "c"
    case TACString => "s"
    case TACArray(elemType, _) => s"a${tacTypeToMangledString(elemType)}"
    case TACPair(fst, snd) => s"p${tacTypeToMangledString(fst)}${tacTypeToMangledString(snd)}"
    case _ => "x" // Unknown type
  }