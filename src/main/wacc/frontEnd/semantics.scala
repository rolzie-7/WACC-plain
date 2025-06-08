package wacc

import SymbolTable._
import wacc.Errors._ 
import wacc.ast.Literals._
import wacc.ast.Arrays._
import wacc.ast._
import wacc.ast.Types._
import wacc.ast.Functions._
import wacc.ast.Statements._
import wacc.ast.BinaryOps._
import wacc.ast.UnaryOps._
import wacc.ast.Pairs._
// import wacc.ast.{Ident, Expr}

import scala.language.implicitConversions

import SemanticsChecker._
import TypeGetter._
import SemanticTypes._
import ErrorCollector._

sealed abstract class SemanticType {
  def intersect(other: SemanticType): SemanticType = SemanticTypes.intersect(this, other)
}

case object Any extends SemanticType
object SemanticTypes {
  case object IntT extends SemanticType
  case object CharT extends SemanticType
  case object StringT extends SemanticType
  case object BoolT extends SemanticType
  case class ArrayT(baseType: SemanticType) extends SemanticType
  case class PairT(first: SemanticType, second: SemanticType) extends SemanticType
  case class DebugT(string: String) extends SemanticType
  // pair erased == PairT(Any, Any)
  case object Nothing extends SemanticType

  implicit def typeToSemanticType(t: Type): SemanticType = astToSemanticType(t)

  def astToSemanticType(t: Type): SemanticType = t match {
    case Types.IntType(pos) => IntT
    case Types.CharType(pos) => CharT
    case Types.StringType(pos) => StringT
    case Types.BoolType(pos) => BoolT
    case Types.ArrayType(baseType) => ArrayT(astToSemanticType(baseType))
    case Types.PairType(first, second) => PairT(astToSemanticType(first), astToSemanticType(second))
    case Types.PairElemType2(baseType) => astToSemanticType(baseType)
    case Types.PairElemType1(_,_) => PairT(Any, Any)
  }

  def intersect(t1: SemanticType, t2: SemanticType): SemanticType = (t1, t2) match {
    case (ArrayT(t1), ArrayT(t2)) => ArrayT(intersect(t1, t2))
    case (PairT(t1, t2), PairT(t3, t4)) => PairT(intersect(t1, t3), intersect(t2, t4))
    case (t1, t2) => typeReduce(t1, t2)
  }
}

object TypeGetter {
  // variables are handled in the symbol table
  // functions are handled in the function table
  // lvalues are handled here
  // ⟨lvalue⟩ ::= ⟨ident⟩ | ⟨array-elem⟩ | ⟨pair-elem⟩
  def getFstType(pair: Lvalue): SemanticType = {
    val t = getLvalueType(pair)
    t match {
      case PairT(fstType, _) => 
        pair.asInstanceOf[TypeInfo].semanticType = Some(t)
        fstType
      case other =>
        addError(InvalidPairElementError("fst", other, pair.pos))
        DebugT(s"Cannot apply 'fst' to non-pair type $other")
    }
  }

  def getSndType(pair: Lvalue): SemanticType = {
    val t = getLvalueType(pair)
    t match {
      case PairT(_, sndType) => 
        pair.asInstanceOf[TypeInfo].semanticType = Some(t)
        sndType
      case other =>
        addError(InvalidPairElementError("snd", other, pair.pos))
        DebugT(s"Cannot apply 'snd' to non-pair type $other")
    }
  }

  def getLvalueType(lvalue: Lvalue): SemanticType = lvalue match {
    case ident @ Ident(name) =>
      SymbolTable.lookup(name) match {
        case Some(t) => 
          ident.semanticType = Some(t)
          ident.trueName = SymbolTable.getTrueName(name)
          t
        case None =>
          addError(UndeclaredIdentifierError(name, lvalue.pos))
          DebugT(s"Undeclared identifier in getLvalueType '$name'")
      }
    case arrElem @ ArrayElem(ident, indices) =>
      SymbolTable.lookup(ident.name) match {
        case Some(ArrayT(elemType)) => 
          ident.semanticType = Some(ArrayT(elemType))
          ident.trueName = SymbolTable.getTrueName(ident.name)
          arrElem.semanticType = Some(elemType)
          indices.foreach(index => {
            checkExpr(index)
          })
          elemType
        case Some(t) =>
          addError(ArrayTypeError(ident.name, lvalue.pos))
          DebugT(s"Expected array type for '${ident.name}' but found $t")
        case None =>
          addError(UndeclaredIdentifierError(ident.name, lvalue.pos))
          DebugT(s"Undeclared identifier '${ident.name}' used as array")
      }
    case Fst(pair) => getFstType(pair)
    case Snd(pair) => getSndType(pair)
    case _ => DebugT("Unknown lvalue type")
  }

  def getRvalueType(rvalue: Rvalue): SemanticType = rvalue match {
    case rvalue: Expr =>
      val t = checkExpr(rvalue)
      rvalue.semanticType = Some(t)
      t
    
    case arrayLit @ ArrayLit(elemsOpt) =>
      elemsOpt match {
        case Some(elems) =>
          val types = elems.map(checkExpr)
          if (types.distinct.length <= 1)
            val t = ArrayT(types.headOption.getOrElse(DebugT("Empty array literal")))
            arrayLit.semanticType = Some(t)
            t
          else if (types.forall(t => t == StringT || t == ArrayT(CharT))) {
            val t = ArrayT(StringT)
            arrayLit.semanticType = Some(t)
            t
          } else {
            addError(MultipleTypesInArrayError(rvalue.pos))
            DebugT("Array with inconsistent element types")
          }
        case None => 
          val t = ArrayT(Any)
          arrayLit.semanticType = Some(t)
          t
      }

    case newPair @ NewPair(fst, snd) =>
      val t1 = checkExpr(fst)
      val t2 = checkExpr(snd)
      val t = PairT(t1, t2)
      newPair.semanticType = Some(t)
      t

    case fst @ Fst(pair) => 
      val t = getFstType(pair)
      fst.semanticType = Some(t)
      t

    case snd @ Snd(pair) =>
      val t = getSndType(pair)
      snd.semanticType = Some(t)
      t
      
    case call @ Call(func, argsOpt) =>
      SymbolTable.functionLookup(func.name) match {
        case Some(FunctionInfo(returnType, paramList)) =>
          func.semanticType = Some(returnType)
          argsOpt match {
            case Some(args) =>
              if (args.args.length != paramList.params.length) {
                addError(NumOfArgumentsError(func, paramList.params.length, args.args.length, rvalue.pos))
                DebugT(s"Wrong number of arguments for function '${func.name}'")
              } else {
                val argTypes = args.args.map(checkExpr)
                if (paramList.params.zip(argTypes).forall { case (param, arg) =>
                      typeCompatibility(param.typ, arg)
                    })
                  returnType
                else {
                  addError(TypeError("Function call",
                    paramList.params.map(param => astToSemanticType(param.typ)).toSet,
                    argTypes.toSet,
                    rvalue.pos))
                  DebugT(s"Type mismatch in function call to '${func.name}'")
                }
              }
            case None =>
              if (paramList.params.isEmpty) returnType
              else {
                addError(NumOfArgumentsError(func, paramList.params.length, 0, rvalue.pos))
                DebugT(s"Missing arguments for function '${func.name}'")
              }
          }
          argsOpt.foreach(args => 
            args.args.foreach(arg => {
              val t = checkExpr(arg)
              arg.semanticType = Some(t)
            })
          )
          call.semanticType = func.semanticType
          call.semanticType.getOrElse(DebugT("Call type not set"))
        case None =>
          addError(UndefinedFunctionError(func.name, rvalue.pos))
          DebugT(s"Undefined function '${func.name}'")
      }
  }

  def typeCompatibility(lhs: SemanticType, rhs: SemanticType): Boolean = (lhs, rhs) match {
    case (StringT, ArrayT(CharT)) => true
    case (ArrayT(CharT), StringT) => false
    case (ArrayT(t1), ArrayT(t2)) => invariantCompatibility(t1, t2)
    case (PairT(t1, t2), PairT(r1, r2)) => invariantCompatibility(t1, r1) && invariantCompatibility(t2, r2)
    case (Any, t) => true
    case (t, Any) => true
    case (t1, t2) => t1 == t2
  }

  def invariantCompatibility(lhs: SemanticType, rhs: SemanticType): Boolean = (lhs, rhs) match {
    case (Any, _) => true
    case (_, Any) => true
    case (ArrayT(t1), ArrayT(t2)) => invariantCompatibility(t1, t2)
    case (PairT(t1, t2), PairT(r1, r2)) => invariantCompatibility(t1, r1) && invariantCompatibility(t2, r2)
    case (t1, t2) => t1 == t2
  }

  def typeReduce(lhs: SemanticType, rhs: SemanticType): SemanticType = (lhs, rhs) match {
    case (StringT, ArrayT(CharT)) => StringT
    case (ArrayT(CharT), StringT) => StringT
    case (t1, t2) => if (t1 == t2) t1 else Any
  }

  def getLvalueIdent(lvalue: Lvalue): Ident = lvalue match {
    case ident @ Ident(name) => 
      ident.trueName = SymbolTable.getTrueName(name)
      ident
    case ArrayElem(ident, _) => 
      ident.trueName = SymbolTable.getTrueName(ident.name)
      ident
    case Fst(pair) => getLvalueIdent(pair)
    case Snd(pair) => getLvalueIdent(pair)
    case _ => Ident("_")(lvalue.pos)
  }
}

object SemanticsChecker {

  def scope[A](block: => A): A = {
    enterScope()
    try {
      block
    } finally {
      exitScope()
    }
  }

  def check(stmt: Statements.Stmt): SemanticType = stmt match {
    case BeginEnd(stmt) =>
      scope {
        check(stmt)
      }

    case StmtList(stmt1, stmt2) =>
      check(stmt1)
      check(stmt2)

    case IfThenElse(cond, thenStmt, elseStmt) =>
      val condType = checkExpr(cond)
      if (condType == BoolT) {
        scope { check(thenStmt) }
        scope { check(elseStmt) }
        BoolT
      } else {
        addError(InvalidConditionError("if", condType, stmt.pos))
        BoolT
      }

    case WhileDo(cond, whileBody) =>
      val condType = checkExpr(cond)
      if (condType == BoolT) {
        scope { check(whileBody) }
        BoolT
      } else {
        addError(InvalidConditionError("while", condType, stmt.pos))
        BoolT
      }

    case Read(lvalue) =>
      val lType = getLvalueType(lvalue)
      lType match {
        case IntT | CharT => IntT
        case other =>
          addError(InvalidOperandError("read", IntT, other, stmt.pos))
          IntT
      }

    case Exit(expr) =>
      val t = checkExpr(expr)
      if (t == IntT) IntT
      else {
        addError(InvalidOperandError("exit", IntT, t, stmt.pos))
        IntT
      }

    case Free(expr) =>
      val t = checkExpr(expr)
      t match {
        case t @ (ArrayT(_) | PairT(_, _)) => t
        case _ =>
          addError(FreeingError(stmt.pos))
          t
      }

    case Return(expr) =>
      SymbolTable.getReturnType() match {
        case Some(expected) =>
          val found = checkExpr(expr)
          if (found == Any) {
            addError(ScopeError("outside function", stmt.pos))
            DebugT("Return statement outside function")
            expected
          } else if (typeCompatibility(expected, found)) {
            expected
          } else {
            addError(TypeError("Return", Set(expected), Set(found), stmt.pos))
            expected
          }
        case None =>
          addError(ScopeError("outside function", stmt.pos))
          DebugT("Return statement outside function")
      }

    case Program(funcs, stmt) =>
      // PRECOND: we are in global scope (no parent scope)
      SymbolTable.clear()
      funcs.foreach { func =>
        if (SymbolTable.functionLookup(func.name.name).isDefined) {
          addError(FunctionRedefinitionError(func.name.name, func.name.pos))
        } else {
          SymbolTable.addFunction(func.name.name, func.returnType, func.params)
        }
      }
      funcs.foreach(func => check(func))
      scope {
        check(stmt)
      }

    case Func(returnType, name, paramList, body) =>
      if (!SymbolTable.isGlobalScope) {
        addError(ScopeError("function declaration", stmt.pos))
        DebugT("Nested function declaration not allowed")
      } else {
        val paramNames = paramList.params.map(_.name.name)
        if (paramNames.distinct.length != paramNames.length) {
          addError(UndefinedError(stmt.pos))
          DebugT("Duplicate parameter names in function")
        } else {
          SymbolTable.functionLookup(name.name) match {
            case Some(_) =>
              name.semanticType = Some(returnType)
              scope {
                paramList.params.foreach(param => 
                  SymbolTable.add(param.name.name, param.typ)
                  param.name.trueName = SymbolTable.getTrueName(param.name.name)
                )
                SymbolTable.setReturnType(returnType)
                scope {
                  check(body)
                }
              }
            case None =>
              addError(UndefinedFunctionError(name.name, stmt.pos))
              DebugT(s"Undefined function '${name.name}'")
          }
        }
      }

    case decl @Declare(typ, id, rhs) =>
      val rhsType = getRvalueType(rhs)
      if (typeCompatibility(typ, rhsType) && !SymbolTable.localLookup(id.name).isDefined) {
        SymbolTable.add(id.name, typ)
        id.trueName = SymbolTable.getTrueName(id.name)
        decl.semanticType = Some(typ)
        id.semanticType = Some(typ)
        typ
      } else if (SymbolTable.localLookup(id.name).isDefined) {
        addError(RedeclarationError(id.name, stmt.pos))
        DebugT(s"Redeclaration of '${id.name}'")
      } else {
        SymbolTable.add(id.name, typ)
        id.trueName = SymbolTable.getTrueName(id.name)
        id.semanticType = Some(typ)
        decl.semanticType = Some(typ)
        addError(TypeError("Declaration", Set(typ), Set(rhsType), stmt.pos))
        DebugT(s"Type mismatch in declaration of '${id.name}'")
      }

    case Assign(lhs: Lvalue, rhs: Rvalue) =>
      val lhsType = getLvalueType(lhs)
      val rhsType = getRvalueType(rhs)
      val ident = getLvalueIdent(lhs)
      val lookup = SymbolTable.lookup(ident.name)
      if (lookup.isDefined) {
        ident.semanticType = Some(lookup.get)
        ident.trueName = SymbolTable.getTrueName(ident.name)
      }
      if (lookup.isEmpty) {
        addError(UndeclaredIdentifierError(ident.name, stmt.pos))
        DebugT(s"Assignment to undeclared variable '${ident.name}'")
      } else if ((lhs.isInstanceOf[Fst] || lhs.isInstanceOf[Snd]) && lhsType == Any && rhsType == Any) {
        addError(TypeError("Assignment not legal when pair element type is unknown", Set(lhsType), Set(rhsType), stmt.pos))
        DebugT("Cannot assign to pair element with unknown type")
      } else (lhsType, rhsType) match {
        case (ArrayT(elemType), t) if lhs.isInstanceOf[ArrayElem] && typeCompatibility(elemType, t) =>
          lhs.semanticType = Some(t)
          rhs.semanticType = Some(t)
          t
        case (Any, t) if t != Any =>
          lhs.semanticType = Some(t)
          rhs.semanticType = Some(t)
          t
        case (l, Any) if l != Any =>
          lhs.semanticType = Some(l)
          rhs.semanticType = Some(l)
          l
        case (l, r) if typeCompatibility(l, r) =>
          lhs.semanticType = Some(r)
          rhs.semanticType = Some(r)
          r
        case (l, r) =>
          addError(TypeError("Assignment", Set(l), Set(r), stmt.pos))
          DebugT(s"Type mismatch in assignment of '${ident.name}'")
      }
    
    case Print(expr) =>
      checkExpr(expr)
    case Println(expr) =>
      checkExpr(expr)
    case _ => DebugT("Unknown statement type")
  }

  def checkExpr(expr: Expr): SemanticType = {
    val typ = expr match {
      case ident @ Ident(name) =>
        SymbolTable.lookup(name) match {
          case Some(t) =>
            ident.semanticType = Some(t)
            ident.trueName = SymbolTable.getTrueName(name)
            t
          case None =>
            addError(UndeclaredIdentifierError(name, expr.pos))
            DebugT(s"Undeclared identifier in checkExpr '$name'")
        }
      
      case intLit @ IntLit(_) =>
        intLit.semanticType = Some(IntT)
        IntT
        
      case boolLit @ BoolLit(_) =>
        boolLit.semanticType = Some(BoolT)
        BoolT
        
      case charLit @ CharLit(_) =>
        charLit.semanticType = Some(CharT)
        CharT
        
      case strLit @ StrLit(_) =>
        strLit.semanticType = Some(StringT)
        StringT
        
      case pairLit @ Literals.PairLit(_) =>
        PairT(Any, Any)

      case arrElem @ Arrays.ArrayElem(ident, indices) =>
        val baseType = SymbolTable.lookup(ident.name) match {
          case Some(t) => 
            ident.semanticType = Some(t)
            ident.trueName = SymbolTable.getTrueName(ident.name)
            arrElem.semanticType = Some(t)
            t
          case None =>
            addError(UndeclaredIdentifierError(ident.name, expr.pos))
            DebugT(s"Undeclared array identifier '${ident.name}'")
        }
        baseType match {
          case ArrayT(_) => 
          case _ =>
            addError(ArrayTypeError(ident.name, expr.pos))
            return DebugT(s"'${ident.name}' is not an array")
        }
        val dimensions = countArrayDimensions(baseType)
        if (indices.length > dimensions) {
          addError(ArrayDimensionalError(indices.length, dimensions, expr.pos))
          return DebugT(s"Array access with too many indices (${indices.length} > $dimensions)")
        }
        indices.forall { idx =>
          val idxType = checkExpr(idx)
          if (idxType != IntT) {
            addError(TypeError("Array index", Set(IntT), Set(idxType), expr.pos))
            false
          } else true
        } match {
          case true => baseType match {
            case ArrayT(t) => t
            case _ =>
              addError(ArrayTypeError(ident.name, expr.pos))
              DebugT(s"'${ident.name}' is not an array")
          }
          case false => DebugT("Invalid array index type")
        }

      case op @ (BinaryOps.E(_, _) | BinaryOps.NE(_, _)) =>
        val lType = checkExpr(op.left)
        val rType = checkExpr(op.right)
        op.semanticType = Some(BoolT)
        (lType, rType) match {
          case (PairT(_, _), PairT(Any, Any)) => BoolT
          case (PairT(Any, Any), PairT(_, _)) => BoolT
          case (l, r) if l == r => BoolT
          case (l, r) =>
            addError(TypeError("Comparison", Set(l), Set(r), expr.pos))
            BoolT
        }
      case op @ (
        BinaryOps.LT(_, _) | BinaryOps.GT(_, _) | 
        BinaryOps.LTE(_, _) | BinaryOps.GTE(_, _)
      ) =>
        val lType = checkExpr(op.left)
        val rType = checkExpr(op.right)
        op.semanticType = Some(BoolT)
        if ((lType == IntT && rType == IntT) || (lType == CharT && rType == CharT))
          BoolT
        else {
          val expectedType = if (lType == IntT || rType == IntT) IntT else CharT
          addError(InvalidOperandError("comparison operator", expectedType, lType, op.pos))
          BoolT
        }
      case op @ (BinaryOps.And(_, _) | BinaryOps.Or(_, _)) =>
        val lType = checkExpr(op.left)
        val rType = checkExpr(op.right)
        op.semanticType = Some(BoolT)
        if (lType == BoolT && rType == BoolT) BoolT
        else {
          addError(InvalidOperandError("boolean operator", BoolT, lType, expr.pos))
          BoolT
        }

      case op @ (_: BinaryOps.Add | _: BinaryOps.Sub | 
                 _: BinaryOps.Mul | _: BinaryOps.Div | 
                 _: BinaryOps.Mod) =>
        op.semanticType = Some(IntT)
        processBinaryOp(op.left, op.right)

      case op @UnaryOps.Not(e) =>
        val t = checkExpr(e)
        op.semanticType = Some(BoolT)
        if (t == BoolT) BoolT
        else {
          addError(InvalidOperandError("!", BoolT, t, expr.pos))
          BoolT
        }
      case op @ UnaryOps.Neg(e) =>
        val t = checkExpr(e)
        op.semanticType = Some(IntT)
        if (t == IntT) IntT
        else {
          addError(InvalidOperandError("-", IntT, t, expr.pos))
          IntT
        }
      case op @ UnaryOps.Len(e) =>
        op.semanticType = Some(IntT)
        val t = checkExpr(e)
        t match {
          case ArrayT(_) => IntT
          case other =>
            addError(InvalidOperandError("len", ArrayT(Any), other, expr.pos))
            IntT
        }
      case op @ UnaryOps.Ord(e) =>
        op.semanticType = Some(IntT)
        val t = checkExpr(e)
        if (t == CharT) IntT
        else {
          addError(InvalidOperandError("ord", CharT, t, expr.pos))
          IntT
        }
      case op @ UnaryOps.Chr(e) =>
        val t = checkExpr(e)
        op.semanticType = Some(CharT)
        if (t == IntT) CharT
        else {
          addError(InvalidOperandError("chr", IntT, t, expr.pos))
          CharT
        }
    }
    expr.semanticType = Some(typ)
    typ
  }

  def processBinaryOp(
      left: Expr,
      right: Expr,
  ): SemanticType = {
    val lType = checkExpr(left)
    val rType = checkExpr(right)
    (lType, rType) match {
      case (IntT, IntT) => IntT
      case (IntT, _) => 
        addError(InvalidOperandError("arithmetic operator", IntT, rType, right.pos))
        IntT
      case (_, IntT) => 
        addError(InvalidOperandError("arithmetic operator", IntT, lType, left.pos))
        IntT
      case (_, _) =>
        addError(InvalidOperandError("arithmetic operator", IntT, lType, left.pos))
        addError(InvalidOperandError("arithmetic operator", IntT, rType, right.pos))
        IntT
    }
  }

  def countArrayDimensions(t: SemanticType): Int = t match {
    case ArrayT(baseType) => 1 + countArrayDimensions(baseType)
    case _ => 0
  }

  def isStrongerType(t1: SemanticType, t2: SemanticType): Boolean = (t1, t2) match {
    case (ArrayT(_), StringT) => true
    case (PairT(Any, Any), PairT(_, _)) => true
    case _ => false
  }
}
