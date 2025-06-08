package wacc

import ast.Statements._
import ast.Expr
import ast.BinaryOps._
import ast.Rvalue  
import ast.Functions.Program
import ast.UnaryOps._

object ConstantFolder {
  /** Applies constant folding to an entire program AST */
def foldAST(stmt: Stmt): Stmt = {

  stmt match {
    case Program(funcs, main) =>
      Program(funcs, foldAST(main))(stmt.pos) // Apply folding to the main statement

    case Declare(typ, id, rhs) =>
      val foldedRhs = foldRvalue(rhs)
      Declare(typ, id, foldedRhs)(stmt.pos)

    case Assign(lhs, rhs) =>
      val foldedRhs = foldRvalue(rhs)
      Assign(lhs, foldedRhs)(stmt.pos)

    case IfThenElse(cond, thenStmt, elseStmt) =>
      val foldedCond = foldExpr(cond)
      val foldedThen = foldAST(thenStmt)
      val foldedElse = foldAST(elseStmt)
      IfThenElse(foldedCond, foldedThen, foldedElse)(stmt.pos)

    case WhileDo(cond, body) =>
      val foldedCond = foldExpr(cond)
      val foldedBody = foldAST(body)
      WhileDo(foldedCond, foldedBody)(stmt.pos)

    case StmtList(first, second) =>
      val foldedFirst = foldAST(first)
      val foldedSecond = foldAST(second)
      StmtList(foldedFirst, foldedSecond)(stmt.pos)

    case other =>
      other
  }
}



  /** Applies constant folding to expressions (merged debug version) */
  def foldExpr(expr: Expr): Expr = {
    expr match {
      case b: BinaryOp =>
        val leftFolded = foldExpr(b.left)
        val rightFolded = foldExpr(b.right)

        val result = b match {
          case Add(_, _) => Add.fold(leftFolded, rightFolded)(b.pos)
          case Sub(_, _) => Sub.fold(leftFolded, rightFolded)(b.pos)
          case Mul(_, _) => Mul.fold(leftFolded, rightFolded)(b.pos)
          case Div(_, _) => Div.fold(leftFolded, rightFolded)(b.pos)
          case Mod(_, _) => Mod.fold(leftFolded, rightFolded)(b.pos)
          case LT(_, _)  => LT.fold(leftFolded, rightFolded)(b.pos)
          case LTE(_, _) => LTE.fold(leftFolded, rightFolded)(b.pos)
          case GT(_, _)  => GT.fold(leftFolded, rightFolded)(b.pos)
          case GTE(_, _) => GTE.fold(leftFolded, rightFolded)(b.pos)
          case E(_, _)   => E.fold(leftFolded, rightFolded)(b.pos)
          case NE(_, _)  => NE.fold(leftFolded, rightFolded)(b.pos)
          case And(_, _) => And.fold(leftFolded, rightFolded)(b.pos)
          case Or(_, _)  => Or.fold(leftFolded, rightFolded)(b.pos)
        }

        result
         // Handle Unary Operators (New Implementation)
      case u: UnaryOp =>
        val innerFolded = foldExpr(u.expr)

        val result = u match {
          case Not(_) => Not.fold(innerFolded)(u.pos)  // Fix scoping
          case Neg(_) => Neg.fold(innerFolded)(u.pos)  // Fix scoping
          case _ => u
        }

        result
      case other =>
        other
    }
  }

  def foldRvalue(rval: Rvalue): Rvalue = {

  rval match {
    case e: Expr => 
      val foldedExpr = foldExpr(e) // Apply constant folding
      foldedExpr
    case other =>
      other
  }
}

}
