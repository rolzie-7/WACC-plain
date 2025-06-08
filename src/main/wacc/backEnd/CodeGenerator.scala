package wacc.backEnd

import wacc.backEnd.ARMInstructions._
import scala.collection.mutable
import TACTypes._
import wacc.backEnd.Constants._

object CodeGenerator {
  private val requiredRuntimeErrors = mutable.Set[String]()
  private val requiredRuntimeFunctions = mutable.Set[String]()

  private val TEMP_REG = registers(TEMP_REG_INDEX) 
  private val PRESERVE_REG = registers(PRESERVE_REG_INDEX) 

  private def validateInstruction(inst: ARMInstruction): ARMInstruction = {
    InstructionValidator.validate(inst) match {
      case Left(error) =>
        // Log the error but return the instruction anyway - the assembler will catch it
        println(s"Warning: $error in instruction: $inst")
        inst
      case Right(_) => inst
    }
  }

  private def getAlternatePreserveRegister(
      left: Register,
      right: Register
  ): Register = {
    // If the left operand conflicts with the right, choose a different register
    if (left == right) TEMP_REG else left
  }

  def translateTACToARM(
      tacInsts: List[TACInstruction]
  ): List[ARMInstruction] = {
    tacInsts.flatMap(translateTACInst).map(validateInstruction)
  }

  def translateTACToARMOptimized(
      tacInsts: List[TACInstruction]
  ): List[ARMInstruction] = {
    val unoptimized = translateTACToARM(tacInsts)
    PeepholeOptimizer.optimize(unoptimized)
  }

  def translateTACInst(inst: TACInstruction): List[ARMInstruction] = inst match {
    case Block(label, instructions) =>
      List(Label(label.name)) ++ translateTACToARM(instructions)

    case PushRegisters(registers) => 
      List(
        Push(registers.map(r => ARMInstructions.registers(r.index)))
      )

    case PopRegisters(registers) =>
      List(
        Pop(registers.map(r => ARMInstructions.registers(r.index)))
      )

    case BinaryOperation(op, left, right, dest) =>
      val loadLeft = loadVariable(left)
      val leftReg = getRegisterForVariable(left)
      val loadRight = loadVariable(right)
      val rightReg = getRegisterForVariable(right)
      val destReg = getRegisterForVariable(dest)

      val (preserveLeft, finalLeftReg) = 
      if (isMemoryAccess(left)) {
        val chosenReg = getAlternatePreserveRegister(PRESERVE_REG, rightReg)
        (List(Mov(chosenReg, leftReg)), chosenReg)
      } else {
        (Nil, leftReg)
      }
      val operation = op match {
        case TACAdd => 
          requiredRuntimeErrors.add("msg_overflow")
          List(
            Adds(destReg, finalLeftReg, rightReg), // Use S-variant to set flags
            Cond.branch(Label("_overflow_error"), Vs) 
          )

        case TACSubtract => 
          requiredRuntimeErrors.add("msg_overflow")
          List(
            Subs(destReg, finalLeftReg, rightReg), // Use S-variant to set flags
            Cond.branch(Label("_overflow_error"), Vs) 
          )

        case TACMultiply => 
          requiredRuntimeErrors.add("msg_overflow")
          List(
            Smull(destReg, TEMP_REG, finalLeftReg, rightReg),
            Mov(PRESERVE_REG, destReg), 
            Mov(PRESERVE_REG, destReg), 
            Asr(PRESERVE_REG, PRESERVE_REG, ImmNum(SIGN_EXTENSION_SHIFT)), 
            Cmp(TEMP_REG, PRESERVE_REG),
            Cond.branch(Label("_overflow_error"), Ne) 
          )

        case TACDivide => 
          generateDivModOperation(finalLeftReg, rightReg, destReg, isDivision = true)

        case TACMod => 
          generateDivModOperation(finalLeftReg, rightReg, destReg, isDivision = false)

        case TACAnd => Cond.booleanOp(destReg, finalLeftReg, rightReg, "and")
        case TACOr => Cond.booleanOp(destReg, finalLeftReg, rightReg, "or")
        case TACGreaterThan => Cond.comparison(destReg, finalLeftReg, rightReg, ">")
        case TACGreaterEqualThan => Cond.comparison(destReg, finalLeftReg, rightReg, ">=")
        case TACLessThan => Cond.comparison(destReg, finalLeftReg, rightReg, "<")
        case TACLessEqualThan => Cond.comparison(destReg, finalLeftReg, rightReg, "<=")
        case TACEqual =>
          val preserveReg = getAlternatePreserveRegister(finalLeftReg, rightReg)
          val preservedLeft = List(Mov(preserveReg, finalLeftReg))
          val comparison = Cond.comparison(destReg, preserveReg, rightReg, "==")
          preservedLeft ++ comparison             
        case TACNotEqual => Cond.comparison(destReg, finalLeftReg, rightReg, "!=")
      }
      
      loadLeft ++ preserveLeft ++ loadRight ++ operation ++ storeVariable(dest)
      
    case UnaryOperation(op, expr, dest) =>      
      val loadSrc = loadVariable(expr)
      val srcReg = getRegisterForVariable(expr)
      val destReg = getRegisterForVariable(dest)
      
      val operation = op match {
        case TACNeg => 
          requiredRuntimeErrors.add("msg_overflow")
          List(
            RsbS(destReg, srcReg, ImmNum(BOOL_FALSE)), 
            Cond.branch(Label("_overflow_error"), Vs) 
          )

        case TACNot =>
          List(
            Cmp(srcReg, ImmNum(BOOL_FALSE)),
            Mov(destReg, ImmNum(BOOL_TRUE), Eq),
            Mov(destReg, ImmNum(BOOL_FALSE), Ne)
          )

        case TACLen => List(
          Ldr(destReg, Address(srcReg, ARRAY_LENGTH_OFFSET))
        )

        case TACOrd => List(
          Mov(destReg, srcReg)
        )
        
        case TACChr => 
          requiredRuntimeErrors.add("msg_chr_range")
          val chrCheck = List(
            Cmp(srcReg, ImmNum(MIN_CHAR_VALUE)),
            Cond.branch(Label("_chr_range_error"), Lt),
            Cmp(srcReg, ImmNum(MAX_CHAR_VALUE)),
            Cond.branch(Label("_chr_range_error"), Gt)
          )
          chrCheck ++ List(
            Mov(destReg, srcReg)
          )
      }
      
      loadSrc ++ operation ++ storeVariable(dest)
      
   
    case TACAssign(dest, src) =>
      val loadSrc = loadVariable(src)
      val srcReg = getRegisterForVariable(src)
      val destReg = getRegisterForVariable(dest)
      
      loadSrc ++ List(Mov(destReg, srcReg)) ++ storeVariable(dest)
      
    case TACLabel(label) =>
      List(ARMInstructions.Label(label))
      
    case Jump(label) =>
      List(Cond.branch(ARMInstructions.Label(label), Al))
      
    case JumpIfZero(cond, label) =>
      val loadCond = loadVariable(cond)
      val condReg = getRegisterForVariable(cond)
      
      loadCond ++ List(
        Cmp(condReg, ImmNum(BOOL_FALSE)),
        Cond.branch(ARMInstructions.Label(label), Eq)
      )
      
    case CallInst(func, args, dest) =>
      // Setup arguments - first 4 in r0-r3, rest on stack
      val argSetup = args.zipWithIndex.flatMap { case (arg, idx) =>
        val loadArg = loadVariable(arg)
        val argReg = getRegisterForVariable(arg)
        
        if (idx < MAX_REGISTER_ARGS) {
          val targetReg = idx match {
            case R0_INDEX => registers(R0_INDEX)
            case R1_INDEX => registers(R1_INDEX)
            case R2_INDEX => registers(R2_INDEX)
            case R3_INDEX => registers(R3_INDEX)
          }
          loadArg ++ List(Mov(targetReg, argReg))
        } else {
          // Push remaining args on stack
          loadArg ++ List(Push(Seq(argReg)))
        }
      }
      
      val destReg = getRegisterForVariable(dest)
      
      argSetup ++ List(
        Cond.branchLink(ARMInstructions.Label(func), Al),
        Mov(destReg, registers(R0_INDEX))
      ) ++ storeVariable(dest)
      
    case ReturnInst(expr) =>
      val loadExpr = loadVariable(expr)
      val exprReg = getRegisterForVariable(expr)
      
      loadExpr ++ List(
        Mov(registers(R0_INDEX), exprReg),
        // Epilogue - restore frame and return
        Mov(SP, FP, Al),
        Pop(List(FP, PC))
      )
      
    case IntLiteral(value, dest) =>
      val destReg = getRegisterForVariable(dest)
      val loadInst = if (value >= MIN_IMMEDIATE_VALUE && value <= MAX_IMMEDIATE_VALUE) {
        List(Mov(destReg, ImmNum(value.toInt)))
      } else {
        List(Ldr(destReg, ImmLoadNum(value.toInt)))
      }
      loadInst ++ storeVariable(dest)
      
    case BoolLiteral(value, dest) =>
      val destReg = getRegisterForVariable(dest)
      List(Mov(destReg, ImmNum(if (value) BOOL_TRUE else BOOL_FALSE))) ++ storeVariable(dest)
      
    case CharLiteral(value, dest) =>
      val destReg = getRegisterForVariable(dest)
      List(Mov(destReg, ImmNum(value.toInt))) ++ storeVariable(dest)
      
    case StringLiteral(value, dest) =>
      // Add string to literal pool
      val label = literalPool.add(s"\"$value\"")
      val destReg = getRegisterForVariable(dest)
      
      List(Ldr(destReg, ImmLoadLabel(ARMInstructions.Label(label)))) ++ storeVariable(dest)
      
    case NullPairLiteral(dest) =>
      val destReg = getRegisterForVariable(dest)
      List(Mov(destReg, ImmNum(BOOL_FALSE))) ++ storeVariable(dest)
      
    case ArrayAccess(array, indexExpr, result) =>
      val loadArray = loadVariable(array)
      val arrayReg = getRegisterForVariable(array)
      val (tacIndexInstr, indexVar) = TACGenerator.generateRvalue(indexExpr)
      val indexInstr = translateTACToARM(tacIndexInstr)
      val indexLoad = loadVariable(indexVar)
      val indexReg  = getRegisterForVariable(indexVar)
      val resultReg = getRegisterForVariable(result)
      
      requiredRuntimeErrors.add("msg_null_ref")
      val nullCheck = List(
        Cmp(arrayReg, ImmNum(BOOL_FALSE)),
        Cond.branch(Label("_null_ref_error"), Eq)
      )
      
      requiredRuntimeErrors.add("msg_array_bounds")
      val boundsCheck = List(
        Ldr(TEMP_REG, Address(arrayReg, ARRAY_LENGTH_OFFSET)),
        Cmp(indexReg, ImmNum(MIN_ARRAY_INDEX)),
        Cond.branch(Label("_array_bounds_error"), Lt),
        Cmp(indexReg, TEMP_REG),
        Cond.branch(Label("_array_bounds_error"), Ge)
      )
      
      val loadCode = List(
        Lsl(indexReg, indexReg, ImmNum(WORD_SIZE_SHIFT)),
        Add(resultReg, arrayReg, indexReg),
        Ldr(resultReg, Address(resultReg, ARRAY_DATA_OFFSET))
      )
      
      loadArray ++ indexInstr ++ indexLoad ++ 
      nullCheck ++ boundsCheck ++ loadCode ++ storeVariable(result)
      
    case NewArray(size, dest) =>
      val loadSize = loadVariable(size)
      val sizeReg = getRegisterForVariable(size)
      val destReg = getRegisterForVariable(dest)
      
      requiredRuntimeErrors.add("msg_malloc")
      
      loadSize ++ List(
        Add(registers(R0_INDEX), sizeReg, ImmNum(BYTE_SIZE)),
        Lsl(registers(R0_INDEX), registers(R0_INDEX), ImmNum(WORD_SIZE_SHIFT)),
        Bl(Label("malloc"), Al),
        Cmp(registers(R0_INDEX), ImmNum(BOOL_FALSE)),
        Cond.branch(Label("_malloc_error"), Eq),
        Mov(destReg, registers(R0_INDEX)),
        Str(sizeReg, Address(destReg, ARRAY_DATA_OFFSET))
      ) ++ storeVariable(dest)
    
    case ArrayLiteral(elements, dest) =>
      val destReg = getRegisterForVariable(dest)
      
      requiredRuntimeErrors.add("msg_malloc")
      
      // Calculate array size: (elements.length + 1) * 4 bytes
      // +1 for the length field, *4 because each element is 4 bytes
      val arraySize = (elements.length + INCREMENT_COUNTER_VALUE) * WORD_SIZE
      
      val mallocCode = List(
        Mov(registers(R0_INDEX), ImmNum(arraySize)),
        Bl(Label("malloc"), Al),
        Cmp(registers(R0_INDEX), ImmNum(BOOL_FALSE)),
        Cond.branch(Label("_malloc_error"), Eq),
        Mov(destReg, registers(R0_INDEX)),
        Mov(registers(R1_INDEX), ImmNum(elements.length)),
        Str(registers(R1_INDEX), Address(registers(R0_INDEX), ARRAY_DATA_OFFSET)),
        Add(destReg, destReg, ImmNum(ARRAY_HEADER_SIZE))
      )
      
      // Generate code to initialize each element
      val initCode = elements.zipWithIndex.flatMap { case (expr, idx) =>
        val offset = idx * WORD_SIZE
        
        val (tacExprInstr, exprVar) = TACGenerator.generateRvalue(expr)
        val exprInstr = translateTACToARM(tacExprInstr)
        val exprLoad = loadVariable(exprVar)
        val exprReg = getRegisterForVariable(exprVar)
        
        exprInstr ++ exprLoad ++ List(
          Str(exprReg, Address(destReg, offset))
        )
      }
      
      mallocCode ++ initCode ++ storeVariable(dest)
      
    case NewPairAlloc(fst, snd, dest) =>
      val loadFirst = loadVariable(fst)
      val loadSecond = loadVariable(snd)
      val firstReg = getRegisterForVariable(fst)
      val secondReg = getRegisterForVariable(snd)
      val destReg = getRegisterForVariable(dest)
      
      requiredRuntimeErrors.add("msg_malloc")
      
      val allocPair = List(
        Mov(registers(R0_INDEX), ImmNum(PAIR_SIZE)),
        Bl(Label("malloc"), Al),
        Cmp(registers(R0_INDEX), ImmNum(BOOL_FALSE)),
        Cond.branch(Label("_malloc_error"), Eq),
        Mov(destReg, registers(R0_INDEX))
      )
      
      // Save destReg to preserve it during second malloc
      val saveDestReg = List(Push(List(destReg)))
      
      val allocFirst = List(
        Mov(registers(R0_INDEX), ImmNum(WORD_SIZE)),
        Bl(Label("malloc"), Al),
        Cmp(registers(R0_INDEX), ImmNum(BOOL_FALSE)),
        Cond.branch(Label("_malloc_error"), Eq),
        Str(firstReg, Address(registers(R0_INDEX), BOOL_FALSE)),
        Ldr(registers(R1_INDEX), Address(SP, BOOL_FALSE)),
        Str(registers(R0_INDEX), Address(registers(R1_INDEX), PAIR_FST_OFFSET))
      )
      
      val allocSecond = List(
        Mov(registers(R0_INDEX), ImmNum(WORD_SIZE)),
        Bl(Label("malloc"), Al),
        Cmp(registers(R0_INDEX), ImmNum(BOOL_FALSE)),
        Cond.branch(Label("_malloc_error"), Eq),
        Str(secondReg, Address(registers(R0_INDEX), BOOL_FALSE)),
        Ldr(registers(R1_INDEX), Address(SP, BOOL_FALSE)),
        Str(registers(R0_INDEX), Address(registers(R1_INDEX), PAIR_SND_OFFSET)),
        Pop(List(destReg))
      )
      
      loadFirst ++ loadSecond ++ allocPair ++ saveDestReg ++ allocFirst ++ allocSecond ++ storeVariable(dest)
      
    case BoundsCheck(index, size) =>
      val loadIndex = loadVariable(index)
      val loadSize = loadVariable(size)
      val indexReg = getRegisterForVariable(index)
      val sizeReg = getRegisterForVariable(size)
      
      requiredRuntimeErrors.add("msg_array_bounds")
      loadIndex ++ loadSize ++ List(
        Cmp(indexReg, sizeReg),
        Cond.branch(Label("_array_bounds_error"), Ge)
      )
      
    case OverflowCheck() =>
      requiredRuntimeErrors.add("msg_overflow")
      List()
      
    case NullCheck(ref) =>
      val loadRef = loadVariable(ref)
      val refReg = getRegisterForVariable(ref)
      
      requiredRuntimeErrors.add("msg_null_ref")
      loadRef ++ Cond.runtimeCheck("null", refReg, "_null_ref_error")
      
    case FstAccess(pair, dest) =>
      val loadPair = loadVariable(pair)
      val pairReg = getRegisterForVariable(pair)
      val destReg = getRegisterForVariable(dest)
      
      loadPair ++ List(
        Ldr(TEMP_REG, Address(pairReg, PAIR_FST_OFFSET)),
        Ldr(destReg, Address(TEMP_REG, BOOL_FALSE))
      ) ++ storeVariable(dest)
      
    case SndAccess(pair, dest) =>
      val loadPair = loadVariable(pair)
      val pairReg = getRegisterForVariable(pair)
      val destReg = getRegisterForVariable(dest)
      
      loadPair ++ List(
        Ldr(TEMP_REG, Address(pairReg, PAIR_SND_OFFSET)),
        Ldr(destReg, Address(TEMP_REG, BOOL_FALSE))
      ) ++ storeVariable(dest)
      
    case FstStore(pair, value) =>
      val loadPair = loadVariable(pair)
      val loadValue = loadVariable(value)
      val pairReg = getRegisterForVariable(pair)
      val valueReg = getRegisterForVariable(value)
      
      loadPair ++ loadValue ++ List(
        Str(valueReg, Address(pairReg, PAIR_FST_OFFSET))
      )
      
    case SndStore(pair, value) =>
      val loadPair = loadVariable(pair)
      val loadValue = loadVariable(value)
      val pairReg = getRegisterForVariable(pair)
      val valueReg = getRegisterForVariable(value)
      
      loadPair ++ loadValue ++ List(
        Str(valueReg, Address(pairReg, PAIR_SND_OFFSET))
      )
      
    case PrintInst(value, isLn) =>
      val loadValue = loadVariable(value)
      val valueReg = getRegisterForVariable(value)
      
      val printFunc = value.tacType match {
        case TACInt       => "_print_int"
        case TACBool      => "_print_bool"
        case TACChar      => "_print_char"
        case TACString    => "_print_string"
        case _            => "_print_reference"
      }
      requiredRuntimeFunctions += printFunc
      // Ensure flush is called to output the prompt immediately.
      requiredRuntimeFunctions += "_flush"
      if (isLn) requiredRuntimeFunctions += "_print_ln"
      
      val printInstr = loadValue ++ List(
        Mov(registers(R0_INDEX), valueReg),
        Cond.branchLink(Label(printFunc), Al)
      )
      
      if (isLn) {
        printInstr ++ List(Cond.branchLink(Label("_print_ln"), Al))
      } else {
        printInstr
      }
      
    case ReadInst(dest) =>
      val destReg = getRegisterForVariable(dest)
      
      val readFunc = dest.tacType match {
        case TACInt => "_read_int"
        case TACChar => "_read_char"
        case _ => "_read_reference"
      }
      requiredRuntimeFunctions += readFunc
      
      List(
        Bl(Label(readFunc), Al),
        Mov(destReg, registers(R0_INDEX))
      ) ++ storeVariable(dest)
      
    case FreeInst(expr) =>
      val loadExpr = loadVariable(expr)
      val exprReg = getRegisterForVariable(expr)
      
      loadExpr ++ List(
        Mov(registers(R0_INDEX), exprReg),
        Cond.branchLink(Label("free"), Al)
      )
      
    case ExitInst(code) =>
      val loadCode = loadVariable(code)
      val codeReg = getRegisterForVariable(code)
      
      requiredRuntimeFunctions += "_exit"
      
      loadCode ++ List(
        Mov(registers(R0_INDEX), codeReg),
        Bl(Label("_exit"), Al)
      )
      
    case ArrayStore(array, indices, value) =>
      val loadArray = loadVariable(array)
      val arrayReg = getRegisterForVariable(array)
      
      val (tacIndexInstr, indexVar) = TACGenerator.generateRvalue(indices.head)
      val indexInstr = translateTACToARM(tacIndexInstr)
      val indexLoad = loadVariable(indexVar)
      val indexReg = getRegisterForVariable(indexVar)
      
      val loadValue = loadVariable(value)
      val valueReg = getRegisterForVariable(value)
      
      requiredRuntimeErrors.add("msg_null_ref")
      val nullCheck = List(
        Cmp(arrayReg, ImmNum(BOOL_FALSE)),
        Cond.branch(Label("_null_ref_error"), Eq)
      )
      
      requiredRuntimeErrors.add("msg_array_bounds")
      val boundsCheck = List(
        Ldr(TEMP_REG, Address(arrayReg, ARRAY_LENGTH_OFFSET)),
        Cmp(indexReg, ImmNum(MIN_ARRAY_INDEX)),
        Cond.branch(Label("_array_bounds_error"), Lt),
        Cmp(indexReg, TEMP_REG),
        Cond.branch(Label("_array_bounds_error"), Ge)
      )
      
      val storeCode = List(
        Lsl(indexReg, indexReg, ImmNum(WORD_SIZE_SHIFT)), 
        Add(TEMP_REG, arrayReg, indexReg),
        Str(valueReg, Address(TEMP_REG, ARRAY_DATA_OFFSET))
      )
      
      loadArray ++ indexInstr ++ indexLoad ++ loadValue ++ 
      nullCheck ++ boundsCheck ++ storeCode
      
    case _ => List(Nop)
  }

  private def getRegisterForVariable(
      variable: Variable
  ): ARMInstructions.Register = variable match {
    case RegisterVar(_, _, Register(name, index)) =>
      // Safety check - never use PC (R15) 
      if (index == PC_REGISTER_INDEX) {
        // Use IP (R12) instead as a temporary register
        ARMInstructions.registers(IP_REGISTER_INDEX)
      } else {
        ARMInstructions.registers(index)
      }
    case RegisterVar(_, _, StackLocation(_)) =>
      // If it's a stack location, use IP (r12)
      ARMInstructions.registers(IP_REGISTER_INDEX)
    case _ =>
      // For Var types, use IP (r12)
      ARMInstructions.registers(IP_REGISTER_INDEX)
  }

  // Helper to load a variable into the appropriate register
  private def loadVariable(variable: Variable): List[ARMInstruction] =
    variable match {
      case RegisterVar(_, _, Register(name, _)) =>
        // Already in a register, nothing to do
        List()
      case RegisterVar(_, _, StackLocation(offset)) =>
        // Load from stack location
        List(Ldr(ARMInstructions.registers(IP_REGISTER_INDEX), Address(FP, offset)))
      case Var(name, _) =>
        // Global variable - load its value
        List(
          Ldr(ARMInstructions.registers(GLOBAL_ACCESS_REG_INDEX), ImmLoadLabel(Label(name))),
          Ldr(
            ARMInstructions.registers(IP_REGISTER_INDEX),
            Address(ARMInstructions.registers(GLOBAL_ACCESS_REG_INDEX), BOOL_FALSE)
          )
        )
      case _ =>
        List() // Other variable types not handled
    }

  // Helper to store a variable back to memory if needed
  private var globalVariables = Set[String]()

  // Track globals when storing variables
  private def storeVariable(variable: Variable): List[ARMInstruction] =
    variable match {
      case RegisterVar(_, _, Register(_, _)) =>
        // Already in a register, nothing to do
        List()
      case RegisterVar(_, _, StackLocation(offset)) =>
        // Store to stack location
        List(Str(ARMInstructions.registers(IP_REGISTER_INDEX), Address(FP, offset)))
      case Var(name, _) =>
        // Global variable
        globalVariables += name
        List(
          Ldr(ARMInstructions.registers(GLOBAL_ACCESS_REG_INDEX), ImmLoadLabel(Label(name))),
          Str(
            ARMInstructions.registers(IP_REGISTER_INDEX),
            Address(ARMInstructions.registers(GLOBAL_ACCESS_REG_INDEX), BOOL_FALSE)
          )
        )
      case _ =>
        List() // Other variable types not handled
    }

  // keeping map incase we want to change the error messages.
  val runtimeErrorMessages: Map[String, String] = Map(
    "msg_array_bounds" -> "\"#runtime_error#\"",
    "msg_null_ref"     -> "\"#runtime_error#\"",
    "msg_malloc"       -> "\"#runtime_error#\"",
    "msg_overflow"     -> "\"#runtime_error#\"",
    "msg_divzero"      -> "\"#runtime_error#\"",
    "msg_chr_range"    -> "\"#runtime_error#\"",
    "msg_misaligned_fp" -> "\"#runtime_error#: Frame pointer misaligned\"",
    "msg_misaligned_sp" -> "\"#runtime_error#: Stack pointer misaligned\""
  )
  
  def generateErrorMessageLabels(): List[ARMInstruction] = {
    requiredRuntimeErrors.toList.flatMap { key =>
      runtimeErrorMessages
        .get(key)
        .map { msg =>
          List(
            ARMInstructions.Label(key),
            ARMInstructions.define(s".asciz $msg")
          )
        }
        .getOrElse(Nil)
    }
  }

  def generateErrorHandlerRoutines(): List[ARMInstruction] = {
    def createErrorHandler(errorType: String): List[ARMInstruction] = {
      List(
        Label(s"_${errorType}_error"),
        Push(List(FP, LR)),
        Mov(FP, SP),
        Ldr(registers(R0_INDEX), ImmLoadLabel(Label(s"msg_$errorType"))),
        Bl(Label("puts"), Al),
        Mov(registers(R0_INDEX), ImmNum(ERROR_EXIT_CODE)),
        Bl(Label("exit"), Al),
        Mov(SP, FP),
        Pop(List(FP, PC))
      )
    }

    val errorLabelMap = Map(
      "msg_null_ref"     -> "null_ref",
      "msg_array_bounds" -> "array_bounds",
      "msg_overflow"     -> "overflow",
      "msg_divzero"      -> "divzero",
      "msg_chr_range"    -> "chr_range",
      "msg_misaligned_fp" -> "misaligned_fp",
      "msg_misaligned_sp" -> "misaligned_sp",
      "msg_malloc"       -> "malloc"
    )
    
    requiredRuntimeErrors.toList
      .flatMap(label => errorLabelMap.get(label))
      .distinct
      .flatMap(createErrorHandler)
  }

  class LiteralPool {
    private var literals = Map[String, String]()
    private var nextLabel = 0

    def add(value: String): String = {
      literals.find(_._2 == value) match {
        case Some((label, _)) => label
        case None =>
          val label = s"litpool_${nextLabel}"
          nextLabel += INCREMENT_COUNTER_VALUE

          val processedValue =
            if (value.startsWith("\"") && value.endsWith("\"")) {
              val content = value.substring(1, value.length - 1)
              s"\"${escapeAssemblyString(content)}\""
            } else {
              value
            }

          literals += (label -> processedValue)
          label
      }
    }

    def generatePool(): List[ARMInstruction] = {
      literals.toList.flatMap { case (label, value) =>
        val directive = if (value.startsWith("\"")) {
          // String literal - use .asciz for null-terminated strings
          s".asciz $value"
        } else {
          // Number literal - use .word
          s".word $value"
        }
        List(
          Label(label),
          define(directive)
        )
      }
    }

    // Add or modify escape character handling function
    def escapeAssemblyString(str: String): String = {
      str.flatMap {
        case '\b' => "\\b" // Backspace
        case '\t' => "\\t" // Tab
        case '\n' => "\\n" // Newline
        case '\f' => "\\f" // Form feed
        case '\r' => "\\r" // Carriage return
        case '\"' => "\\\"" // Double quote
        case '\\' => "\\\\" // Backslash
        case '\'' => "\\'" // Single quote
        case c    => c.toString
      }
    }
  }

  private var literalPool = new LiteralPool()

  def generateDataSection(): List[ARMInstruction] = {
    val formatStrings = List[Tuple2[String, String]](
      ("int_format", ".asciz \"%d\""),
      ("read_int_format", ".asciz \" %d\""),
      ("str_format", ".asciz \"%s\""),
      ("char_format", ".asciz \"%c\""),
      ("read_char_format", ".asciz \" %c\""),
      ("ptr_format", ".asciz \"%p\""),
      ("read_ptr_format", ".asciz \" %p\""),
      ("newline", ".asciz \"\\n\""),
      ("true_str", ".asciz \"true\""),
      ("false_str", ".asciz \"false\"")
    )
    
    val filteredFormats = formatStrings.filter { 
      case ("int_format", _) => 
        requiredRuntimeFunctions.contains("_print_int")
      case ("read_int_format", _) =>
        requiredRuntimeFunctions.contains("_read_int")
      case ("str_format", _) => 
        requiredRuntimeFunctions.contains("_print_string")
      case ("char_format", _) => 
        requiredRuntimeFunctions.contains("_print_char") 
      case ("read_char_format", _) =>
        requiredRuntimeFunctions.contains("_read_char")
      case ("ptr_format", _) => 
        requiredRuntimeFunctions.contains("_print_reference")
      case ("read_ptr_format", _) =>
        requiredRuntimeFunctions.contains("_read_reference")
      case ("true_str", _) =>
        requiredRuntimeFunctions.contains("_print_true")
      case ("false_str", _) =>
        requiredRuntimeFunctions.contains("_print_false")
      case ("newline", _) =>
        requiredRuntimeFunctions.contains("_print_ln")
      case _ => false
    }

    // Generate only needed format definitions
    val formatDefs = filteredFormats.flatMap { case (name: String, value: String) =>
      List(
        Label(name),
        define(value)
      )
    }

    val errorMsgDefs = generateErrorMessageLabels()
    
    // Generate global variables
    val globalVarDefs = globalVariables.toList.flatMap { name =>
      List(
        Label(name),
        define(".word 0")  // Default initialization to 0
      )
    }
    
    val stringLiterals = literalPool.generatePool()
    
    formatDefs ++ errorMsgDefs ++ globalVarDefs ++ stringLiterals
  }

  def generateProgramFooter(): List[ARMInstruction] = {
    List(
      Mov(registers(R0_INDEX), ImmNum(DEFAULT_EXIT_CODE)),
      Pop(List(FP, PC))
    )
  }

  // Extract runtime support functions into separate methods
  def generateExitFunction(): List[ARMInstruction] = List(
    Label("_exit"),
    Push(List(FP, LR)),
    Mov(FP, SP),
    Bic(registers(R0_INDEX), registers(R0_INDEX), ImmNum(BYTE_MASK)),
    Cond.branchLink(Label("exit"), Al),
    Mov(SP, FP),
    Pop(List(FP, PC))
  )

  def generateRuntimeSupport(): List[ARMInstruction] = {
    if (requiredRuntimeFunctions.contains("_print_bool")) {
      requiredRuntimeFunctions += "_print_true"
      requiredRuntimeFunctions += "_print_false"
    }

    // Helper to create a complete function block.
    def createRuntimeFunction(name: String, body: List[ARMInstruction]): List[ARMInstruction] = {
      List(
        Label(name),
        Push(List(FP, LR)),
        Mov(FP, SP)
      ) ++ body ++ List(
        Pop(List(FP, PC))
      )
    }

    // Conditionally create a print function.
    def maybeCreatePrintFunction(fnName: String, formatLabel: String, needsFormatting: Boolean = true): Option[List[ARMInstruction]] = {
      if (requiredRuntimeFunctions.contains(fnName)) {
        // Only add _flush call if it was explicitly marked as needed.
        val flushCall = if (requiredRuntimeFunctions.contains("_flush")) List(Bl(Label("_flush"), Al)) else Nil
        val printCode = if (needsFormatting) {
          List(
            Mov(registers(R1_INDEX), registers(R0_INDEX)),
            Ldr(registers(R0_INDEX), ImmLoadLabel(Label(formatLabel))),
            Bl(Label("printf"), Al)
          )
        } else {
          List(
            Ldr(registers(R0_INDEX), ImmLoadLabel(Label(formatLabel))),
            Bl(Label("puts"), Al)
          )
        }
        Some(createRuntimeFunction(fnName, printCode ++ flushCall))
      } else None
    }

    // Conditionally create a read function.
    def maybeCreateReadFunction(fnName: String, routine: List[ARMInstruction]): Option[List[ARMInstruction]] = {
      if (requiredRuntimeFunctions.contains(fnName)) Some(createRuntimeFunction(fnName, routine))
      else None
    }

    // Build all function blocks only if they are required.
    val printFunctionBlocks = List(
      maybeCreatePrintFunction("_print_int", "int_format"),
      maybeCreatePrintFunction("_print_string", "str_format"),
      maybeCreatePrintFunction("_print_char", "char_format"),
      maybeCreatePrintFunction("_print_reference", "ptr_format"),
      maybeCreatePrintFunction("_print_ln", "newline", false),
      maybeCreatePrintFunction("_print_true", "true_str", true),
      maybeCreatePrintFunction("_print_false", "false_str", true)
    ).flatten

    val printBoolBlock = if (requiredRuntimeFunctions.contains("_print_bool")) {
      List(
        Label("_print_bool"),
        Push(List(FP, LR)),
        Mov(FP, SP),
        Cmp(registers(R0_INDEX), ImmNum(BOOL_FALSE)),
        Cond.branch(Label("_print_false_call"), Eq),
        Cond.branchLink(Label("_print_true"), Al),
        B(Label("_print_bool_return"), Al),
        Label("_print_false_call"),
        Cond.branchLink(Label("_print_false"), Al),
        Label("_print_bool_return"),
        Pop(List(FP, PC))
      ) :: Nil
    } else Nil

    val flushBlock = if (requiredRuntimeFunctions.contains("_flush")) {
      Some(createRuntimeFunction("_flush", List(
        Mov(registers(R0_INDEX), ImmNum(BOOL_FALSE)),  // Use 0 to flush all output streams
        Bl(Label("fflush"), Al),
        Mov(SP, FP)
      )))
    } else None

    // Helper method to generate common read function code
    def generateReadFunctionBody(name: String, formatLabel: String, loadInstruction: ARMInstruction): List[ARMInstruction] = {
      val usesSP = name != "_read_reference" // _read_reference uses Push/Pop pattern instead
      
      // Common setup
      val setup = if (usesSP) {
        List(
          // Store the original value of r0 on the stack for potential EOF handling
          Sub(SP, SP, ImmNum(LOCAL_VAR_STACK_SPACE)),  // 8 bytes - 4 for original value, 4 for read value
          Str(registers(R0_INDEX), Address(SP, BOOL_FALSE))  // Save original value at SP
        )
      } else {
        List(
          // Store the original value of r0 (which is also the destination ptr) on the stack
          Push(List(registers(R0_INDEX)))  // Save original value
        )
      }
      
      // Setup for scanf
      val scanfSetup = if (usesSP) {
        List(
          Add(registers(R1_INDEX), SP, ImmNum(LOCAL_VAR_VALUE_OFFSET)),  // Point r1 to SP+4 for the read value
          Ldr(registers(R0_INDEX), ImmLoadLabel(Label(formatLabel)))
        )
      } else {
        List(
          Mov(registers(R1_INDEX), registers(R0_INDEX)),  // Move destination to r1 for scanf
          Ldr(registers(R0_INDEX), ImmLoadLabel(Label(formatLabel)))
        )
      }
      
      // Common flush stdin
      val flushCode = List(
        Push(List(registers(R0_INDEX), registers(R1_INDEX))),
        Mov(registers(R0_INDEX), ImmNum(BOOL_FALSE)),
        Bl(Label("fflush"), Al),
        Pop(List(registers(R0_INDEX), registers(R1_INDEX)))
      )
      
      // Reading and validation
      val readCode = List(
        Bl(Label("scanf"), Al),
        Cmp(registers(R0_INDEX), ImmNum(SCANF_SUCCESS))  // scanf returns number of items successfully read
      )
      
      // Custom handling based on function type
      val successHandler = if (usesSP) {
        val successLoadInst = loadInstruction
        val successBranch = Label(s"${name}_end")
        val eofLabel = Label(s"${name}_eof")
        
        List(
          Cond.branch(eofLabel, Lt),  // If < 1, EOF or error occurred
          successLoadInst,
          Cond.branch(successBranch, Al),
          eofLabel,
          Ldr(registers(R0_INDEX), Address(SP, BOOL_FALSE)),
          successBranch,
          Add(SP, SP, ImmNum(LOCAL_VAR_STACK_SPACE))
        )
      } else {
        // Reference pattern is different
        val eofLabel = Label("_read_ref_eof")
        val endLabel = Label("_read_ref_end")
        val exitLabel = Label("_read_ref_exit")
        
        List(
          Cond.branch(eofLabel, Lt),  // If < 1, EOF or error occurred
          Cond.branch(endLabel, Al),
          eofLabel,
          Pop(List(registers(R0_INDEX))),
          Cond.branch(exitLabel, Al),
          endLabel,
          Add(SP, SP, ImmNum(LOCAL_VAR_VALUE_OFFSET)),
          exitLabel
        )
      }
      
      setup ++ scanfSetup ++ flushCode ++ readCode ++ successHandler
    }

    val readFunctionBlocks = List(
      maybeCreateReadFunction("_read_int", 
        generateReadFunctionBody("_read_int", "read_int_format", 
          Ldr(registers(R0_INDEX), Address(SP, LOCAL_VAR_VALUE_OFFSET)))),
        
      maybeCreateReadFunction("_read_char", 
        generateReadFunctionBody("_read_char", "read_char_format", 
          Ldrb(registers(R0_INDEX), Address(SP, LOCAL_VAR_VALUE_OFFSET)))),
        
      maybeCreateReadFunction("_read_reference", 
        generateReadFunctionBody("_read_reference", "read_ptr_format", Nop))
    ).flatten

    (printFunctionBlocks ++ printBoolBlock ++ readFunctionBlocks ++ flushBlock.toList).flatten
  }

  // Generate ARM code from TAC instructions directly to a stream
  def generateARMFromTAC(
      tacInstructions: List[TACInstruction],
      stream: java.io.OutputStream = System.out,
      optimize: Boolean = true
  ): Unit = {
    val writer = new java.io.PrintWriter(stream)
    try {
      // Reset global variables and other state
      globalVariables = Set[String]()
      literalPool = new LiteralPool()
      requiredRuntimeErrors.clear()
      requiredRuntimeFunctions.clear() 
      
      requiredRuntimeErrors.add("msg_misaligned_fp")
      requiredRuntimeErrors.add("msg_misaligned_sp")
      
      val armInsts = if (optimize) {
        translateTACToARMOptimized(tacInstructions)
      } else {
        translateTACToARM(tacInstructions)
      }
      
      val assemblyCode = generateAssemblyCode(armInsts)

      assemblyCode.foreach(writer.println)
      writer.flush()
    } finally {
      if (stream != System.out) {
        writer.close()
      }
    }
  }

  def generateAssemblyCode(armInsts: List[ARMInstruction]): List[String] = {
    val exitFunction = if (requiredRuntimeFunctions.contains("_exit")) {
      generateExitFunction()
    } else {
      List.empty[ARMInstruction]
    }
    
    val runtimeSupport = generateRuntimeSupport()
    val errorHandlers = generateErrorHandlerRoutines()
    
    val staticData = generateDataSection()
    val dataSection = if (staticData.isEmpty) {
      List.empty[ARMInstruction]
    } else {
      List(define(".data"), define(s".align ${DEFAULT_ALIGNMENT}")) ++ staticData
    }
    
    // Add alignment checks for debugging segfaults
    val alignmentChecks = generateFramePointerCheck() ++ generateStackPointerCheck()
    
    // Build the complete program with proper section ordering
    val fullProgram = List(
      define(".text"),
      define(".global main"),
      Label("main"),
      Push(List(FP, LR)),
      Mov(FP, SP)
    ) ++ 
    alignmentChecks ++  
    armInsts ++ 
    generateProgramFooter() ++
    exitFunction ++
    runtimeSupport ++
    errorHandlers ++
    dataSection
    
    fullProgram.map(_.toString)
  }

  def generateARMToFile(
      tacInstructions: List[TACInstruction],
      filePath: String,
      optimize: Boolean = true
  ): Unit = {
    val fileStream = new java.io.FileOutputStream(filePath)
    try {
      generateARMFromTAC(tacInstructions, fileStream, optimize)
    } finally {
      fileStream.close()
    }
  }

  def generateGlobalVariables(): List[ARMInstruction] = {
    globalVariables.toList.map { name =>
      Label(name) :: define(".word 0") :: Nil
    }.flatten
  }

  // Helper to determine if a variable requires memory access
  def isMemoryAccess(variable: Variable): Boolean = variable match {
    case RegisterVar(_, _, Register(_, _)) => false
    case _ => true
  }

  // Helper functions for debugging
  def generateFramePointerCheck(): List[ARMInstruction] = {
    List(
      define("@ DEBUG: Frame pointer alignment check"),
      Mov(TEMP_REG, FP),
      And(TEMP_REG, TEMP_REG, ImmNum(WORD_ALIGNMENT_MASK)),
      Cmp(TEMP_REG, ImmNum(BOOL_FALSE)),
      Cond.branch(Label("_misaligned_fp_error"), Ne)
    )
  }

  def generateStackPointerCheck(): List[ARMInstruction] = {
    List(
      define("@ DEBUG: Stack pointer alignment check"),
      Mov(TEMP_REG, SP),
      And(TEMP_REG, TEMP_REG, ImmNum(WORD_ALIGNMENT_MASK)),
      Cmp(TEMP_REG, ImmNum(BOOL_FALSE)),
      Cond.branch(Label("_misaligned_sp_error"), Ne)
    )
  }

  // Helper function for division and modulo operations
  private def generateDivModOperation(
    leftReg: Register, 
    rightReg: Register, 
    destReg: Register,
    isDivision: Boolean
  ): List[ARMInstruction] = {
    requiredRuntimeErrors.add("msg_divzero")

    val divCheck = List(
      Cmp(rightReg, ImmNum(BOOL_FALSE)),
      Cond.branch(Label("_divzero_error"), Eq)
    )
    
    val setupRegisters = List(
      Mov(registers(R0_INDEX), leftReg),
      Mov(registers(R1_INDEX), rightReg)
    )
    
    val operationCall = if (isDivision) {
      List(
        Bl(Label("__aeabi_idiv"), Al),
        Mov(destReg, registers(R0_INDEX))
      )
    } else {
      List(
        Bl(Label("__aeabi_idivmod"), Al),
        Mov(destReg, registers(R1_INDEX))
      )
    }
    
    divCheck ++ setupRegisters ++ operationCall
  }
}
