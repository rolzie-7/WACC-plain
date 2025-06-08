package wacc

import wacc.ast._
import ast.Statements._
import ast.BinaryOps._
import wacc.SemanticTypes.{DebugT, typeToSemanticType} // Fix: Import DebugT & type conversion

object Optimizer {

  // Helper function for propagating constants
  def propagateExpr(expr: Expr): Expr = {
    println(s"DEBUG: Propagating expression: $expr") // Debug log

    val propagated = expr match {
      case Ident(name) =>
        val lookupResult = SymbolTable.getCurrentScope.lookupConstant(name)
        println(s"DEBUG: Lookup constant for identifier '$name': $lookupResult") // Debug log
        lookupResult match {
          case Some(lit: Literals.IntLit)  => 
            val res = Literals.IntLit(lit.value)(expr.pos)
            res
          case Some(lit: Literals.BoolLit) => 
            val res = Literals.BoolLit(lit.value)(expr.pos)
            res
          case Some(lit: Literals.CharLit) =>
            val res = Literals.CharLit(lit.value)(expr.pos)
            res
          case Some(lit: Literals.StrLit)  =>
            val res = Literals.StrLit(lit.value)(expr.pos)
            res
          case _ =>
            expr
        }

      case op: BinaryOps.BinaryOp =>
        println(s"DEBUG: Propagating binary operation: $op") //  Debug log
        val leftProp  = propagateExpr(op.left)
        val rightProp = propagateExpr(op.right)
        val result = op match {
          case BinaryOps.Add(_, _)  => BinaryOps.Add.fold(leftProp, rightProp)(expr.pos)
          case BinaryOps.Sub(_, _)  => BinaryOps.Sub.fold(leftProp, rightProp)(expr.pos)
          case BinaryOps.Mul(_, _)  => BinaryOps.Mul.fold(leftProp, rightProp)(expr.pos)
          case BinaryOps.Div(_, _)  => BinaryOps.Div.fold(leftProp, rightProp)(expr.pos)
          case BinaryOps.Mod(_, _)  => BinaryOps.Mod.fold(leftProp, rightProp)(expr.pos)
          case BinaryOps.And(_, _)  => BinaryOps.And.fold(leftProp, rightProp)(expr.pos)
          case BinaryOps.Or(_, _)   => BinaryOps.Or.fold(leftProp, rightProp)(expr.pos)
          case BinaryOps.E(_, _)    => BinaryOps.E.fold(leftProp, rightProp)(expr.pos)
          case BinaryOps.NE(_, _)   => BinaryOps.NE.fold(leftProp, rightProp)(expr.pos)
          case BinaryOps.LT(_, _)   => BinaryOps.LT.fold(leftProp, rightProp)(expr.pos)
          case BinaryOps.LTE(_, _)  => BinaryOps.LTE.fold(leftProp, rightProp)(expr.pos)
          case BinaryOps.GT(_, _)   => BinaryOps.GT.fold(leftProp, rightProp)(expr.pos)
          case BinaryOps.GTE(_, _)  => BinaryOps.GTE.fold(leftProp, rightProp)(expr.pos)
        }
        println(s"DEBUG: Folded binary operation result: $result") // Debug log
        result
      case op: UnaryOps.UnaryOp =>
        println(s"DEBUG: Propagating unary operation: $op") //debug log
        val innerProp = propagateExpr(op.expr)
        val result = op match {
          case UnaryOps.Not(_) =>
            val folded = UnaryOps.Not.fold(innerProp)(expr.pos)
            folded

          case UnaryOps.Neg(_) =>
            val folded = UnaryOps.Neg.fold(innerProp)(expr.pos)
            folded

          case UnaryOps.Len(_) =>
            val folded = UnaryOps.Len(innerProp)(expr.pos)
            folded

          case UnaryOps.Ord(_) =>
            val folded = UnaryOps.Ord(innerProp)(expr.pos)
            folded

          case UnaryOps.Chr(_) =>
            val folded = UnaryOps.Chr(innerProp)(expr.pos)
            folded
        }
        result
    
      case _ =>
        println(s"DEBUG: Expression unchanged: $expr") //  Debug log
        expr
    }

    println(s"DEBUG: Result after propagation: $propagated") // Debug log
    propagated
  }

  // Propagates constants for Rvalues (handles arrays & pairs)
  def propagateRvalue(rvalue: Rvalue): Rvalue = {
  println(s"DEBUG: Propagating Rvalue (type: ${rvalue.getClass.getSimpleName}): $rvalue")

  val propagated: Rvalue = rvalue match {
    case Ident(name) =>
      SymbolTable.getCurrentScope.lookupConstant(name) match {
        case Some(pair: Pairs.NewPair) =>
          println(s"DEBUG: Found NewPair for $name in SymbolTable, propagaying")
          pair
        case Some(expr: Expr) =>
          println(s"DEBUG Found Expr for $name in SymbolTable")
          propagateExpr(expr)
        case _ =>
          rvalue
      }
    case arrElem @ Arrays.ArrayElem(array, indices) =>
      println(s"DEBUG: Attempting to optimize ArrayElem access: $arrElem")
      val newIndices = indices.map(propagateExpr)
      array match {
        case Ident(name) =>
          val lookupResult = SymbolTable.getCurrentScope.lookupConstant(name)
          println(s"DEBUG: Lookup result for $name in SymbolTable: $lookupResult")
          lookupResult match {
            case Some(pair: Pairs.NewPair) =>
              println(s"DEBUG: Replacing identifier $name with stored pair $pair") 
              pair
            case Some(arrLit: Arrays.ArrayLit) if newIndices.length == 1 =>
              newIndices.head match {
                case Literals.IntLit(idx) if idx >= 0 && idx < arrLit.elements.get.length =>
                  arrLit.elements.get(idx.toInt)
                case _ =>
                  Arrays.ArrayElem(array, newIndices)(rvalue.pos)
              }
            case _ =>
              println(s"DEBUG: Array ${name} is not a constant, keeping ArrayElem")
              Arrays.ArrayElem(array, newIndices)(rvalue.pos)
          }
      }

    case expr: Expr =>
      println("DEBUG: Treating as general Expr")
      propagateExpr(expr)

    case Pairs.NewPair(fst, snd) =>
      println(s"DEBUG: Propagating NewPair ($fst, $snd) for optimization")
      val optimizedFst = propagateRvalue(fst)
      val optimizedSnd = propagateRvalue(snd)
      println(s"DEBUG: Optimized NewPair -> ($optimizedFst, $optimizedSnd)")
      (optimizedFst, optimizedSnd) match {
        case (fstExpr: Expr, sndExpr: Expr) =>
          val optimizedPair = Pairs.NewPair(fstExpr, sndExpr)(rvalue.pos)
          optimizedPair
        case _ =>
          println(s"DEBUG: Failed to optimize NewPair due to type mismatch: ($optimizedFst, $optimizedSnd)")
          rvalue // Return the original value if optimization isn't valid
        }
    case Pairs.Fst(Ident(name)) =>
      println(s"DEBUG: Propagating Fst of $name")
      SymbolTable.getCurrentScope.lookupPairElement(name, "fst") match {
        case Some(fst: Expr) =>
          println(s"DEBUG: Propagated Fst to $fst")
          propagateRvalue(fst)
        case _ =>
          Pairs.Fst(Ident(name).asInstanceOf[Lvalue])(rvalue.pos)
     
      }

    case Pairs.Snd(Ident(name)) =>
      println(s"DEBUG: Propagating Snd of $name")
      SymbolTable.getCurrentScope.lookupPairElement(name, "snd") match {
        case Some(snd: Expr) =>
          println(s"DEBUG: Propagated Snd to $snd")
          propagateRvalue(snd)
        case _ =>
          Pairs.Snd(Ident(name).asInstanceOf[Lvalue])(rvalue.pos)
      }

    case Pairs.Fst(Pairs.NewPair(fst, _)) =>
      println(s"DEBUG: Optimized Fst(NewPair) -> $fst")
      propagateRvalue(fst.asInstanceOf[Expr])

    case Pairs.Snd(Pairs.NewPair(_, snd)) =>
      println(s"DEBUG: Optimized Snd(NewPair) -> $snd")
      propagateRvalue(snd.asInstanceOf[Expr])

    case other =>
      println(s"DEBUG: Unmatched Rvalue case, returning unchanged: $other")
      other
  }

  println(s"DEBUG: Result after propagation: $propagated")
  propagated
}

  def optimizeStmt(stmt: Statements.Stmt): Statements.Stmt = {
    println(s"DEBUG: Optimizing statement: $stmt") //  Debug log

    val optimized = stmt match {
      case program: Functions.Program => 
        val optimizedProgram = program.optimize()
        println(s"DEBUG: Optimized Program: $optimizedProgram") // Debug log
        optimizedProgram
      case Declare(typ, id, rhs) =>
        val propagatedRhs = rhs match {
          case expr: Expr => ConstantFolder.foldExpr(propagateExpr(expr))
          case _ => rhs
        }
        println(s"DEBUG: After propagation & folding, rhs = $propagatedRhs") // Debug log

        val optDecl = Declare(typ, id, propagatedRhs)(stmt.pos).optimize()

        val semanticType = typeToSemanticType(typ)
        propagatedRhs match {
          case lit: Literals.IntLit  => SymbolTable.getCurrentScope.set(id.name, semanticType, Some(lit))
          case lit: Literals.BoolLit => SymbolTable.getCurrentScope.set(id.name, semanticType, Some(lit))
          case lit: Literals.CharLit => SymbolTable.getCurrentScope.set(id.name, semanticType, Some(lit))
          case lit: Literals.StrLit  => SymbolTable.getCurrentScope.set(id.name, semanticType, Some(lit))
          case _ => // Do nothing
        }
        println(s"DEBUG: Updated symbol table with: ${id.name} = $propagatedRhs") // Debug log
        optDecl

      case Assign(lhs, rhs) =>
        println(s"DEBUG: Found Assign statement: $stmt") // Debug log
        val propagatedRhs = rhs match {
          case expr: Expr => ConstantFolder.foldExpr(propagateExpr(expr))
          case _ => rhs
        }
        println(s"DEBUG: After propagation & folding, rhs = $propagatedRhs") // Debug log

        val optAssign = Assign(lhs, propagatedRhs)(stmt.pos).optimize()

        (lhs, propagatedRhs) match {
          case (id: Ident, lit: Literals.IntLit)  => SymbolTable.getCurrentScope.set(id.name, id.semanticType.getOrElse(DebugT("Unknown")), Some(lit))
          case (id: Ident, lit: Literals.BoolLit) => SymbolTable.getCurrentScope.set(id.name, id.semanticType.getOrElse(DebugT("Unknown")), Some(lit))
          case (id: Ident, lit: Literals.CharLit) => SymbolTable.getCurrentScope.set(id.name, id.semanticType.getOrElse(DebugT("Unknown")), Some(lit))
          case (id: Ident, lit: Literals.StrLit)  => SymbolTable.getCurrentScope.set(id.name, id.semanticType.getOrElse(DebugT("Unknown")), Some(lit))

          case (id: Ident, Ident(name)) =>
            SymbolTable.getCurrentScope.lookupConstant(name).foreach { value =>
              SymbolTable.getCurrentScope.setRvalue(id.name, id.semanticType.getOrElse(DebugT("Unknown")), Some(value))
            }

          case _ =>
            lhs match {
              case id: Ident => SymbolTable.getCurrentScope.set(id.name, id.semanticType.getOrElse(DebugT("Unknown")), None)
              case _ => // Handle other cases later
            }
        }
        println(s"DEBUG: Updated symbol table with: ${lhs} = $propagatedRhs") // Debug log
        optAssign

      case IfThenElse(cond, thenStmt, elseStmt) =>
        IfThenElse(propagateExpr(cond), optimizeStmt(thenStmt), optimizeStmt(elseStmt))(stmt.pos)

      case WhileDo(cond, body) =>
        WhileDo(propagateExpr(cond), optimizeStmt(body))(stmt.pos)

      case StmtList(first, second) =>
        StmtList(optimizeStmt(first), optimizeStmt(second))(stmt.pos)

      case Print(expr) =>
        Print(propagateExpr(expr))(stmt.pos)

      case Println(expr) =>
        Println(propagateExpr(expr))(stmt.pos)

      case _ => stmt
    }
    println(s"DEBUG: Finished optimizing statement: $optimized") // Debug log
    optimized
  }
}
