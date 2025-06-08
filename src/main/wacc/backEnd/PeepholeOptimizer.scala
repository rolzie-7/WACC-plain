package wacc.backEnd

import wacc.backEnd.ARMInstructions._
import scala.collection.mutable.ListBuffer

object PeepholeOptimizer {
  def optimize(instructions: List[ARMInstruction]): List[ARMInstruction] = {
    var optimized = instructions
    var previousCount = instructions.length
    var currentCount = 0
    
    // Keep applying optimizations until no more changes
    while (previousCount != currentCount) {
      previousCount = optimized.length
      optimized = removeRedundantLoadAfterStore(optimized)
      optimized = removeRedundantMoves(optimized)
      optimized = removeNoOps(optimized)
      optimized = removeUnreachableCode(optimized)
      optimized = removeDeadStores(optimized)
      optimized = removePushPopPairs(optimized)
      optimized = removeRedundantCompares(optimized)
      optimized = foldConsecutiveArithmetic(optimized)
      currentCount = optimized.length
    }
    
    optimized
  }
  
  /**
   * Remove redundant loads that come directly after storing to the same location
   * Example: STR r0, [fp, #-8] followed by LDR r0, [fp, #-8]
   */
  def removeRedundantLoadAfterStore(instructions: List[ARMInstruction]): List[ARMInstruction] = {
    val result = ListBuffer[ARMInstruction]()
    var i = 0
    
    while (i < instructions.length - 1) {
      val current = instructions(i)
      val next = instructions(i + 1)
      
      (current, next) match {
        case (Str(reg, addr1), Ldr(sameReg, addr2)) if reg == sameReg && addr1 == addr2 => 
          // Skip the redundant load, just keep the store
          result += current
          i += 2
          
        case (Strb(reg, addr1), Ldrb(sameReg, addr2)) if reg == sameReg && addr1 == addr2 => 
          // Same for byte operations
          result += current
          i += 2
          
        case _ => 
          // Keep the current instruction and move to the next
          result += current
          i += 1
      }
    }
    
    // Add the last instruction if we haven't processed it
    if (i < instructions.length) {
      result += instructions.last
    }
    
    result.toList
  }
  
  /**
   * Remove redundant moves (MOV rx, ry followed by MOV ry, rx)
   * or MOV rx, rx which does nothing
   */
  def removeRedundantMoves(instructions: List[ARMInstruction]): List[ARMInstruction] = {
    val result = ListBuffer[ARMInstruction]()
    var i = 0
    
    while (i < instructions.length) {
      val current = instructions(i)
      
      current match {
        case Mov(destReg, srcReg: Register, _) if destReg == srcReg =>
          // Skip MOV rx, rx as it does nothing
          i += 1
          
        case Mov(destReg, srcReg: Register, cond1) if i < instructions.length - 1 =>
          val next = instructions(i + 1)
          next match {
            case Mov(destReg2, srcReg2: Register, cond2) 
                if destReg == srcReg2 && srcReg == destReg2 && cond1 == cond2 =>
              // Skip MOV rx, ry followed by MOV ry, rx
              i += 2
              
            case _ =>
              result += current
              i += 1
          }
          
        case _ =>
          result += current
          i += 1
      }
    }
    
    result.toList
  }
  
  /**
   * Remove NOP instructions
   */
  def removeNoOps(instructions: List[ARMInstruction]): List[ARMInstruction] = {
    instructions.filterNot(_ == Nop)
  }
  
  /**
   * Remove unreachable code (code after unconditional branches/returns until the next label)
   */
  def removeUnreachableCode(instructions: List[ARMInstruction]): List[ARMInstruction] = {
    val result = ListBuffer[ARMInstruction]()
    var i = 0
    var skipUntilLabel = false
    
    // Collect all labels that are actually referenced by branches
    val referencedLabels = instructions.collect {
      case B(label, _) => label.name
    }.toSet
    
    while (i < instructions.length) {
      val current = instructions(i)
      
      if (skipUntilLabel) {
        current match {
          case label: Label => 
            // Found a label, stop skipping
            skipUntilLabel = false
            // Only add labels that are actually referenced by branches
            if (referencedLabels.contains(label.name)) {
              result += label
            }
          case _ => 
            // Skip this instruction (unreachable code)
        }
      } else {
        // Check if this is an unconditional branch or return
        current match {
          case B(_, Al) => 
            // Unconditional branch
            result += current
            skipUntilLabel = true
          case Pop(regs) if regs.contains(PC) => 
            // Return instruction (pop that includes PC)
            result += current
            skipUntilLabel = true
          case _ => 
            // Normal instruction
            result += current
        }
      }
      
      i += 1
    }
    
    result.toList
  }
  
  /**
   * Remove dead stores (stores that are overwritten without being read)
   */
  def removeDeadStores(instructions: List[ARMInstruction]): List[ARMInstruction] = {
    val result = ListBuffer[ARMInstruction]()
    var i = 0
    
    while (i < instructions.length - 1) {
      val current = instructions(i)
      val next = instructions(i + 1)
      
      (current, next) match {
        case (Str(reg1, addr1), Str(reg2, addr2)) if addr1 == addr2 && 
             !instructionBetweenUsesRegister(instructions, i + 1, reg1) => 
          // Skip the first store as it's overwritten immediately
          i += 1
          
        case _ => 
          result += current
          i += 1
      }
    }
    
    // Add the last instruction
    if (i < instructions.length) {
      result += instructions.last
    }
    
    result.toList
  }
  
  /**
   * Remove redundant push/pop pairs that cancel each other out
   * Example: PUSH {r4} followed by POP {r4} with no use of r4 in between
   */
  def removePushPopPairs(instructions: List[ARMInstruction]): List[ARMInstruction] = {
    val result = ListBuffer[ARMInstruction]()
    var i = 0
    
    while (i < instructions.length - 1) {
      val current = instructions(i)
      val next = instructions(i + 1)
      
      (current, next) match {
        case (Push(regs1), Pop(regs2)) if regs1 == regs2 && 
            regsNotUsedBetween(instructions, i, i + 1, regs1) => 
          // Skip both push and pop if they're exactly the same registers
          // and none of those registers are used between the two instructions
          i += 2
          
        case _ => 
          result += current
          i += 1
      }
    }
    
    // Add the last instruction
    if (i < instructions.length) {
      result += instructions.last
    }
    
    result.toList
  }
  
  /**
   * Remove redundant compare instructions
   * Example: CMP rx, #0 followed by CMP rx, #0
   */
  def removeRedundantCompares(instructions: List[ARMInstruction]): List[ARMInstruction] = {
    val result = ListBuffer[ARMInstruction]()
    var i = 0
    
    // Keep track of the last CMP instruction and its index
    var lastCmpOp1: Option[Operand] = None
    var lastCmpOp2: Option[Operand] = None
    var lastCmpIndex = -1
    
    while (i < instructions.length) {
      val current = instructions(i)
      
      current match {
        case Cmp(op1, op2) =>
          // If this is the same compare as last time and nothing in between could
          // have changed the operands, we can skip this comparison
          if (lastCmpOp1.isDefined && lastCmpOp2.isDefined && 
              op1 == lastCmpOp1.get && op2 == lastCmpOp2.get) {
              
            // Check if any instruction between lastCmpIndex and i could have 
            // changed the registers used in the comparison
            val couldChange = (lastCmpIndex + 1 until i).exists { j =>
              val instr = instructions(j)
              op1 match {
                case reg1: Register =>
                  modifiesRegister(instr, reg1) || (op2 match {
                    case reg2: Register => modifiesRegister(instr, reg2)
                    case _ => false
                  })
                case _ => op2 match {
                  case reg2: Register => modifiesRegister(instr, reg2)
                  case _ => false
                }
              }
            }
            
            if (!couldChange) {
              // Skip this redundant compare
              i += 1
            } else {
              // Not redundant - save this compare for later
              result += current
              lastCmpOp1 = Some(op1)
              lastCmpOp2 = Some(op2)
              lastCmpIndex = i
              i += 1
            }
          } else {
            // First compare or different operands - save this compare for later
            result += current
            lastCmpOp1 = Some(op1)
            lastCmpOp2 = Some(op2)
            lastCmpIndex = i
            i += 1
          }
          
        case _ =>
          // Any other instruction
          result += current
          i += 1
      }
    }
    
    result.toList
  }
  
  /**
   * Check if any of the registers in the given sequence are used between
   * the start and end indices in the instruction list
   */
  private def regsNotUsedBetween(
    instructions: List[ARMInstruction], 
    startIndex: Int, 
    endIndex: Int, 
    registers: Seq[Register]
  ): Boolean = {
    // If there are no instructions between start and end (they're consecutive),
    // then the registers are not used between them
    if (endIndex - startIndex <= 1) {
      return true
    }
    
    // Check if any register is used in any instruction between start and end
    var i = startIndex + 1
    while (i < endIndex) {
      val instr = instructions(i)
      if (registers.exists(reg => usesRegister(instr, reg) || modifiesRegister(instr, reg))) {
        return false
      }
      i += 1
    }
    true
  }
  
  /**
   * Check if any instruction between the current index and the next store/branch
   * uses the specified register
   */
  private def instructionBetweenUsesRegister(
    instructions: List[ARMInstruction], 
    startIndex: Int, 
    register: Register
  ): Boolean = {
    var i = startIndex
    while (i < instructions.length) {
      val instr = instructions(i)
      
      instr match {
        case _: Label | _: define => // Skip these
        case _ if usesRegister(instr, register) => 
          return true
        case Str(_, _) | B(_, _) => 
          // Reached next store or branch
          return false
        case _ => // Continue checking
      }
      
      i += 1
    }
    false
  }
  
  /**
   * Check if an instruction uses a specific register
   */
  private def usesRegister(instruction: ARMInstruction, register: Register): Boolean = {
    instruction match {
      case Ldr(dest, Address(base, _)) => dest == register || base == register
      case Str(src, Address(base, _)) => src == register || base == register
      case Add(dest, src1, src2: Register) => dest == register || src1 == register || src2 == register
      case Add(dest, src1, _) => dest == register || src1 == register
      case Sub(dest, src1, src2: Register) => dest == register || src1 == register || src2 == register
      case Sub(dest, src1, _) => dest == register || src1 == register
      case Mul(dest, src1, src2) => dest == register || src1 == register || src2 == register
      case Mov(dest, src: Register, _) => dest == register || src == register
      case Cmp(src1: Register, src2: Register) => src1 == register || src2 == register
      case Cmp(src1: Register, _) => src1 == register
      case Cmp(_, src2: Register) => src2 == register
      case Push(regs) => regs.contains(register)
      case Pop(regs) => regs.contains(register)
      case B(_, _) => false
      case Bl(_, _) => false // Branch with link affects LR but we don't track that here
      case _ => false // Other cases
    }
  }
  
  /**
   * Check if an instruction modifies a specific register
   */
  private def modifiesRegister(instruction: ARMInstruction, register: Register): Boolean = {
    instruction match {
      case Ldr(dest, _) => dest == register
      case Ldrb(dest, _) => dest == register
      case Str(_, _) => false // STR doesn't modify registers
      case Strb(_, _) => false
      case Add(dest, _, _) => dest == register
      case Sub(dest, _, _) => dest == register
      case Mul(dest, _, _) => dest == register
      case Mov(dest, _, _) => dest == register
      case Pop(regs) => regs.contains(register)
      case Push(_) => false // PUSH doesn't modify the registers being pushed
      case Bl(_, _) => register == LR // Branch with link modifies LR
      case Smull(destLo, destHi, _, _) => destLo == register || destHi == register
      case And(dest, _, _) => dest == register
      case Asr(dest, _, _) => dest == register
      case Cmp(_, _) => false // CMP doesn't modify registers
      case _ => false // Other cases
    }
  }
  
  /**
   * Fold consecutive arithmetic operations on the same register
   * Example: ADD r0, r0, #4 followed by ADD r0, r0, #8 can be combined into ADD r0, r0, #12
   */
  def foldConsecutiveArithmetic(instructions: List[ARMInstruction]): List[ARMInstruction] = {
    val result = ListBuffer[ARMInstruction]()
    var i = 0
    
    while (i < instructions.length - 1) {
      val current = instructions(i)
      val next = instructions(i + 1)
      
      (current, next) match {
        // Combine consecutive ADD with immediate values
        case (Add(dest1, src1, ImmNum(val1)), Add(dest2, src2, ImmNum(val2))) 
            if dest1 == dest2 && dest1 == src2 && src1 == src2 =>
          // Replace ADD r0, r0, #x followed by ADD r0, r0, #y with ADD r0, r0, #(x+y)
          result += Add(dest1, src1, ImmNum(val1 + val2))
          i += 2
          
        // Combine consecutive SUB with immediate values
        case (Sub(dest1, src1, ImmNum(val1)), Sub(dest2, src2, ImmNum(val2))) 
            if dest1 == dest2 && dest1 == src2 && src1 == src2 =>
          // Replace SUB r0, r0, #x followed by SUB r0, r0, #y with SUB r0, r0, #(x+y)
          result += Sub(dest1, src1, ImmNum(val1 + val2))
          i += 2
          
        // Combine ADD followed by SUB with immediate values
        case (Add(dest1, src1, ImmNum(val1)), Sub(dest2, src2, ImmNum(val2))) 
            if dest1 == dest2 && dest1 == src2 && src1 == src2 =>
          if (val1 >= val2) {
            result += Add(dest1, src1, ImmNum(val1 - val2))
          } else {
            result += Sub(dest1, src1, ImmNum(val2 - val1))
          }
          i += 2
          
        // Combine SUB followed by ADD with immediate values
        case (Sub(dest1, src1, ImmNum(val1)), Add(dest2, src2, ImmNum(val2))) 
            if dest1 == dest2 && dest1 == src2 && src1 == src2 =>
          if (val1 >= val2) {
            result += Sub(dest1, src1, ImmNum(val1 - val2))
          } else {
            result += Add(dest1, src1, ImmNum(val2 - val1))
          }
          i += 2
          
        case _ => 
          result += current
          i += 1
      }
    }
    
    // Add the last instruction
    if (i < instructions.length) {
      result += instructions.last
    }
    
    result.toList
  }
} 