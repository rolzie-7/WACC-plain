package wacc

import parsley.generic._
import parsley.generic
import ast.Types.Type
import parsley.errors.combinator._
import parsley.Parsley
import wacc.SemanticTypes.DebugT
import wacc.SemanticTypes.typeToSemanticType


object ast {

  object Types {
    sealed trait Type
    sealed trait PairElemType extends Type
    
    case class PairElemType1(val pos: (Int, Int)) extends PairElemType
    case object PairElemType1 extends ParserSingletonBridgePos[PairElemType] {
      protected def con(pos: (Int, Int)): PairElemType = PairElemType1(pos)
    }

    case class PairElemType2(t: Type)(val pos: (Int, Int)) extends PairElemType
    case object PairElemType2 extends ParserBridgePos1[Type, PairElemType]

    sealed trait BaseType extends Type with PairElemType

    case class ArrayType(t: Type)(val pos: (Int, Int))
        extends Type
        with PairElemType
    object ArrayType extends ParserBridgePos1[Type, ArrayType]

    case class PairType(t1: PairElemType, t2: PairElemType)(val pos: (Int, Int))
        extends Type
    object PairType
        extends ParserBridgePos2[PairElemType, PairElemType, PairType]

    case class IntType(val pos: (Int, Int)) extends BaseType
    case object IntType extends ParserSingletonBridgePos[BaseType] {
      protected def con(pos: (Int, Int)): BaseType = IntType(pos)
    }

    case class BoolType(val pos: (Int, Int)) extends BaseType
    case object BoolType extends ParserSingletonBridgePos[BaseType] {
      protected def con(pos: (Int, Int)): BaseType = BoolType(pos)
    }

    case class CharType(val pos: (Int, Int)) extends BaseType
    case object CharType extends ParserSingletonBridgePos[BaseType] {
      protected def con(pos: (Int, Int)): BaseType = CharType(pos)
    }

    case class StringType(val pos: (Int, Int)) extends BaseType
    case object StringType extends ParserSingletonBridgePos[BaseType] {
      protected def con(pos: (Int, Int)): BaseType = StringType(pos)
    }

    implicit class TypeCompare(t: Type) {
      def :>(that: Type): Boolean = (t, that) match {
        case (a: BaseType, b: BaseType) => a == b

        case (ArrayType(t1), ArrayType(t2)) =>
          t1 :> t2 && t2 :> t1

        case (t: StringType, ArrayType(t1: Type))     => true
        case (ArrayType(t: CharType), t1: StringType) => true

        case (PairType(p1, p2), PairType(t1, t2)) =>
          p1 :> t1 && p2 :> t2 && t1 :> p1 && t2 :> p2

        case _ => false
      }
    }
  }

  // Add TypeInfo trait
  trait TypeInfo {
    var semanticType: Option[SemanticType] = None
  }

  sealed trait Lvalue extends TypeInfo {
    def pos: (Int, Int)
  }

  sealed trait Rvalue extends TypeInfo {
    def pos: (Int, Int)
  }

  // Add TypeInfo to Expr
  sealed trait Expr extends Rvalue with Lvalue with TypeInfo {
    def pos: (Int, Int)
  }

  object BinaryOps {
    sealed trait BinaryOp extends Expr {
      def left: Expr
      def right: Expr
    }

    case class Add(left: Expr, right: Expr)(val pos: (Int, Int)) extends BinaryOp {
      semanticType = Some(SemanticTypes.IntT)
    }
    object Add extends ParserBridgePos2[Expr, Expr, Add] {

      def fold(left: Expr, right: Expr)(pos: (Int, Int)): Expr = (left, right) match {
        case (Literals.IntLit(v1), Literals.IntLit(v2)) => Literals.IntLit(v1 + v2)(pos)
        case _ => new Add(left, right)(pos)
      }
    }

    case class Sub(left: Expr, right: Expr)(val pos: (Int, Int)) extends BinaryOp {
      semanticType = Some(SemanticTypes.IntT)
    }
    object Sub extends ParserBridgePos2[Expr, Expr, Sub] {
  
      def fold(left: Expr, right: Expr)(pos: (Int, Int)): Expr = (left, right) match {
        case (Literals.IntLit(v1), Literals.IntLit(v2)) => Literals.IntLit(v1 - v2)(pos)
        case _ => new Sub(left, right)(pos)
      }
    }
  
    case class Mul(left: Expr, right: Expr)(val pos: (Int, Int)) extends BinaryOp {
      semanticType = Some(SemanticTypes.IntT)
    }
    object Mul extends ParserBridgePos2[Expr, Expr, Mul] {
  
      def fold(left: Expr, right: Expr)(pos: (Int, Int)): Expr = (left, right) match {
        case (Literals.IntLit(v1), Literals.IntLit(v2)) => Literals.IntLit(v1 * v2)(pos)
        case _ => new Mul(left, right)(pos)
      }
    }
  
    case class Div(left: Expr, right: Expr)(val pos: (Int, Int)) extends BinaryOp {
      semanticType = Some(SemanticTypes.IntT)
    }
    object Div extends ParserBridgePos2[Expr, Expr, Div] {
  
      def fold(left: Expr, right: Expr)(pos: (Int, Int)): Expr = (left, right) match {
        case (_, Literals.IntLit(0)) => throw new ArithmeticException("Division by zero at compile-time")
        case (Literals.IntLit(v1), Literals.IntLit(v2)) => Literals.IntLit(v1 / v2)(pos)
        case _ => new Div(left, right)(pos)
      }
      }
  
    case class Mod(left: Expr, right: Expr)(val pos: (Int, Int)) extends BinaryOp {
      semanticType = Some(SemanticTypes.IntT)
    }
    object Mod extends ParserBridgePos2[Expr, Expr, Mod] {
  
      def fold(left: Expr, right: Expr)(pos: (Int, Int)): Expr = (left, right) match {
        case (_, Literals.IntLit(0)) => throw new ArithmeticException("Modulo by zero at compile-time")
        case (Literals.IntLit(v1), Literals.IntLit(v2)) => Literals.IntLit(v1 % v2)(pos)
        case _ => new Mod(left, right)(pos)
      }
    }
  
    // Comparison Operations
    case class LT(left: Expr, right: Expr)(val pos: (Int, Int)) extends BinaryOp {
      semanticType = Some(SemanticTypes.BoolT)
    }
    object LT extends ParserBridgePos2[Expr, Expr, LT] {
  
      def fold(left: Expr, right: Expr)(pos: (Int, Int)): Expr = (left, right) match {
        case (Literals.IntLit(v1), Literals.IntLit(v2)) => Literals.BoolLit(v1 < v2)(pos)
        case (Literals.CharLit(c1), Literals.CharLit(c2)) => Literals.BoolLit(c1 < c2)(pos)
        case _ => new LT(left, right)(pos)
      }
    }
  
    case class LTE(left: Expr, right: Expr)(val pos: (Int, Int)) extends BinaryOp {
      semanticType = Some(SemanticTypes.BoolT)
    }
    object LTE extends ParserBridgePos2[Expr, Expr, LTE] {
  
      def fold(left: Expr, right: Expr)(pos: (Int, Int)): Expr = (left, right) match {
        case (Literals.IntLit(v1), Literals.IntLit(v2)) => Literals.BoolLit(v1 <= v2)(pos)
        case (Literals.CharLit(c1), Literals.CharLit(c2)) => Literals.BoolLit(c1 <= c2)(pos)
        case _ => new LTE(left, right)(pos)
      }
    }

    case class E(left: Expr, right: Expr)(val pos: (Int, Int)) extends BinaryOp {
      semanticType = Some(SemanticTypes.BoolT)
    }
    object E extends ParserBridgePos2[Expr, Expr, E] {

      def fold(left: Expr, right: Expr)(pos: (Int, Int)): Expr = (left, right) match {
        case (Literals.IntLit(v1), Literals.IntLit(v2)) => Literals.BoolLit(v1 == v2)(pos)
        case (Literals.CharLit(c1), Literals.CharLit(c2)) => Literals.BoolLit(c1 == c2)(pos)
        case _ => new E(left, right)(pos)
      }
    }

    case class NE(left: Expr, right: Expr)(val pos: (Int, Int)) extends BinaryOp {
      semanticType = Some(SemanticTypes.BoolT)
    }
    object NE extends ParserBridgePos2[Expr, Expr, NE] {

      def fold(left: Expr, right: Expr)(pos: (Int, Int)): Expr = (left, right) match {
        case (Literals.IntLit(v1), Literals.IntLit(v2)) => Literals.BoolLit(v1 != v2)(pos)
        case (Literals.CharLit(c1), Literals.CharLit(c2)) => Literals.BoolLit(c1 != c2)(pos)
        case _ => new NE(left, right)(pos)
      }
    }
    case class GT(left: Expr, right: Expr)(val pos: (Int, Int)) extends BinaryOp {
      semanticType = Some(SemanticTypes.BoolT)
    }
    object GT extends ParserBridgePos2[Expr, Expr, GT] {
    
      def fold(left: Expr, right: Expr)(pos: (Int, Int)): Expr = (left, right) match {
        case (Literals.IntLit(v1), Literals.IntLit(v2)) => Literals.BoolLit(v1 > v2)(pos)
        case (Literals.CharLit(c1), Literals.CharLit(c2)) => Literals.BoolLit(c1 > c2)(pos)
        case _ => new GT(left, right)(pos)
      }
    }
    
    case class GTE(left: Expr, right: Expr)(val pos: (Int, Int)) extends BinaryOp {
      semanticType = Some(SemanticTypes.BoolT)
    }
    object GTE extends ParserBridgePos2[Expr, Expr, GTE] {
    
      def fold(left: Expr, right: Expr)(pos: (Int, Int)): Expr = (left, right) match {
        case (Literals.IntLit(v1), Literals.IntLit(v2)) => Literals.BoolLit(v1 >= v2)(pos)
        case (Literals.CharLit(c1), Literals.CharLit(c2)) => Literals.BoolLit(c1 >= c2)(pos) 
        case _ => new GTE(left, right)(pos)
      }
    }

        // Logical Operations
    case class And(left: Expr, right: Expr)(val pos: (Int, Int)) extends BinaryOp {
      semanticType = Some(SemanticTypes.BoolT)
    }
    object And extends ParserBridgePos2[Expr, Expr, And] {
  
      def fold(left: Expr, right: Expr)(pos: (Int, Int)): Expr = (left, right) match {
        case (Literals.BoolLit(v1), Literals.BoolLit(v2)) => Literals.BoolLit(v1 && v2)(pos)
        case _ => new And(left, right)(pos)
      }
    }
  
    case class Or(left: Expr, right: Expr)(val pos: (Int, Int)) extends BinaryOp {
      semanticType = Some(SemanticTypes.BoolT)
    }
    object Or extends ParserBridgePos2[Expr, Expr, Or] {
  
      def fold(left: Expr, right: Expr)(pos: (Int, Int)): Expr = (left, right) match {
        case (Literals.BoolLit(v1), Literals.BoolLit(v2)) => Literals.BoolLit(v1 || v2)(pos)
        case _ => new Or(left, right)(pos)
      }
    }
    }
  
  
  object UnaryOps {
    sealed trait UnaryOp extends Expr {
      def expr: Expr
    }

    case class Not(expr: Expr)(val pos: (Int, Int)) extends UnaryOp {
      semanticType = Some(SemanticTypes.BoolT)
    }
    object Not extends ParserBridgePos1[Expr, Not] {
      def fold(expr: Expr)(pos: (Int, Int)): Expr = expr match {
        case Literals.BoolLit(v) => Literals.BoolLit(!v)(pos) 
        case _                   => new Not(expr)(pos)
      }
    }

    case class Neg(expr: Expr)(val pos: (Int, Int)) extends UnaryOp {
    semanticType = Some(SemanticTypes.IntT)
  }
    object Neg extends ParserBridgePos1[Expr, Neg] {
      def fold(expr: Expr)(pos: (Int, Int)): Expr = expr match {
        case Literals.IntLit(v) => Literals.IntLit(-v)(pos) 
        case _                   => new Neg(expr)(pos)
      }
    }

    case class Len(expr: Expr)(val pos: (Int, Int)) extends UnaryOp {
      semanticType = Some(SemanticTypes.IntT)
    }
    object Len extends ParserBridgePos1[Expr, Len]

    case class Ord(expr: Expr)(val pos: (Int, Int)) extends UnaryOp {
      semanticType = Some(SemanticTypes.IntT)
    }
    object Ord extends ParserBridgePos1[Expr, Ord]

    case class Chr(expr: Expr)(val pos: (Int, Int)) extends UnaryOp {
      semanticType = Some(SemanticTypes.CharT)
    }
    object Chr extends ParserBridgePos1[Expr, Chr]
  }

  object Literals {
    case class IntLit(value: BigInt)(val pos: (Int, Int)) extends Expr
    object IntLit extends ParserBridgePos1[BigInt, IntLit]

    case class BoolLit(value: Boolean)(val pos: (Int, Int)) extends Expr
    object BoolLit extends ParserBridgePos1[Boolean, BoolLit]

    case class CharLit(value: Char)(val pos: (Int, Int)) extends Expr
    object CharLit extends ParserBridgePos1[Char, CharLit]

    case class StrLit(value: String)(val pos: (Int, Int)) extends Expr
    object StrLit extends ParserBridgePos1[String, StrLit]

    case class PairLit(val pos: (Int, Int)) extends Expr
    object PairLit extends ParserSingletonBridgePos[PairLit] {
      protected def con(pos: (Int, Int)): PairLit = PairLit(pos)
    }
  }

  case class Ident(name: String)(val pos: (Int, Int)) extends Expr with Lvalue with TypeInfo {
    var trueName: String = s"Ident $name has not gotten a true name yet"
  }
  object Ident extends ParserBridgePos1[String, Ident]

  object Statements {
    sealed trait Stmt {
      def pos: (Int, Int)
      def optimize():Stmt = this
    }

    case class Skip(val pos: (Int, Int)) extends Stmt
    case object Skip extends ParserSingletonBridgePos[Stmt] {
      protected def con(pos: (Int, Int)): Stmt = Skip(pos)
    }

    // Declaration and Assignment
    case class Declare(typ: Type, id: Ident, rhs: Rvalue)(val pos: (Int, Int))
        extends Stmt with TypeInfo {
          override def optimize(): Declare = {
            //step 1: propagate constant in rhs
            val propagatedRhs = Optimizer.propagateRvalue(rhs)
            //step 2: fold constants (existing code)
            val foldedRhs = propagatedRhs match {
              case expr: Expr => ConstantFolder.foldExpr(expr)
              case other      => other
            }
            // step 3: update symbol table if rhs is a literal
            val semanticType = typeToSemanticType(typ)
            SymbolTable.getCurrentScope.add(id.name, semanticType)

            foldedRhs match {
              case lit: Literals.IntLit  =>
                SymbolTable.getCurrentScope.set(id.name, semanticType, Some(lit))
              case lit: Literals.BoolLit =>
                SymbolTable.getCurrentScope.set(id.name, semanticType, Some(lit))
              case lit: Literals.CharLit =>
                SymbolTable.getCurrentScope.set(id.name, semanticType, Some(lit))
              case lit: Literals.StrLit  =>
                SymbolTable.getCurrentScope.set(id.name, semanticType, Some(lit))
              case arrLit: Arrays.ArrayLit =>
                SymbolTable.getCurrentScope.setRvalue(id.name, semanticType, Some(arrLit))
              case pair: Pairs.NewPair =>
                SymbolTable.getCurrentScope.setRvalue(id.name, semanticType, Some(pair))
              case _ => // do nothing
            }           
            Declare(typ, id, foldedRhs)(pos)
          }          
          } 
    object Declare extends ParserBridgePos3[Type, Ident, Rvalue, Declare]

    case class Assign(lhs: Lvalue, rhs: Rvalue)(val pos: (Int, Int))
        extends Stmt {
      override def optimize(): Assign = {
        // Step 1: Propagate constant in rhs (only if it's an Expr)
        val propagatedRhs = Optimizer.propagateRvalue(rhs)

        // Step 2: Fold constant (if applicable)
        val foldedRhs = propagatedRhs match {
          case expr: Expr => ConstantFolder.foldExpr(expr) 
          case _ => propagatedRhs 
        }

        // Step 3: Update symbol table if possible

        (lhs, foldedRhs) match {
          case (id: Ident, Ident(name)) =>
            // Propagate constant value if variable is constant
            SymbolTable.getCurrentScope.lookupConstant(name).foreach { value =>
              SymbolTable.getCurrentScope.setRvalue(id.name, id.semanticType.getOrElse(DebugT("Unknown")), Some(value))
            }
          case (id: Ident, lit: Literals.IntLit) =>
            SymbolTable.getCurrentScope.set(id.name, id.semanticType.getOrElse(DebugT("Unknown")), Some(lit))

          case (id: Ident, lit: Literals.BoolLit) =>
            SymbolTable.getCurrentScope.set(id.name, id.semanticType.getOrElse(DebugT("Unknown")), Some(lit))

          case (id: Ident, lit: Literals.CharLit) =>
            SymbolTable.getCurrentScope.set(id.name, id.semanticType.getOrElse(DebugT("Unknown")), Some(lit))

          case (id: Ident, lit: Literals.StrLit) =>
            SymbolTable.getCurrentScope.set(id.name, id.semanticType.getOrElse(DebugT("Unknown")), Some(lit))

          case (id: Ident, arrLit: Arrays.ArrayLit) =>
            SymbolTable.getCurrentScope.setRvalue(id.name, id.semanticType.getOrElse(DebugT("Unknown")), Some(arrLit))
         // CASE: Assigning an entire pair to an identifier
          case (id: Ident, pair: Pairs.NewPair) =>
            println(s"DEBUG: Assigning pair ${id.name} in SymbolTable")
            SymbolTable.getCurrentScope.setRvalue(
              id.name,
              id.semanticType.getOrElse(DebugT("Unknown")),
              Some(pair)
            )
 
          // CASE: Assigning to fst(x)
          case (Pairs.Fst(ident: Ident), value: Expr) =>
            SymbolTable.getCurrentScope.lookupConstant(ident.name) match {
              case Some(existingPair: Pairs.NewPair) =>
                println(s"DEBUG: Updating fst of pair ${ident.name}")
                val newPair = Pairs.NewPair(value, existingPair.snd)(pos)
                SymbolTable.getCurrentScope.setRvalue(
                  ident.name,
                  ident.semanticType.getOrElse(DebugT("Unknown")),
                  Some(newPair)
                )
              case _ =>
                println(s"DEBUG: No existing pair found for ${ident.name}")
            }

          // CASE: Assigning to snd(x)
          case (Pairs.Snd(ident: Ident), value: Expr) =>
            SymbolTable.getCurrentScope.lookupConstant(ident.name) match {
              case Some(existingPair: Pairs.NewPair) =>
                println(s"DEBUG: Updating snd of pair ${ident.name}")
                val newPair = Pairs.NewPair(existingPair.fst, value)(pos)
                SymbolTable.getCurrentScope.setRvalue(
                  ident.name,
                  ident.semanticType.getOrElse(DebugT("Unknown")),
                  Some(newPair)
                )
              case _ =>
                println(s"DEBUG: No existing pair found for ${ident.name}")
            }


          case (arrayElem: Arrays.ArrayElem, expr: Expr) if arrayElem.indices.length == 1 =>
            // Ensure the array identifier exists in the symbol table
            val arrayId = arrayElem.array.asInstanceOf[Ident]
            val indexExpr = arrayElem.indices.head
                  // Ensure the index is an integer literal
            if (indexExpr.isInstanceOf[Literals.IntLit]) {
              val idx = indexExpr.asInstanceOf[Literals.IntLit].value.toInt
                    // Look up the array in the symbol table
              SymbolTable.getCurrentScope.lookupConstant(arrayId.name) match {
                case Some(arrayLit: Arrays.ArrayLit) =>
                  arrayLit.elements match {
                    case Some(elementsList) if idx >= 0 && idx < elementsList.length =>
                            // Update the element in the array
                      val updatedElements = elementsList.updated(idx, expr)
                      val updatedArray = Arrays.ArrayLit(Some(updatedElements))(pos)
                            // Store updated array in the symbol table
                      SymbolTable.getCurrentScope.setRvalue(arrayId.name, arrayId.semanticType.getOrElse(DebugT("Unknown")), Some(updatedArray))
                    case _ =>
                      println(s"DEBUG: Invalid array index or missing elements for ${arrayId.name}") // ⚠️ Debug log
                  }
          

                case _ =>
                  println(s"DEBUG: No existing array found in symbol table for ${arrayId.name}") // ⚠️ Debug log
              }
           }    
          case (Pairs.Fst(ident: Ident), value) =>
            SymbolTable.getCurrentScope.lookupConstant(ident.name) match {
              case Some(pairConstant: Pairs.NewPair) =>
                val newPair = Pairs.NewPair(value.asInstanceOf[Expr], pairConstant.snd.asInstanceOf[Expr])(pos)
                SymbolTable.getCurrentScope.setRvalue(ident.name, DebugT("Pair"), Some(newPair))
              case _ =>
            }

          case (Pairs.Snd(ident: Ident), value) =>
            SymbolTable.getCurrentScope.lookupConstant(ident.name) match {
              case Some(pairConstant: Pairs.NewPair) =>
                val newPair = Pairs.NewPair(pairConstant.fst.asInstanceOf[Expr], value.asInstanceOf[Expr])(pos)
                SymbolTable.getCurrentScope.setRvalue(ident.name, DebugT("Pair"), Some(newPair))
              case _ =>
            }


          case _ =>
            // Invalidate variable in symbol table if it's no longer a constant
            lhs match {
              case id: Ident =>
                SymbolTable.getCurrentScope.set(id.name, id.semanticType.getOrElse(DebugT("Unknown")), None)
              case _ => // Handle arrays/pairs later if needed
            }
        }
        Assign(lhs, foldedRhs)(pos)
      }
      }

      object Assign extends ParserBridgePos2[Lvalue, Rvalue, Assign]

    // IO Operations
    case class Read(lvalue: Lvalue)(val pos: (Int, Int)) extends Stmt
    object Read extends ParserBridgePos1[Lvalue, Read]

    case class Free(expr: Expr)(val pos: (Int, Int)) extends Stmt
    object Free extends ParserBridgePos1[Expr, Free]

    case class Return(expr: Expr)(val pos: (Int, Int)) extends Stmt
    object Return extends ParserBridgePos1[Expr, Return]

    case class Exit(expr: Expr)(val pos: (Int, Int)) extends Stmt
    object Exit extends ParserBridgePos1[Expr, Exit]

    case class Print(expr: Expr)(val pos: (Int, Int)) extends Stmt
    object Print extends ParserBridgePos1[Expr, Print]

    case class Println(expr: Expr)(val pos: (Int, Int)) extends Stmt
    object Println extends ParserBridgePos1[Expr, Println]

    // Control Flow
    case class IfThenElse(cond: Expr, thenStmt: Stmt, elseStmt: Stmt)(
        val pos: (Int, Int)
    ) extends Stmt
    object IfThenElse extends ParserBridgePos3[Expr, Stmt, Stmt, IfThenElse]

    case class WhileDo(cond: Expr, body: Stmt)(val pos: (Int, Int)) extends Stmt
    object WhileDo extends ParserBridgePos2[Expr, Stmt, WhileDo]

    case class BeginEnd(stmt: Stmt)(val pos: (Int, Int)) extends Stmt
    object BeginEnd extends ParserBridgePos1[Stmt, BeginEnd]

    case class StmtList(first: Stmt, second: Stmt)(val pos: (Int, Int))
        extends Stmt {
          override def optimize(): StmtList = {
            val optimizedFirst = first.optimize()
            val optimizedSecond = second.optimize()
            StmtList(optimizedFirst, optimizedSecond)(pos)
          }
        }
    object StmtList extends ParserBridgePos2[Stmt, Stmt, StmtList]
  }

  object Arrays {
    case class ArrayLit(elements: Option[List[Expr]])(val pos: (Int, Int))
        extends Rvalue with TypeInfo
    object ArrayLit extends ParserBridgePos1[Option[List[Expr]], ArrayLit]

    case class ArrayElem(array: Ident, indices: List[Expr])(val pos: (Int, Int))
        extends Expr with Lvalue with TypeInfo {
          def optimizeArrayElem(): ArrayElem = {
            // Propagate constant values in array and indices
           val newArray = Optimizer.propagateRvalue(array) match {
             case ident: Ident => ident 
             case other =>
               array
           }
        
           val newIndices = indices.map(Optimizer.propagateExpr)
           ArrayElem(newArray, newIndices)(pos) // ✅ Now accepts `Expr`
          }
        }
    object ArrayElem extends ParserBridgePos2[Ident, List[Expr], ArrayElem]

    object IdentOrArrayElem {
      def apply(ident: Ident, indices: List[Expr]) (pos: (Int, Int)): Expr = indices match {
        case Nil => ident
        case _   => ArrayElem(ident, indices)(pos)
      }
    }
  }

  object Pairs {
    case class NewPair(fst: Expr, snd: Expr)(val pos: (Int, Int)) extends Rvalue with TypeInfo
    object NewPair extends ParserBridgePos2[Expr, Expr, NewPair]

    sealed trait PairElem extends Lvalue with Rvalue with TypeInfo {
      def pos: (Int, Int)
    }

    case class Fst(pair: Lvalue)(val pos: (Int, Int)) extends PairElem
    object Fst extends ParserBridgePos1[Lvalue, Fst]

    case class Snd(pair: Lvalue)(val pos: (Int, Int)) extends PairElem
    object Snd extends ParserBridgePos1[Lvalue, Snd]
  }

  object Functions {
    case class Program(functions: List[Func], main: Statements.Stmt)(val pos: (Int, Int))
        extends Statements.Stmt {
          override def optimize(): Program = {
            println(s"DEBUG: Optimizing Program") //debug log
            val optimizedMain = main.optimize()
            val optimizedFunctions = functions.map(_.optimize())
            Program(optimizedFunctions, optimizedMain)(pos)
          }
        }
    object Program extends ParserBridgePos2[List[Func], Statements.Stmt, Program]

    case class Func(
        returnType: Type,
        name: Ident,
        params: ParamList,
        body: Statements.Stmt
    )(val pos: (Int, Int))
        extends Statements.Stmt with TypeInfo{
          //ensure functions can be optimized
          override def optimize(): Func = {
            val optimizedBody = body.optimize()
            Func(returnType, name, params, optimizedBody)(pos)
          }
        }
    object Func
        extends ParserBridgePos4[
          Type,
          Ident,
          ParamList,
          Statements.Stmt,
          Func
        ] {
      def isValidFunctionEnd(stmt: Statements.Stmt): Boolean = stmt match {
        case Statements.Return(_)         => true
        case Statements.Exit(_)           => true
        case Statements.StmtList(_, stmt) => isValidFunctionEnd(stmt)
        case Statements.IfThenElse(_, thenStmt, elseStmt) =>
          isValidFunctionEnd(thenStmt) && isValidFunctionEnd(elseStmt)
        case Statements.BeginEnd(stmt) => isValidFunctionEnd(stmt)
        case _                         => false
      }
      override def apply(
          returnType: Parsley[Type],
          name: => Parsley[Ident],
          params: => Parsley[ParamList],
          body: => Parsley[Statements.Stmt]
      ): Parsley[Func] =
        super.apply(returnType, name, params, body).guardAgainst {
          case Func(_, _, _, body) if !isValidFunctionEnd(body) =>
            Seq(
              s"Function body does not end with a return or exit" +
              s" statement or an if statement with two returning blocks"
            )
        }
    }

    case class Call(function: Ident, args: Option[ArgList])(val pos: (Int, Int))
        extends Rvalue with TypeInfo
    object Call extends ParserBridgePos2[Ident, Option[ArgList], Call]

    case class ParamList(params: List[Param])
    object ParamList extends ParserBridge1[List[Param], ParamList]

    case class Param(typ: Type, name: Ident)
    object Param extends ParserBridge2[Type, Ident, Param]

    case class ArgList(args: List[Expr])
    object ArgList extends ParserBridge1[List[Expr], ArgList]
  }

}
