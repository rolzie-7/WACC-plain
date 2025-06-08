package wacc

import scala.util.{Try, Success, Failure}
import parsley.{Success => PSuccess, Failure => PFailure}
import wacc.backEnd.{CodeGenerator, TACGenerator}
import java.io.File

object ExitCodes {
  val SUCCESS = 0
  val SYNTAX_ERROR = 100
  val SEMANTIC_ERROR = 200
  val NO_FILE = 1
}

object WaccRunner {
  def main(args: Array[String]): Unit = {
    if (args.isEmpty) {
      // println("Usage: WaccRunner <filepath> [--no-optimize]")
      System.exit(ExitCodes.NO_FILE)
    }

    val filePath = args(0)
    val optimize = !args.contains("--no-optimize")
    
    val currentDir = new File(".").getCanonicalPath
    println(s"Current directory: $currentDir")
    println(s"Processing file: $filePath")
    println(s"Optimization: ${if (optimize) "enabled" else "disabled"}")

    val result: Either[(String, String, Int), String] = Try {
      Parser.parse(filePath) match {
        case PSuccess(ast) =>
          ErrorCollector.clear()
          ErrorCollector.setCurrentFile(filePath)
          SemanticsChecker.check(ast)
          if (ErrorCollector.hasErrors) {
            Left((filePath, ErrorCollector.formatErrors(), ExitCodes.SEMANTIC_ERROR))
          } else {
            // Generate TAC from AST
            val tacInstructions = TACGenerator.generateFullTAC(ast)
            
            // Generate assembly from TAC
            // Create output file at root level, not next to input file
            val outputFileName = new File(filePath).getName.replaceAll("\\.wacc$", ".s")
            
            // Write assembly to file at root level with optimize flag
            CodeGenerator.generateARMToFile(tacInstructions, outputFileName, optimize)
            
            // Return success with just the filename
            Right(outputFileName)
          }
        case PFailure(msg) => Left((filePath, s"Parse error: $msg", ExitCodes.SYNTAX_ERROR))
      }
    } match {
      case Success(res) => res
      case Failure(e)   => Left((filePath, s"Unexpected error: ${e.getMessage}", ExitCodes.SYNTAX_ERROR))
    }

    result match {
      case Left((fp, errMsg, exitCode)) =>
        println(s"Error processing file $fp:")
        println(errMsg)
        System.exit(exitCode)
      case Right(outputFileName) =>
        println(s"File processed successfully: $filePath")
        println(s"Assembly code written to: $outputFileName")
        System.exit(ExitCodes.SUCCESS)
    }
  }
}
