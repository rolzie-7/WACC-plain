package wacc.backEnd

import scala.io.StdIn
import parsley.Success
import parsley.Failure
import scala.util.Try
import java.io.{File, PrintWriter, ByteArrayOutputStream, ByteArrayInputStream}
import scala.sys.process._
import wacc.Parser
import wacc.SemanticsChecker
import wacc.ast.Statements.{Skip}

object WaccRepl {

  // Helper function to reindent code.
  def reindent(code: String): String = {
    val lines = code.split("\n")
    var indentLevel = 0
    val indentSize = 2 // Number of spaces per indent level.
    val formattedLines = lines.map { line =>
      val trimmed = line.trim
      // If a line starts with "end", decrease indent level.
      if (trimmed.startsWith("end")) {
        indentLevel = math.max(indentLevel - 1, 0)
      }
      val indentedLine = (" " * (indentLevel * indentSize)) + trimmed
      // Increase indent if the line is exactly "begin" or ends with "is" (for function definitions).
      if (trimmed == "begin" || trimmed.endsWith("is")) {
        indentLevel += 1
      }
      indentedLine
    }
    formattedLines.mkString("\n")
  }

  // Helper method to check if a command exists in PATH.
  def checkForCommand(cmd: String): Boolean = {
    Try(Process(Seq("which", cmd)).!!.trim).toOption.exists(_.nonEmpty)
  }

  // Generic helper to download/install a package using apt-get.
  def downloadPackage(packageName: String): Boolean = {
    println(s"Attempting to install $packageName using apt-get...")
    val updateResult = Process(Seq("sudo", "apt-get", "update")).!
    if (updateResult != 0) {
      println("Failed to update package list.")
      return false
    }
    val installResult = Process(Seq("sudo", "apt-get", "install", "-y", packageName)).!
    installResult == 0
  }

  // Check and download the assembler if necessary.
  def ensureAssemblerExists(): Unit = {
    if (!checkForCommand("arm-linux-gnueabi-gcc")) {
      println("Assembler not found: arm-linux-gnueabi-gcc")
      if (!downloadPackage("gcc-arm-linux-gnueabi")) {
        println("Failed to install arm-linux-gnueabi-gcc. Exiting.")
        System.exit(1)
      } else println("Successfully installed arm-linux-gnueabi-gcc.")
    }
  }

  // Check and download QEMU if necessary.
  def ensureQemuExists(): Unit = {
    if (!checkForCommand("qemu-arm")) {
      println("qemu-arm not found.")
      if (!downloadPackage("qemu-user")) {
        println("Failed to install qemu-user. Exiting.")
        System.exit(1)
      } else println("Successfully installed qemu-user.")
    }
  }

  def compileAndRun(asmFile: File, input: Option[String]): (Int, String) = {
    val exeName = asmFile.getPath.replace(".s", "")
    
    // Compile the ARM assembly
    val compileCmd = Seq(
      "arm-linux-gnueabi-gcc", 
      "-o", exeName, 
      "-march=armv6",    // Raspberry Pi compatible
      "-marm",           // Force ARM mode
      "-static",         // Static linking 
      asmFile.getPath
    )
    
    val compileOutputStream = new ByteArrayOutputStream
    val compileErrorStream = new ByteArrayOutputStream
    val compileResult = Process(compileCmd).!(ProcessLogger(
      out => compileOutputStream.write(out.getBytes),
      err => compileErrorStream.write(err.getBytes)
    ))
    
    if (compileResult != 0) {
      val errorOutput = compileErrorStream.toString
      return (-1, s"Compilation failed with code $compileResult\nCommand: ${compileCmd.mkString(" ")}\nError: $errorOutput")
    }
    
    // Run the compiled program
    val runCmd = Seq("qemu-arm", exeName)
    val outputStream = new ByteArrayOutputStream
    val errorStream = new ByteArrayOutputStream
    
    val (exitCode, output) = input match {
      case Some(in) => 
        val process = Process(runCmd).#<(new ByteArrayInputStream(in.getBytes))
        val code = process.!(ProcessLogger(
          out => outputStream.write(out.getBytes),
          err => errorStream.write(err.getBytes)
        ))
        (code, outputStream.toString + errorStream.toString)
      case None =>
        val code = Process(runCmd).!(ProcessLogger(
          out => outputStream.write(out.getBytes),
          err => errorStream.write(err.getBytes)
        ))
        (code, outputStream.toString + errorStream.toString)
    }
    
    // Clean up the executable file after running
    new File(exeName).delete()
    
    (exitCode, output)
  }

  // Interactive change mode: print each line with its number and allow changing one line at a time.
  def changeAccumulator(accumulator: StringBuilder): Unit = {
    if (accumulator.isEmpty) {
      println("Accumulator is empty. Nothing to change.")
      return
    }
    val lines = accumulator.toString.split("\n").toBuffer
    println("Entering change mode. Current code:")
    for ((line, idx) <- lines.zipWithIndex) {
      println(s"${idx + 1}: $line")
    }
    println("Type the line number you want to change, or type ':endchange' to finish.")
    var editing = true
    while (editing) {
      print("CHANGE> ")
      val input = StdIn.readLine().trim
      if (input == ":endchange") {
        editing = false
      } else {
        try {
          val lineNum = input.toInt
          if (lineNum < 1 || lineNum > lines.size) {
            println("Invalid line number.")
          } else {
            println(s"Current content of line $lineNum: ${lines(lineNum - 1)}")
            println("Enter new content for this line (leave blank to keep unchanged):")
            val newContent = StdIn.readLine()
            if (newContent.trim.nonEmpty) {
              lines(lineNum - 1) = newContent
              println(s"Line $lineNum updated.")
            } else {
              println(s"Line $lineNum remains unchanged.")
            }
          }
        } catch {
          case _: NumberFormatException =>
            println("Please enter a valid line number or ':endchange' to finish.")
        }
      }
    }
    accumulator.clear()
    accumulator.append(lines.mkString("\n"))
    println("Accumulator updated.")
  }

  def runRepl(args: Array[String]): Unit = {
    // Ensure required external tools are available.
    /*  These cannot be run on labts due to no sudo privelages
    ensureAssemblerExists()
    ensureQemuExists()
    */
    println("Welcome to the WACC REPL.")
    println("Enter your complete program between 'begin' and 'end'.")
    println("When finished, type ':run' followed by optional flags (-t for TAC, -a for ARM) to compile and execute.")
    println("Type ':print' to display the current accumulated code (formatted).")
    println("Type ':clear' to clear the accumulated code.")
    println("Type ':change' to edit the accumulated code line-by-line (enter a line number to modify that line; leave input blank to keep unchanged; type ':endchange' when finished).")
    println("Type ':help' for help or ':quit' to exit.")
    println()
    
    val accumulator: StringBuilder = new StringBuilder
    var continue: Boolean = true

    try {
      while (continue) {
        print("WACC> ")
        
        val line = Option(StdIn.readLine())
        line match {
          case None | Some(":quit") | Some(":q") =>
            continue = false
          case Some(input) =>
            input.trim match {
              case ":help" =>
                println("WACC REPL Help:")
                println("  - Enter your program between 'begin' and 'end'.")
                println("  - To run your program, type ':run' followed by optional flags:")
                println("        -t   Print the generated TAC (Three-Address Code).")
                println("        -a   Print the generated ARM assembly code.")
                println("      For example: ':run -t -a'")
                println("  - Type ':print' to print the current accumulated code (formatted).")
                println("  - Type ':clear' to clear the accumulated code.")
                println("  - Type ':change' to edit the accumulated code line-by-line. In change mode,")
                println("      enter a line number to modify that line. If you enter an empty string,")
                println("      the line remains unchanged. Type ':endchange' to finish editing.")
                println("  - Type ':quit' or ':q' to exit the REPL.")
              case ":print" =>
                println("Current accumulated code:")
                println(reindent(accumulator.toString))
              case ":clear" =>
                accumulator.clear()
                println("Accumulator cleared.")
              case ":change" =>
                changeAccumulator(accumulator)
              case command if command.startsWith(":run") =>
                // Parse flags from the :run command.
                val tokens = input.trim.split("\\s+")
                val printTAC = tokens.contains("-t")
                val printARM = tokens.contains("-a")
                
                val code = accumulator.toString.trim
                if (code.startsWith("begin") && code.endsWith("end")) {
                  // Write accumulated code to a temporary file.
                  val tempFile: File = File.createTempFile("wacc_repl_", ".wacc")
                  val writer = new PrintWriter(tempFile)
                  try { writer.write(code) } finally { writer.close() }
                  Parser.parse(tempFile.getPath) match {
                    case Success(program) =>
                      // Ensure that if functions are defined, main code is provided.
                      if (program.functions.nonEmpty && program.main.isInstanceOf[Skip]) {
                        println("Error: Functions must be defined together with main code. Please include main statements in your program.")
                      } else {
                        Try(SemanticsChecker.check(program)) match {
                          case scala.util.Success(_) =>
                            try {
                            
                              val tacInsts = TACGenerator.generateFullTAC(program)
                              if (printTAC)
                                println(s"\nTAC:\n$tacInsts")
                              
                              val armOutputStream = new ByteArrayOutputStream()
                              CodeGenerator.generateARMFromTAC(tacInsts, armOutputStream)
                              val armCode = armOutputStream.toString
                              if (printARM)
                                println(s"\nGenerated ARM code:\n$armCode")

                              // Write the ARM code to a temporary file.
                              val tempAsmFile = File.createTempFile("wacc_repl_", ".s")
                              val asmWriter = new PrintWriter(tempAsmFile)
                              try { asmWriter.write(armCode) } finally { asmWriter.close() }
                              
                              // Compile and run the ARM code.
                              val (exitCode, runtimeOutput) = compileAndRun(tempAsmFile, None)
                              println("Program Output:")
                              println(runtimeOutput)
                              println(s"Exit code: $exitCode")
                              
                              tempAsmFile.delete()
                            } catch {
                              case e: Exception =>
                                println(s"Generation/Execution error: ${e.getMessage}")
                            }

                          case scala.util.Failure(e) =>
                            println(s"Semantic error: ${e.getMessage}")
                        }
                      }
                    case Failure(msg) =>
                      if (!msg.toString.contains("unexpected end")) {
                        println(s"Parse error: ${msg.toString}")
                        accumulator.clear()
                      }
                  }

                  tempFile.delete()
                } else {
                  println("Error: Your snippet must start with 'begin' and end with 'end'.")
                }
              case other =>
                // Only accumulate if the first non-command line is "begin".
                if (accumulator.isEmpty && other.trim != "begin") {
                  println("Please start your program with 'begin'.")
                } else {
                  accumulator.append(other).append("\n")
                }
            }
        }
      }
    } catch {
      case e: Exception =>
        println(s"Fatal error: ${e.getMessage}")
    } finally {
      println("Goodbye!")
    }
  }
}
