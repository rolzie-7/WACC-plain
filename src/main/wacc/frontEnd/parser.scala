package wacc

import parsley.{Parsley}
import parsley.{Result, Success, Failure}
import java.io.File
import StatementParser.`<program>`
import parsley.expr.chain
import parsley.quick.*
// import parsley.combinator.{sepBy1, sepBy, option}
import parsley.expr.{precedence, SOps, Atoms, InfixL, InfixR, InfixN, Prefix}

import lexer.implicits.implicitSymbol

import ast.Functions._
import ast.Types._
import ast.Statements._
import ast.BinaryOps._
import ast.UnaryOps._
import ast.Arrays._
import ast.Pairs._
import ast.{Lvalue, Rvalue, Ident, Expr}
import ast.Literals._

import TypesParser._
import wacc.lexer.{ident, string, integer, bool, char}

import ExprsParser._

object Parser {
  
  def parse(filename: String): Result[String, Program] = {
    fully(`<program>`).parseFile(new File(filename)) match {
      case scala.util.Success(result) => result match {
        case Success(program) => Success(program)
        case Failure(msg) => Failure(msg)
      }
      case scala.util.Failure(error) => 
        Failure(error.getMessage)
    }
  }
  
  private def fully[A](p: Parsley[A]): Parsley[A] = {
    import parsley.Parsley.eof
    p <~ eof
  }
}

object ExprsParser {
    // ⟨expr⟩ ::= ⟨atom⟩ | ⟨unary-op⟩ ⟨expr⟩ | ⟨expr⟩ ⟨binary-op⟩ ⟨expr⟩
    lazy val `<expr>`: Parsley[Expr] = 
        precedence {
            Atoms(`<atom>`) :+
            SOps(Prefix)(
                Not from "!",
                Neg from atomic("-" <~ notFollowedBy(digit)),
                Len from "len",
                Ord from "ord",
                Chr from "chr"
            ) :+
            SOps(InfixL)(Mul from "*", Mod from "%", Div from "/") :+
            SOps(InfixL)(Add from "+", Sub from "-") :+
            SOps(InfixN)(GT from ">", GTE from ">=", LT from "<", LTE from "<=") :+
            SOps(InfixN)(E from "==", NE from "!=") :+
            SOps(InfixR)(And from "&&") :+
            SOps(InfixR)(Or from "||")
        }

    lazy val `<ident>`: Parsley[Ident] = Ident(ident)
    lazy val `<int-liter>` = IntLit(integer)
    lazy val `<bool-liter>` = BoolLit(bool)
    lazy val `<char-liter>` = CharLit(char)
    lazy val `<str-liter>` = StrLit(string)
    lazy val `<array-elem>` = ArrayElem(`<ident>`, some("[" ~> `<expr>` <~ "]"))

    // ⟨atom⟩ ::= ⟨int-liter⟩ | ⟨bool-liter⟩ | ⟨char-liter⟩ | ⟨str-liter⟩ | 
    // 'null' | ⟨ident⟩ | ⟨array-elem⟩ | '(' ⟨expr⟩ ')'
    lazy val `<atom>`: Parsley[Expr] =
        atomic(
        `<int-liter>`   |
        `<bool-liter>`  |
        `<char-liter>`  |
        `<str-liter>`   |
        PairLit <# "null" |
        (`<ident>` <~> many("[" ~> `<expr>` <~ "]")).map { case (id, indices) => IdentOrArrayElem(id, indices)(id.pos) } |
        "(" ~> `<expr>` <~ ")"
        )
}

object TypesParser {
    // ⟨type⟩ ::= ⟨base-type⟩ | ⟨pair-type⟩ | ⟨array-type⟩
    lazy val `<type>`: Parsley[Type] =
        atomic(
            atomic(`<base-type>` <~ notFollowedBy("[]")) |
            atomic(`<pair-type>` <~ notFollowedBy("[]")) |
            `<array-type>`
        )

    // ⟨base-type⟩ ::= 'int' | 'bool' | 'char' | 'string'    
    lazy val `<base-type>`: Parsley[BaseType] =
        atomic(
            IntType <# "int" |
            BoolType <# "bool" |
            CharType <# "char" |
            StringType <# "string"
        )

    //chain postfix is used to handle nested array types
    // ⟨array-type⟩ ::= ⟨base-type⟩ '[' ']'    
    lazy val `<array-type>`: Parsley[Type] =
        atomic(
            chain.postfix1(`<base-type>` | `<pair-type>`)(ArrayType from "[]")
        )

    // ⟨pair-type⟩ ::= 'pair' '(' ⟨pair-elem-type⟩ ',' ⟨pair-elem-type⟩ ')'
    lazy val `<pair-type>`: Parsley[PairType] = 
        atomic(
            PairType("pair" ~> "(" ~> `<pair-elem-type>` <~ ",", `<pair-elem-type>` <~ ")")
        )

    // ⟨pair-elem-type⟩ ::= ⟨type⟩ | 'pair'    
    lazy val `<pair-elem-type>`: Parsley[PairElemType] =
        atomic(
            PairElemType2(`<array-type>` | `<base-type>`) |
            PairElemType1 <# "pair"
        )
}

object StatementParser {

    // ⟨program⟩ ::= 'begin' ⟨func⟩* ⟨stmt⟩ 'end'
    lazy val `<program>`: Parsley[Program] =
        lexer.fully(atomic(Program("begin" ~> many(`<func>`), `<stmt>` <~ "end")))

    // ⟨func⟩ ::= ⟨type⟩ ⟨ident⟩ '(' ⟨param-list⟩? ')' 'is' ⟨stmt⟩ 'end'
    lazy val `<func>`: Parsley[Func] =
        atomic(Func(`<type>`, `<ident>` <~ "(", `<param-list>` <~ ")", "is" ~> `<stmt>` <~ "end"))
    
    // ⟨param-list⟩ ::= ⟨param⟩ (',' ⟨param⟩)*
    lazy val `<param-list>`: Parsley[ParamList] =
        atomic(
            ParamList(sepBy(`<param>`,","))
        )

    // ⟨param⟩ ::= ⟨type⟩ ⟨ident⟩    
    lazy val `<param>`: Parsley[Param] =
        atomic(
            Param(`<type>`, `<ident>`)
        )

    // ⟨stmt⟩ ::= ⟨stmt-unit⟩ (';' ⟨stmt⟩)?    
    lazy val `<stmt>`: Parsley[Stmt] = 
        atomic(
            chain.left1(stmtUnit)(StmtList <# ";")
        )

    // ⟨stmt-unit⟩ ::= 'skip' | ⟨decl⟩ | ⟨assign⟩ | ⟨read⟩ | ⟨free⟩ | ⟨return⟩ |
    // ⟨exit⟩ | ⟨print⟩ | ⟨println⟩ | ⟨if-then-else⟩ | ⟨while-do⟩ | ⟨begin-end⟩    
    lazy val stmtUnit: Parsley[Stmt] =
        atomic(
            Skip <# "skip" |
            Declare(`<type>`, `<ident>` <~ "=", `<rvalue>`) |
            Assign(`<lvalue>` <~ "=", `<rvalue>`) |
            Read("read" ~> `<lvalue>`) |
            Free("free" ~> `<expr>`) |
            Return("return" ~> `<expr>`) |
            Exit("exit" ~> `<expr>`) |
            Print("print" ~> `<expr>`) |
            Println("println" ~> `<expr>`) |
            IfThenElse("if" ~> `<expr>`, "then" ~> `<stmt>`, "else" ~> `<stmt>` <~ "fi") |
            WhileDo("while" ~> `<expr>`, "do" ~> `<stmt>` <~ "done") |
            BeginEnd("begin" ~> `<stmt>` <~ "end")
        )

    lazy val `<pair-elem>`: Parsley[PairElem] = 
        atomic(
            Fst("fst" ~> `<lvalue>`) |
            Snd("snd" ~> `<lvalue>`)
        )

    lazy val `<array-liter>`: Parsley[ArrayLit] = 
        ArrayLit(
                "[" ~>
                option(sepBy1(`<expr>`, ","))
                <~ "]"
            )

    lazy val `<arg-list>`: Parsley[ArgList] =
        ArgList(sepBy1(`<expr>`, ","))

    // ⟨lvalue⟩ ::= ⟨ident⟩ | ⟨array-elem⟩ | ⟨pair-elem⟩        
    lazy val `<lvalue>`: Parsley[Lvalue] = atomic(
            (`<ident>` <~> many("[" ~> `<expr>` <~ "]")).map { case (id, indices) => IdentOrArrayElem(id, indices)(id.pos) } |
            `<pair-elem>`
        )
    
    // ⟨rvalue⟩ ::= ⟨expr⟩ | ⟨array-liter⟩ | 'newpair' '(' ⟨expr⟩ ',' ⟨expr⟩ ')' | 
    // ⟨pair-elem⟩ | 'call' ⟨ident⟩ '(' ⟨arg-list⟩? ')'
    lazy val `<rvalue>`: Parsley[Rvalue] =
        atomic(
            `<expr>` |
            `<array-liter>` |
            NewPair("newpair" ~> "(" ~> `<expr>`, "," ~> `<expr>` <~ ")") |
            `<pair-elem>` |
            Call("call" ~> `<ident>` <~ "(", option(`<arg-list>`) <~ ")")
        )
}