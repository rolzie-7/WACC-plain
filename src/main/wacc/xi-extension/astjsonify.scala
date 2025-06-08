package wacc

import io.circe._
import io.circe.syntax._
import ast._
import ast.Types._
import ast.Statements._
import ast.BinaryOps._
import ast.UnaryOps._
import ast.Arrays._
import ast.Pairs._
import ast.Functions._
import ast.Literals._

object ASTJsonify {
  // Position encoder
  implicit val positionEncoder: Encoder[(Int, Int)] = new Encoder[(Int, Int)] {
    final def apply(pos: (Int, Int)): Json = Json.obj(
      "line" -> Json.fromInt(pos._1),
      "column" -> Json.fromInt(pos._2)
    )
  }

  // Type encoders
  implicit val typeEncoder: Encoder[Type] = new Encoder[Type] {
    final def apply(t: Type): Json = t match {
      case IntType(pos) => Json.obj(
        "type" -> Json.fromString("IntType"),
        "pos" -> positionEncoder(pos)
      )
      case BoolType(pos) => Json.obj(
        "type" -> Json.fromString("BoolType"),
        "pos" -> positionEncoder(pos)
      )
      case CharType(pos) => Json.obj(
        "type" -> Json.fromString("CharType"),
        "pos" -> positionEncoder(pos)
      )
      case StringType(pos) => Json.obj(
        "type" -> Json.fromString("StringType"),
        "pos" -> positionEncoder(pos)
      )
      case a @ ArrayType(baseType) => Json.obj(
        "type" -> Json.fromString("ArrayType"),
        "baseType" -> apply(baseType),
        "pos" -> positionEncoder(a.pos)
      )
      case p @ PairType(t1, t2) => Json.obj(
        "type" -> Json.fromString("PairType"),
        "firstType" -> apply(t1),
        "secondType" -> apply(t2),
        "pos" -> positionEncoder(p.pos)
      )
      case pt1 @ PairElemType1(pos) => Json.obj(
        "type" -> Json.fromString("PairElemType1"),
        "pos" -> positionEncoder(pt1.pos)
      )
      case pt2 @ PairElemType2(t) => Json.obj(
        "type" -> Json.fromString("PairElemType2"),
        "baseType" -> apply(t),
        "pos" -> positionEncoder(pt2.pos)
      )
    }
  }

  // Expression encoders
  implicit val exprEncoder: Encoder[Expr] = new Encoder[Expr] {
    final def apply(expr: Expr): Json = expr match {
      case lit: IntLit => Json.obj(
        "type" -> Json.fromString("IntLit"),
        "value" -> Json.fromBigInt(lit.value),
        "pos" -> positionEncoder(lit.pos)
      )
      case lit: BoolLit => Json.obj(
        "type" -> Json.fromString("BoolLit"),
        "value" -> Json.fromBoolean(lit.value),
        "pos" -> positionEncoder(lit.pos)
      )
      case lit: CharLit => Json.obj(
        "type" -> Json.fromString("CharLit"),
        "value" -> Json.fromString(lit.value.toString),
        "pos" -> positionEncoder(lit.pos)
      )
      case lit: StrLit => Json.obj(
        "type" -> Json.fromString("StrLit"),
        "value" -> Json.fromString(lit.value),
        "pos" -> positionEncoder(lit.pos)
      )
      case id: Ident => Json.obj(
        "type" -> Json.fromString("Ident"),
        "name" -> Json.fromString(id.name),
        "pos" -> positionEncoder(id.pos)
      )
      // Binary Operations
      case op: BinaryOp => Json.obj(
        "type" -> Json.fromString(op.getClass.getSimpleName),
        "left" -> apply(op.left),
        "right" -> apply(op.right),
        "pos" -> positionEncoder(op.pos)
      )
      
      // Unary Operations
      case op: UnaryOp => Json.obj(
        "type" -> Json.fromString(op.getClass.getSimpleName),
        "expr" -> apply(op.expr),
        "pos" -> positionEncoder(op.pos)
      )
      
      case elem @ ArrayElem(array, indices) => Json.obj(
        "type" -> Json.fromString("ArrayElem"),
        "array" -> apply(array),
        "indices" -> Json.fromValues(indices.map(apply)),
        "pos" -> positionEncoder(elem.pos)
      )
      case lit @ PairLit(pos) => Json.obj(
        "type" -> Json.fromString("PairLit"),
        "pos" -> positionEncoder(lit.pos)
      )
    }
  }

  // Statement encoders
  implicit val stmtEncoder: Encoder[Stmt] = new Encoder[Stmt] {
    final def apply(stmt: Stmt): Json = stmt match {
      case Skip(pos) => Json.obj(
        "type" -> Json.fromString("Skip"),
        "pos" -> positionEncoder(pos)
      )
      case decl @ Declare(typ, id, rhs) => Json.obj(
        "type" -> Json.fromString("Declare"),
        "varType" -> typeEncoder(typ),
        "identifier" -> exprEncoder(id),
        "rhs" -> rvalueEncoder(rhs),
        "pos" -> positionEncoder(decl.pos)
      )
      case assign @ Assign(lhs, rhs) => Json.obj(
        "type" -> Json.fromString("Assign"),
        "lhs" -> lvalueEncoder(lhs),
        "rhs" -> rvalueEncoder(rhs),
        "pos" -> positionEncoder(assign.pos)
      )
      case read @ Read(lvalue) => Json.obj(
        "type" -> Json.fromString("Read"),
        "lvalue" -> lvalueEncoder(lvalue),
        "pos" -> positionEncoder(read.pos)
      )
      case free @ Free(expr) => Json.obj(
        "type" -> Json.fromString("Free"),
        "expr" -> exprEncoder(expr),
        "pos" -> positionEncoder(free.pos)
      )
      case ret @ Return(expr) => Json.obj(
        "type" -> Json.fromString("Return"),
        "expr" -> exprEncoder(expr),
        "pos" -> positionEncoder(ret.pos)
      )
      case exit @ Exit(expr) => Json.obj(
        "type" -> Json.fromString("Exit"),
        "expr" -> exprEncoder(expr),
        "pos" -> positionEncoder(exit.pos)
      )
      case print @ Print(expr) => Json.obj(
        "type" -> Json.fromString("Print"),
        "expr" -> exprEncoder(expr),
        "pos" -> positionEncoder(print.pos)
      )
      case println @ Println(expr) => Json.obj(
        "type" -> Json.fromString("Println"),
        "expr" -> exprEncoder(expr),
        "pos" -> positionEncoder(println.pos)
      )
      case ifStmt @ IfThenElse(cond, thenStmt, elseStmt) => Json.obj(
        "type" -> Json.fromString("IfThenElse"),
        "condition" -> exprEncoder(cond),
        "thenStmt" -> apply(thenStmt),
        "elseStmt" -> apply(elseStmt),
        "pos" -> positionEncoder(ifStmt.pos)
      )
      case whileStmt @ WhileDo(cond, body) => Json.obj(
        "type" -> Json.fromString("WhileDo"),
        "condition" -> exprEncoder(cond),
        "body" -> apply(body),
        "pos" -> positionEncoder(whileStmt.pos)
      )
      case begin @ BeginEnd(stmt) => Json.obj(
        "type" -> Json.fromString("BeginEnd"),
        "stmt" -> apply(stmt),
        "pos" -> positionEncoder(begin.pos)
      )
      case stmtList @ StmtList(first, second) => Json.obj(
        "type" -> Json.fromString("StmtList"),
        "first" -> apply(first),
        "second" -> apply(second),
        "pos" -> positionEncoder(stmtList.pos)
      )
      case prog @ Program(functions, main) => Json.obj(
        "type" -> Json.fromString("Program"),
        "functions" -> Json.fromValues(functions.map(funcEncoder(_))),
        "main" -> apply(main),
        "pos" -> positionEncoder(prog.pos)
      )
      case func @ Func(returnType, name, params, body) => Json.obj(
        "type" -> Json.fromString("Function"),
        "returnType" -> typeEncoder(returnType),
        "name" -> exprEncoder(name),
        "params" -> Json.fromValues(params.params.map(paramEncoder(_))),
        "body" -> apply(body),
        "pos" -> positionEncoder(func.pos)
      )
    }
  }

  // Add encoders for other AST types (Rvalue, Lvalue, etc.)
  implicit val rvalueEncoder: Encoder[Rvalue] = new Encoder[Rvalue] {
    final def apply(rvalue: Rvalue): Json = rvalue match {
      case expr: Expr => exprEncoder(expr)
      case arrLit @ ArrayLit(elements) => Json.obj(
        "type" -> Json.fromString("ArrayLit"),
        "elements" -> Json.fromValues(elements.map(_.map(exprEncoder(_))).getOrElse(List.empty)),
        "pos" -> positionEncoder(arrLit.pos)
      )
      case np @ NewPair(fst, snd) => Json.obj(
        "type" -> Json.fromString("NewPair"),
        "first" -> exprEncoder(fst),
        "second" -> exprEncoder(snd),
        "pos" -> positionEncoder(np.pos)
      )
      case call @ Call(function, args) => Json.obj(
        "type" -> Json.fromString("Call"),
        "function" -> exprEncoder(function),
        "args" -> Json.fromValues(args.map(_.args.map(exprEncoder(_))).getOrElse(List.empty)),
        "pos" -> positionEncoder(call.pos)
      )
      case fst @ Fst(pair) => Json.obj(
        "type" -> Json.fromString("Fst"),
        "pair" -> lvalueEncoder(pair),
        "pos" -> positionEncoder(fst.pos)
      )
      case snd @ Snd(pair) => Json.obj(
        "type" -> Json.fromString("Snd"),
        "pair" -> lvalueEncoder(pair),
        "pos" -> positionEncoder(snd.pos)
      )
    }
  }

  // New encoder for Lvalue
  implicit val lvalueEncoder: Encoder[Lvalue] = new Encoder[Lvalue] {
    final def apply(lvalue: Lvalue): Json = lvalue match {
      case expr: Expr => exprEncoder(expr)
      case fst @ Fst(pair) => Json.obj(
        "type" -> Json.fromString("Fst"),
        "pair" -> apply(pair),
        "pos" -> positionEncoder(fst.pos)
      )
      case snd @ Snd(pair) => Json.obj(
        "type" -> Json.fromString("Snd"),
        "pair" -> apply(pair),
        "pos" -> positionEncoder(snd.pos)
      )
    }
  }

  def toJson(program: Program): String = {
    implicit val programEncoder: Encoder[Program] = new Encoder[Program] {
      final def apply(program: Program): Json = Json.obj(
        "type" -> Json.fromString("Program"),
        "functions" -> Json.fromValues(program.functions.map(funcEncoder(_))),
        "main" -> stmtEncoder(program.main),
        "pos" -> positionEncoder(program.pos)
      )
    }

    program.asJson.spaces2
  }

  implicit val funcEncoder: Encoder[Func] = new Encoder[Func] {
    final def apply(func: Func): Json = Json.obj(
      "type" -> Json.fromString("Function"),
      "returnType" -> typeEncoder(func.returnType),
      "name" -> exprEncoder(func.name),
      "params" -> Json.fromValues(func.params.params.map(paramEncoder(_))),
      "body" -> stmtEncoder(func.body),
      "pos" -> positionEncoder(func.pos)
    )
  }

  implicit val paramEncoder: Encoder[Param] = new Encoder[Param] {
    final def apply(param: Param): Json = Json.obj(
      "type" -> Json.fromString("Param"),
      "paramType" -> typeEncoder(param.typ),
      "name" -> exprEncoder(param.name)
    )
  }
}
