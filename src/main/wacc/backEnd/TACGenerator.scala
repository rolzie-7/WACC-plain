package wacc.backEnd

import wacc.ast._
import wacc.ast.Statements._
import wacc.ast.BinaryOps._
import wacc.ast.UnaryOps._
import wacc.ast.Literals._
import wacc.ast.Functions._
import wacc.ast.Arrays._
import wacc.ast.Pairs._
import scala.language.implicitConversions
import TACTypes._
import wacc.SemanticTypes

import wacc.backEnd.Constants._

object TACGenerator {

  import wacc.SemanticTypes._

  private var labelCounter = INITIAL_COUNTER_VALUE

  def getUniqueLabel(prefix: String): String = {
    val label = s"${prefix}_$labelCounter"
    labelCounter += INCREMENT_COUNTER_VALUE
    label
  }

  // Global reset for both counters.
  def resetCounters(): Unit = {
    TempVarGenerator.reset()
    labelCounter = INITIAL_COUNTER_VALUE
  }

  // Top-level entry point for TAC generation which resets counters first.
  def generateFullTAC(prog: Any): List[TACInstruction] = {
    resetCounters()
    generateTAC(prog)
  }

  def generateRvalue(rval: Rvalue): (List[TACInstruction], Variable) =
    rval match {
      // Literals
      case lit: IntLit =>
        val reg = RegisterAllocator.allocateRegister(TACInt)
        (List(IntLiteral(lit.value, reg)), reg)

      case lit: BoolLit =>
        val reg = RegisterAllocator.allocateRegister(TACBool)
        (List(BoolLiteral(lit.value, reg)), reg)

      case lit: CharLit =>
        val reg = RegisterAllocator.allocateRegister(TACChar)
        (List(CharLiteral(lit.value, reg)), reg)

      case lit: StrLit =>
        val reg = RegisterAllocator.allocateRegister(TACString)
        (List(StringLiteral(lit.value, reg)), reg)

      case lit: PairLit =>
        val pairType = lit.semanticType
          .map(TACTypes.fromSemanticType)
          .getOrElse(
            TACDebug("No type information for pair literal in generateRvalue")
          ) match {
          case TACPair(fst, snd) =>
            TACPair(fst, snd)
          case _ =>
            TACDebug(
              "No type information for pair literal in generateRvalue case 2"
            )
        }
        val reg = RegisterAllocator.allocateRegister(pairType)
        (List(NullPairLiteral(reg)), reg)

      // Variables
      case id: Ident =>
        (
          List(),
          Var(id.trueName, id.semanticType.getOrElse(SemanticTypes.Nothing))
        )

      // Array and pair operations
      case arr @ ArrayLit(elements) =>
        elements match {
          case Some(elements) =>
            val arrType: TACType = fromSemanticType(
              arr.semanticType.getOrElse(
                DebugT(
                  "No type information for array literal in some case of generateRvalue"
                )
              )
            ) match {
              case TACArray(elemType, length) =>
                TACArray(elemType, Some(elements.length))
              case _ =>
                TACDebug(
                  "No type information for array literal in some case of generateRvalue case 2"
                )
            }
            val reg = RegisterAllocator.allocateRegister(arrType)
            (List(ArrayLiteral(elements, reg)), reg)
          case None =>
            val arrType = fromSemanticType(
              arr.semanticType.getOrElse(
                DebugT(
                  "No type information for array literal in none case of generateRvalue"
                )
              )
            )
            val reg = RegisterAllocator.allocateRegister(arrType)
            (List(ArrayLiteral(List(), reg)), reg)
        }

      case elem: ArrayElem =>
        // Use the full array type from the array identifier rather than the element type.
        val arrayVar = elem.array match {
          case id: Ident =>
            // id.semanticType should be ArrayT(...)
            Var(
              id.trueName,
              id.semanticType.getOrElse(
                DebugT(
                  "No type information for array identifier in generateRvalue"
                )
              )
            )
        }
        
        // Use the generateArrayAccess method to handle array access with proper bounds checking
        val (instructions, resultReg) = generateArrayAccess(arrayVar, elem.indices)
        
        (instructions, resultReg)

      case pair: NewPair =>
        val (fstInstr, fstVar) = generateRvalue(pair.fst)
        val (sndInstr, sndVar) = generateRvalue(pair.snd)
        val resultReg = RegisterAllocator.allocateRegister(
          pair.semanticType.getOrElse(DebugT("No type information"))
        )

        (
          fstInstr ++ sndInstr ++
            List(NewPairAlloc(fstVar, sndVar, resultReg)),
          resultReg
        )

      case elem: PairElem =>
        generatePairAccess(elem)

      // Function calls
      case call: Call =>
        val args = call.args.getOrElse(Functions.ArgList(List())).args

        // Save the registers by pushing them onto the stack
        val registersToSave = (INITIAL_COUNTER_VALUE + INCREMENT_COUNTER_VALUE to GLOBAL_ACCESS_REG_INDEX).toList ++ List(IP_REGISTER_INDEX)
        val pushRegisters: List[TACInstruction] = List(
          PushRegisters(registersToSave.map(i => Register("r" + i.toString, i)))
        )
        // Process all arguments
        val (processedInstr, processedVars) = args.zipWithIndex.foldLeft(
          (List[TACInstruction](), List[Variable]())
        ) { case ((instrs, vars), (arg, idx)) =>
          val (argInstr, argVar) = generateRvalue(arg)

          // For first MAX_REGISTER_ARGS args, try to put them in register args
          if (idx < MAX_REGISTER_ARGS && args.length > idx) {
            // Allocate specific registers for args
            val reg = RegisterAllocator.argRegs(idx)
            val regVar =
              RegisterAllocator.allocateSpecificRegister(argVar.tacType, reg)

            // Add move instruction if needed
            val moveInstr = List(TACAssign(regVar, argVar))
            (instrs ++ argInstr ++ moveInstr, vars :+ regVar)
          } else {
            (instrs ++ argInstr, vars :+ argVar)
          }
        }

        // Allocate result register (typically r0)
        val resultReg = RegisterAllocator.allocateSpecificRegister(
          call.semanticType.getOrElse(DebugT("No type information")),
          RegisterAllocator.r0 // Return value comes in r0
        )

        // Get mangled function name
        val argVars = processedVars.map(arg => {
          val tacType = arg.tacType match {
            case TACArray(elemType, _) => elemType
            case _                     => arg.tacType
          }
          Var(s"arg_${arg.hashCode}", tacType)
        })
        val mangledName = mangleFunctionName(call.function.name, argVars)

        // restore the registers by popping them from the stack
        val popRegisters: List[TACInstruction] = List(
          PopRegisters(
            registersToSave.map(i => Register("r" + i.toString, i))
            )
        )

        // Use the mangled name in the call instruction
        (
          pushRegisters ++          
          processedInstr ++          
          List(                     
            CallInst(mangledName, processedVars, resultReg)
          ) ++
          popRegisters,              
          resultReg
        )

      // Binary operations
      case op: BinaryOp =>
        val (leftInstr, leftVar) = generateRvalue(op.left)
        
        // Mark left variable as live since we need it for the binary operation
        RegisterAllocator.markLive(leftVar)
        
        val (rightInstr, rightVar) = generateRvalue(op.right)
        
        // Now both left and right variables are available
        val resultReg = RegisterAllocator.allocateRegister(
          op.semanticType.getOrElse(DebugT("No type information"))
        )
        
        // Once we've done the operation, we can mark them as dead
        val instruction = BinaryOperation(binaryOpToTAC(op), leftVar, rightVar, resultReg)
        
        // Add runtime checks based on operation type
        val runtimeChecks = op match {
          case _: Div | _: Mod =>
            val zeroReg = RegisterAllocator.allocateRegister(TACInt)
            val boolReg = RegisterAllocator.allocateRegister(TACBool)
            List(
              IntLiteral(BOOL_FALSE, zeroReg),
              BinaryOperation(TACNotEqual, rightVar, zeroReg, boolReg),
              JumpIfZero(boolReg, "_divzero_error")
            )
          case _: Add | _: Sub | _: Mul =>
            List(OverflowCheck())
          case _ => List()
        }
        
        RegisterAllocator.markDead(leftVar)
        RegisterAllocator.markDead(rightVar)
        
        RegisterAllocator.markLive(resultReg)

        (
          leftInstr ++ rightInstr ++
          runtimeChecks ++ List(instruction),
          resultReg
        )

      // Unary operations
      case op: UnaryOp =>
        val (exprInstr, exprVar) = generateRvalue(op.expr)
        
        RegisterAllocator.markLive(exprVar)

        val resultReg = RegisterAllocator.allocateRegister(
          op.semanticType.getOrElse(DebugT("No type information"))
        )

        val runtimeChecks = op match {
          case _: Chr =>
            val zeroReg = RegisterAllocator.allocateRegister(TACInt)
            val maxCharReg = RegisterAllocator.allocateRegister(TACInt)
            val geCheck = RegisterAllocator.allocateRegister(TACBool)
            val leCheck = RegisterAllocator.allocateRegister(TACBool)
            List(
              IntLiteral(MIN_CHAR_VALUE, zeroReg),
              IntLiteral(MAX_CHAR_VALUE, maxCharReg),
              BinaryOperation(TACGreaterEqualThan, exprVar, zeroReg, geCheck),
              JumpIfZero(geCheck, "_chr_range_error"),
              BinaryOperation(
                TACLessEqualThan,
                exprVar,
                maxCharReg,
                leCheck
              ),
              JumpIfZero(leCheck, "_chr_range_error")
            )
          case _: Neg =>
            List(OverflowCheck())
          case _ => List()
        }
        
        RegisterAllocator.markDead(exprVar)
        
        RegisterAllocator.markLive(resultReg)

        (
          exprInstr ++ runtimeChecks ++
            List(UnaryOperation(unaryOpToTAC(op), exprVar, resultReg)),
          resultReg
        )
    }

  private def binaryOpToTAC(op: BinaryOp): TACBinaryOp = op match {
    case _: Add => TACAdd
    case _: Sub => TACSubtract
    case _: Mul => TACMultiply
    case _: Div => TACDivide
    case _: Mod => TACMod
    case _: GT  => TACGreaterThan
    case _: GTE => TACGreaterEqualThan
    case _: LT  => TACLessThan
    case _: LTE => TACLessEqualThan
    case _: E   => TACEqual
    case _: NE  => TACNotEqual
    case _: And => TACAnd
    case _: Or  => TACOr
  }

  private def unaryOpToTAC(op: UnaryOp): TACUnaryOp = op match {
    case _: Not => TACNot
    case _: Neg => TACNeg
    case _: Len => TACLen
    case _: Ord => TACOrd
    case _: Chr => TACChr
  }

  def generateArrayAccess(
      array: Variable,
      indices: List[Expr]
  ): (List[TACInstruction], Variable) = {
    RegisterAllocator.markLive(array)
    
    indices match {
      case Nil =>
        (List(), array)
      case head :: tail =>
        val baseArrayType = array.tacType match {
          case TACArray(elemType, _) => elemType
          case _ =>
            TACDebug(
              "generateArrayAccess: array variable is not of type TACArray"
            )
        }

        val (indexInstr, indexVar) = generateRvalue(head)
 
        RegisterAllocator.markLive(indexVar)
        
        val resultReg = RegisterAllocator.allocateRegister(baseArrayType)

        val nullCheckInstructions = List(
          NullCheck(array)
        )

        val sizeReg = RegisterAllocator.allocateRegister(TACInt)
        val lenInstr = List(UnaryOperation(TACLen, array, sizeReg))
        
        RegisterAllocator.markLive(sizeReg)
        
        val zeroReg = RegisterAllocator.allocateRegister(TACInt)
        val nonNegBool = RegisterAllocator.allocateRegister(TACBool)
        val lowerBoundCheckInstructions = List(
          IntLiteral(MIN_ARRAY_INDEX, zeroReg),
          BinaryOperation(TACGreaterEqualThan, indexVar, zeroReg, nonNegBool),
          JumpIfZero(nonNegBool, "_array_bounds_error")
        )
        val boundsCheckInstructions = List(
          BoundsCheck(indexVar, sizeReg)
        )

        val accessInstr = indexInstr ++ nullCheckInstructions ++ lenInstr ++
          lowerBoundCheckInstructions ++ boundsCheckInstructions ++
          List(ArrayAccess(array, head, resultReg))
          
        RegisterAllocator.markDead(indexVar)
        RegisterAllocator.markDead(sizeReg)
        RegisterAllocator.markDead(zeroReg)
        RegisterAllocator.markDead(nonNegBool)
        
        RegisterAllocator.markLive(resultReg)

        if (tail.isEmpty) {
          (accessInstr, resultReg)
        } else {
          // For nested access, keep the result live
          val (tailInstr, resultVar) = generateArrayAccess(resultReg, tail)
          RegisterAllocator.markDead(resultReg)
          RegisterAllocator.markLive(resultVar)
          
          (accessInstr ++ tailInstr, resultVar)
        }
    }
  }

  def generatePairAccess(elem: PairElem): (List[TACInstruction], Variable) = {
    elem match {
      case Fst(pair: Ident) =>
        val (pairInstr, pairVar) = generateRvalue(pair)
        
        RegisterAllocator.markLive(pairVar)
        
        val elemType = pairVar.tacType match {
          case TACPair(fst, _) => fst
          case _ =>
            TACDebug(s"Cannot apply 'fst' to non-pair type ${pairVar.tacType}")
        }
        val resultReg = RegisterAllocator.allocateRegister(elemType)
        val nullCheckInstructions = List(NullCheck(pairVar))
        
        RegisterAllocator.markDead(pairVar)
        
        RegisterAllocator.markLive(resultReg)
        
        (
          pairInstr ++ nullCheckInstructions ++ List(
            FstAccess(pairVar, resultReg)
          ),
          resultReg
        )

      case Snd(pair: Ident) =>
        val (pairInstr, pairVar) = generateRvalue(pair)
        
        RegisterAllocator.markLive(pairVar)
        
        val elemType = pairVar.tacType match {
          case TACPair(_, snd) => snd
          case _ =>
            TACDebug(s"Cannot apply 'snd' to non-pair type ${pairVar.tacType}")
        }
        val resultReg = RegisterAllocator.allocateRegister(elemType)
        val nullCheckInstructions = List(NullCheck(pairVar))
        
        RegisterAllocator.markDead(pairVar)
        
        RegisterAllocator.markLive(resultReg)
        
        (
          pairInstr ++ nullCheckInstructions ++ List(
            SndAccess(pairVar, resultReg)
          ),
          resultReg
        )

      case Fst(ArrayElem(arr, indices)) =>
        val arrayVar = Var(
          arr.trueName,
          arr.semanticType.getOrElse(
            DebugT(
              "No type information for array in some case of generatePairAccess"
            )
          )
        )
        val (arrayInstr, elemVar) = generateArrayAccess(arrayVar, indices)
        
        RegisterAllocator.markLive(elemVar)
        
        val resultReg = RegisterAllocator.allocateRegister(
          elem.semanticType.getOrElse(DebugT("No type information"))
        )
        val nullCheckInstructions = List(NullCheck(elemVar))
        
        RegisterAllocator.markDead(elemVar)
        
        RegisterAllocator.markLive(resultReg)
        
        (
          arrayInstr ++ nullCheckInstructions ++ List(
            FstAccess(elemVar, resultReg)
          ),
          resultReg
        )

      case Snd(ArrayElem(arr, indices)) =>
        val arrayVar = Var(
          arr.trueName,
          arr.semanticType.getOrElse(
            DebugT(
              "No type information for array in some case of generatePairAccess"
            )
          )
        )
        val (arrayInstr, elemVar) = generateArrayAccess(arrayVar, indices)
        
        RegisterAllocator.markLive(elemVar)
        
        val resultReg = RegisterAllocator.allocateRegister(
          elem.semanticType.getOrElse(DebugT("No type information"))
        )
        
        RegisterAllocator.markDead(elemVar)
        
        RegisterAllocator.markLive(resultReg)
        
        (arrayInstr ++ List(SndAccess(elemVar, resultReg)), resultReg)

      case Fst(pair: PairElem) =>
        val (pairInstr, pairVar) = generatePairAccess(pair)
        
        RegisterAllocator.markLive(pairVar)
        
        val resultReg = RegisterAllocator.allocateRegister(
          elem.semanticType.getOrElse(DebugT("No type information"))
        )
        
        RegisterAllocator.markDead(pairVar)
        
        RegisterAllocator.markLive(resultReg)
        
        (pairInstr ++ List(FstAccess(pairVar, resultReg)), resultReg)

      case Snd(pair: PairElem) =>
        val (pairInstr, pairVar) = generatePairAccess(pair)
        
        RegisterAllocator.markLive(pairVar)
        
        val resultReg = RegisterAllocator.allocateRegister(
          elem.semanticType.getOrElse(DebugT("No type information"))
        )
        
        RegisterAllocator.markDead(pairVar)
        
        RegisterAllocator.markLive(resultReg)
        
        (pairInstr ++ List(SndAccess(pairVar, resultReg)), resultReg)

      case _ => (List(), Var("dummy", TACDebug("Unhandled pair element")))
    }
  }

  def generateTAC(stmt: Any): List[TACInstruction] = stmt match {
    case Program(funcs, body) =>
      funcs.flatMap(generateTAC(_)) ++ generateTAC(body)
    case Func(returnType, ident, params, body) =>
      val paramMapping = params.params.zipWithIndex.take(MAX_REGISTER_ARGS).map { case (p, idx) =>
        val paramName = p.name.trueName
        val paramType = fromSemanticType(p.typ)
        val regVar = RegisterVar(paramName, paramType, RegisterAllocator.argRegs(idx))
        (paramName, regVar)
      }.toMap

      // println(s"Param mapping: $paramMapping")
      
      val paramVars = params.params.map(p => Var(p.name.trueName, p.typ))
      val mangledName = mangleFunctionName(ident.name, paramVars)
      
      val bodyTAC = generateTAC(body)
      
      val transformedBody = transformTAC(bodyTAC, paramMapping)
      
      List(Block(TACLabel(mangledName), transformedBody))
    case Declare(typ, ident, rval) =>
      val variable = Var(ident.trueName, typ)
      val (instructions, returnVar) = generateRvalue(rval)
      instructions ++
        List(
          TACAssign(variable, returnVar)
        )
    case Statements.Assign(lhs, rhs) =>
      lhs match {
        case ident @ Ident(name) =>
          val (instructions, returnVar) = generateRvalue(rhs)
          instructions ++
            List(
              TACAssign(
                Var(
                  ident.trueName,
                  ident.semanticType.getOrElse(
                    DebugT(
                      s"Undeclared identifier in Assign '$ident.trueName' in some case of generateTAC"
                    )
                  )
                ),
                returnVar
              )
            )
        /* ArrayElem */
        case arrElem @ ArrayElem(arr, idx) =>
          // Use the full array type from the identifier 'arr'
          val arrayElemVar = arr match {
            case id: Ident =>
              Var(
                id.trueName,
                id.semanticType.getOrElse(
                  DebugT(
                    "No type information for array identifier in generateTAC"
                  )
                )
              )
          }
          
          val array = arrayElemVar
          
          val indexVars = idx.map { index =>
            val (_, indexVar) = generateRvalue(index)
            RegisterAllocator.markLive(indexVar)
            indexVar
          }
          
          val indexInstructions = idx.flatMap { index =>
            val (indexInstr, _) = generateRvalue(index)
            indexInstr
          }
          
          val nullCheck = List(NullCheck(array))
          
          val boundsChecks = indexVars.flatMap { indexVar =>
            val sizeReg = RegisterAllocator.allocateRegister(TACInt)
            val lenInstr = List(UnaryOperation(TACLen, array, sizeReg))
            RegisterAllocator.markLive(sizeReg)
            
            val zeroReg = RegisterAllocator.allocateRegister(TACInt)
            val nonNegBool = RegisterAllocator.allocateRegister(TACBool)
            val lowerBoundCheckInstructions = List(
              IntLiteral(MIN_ARRAY_INDEX, zeroReg),
              BinaryOperation(TACGreaterEqualThan, indexVar, zeroReg, nonNegBool),
              JumpIfZero(nonNegBool, "_array_bounds_error")
            )
            
            // Check if index < length
            val boundsCheckInstructions = List(
              BoundsCheck(indexVar, sizeReg)
            )
            
            RegisterAllocator.markDead(sizeReg)
            RegisterAllocator.markDead(zeroReg)
            RegisterAllocator.markDead(nonNegBool)
            
            lenInstr ++ lowerBoundCheckInstructions ++ boundsCheckInstructions
          }
          
          indexVars.foreach(RegisterAllocator.markDead)
          
          val (rhsInstructions, rhsVar) = generateRvalue(rhs)
          
          indexInstructions ++ nullCheck ++ boundsChecks ++ rhsInstructions ++
            List(
              ArrayStore(array, idx, rhsVar)
            )
        case Fst(pair: PairElem) =>
          val (rhsInstructions, rhsReturnVar) = generateRvalue(rhs)
          val (pairInstructions, pairVar) = generatePairAccess(pair)
          val nullCheck = List(NullCheck(pairVar))
          pairInstructions ++ rhsInstructions ++ nullCheck ++ List(
            FstStore(pairVar, rhsReturnVar)
          )
        case Snd(pair: PairElem) =>
          val (rhsInstructions, rhsReturnVar) = generateRvalue(rhs)
          val (pairInstructions, pairVar) = generatePairAccess(pair)
          val nullCheck = List(NullCheck(pairVar))
          pairInstructions ++ rhsInstructions ++ nullCheck ++ List(
            SndStore(pairVar, rhsReturnVar)
          )
        case _ => List()
      }
    case Statements.IfThenElse(cond, thenStmt, elseStmt) =>
      val thenLabel = getUniqueLabel("then")
      val elseLabel = getUniqueLabel("else")
      val endLabel = getUniqueLabel("endif")
      val (condInstr, condVar) = generateRvalue(cond)

      condInstr ++
        List(JumpIfZero(condVar, elseLabel)) ++
        List(TACLabel(thenLabel)) ++
        generateTAC(thenStmt) ++
        List(Jump(endLabel)) ++
        List(TACLabel(elseLabel)) ++
        generateTAC(elseStmt) ++
        List(TACLabel(endLabel))
    case Statements.WhileDo(cond, body) =>
      val condLabel = getUniqueLabel("while")
      val bodyLabel = getUniqueLabel("body")
      val endLabel = getUniqueLabel("endwhile")
      List(TACLabel(condLabel)) ++ {
        val (condInstr, condVar) = generateRvalue(cond)
        condInstr ++ List(JumpIfZero(condVar, endLabel))
      } ++
        List(TACLabel(bodyLabel)) ++
        generateTAC(body) ++
        List(Jump(condLabel)) ++
        List(TACLabel(endLabel))
    case Statements.BeginEnd(stmt) =>
      generateTAC(stmt)
    case Statements.StmtList(first, second) =>
      generateTAC(first) ++ generateTAC(second)
    case Statements.Skip(_) =>
      List(NOP)
    case Statements.Read(lvalue) =>
      lvalue match {
        case id: Ident =>
          val variable = Var(
            id.trueName,
            id.semanticType.getOrElse(
              DebugT(
                "No type information for identifier in some case of generateTAC"
              )
            )
          )
          List(ReadInst(variable))
        case arrayElem: ArrayElem =>
          val arrayVar = Var(
            arrayElem.array.trueName,
            arrayElem.array.semanticType.getOrElse(
              DebugT(
                "No type information for array literal in some case of generateTAC"
              )
            )
          )
          val (arrayInstr, elemVar) =
            generateArrayAccess(arrayVar, arrayElem.indices)
          arrayInstr ++ List(ReadInst(elemVar))
        case pairElem: PairElem =>
          val (pairInstr, pairVar) = generatePairAccess(pairElem)
          pairInstr ++ List(ReadInst(pairVar))
        case _ => List() // Should never happen
      }
    case Statements.Free(expr) =>
      val (exprInstr, exprVar) = generateRvalue(expr)
      val nullCheck = List(NullCheck(exprVar))
      exprInstr ++ nullCheck ++ List(FreeInst(exprVar))
    case Statements.Return(expr) =>
      val (exprInstr, exprVar) = generateRvalue(expr)
      exprInstr ++ List(ReturnInst(exprVar))
    case Statements.Exit(expr) =>
      val (exprInstr, exprVar) = generateRvalue(expr)
      exprInstr ++ List(ExitInst(exprVar))
    case Statements.Print(expr) =>
      val (exprInstr, exprVar) = generateRvalue(expr)
      exprInstr ++ List(PrintInst(exprVar, false))
    case Statements.Println(expr) =>
      val (exprInstr, exprVar) = generateRvalue(expr)
      exprInstr ++ List(PrintInst(exprVar, true))
    case _ => List()
  }

  // Helper to transform TAC instructions to use register vars for parameters
  def transformTAC(
      instructions: List[TACInstruction],
      paramMapping: Map[String, RegisterVar]
  ): List[TACInstruction] = {
    instructions.map {
      case TACAssign(lhs, rhs) =>
        TACAssign(transformVar(lhs, paramMapping), transformVar(rhs, paramMapping))
      case BinaryOperation(op, left, right, dest) =>
        BinaryOperation(op, transformVar(left, paramMapping), transformVar(right, paramMapping), transformVar(dest, paramMapping))
      case UnaryOperation(op, expr, dest) =>
        UnaryOperation(op, transformVar(expr, paramMapping), transformVar(dest, paramMapping))
      case ArrayAccess(array, index, result) =>
        ArrayAccess(transformVar(array, paramMapping), index, transformVar(result, paramMapping))
      case ArrayStore(array, indices, value) =>
        ArrayStore(transformVar(array, paramMapping), indices, transformVar(value, paramMapping))
      case FstStore(pair, value) =>
        FstStore(transformVar(pair, paramMapping), transformVar(value, paramMapping))
      case SndStore(pair, value) =>
        SndStore(transformVar(pair, paramMapping), transformVar(value, paramMapping))
      case FstAccess(pair, dest) =>
        FstAccess(transformVar(pair, paramMapping), transformVar(dest, paramMapping))
      case SndAccess(pair, dest) =>
        SndAccess(transformVar(pair, paramMapping), transformVar(dest, paramMapping))
      case JumpIfZero(cond, label) =>
        JumpIfZero(transformVar(cond, paramMapping), label)
      case CallInst(func, args, dest) =>
        CallInst(func, args.map(arg => transformVar(arg, paramMapping)), transformVar(dest, paramMapping))
      case ReturnInst(expr) =>
        ReturnInst(transformVar(expr, paramMapping))
      case PrintInst(value, isLn) =>
        PrintInst(transformVar(value, paramMapping), isLn)
      case ReadInst(dest) =>
        ReadInst(transformVar(dest, paramMapping))
      case FreeInst(expr) =>
        FreeInst(transformVar(expr, paramMapping))
      case ExitInst(code) =>
        ExitInst(transformVar(code, paramMapping))
      case BoundsCheck(index, size) =>
        BoundsCheck(transformVar(index, paramMapping), transformVar(size, paramMapping))
      case NullCheck(ref) =>
        NullCheck(transformVar(ref, paramMapping))
      case NewPairAlloc(fst, snd, dest) =>
        NewPairAlloc(transformVar(fst, paramMapping), transformVar(snd, paramMapping), transformVar(dest, paramMapping))
      case NewArray(size, dest) =>
        NewArray(transformVar(size, paramMapping), transformVar(dest, paramMapping))
      case LoadAddress(dest, address) =>
        LoadAddress(transformVar(dest, paramMapping), transformVar(address, paramMapping))
      case LoadContent(dest, address, size) =>
        LoadContent(transformVar(dest, paramMapping), transformVar(address, paramMapping), size)
      case StoreContent(address, value, size) =>
        StoreContent(transformVar(address, paramMapping), transformVar(value, paramMapping), size)
      // Other instructions without variables don't need transformation
      case other => other
    }
  }

  // Helper to transform a variable if it's a parameter
  private def transformVar(v: Variable, paramMapping: Map[String, RegisterVar]): Variable = v match {
    case Var(name, _) if paramMapping.contains(name) => 
      // println(s"Transforming $name to register")
      paramMapping(name)
    case _ => 
      // println(s"Not transforming $v")
      v
  }

}
