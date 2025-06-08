package wacc.backEnd

import wacc.backEnd.Constants._

object ARMInstructions {
  sealed trait Instruction {
    override def toString(): String =
      ARMInstructions.DefaultFormatter.format(this)
  }

  sealed trait Operand
  sealed trait Register extends Operand {
    val reg: Int
    override def toString: String = s"R$reg"
  }

  // Conditions
  sealed trait Condition { override def toString: String }
  case object Al extends Condition { override def toString: String = "" }
  case object Eq extends Condition { override def toString: String = "EQ" }
  case object Ne extends Condition { override def toString: String = "NE" }
  case object Ge extends Condition { override def toString: String = "GE" }
  case object Lt extends Condition { override def toString: String = "LT" }
  case object Le extends Condition { override def toString: String = "LE" }
  case object Gt extends Condition { override def toString: String = "GT" }
  case object Vs extends Condition { override def toString: String = "VS" }

  object Cond {
    def branch(label: Label, cond: Condition): B = B(label, cond)

    def move(dest: Register, src: Operand, cond: Condition): Mov =
      Mov(dest, src, cond)

    def branchLink(label: Label, cond: Condition): Bl = Bl(label, cond)

    def compareAndSet(
        dest: Register,
        trueVal: Int,
        falseVal: Int,
        condition: Condition
    ): List[ARMInstruction] = {
      List(
        Mov(dest, ImmNum(falseVal), Al),
        Mov(dest, ImmNum(trueVal), condition)
      )
    }

    def booleanOp(
        dest: Register,
        op1: Register,
        op2: Register,
        opType: String
    ): List[ARMInstruction] = opType match {
      case "and" => List(And(dest, op1, op2))
      case "or"  => List(Orr(dest, op1, op2))
      case "not" =>
        List(
          Cmp(op1, ImmNum(BOOL_FALSE))
        ) ++ compareAndSet(dest, BOOL_TRUE, BOOL_FALSE, Eq)
      case _ => List(Nop)
    }

    def comparison(
        dest: Register,
        op1: Register,
        op2: Register,
        compType: String
    ): List[ARMInstruction] = {
      val condition = compType match {
        case "==" => Eq
        case "!=" => Ne
        case ">"  => Gt
        case ">=" => Ge
        case "<"  => Lt
        case "<=" => Le
        case _    => Al
      }

      List(Cmp(op1, op2)) ++ compareAndSet(dest, BOOL_TRUE, BOOL_FALSE, condition)

    }

    def runtimeCheck(
        checkType: String,
        reg: Register,
        errorLabel: String
    ): List[ARMInstruction] = checkType match {
      case "null" =>
        List(
          Cmp(reg, ImmNum(BOOL_FALSE)),
          branch(Label(errorLabel), Eq)
        )
      case "bounds" =>
        List(
          Cmp(reg, ImmNum(MIN_ARRAY_INDEX)),
          branch(Label(errorLabel), Lt)
        )
      case "overflow" =>
        List(branch(Label(errorLabel), Vs))
      case _ => List(Nop)
    }

    def runtimeCheck(
        checkType: String,
        errorLabel: String
    ): List[ARMInstruction] = checkType match {
      case "overflow" => List(branch(Label(errorLabel), Vs))
      case _          => List(Nop)
    }

    def unaryBooleanOp(
        destReg: Register,
        srcReg: Register,
        op: String
    ): List[ARMInstruction] = {
      op match {
        case "not" =>
          List(
            Eor(destReg, srcReg, ImmNum(BOOL_TRUE)) // XOR with 1 flips the bit
          )
      }
    }
  }

  case class ImmNum(value: Int) extends Operand
  case class ImmLoadNum(value: Int) extends Operand
  case class ImmLoadLabel(label: Label) extends Operand

  case class Address(base: Register, offset: Int) extends Operand

  // Register definitions
  private val registerRange = INITIAL_COUNTER_VALUE to PC_REGISTER_INDEX
  val registers: Map[Int, Register] =
    registerRange.map(i => i -> new Register { val reg = i }).toMap

  val r0 = registers(R0_INDEX)
  val r1 = registers(R1_INDEX)
  val r2 = registers(R2_INDEX)
  val r3 = registers(R3_INDEX)
  val FP = registers(FP_REGISTER_INDEX) // Frame Pointer
  val SP = registers(SP_REGISTER_INDEX) // Stack Pointer
  val LR = registers(LR_REGISTER_INDEX) // Link Register
  val PC = registers(PC_REGISTER_INDEX) // Program Counter

  // Instructions
  sealed trait ARMInstruction extends Instruction

  // Labels and Definitions
  case class Label(name: String) extends ARMInstruction
  case class define(name: String) extends ARMInstruction

  // Arithmetic & Logic
  case class Add(dest: Register, op1: Operand, op2: Operand)
      extends ARMInstruction
  case class Sub(dest: Register, op1: Operand, op2: Operand)
      extends ARMInstruction
  case class Rsb(dest: Register, op1: Operand, op2: Operand)
      extends ARMInstruction
  case class Mul(dest: Register, op1: Operand, op2: Operand)
      extends ARMInstruction

  // Flag-setting variants (S-variants)
  case class Adds(dest: Register, op1: Operand, op2: Operand)
      extends ARMInstruction
  case class Subs(dest: Register, op1: Operand, op2: Operand)
      extends ARMInstruction
  case class RsbS(dest: Register, op1: Operand, op2: Operand)
      extends ARMInstruction

  // Signed multiply long (64-bit result)
  case class Smull(destLo: Register, destHi: Register, op1: Register, op2: Register)
      extends ARMInstruction

  // Boolean operations
  case class Eor(dest: Register, op1: Operand, op2: Operand)
      extends ARMInstruction
  case class And(dest: Register, op1: Operand, op2: Operand)
      extends ARMInstruction
  case class Orr(dest: Register, op1: Operand, op2: Operand)
      extends ARMInstruction
  case class Bic(dest: Register, op1: Operand, op2: Operand)
      extends ARMInstruction

  // Shifts
  case class Lsl(dest: Register, op1: Operand, op2: Operand)
      extends ARMInstruction
  case class Lsr(dest: Register, op1: Operand, op2: Operand)
      extends ARMInstruction
  case class Asr(dest: Register, op1: Operand, op2: Operand)
      extends ARMInstruction
  case class Ror(dest: Register, op1: Operand, op2: Operand)
      extends ARMInstruction

  // Memory
  case class Ldr(dest: Register, op: Operand) extends ARMInstruction
  case class Str(src: Register, op: Operand) extends ARMInstruction
  case class Ldrb(dest: Register, op: Operand) extends ARMInstruction
  case class Strb(src: Register, op: Operand) extends ARMInstruction
  case class Ldm(dest: Register, op: Operand) extends ARMInstruction
  case class Stm(src: Register, op: Operand) extends ARMInstruction
  case class Mov(dest: Register, src: Operand, cond: Condition = Al)
      extends ARMInstruction

  // Control Flow
  case class Cmp(op1: Operand, op2: Operand) extends ARMInstruction
  case class B(label: Label, cond: Condition) extends ARMInstruction
  case class Bl(label: Label, cond: Condition) extends ARMInstruction
  case class Blx(reg: Register) extends ARMInstruction

  // Stack
  case class Push(regs: Seq[Register]) extends ARMInstruction
  case class Pop(regs: Seq[Register]) extends ARMInstruction

  // No Operation (ARM-level)
  case object Nop extends ARMInstruction

  // Instruction Formatting
  trait InstructionFormatter {
    def format(inst: Instruction): String = inst match {
      // Arithmetic & Logic
      case Add(dest, op1, op2) => formatTriOp("add", dest, op1, op2)
      case Sub(dest, op1, op2) => formatTriOp("sub", dest, op1, op2)
      case Rsb(dest, op1, op2) => formatTriOp("rsb", dest, op1, op2)
      case Mul(dest, op1, op2) => formatTriOp("mul", dest, op1, op2)
      // Flag-setting variants
      case Adds(dest, op1, op2) => formatTriOp("adds", dest, op1, op2)
      case Subs(dest, op1, op2) => formatTriOp("subs", dest, op1, op2)
      case RsbS(dest, op1, op2) => formatTriOp("rsbs", dest, op1, op2)
      // Signed multiply long
      case Smull(destLo, destHi, op1, op2) => 
        s"\tsmull ${formatReg(destLo)}, ${formatReg(destHi)}, ${formatReg(op1)}, ${formatReg(op2)}"
      case Eor(dest, op1, op2) => formatTriOp("eor", dest, op1, op2)
      case And(dest, op1, op2) => formatTriOp("and", dest, op1, op2)
      case Orr(dest, op1, op2) => formatTriOp("orr", dest, op1, op2)
      case Bic(dest, op1, op2) => formatTriOp("bic", dest, op1, op2)

      // Shifts
      case Lsl(dest, op1, op2) => formatTriOp("lsl", dest, op1, op2)
      case Lsr(dest, op1, op2) => formatTriOp("lsr", dest, op1, op2)
      case Asr(dest, op1, op2) => formatTriOp("asr", dest, op1, op2)
      case Ror(dest, op1, op2) => formatTriOp("ror", dest, op1, op2)

      // Memory
      case Ldr(dest, op)        => formatMemOp("ldr", dest, op)
      case Str(src, op)         => formatMemOp("str", src, op)
      case Ldrb(dest, op)       => formatMemOp("ldrb", dest, op)
      case Strb(src, op)        => formatMemOp("strb", src, op)
      case Ldm(dest, op)        => formatMemOp("ldm", dest, op)
      case Stm(src, op)         => formatMemOp("stm", src, op)
      case Mov(dest, src, cond) => formatMovOp("mov", dest, src, cond)

      // Control Flow
      case Cmp(op1, op2)   => formatBiOp("cmp", op1, op2)
      case B(label, cond)  => formatBranch("b", label, cond)
      case Bl(label, cond) => formatBranch("bl", label, cond)
      case Blx(reg)        => formatUnaryOp("blx", reg)

      // Stack
      case Push(regs) => formatStackOp("push", regs)
      case Pop(regs)  => formatStackOp("pop", regs)

      // Labels
      case Label(name)  => s"$name:"
      case define(name) => s"$name"

      // No Operation
      case Nop => ""
    }

    private def formatTriOp(
        op: String,
        dest: Register,
        op1: Operand,
        op2: Operand
    ): String =
      s"\t$op ${formatReg(dest)}, ${formatOperand(op1)}, ${formatOperand(op2)}"

    private def formatBiOp(op: String, op1: Operand, op2: Operand): String =
      s"\t$op ${formatOperand(op1)}, ${formatOperand(op2)}"

    private def formatMemOp(op: String, reg: Register, addr: Operand): String =
      s"\t$op ${formatReg(reg)}, ${formatOperand(addr)}"

    private def formatBranch(
        op: String,
        label: Label,
        cond: Condition
    ): String = {
      val labelName = label.name
      s"\t$op${cond} $labelName"
    }

    private def formatUnaryOp(op: String, reg: Register): String =
      s"\t$op ${formatReg(reg)}"

    private def formatStackOp(op: String, regs: Seq[Register]): String =
      s"\t$op {${regs.map(formatReg).mkString(", ")}}"

    private def formatReg(reg: Register): String = reg.toString

    private def formatOperand(op: Operand): String = op match {
      case reg: Register         => formatReg(reg)
      case ImmNum(value)         => s"#$value"
      case ImmLoadNum(value)     => s"=$value"
      case ImmLoadLabel(label)   => s"=${label.name}"
      case Address(base, offset) => s"[${formatReg(base)}, #$offset]"
    }

    private def formatMovOp(
        op: String,
        dest: Register,
        src: Operand,
        cond: Condition
    ): String =
      s"\t$op$cond ${formatReg(dest)}, ${formatOperand(src)}"
  }

  object DefaultFormatter extends InstructionFormatter

  object InstructionValidator {
    def validate(inst: ARMInstruction): Either[String, Unit] = inst match {
      case Add(dest, op1, op2) => validateThreeOp(dest, op1, op2)
      case Sub(dest, op1, op2) => validateThreeOp(dest, op1, op2)
      case Rsb(dest, op1, op2) => validateThreeOp(dest, op1, op2)
      case Mul(dest, op1, op2) => validateThreeOp(dest, op1, op2)
      // Flag-setting variants
      case Adds(dest, op1, op2) => validateThreeOp(dest, op1, op2)
      case Subs(dest, op1, op2) => validateThreeOp(dest, op1, op2)
      case RsbS(dest, op1, op2) => validateThreeOp(dest, op1, op2)
      // Signed multiply long
      case Smull(destLo, destHi, op1, op2) => 
        if (!isValid(destLo) || !isValid(destHi) || !isValid(op1) || !isValid(op2))
          Left("Invalid operand in SMULL instruction")
        else
          Right(())
      case Mov(dest, src, _)   => validateTwoOp(dest, src)
      case Ldr(dest, src)      => validateLoad(dest, src)
      case Str(src, dest)      => validateStore(src, dest)
      case Cmp(op1, op2)       => validateCompare(op1, op2)
      case _                   => Right(())
    }

    private def validateThreeOp(
        dest: Register,
        op1: Operand,
        op2: Operand
    ): Either[String, Unit] = {
      if (!isValid(op1) || !isValid(op2) || !isValid(dest))
        Left(s"Invalid operand in three-operand instruction")
      else if (!isValidImmediate(op2))
        Left(s"Second operand must be a register or immediate value < ${MAX_IMMEDIATE_VALUE}")
      else
        Right(())
    }

    private def validateTwoOp(
        dest: Register,
        src: Operand
    ): Either[String, Unit] = {
      if (!isValid(src) || !isValid(dest))
        Left(s"Invalid operand in two-operand instruction")
      else if (!isValidImmediate(src))
        Left(s"Source operand must be a register or immediate value < ${MAX_IMMEDIATE_VALUE}")
      else
        Right(())
    }

    private def validateLoad(
        dest: Register,
        src: Operand
    ): Either[String, Unit] = src match {
      case Address(_, offset) if offset < MIN_MEMORY_OFFSET || offset > MAX_MEMORY_OFFSET =>
        Left(s"Load offset $offset out of range ($MIN_MEMORY_OFFSET to $MAX_MEMORY_OFFSET)")
      case ImmNum(value) if value < MIN_IMMEDIATE_VALUE || value > MAX_IMMEDIATE_VALUE =>
        Left(s"Immediate value $value out of range ($MIN_IMMEDIATE_VALUE to $MAX_IMMEDIATE_VALUE)")
      case _ if !isValid(dest) =>
        Left(s"Invalid destination register")
      case _ => Right(())
    }

    private def validateStore(
        src: Register,
        dest: Operand
    ): Either[String, Unit] = dest match {
      case Address(_, offset) if offset < MIN_MEMORY_OFFSET || offset > MAX_MEMORY_OFFSET =>
        Left(s"Store offset $offset out of range ($MIN_MEMORY_OFFSET to $MAX_MEMORY_OFFSET)")
      case _ if !isValid(src) =>
        Left(s"Invalid source register")
      case _ => Right(())
    }

    private def validateCompare(
        op1: Operand,
        op2: Operand
    ): Either[String, Unit] = {
      if (!isValid(op1) || !isValid(op2))
        Left(s"Invalid operand in compare instruction")
      else if (!isValidImmediate(op2))
        Left(s"Second operand must be a register or immediate value < ${MAX_IMMEDIATE_VALUE}")
      else
        Right(())
    }

    private def isValid(op: Operand): Boolean = op match {
      case _: Register      => true
      case ImmNum(_)        => true
      case ImmLoadNum(_)    => true
      case ImmLoadLabel(_)  => true
      case Address(base, _) => isValid(base)
    }

    private def isValidImmediate(op: Operand): Boolean = op match {
      case _: Register   => true
      case ImmNum(value) => value >= MIN_IMMEDIATE_VALUE && value <= MAX_IMMEDIATE_VALUE
      case _             => false
    }
  }

}
