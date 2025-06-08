package wacc

import parsley.Parsley
import parsley.token.{Lexer, Basic}
import parsley.token.descriptions.*

object lexer {
  private object Configurations {
    val keywords: Set[String] = Set(
      "if", "then", "else", "fi", "skip", "read", "free",
      "return", "exit", "print", "println", "while", "do", 
      "done", "begin", "end", "is", "true", "false", "int", 
      "bool", "char", "string", "newpair", "fst", "snd", 
      "call", "null", "len", "ord", "chr"
    )

    val operators: Set[String] = Set(
      "$", "||", "&&", "<", "<=", ">", ">=", "==", "!=",
      "/", "+", "-", "*", "%", "=", "!"
    )

    val escapeCharacters: Map[String, Int] = Map(
      "0" -> 0x00, "b" -> 0x08, "t" -> 0x09,
      "n" -> 0x0a, "f" -> 0x0c, "r" -> 0x0d
    )
  }

  private val escapeDesc: EscapeDesc = EscapeDesc(
    escBegin = '\\',
    literals = Set('\'', '\"', '\\'),
    mapping = Configurations.escapeCharacters,
    decimalEscape = NumericEscape.Illegal,
    hexadecimalEscape = NumericEscape.Illegal,
    octalEscape = NumericEscape.Illegal,
    binaryEscape = NumericEscape.Illegal,
    emptyEscape = None,
    gapsSupported = false
  )

  private val desc: LexicalDesc = LexicalDesc.plain.copy(
    nameDesc = NameDesc.plain.copy(
      identifierStart = Basic(c => c.isLetter || c == '_'),
      identifierLetter = Basic(c => c.isLetterOrDigit || c == '_')
    ),
    spaceDesc = SpaceDesc.plain.copy(
      lineCommentStart = "#",
      space = Basic(_.isWhitespace)
    ),
    textDesc = TextDesc.plain.copy(
      escapeSequences = escapeDesc,
      graphicCharacter = Basic(c => !Set('\'', '\\', '\"').contains(c) && c >= ' ')
    ),
    symbolDesc = SymbolDesc.plain.copy(
      hardKeywords = Configurations.keywords,
      hardOperators = Configurations.operators
    )
  )

  private val lexer: Lexer = Lexer(desc)

  def fully[A](p: Parsley[A]): Parsley[A] = lexer.fully(p)
  
  val ident: Parsley[String] = lexer.lexeme.names.identifier
  val integer: Parsley[BigInt] = lexer.lexeme.signed.decimal32
  val char: Parsley[Char] = lexer.lexeme.character.ascii
  val string: Parsley[String] = lexer.lexeme.string.ascii
  val bool: Parsley[Boolean] = 
    (lexer.lexeme.symbol("true") #> true) <|> 
    (lexer.lexeme.symbol("false") #> false)
  val nullLit: Parsley[Unit] = lexer.lexeme.symbol("null")

  val implicits = lexer.lexeme.symbol.implicits
}