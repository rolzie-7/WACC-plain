package wacc

import java.io.{File, PrintWriter}
import parsley.{Success, Failure}
import scala.collection.mutable.ListBuffer

object JsonifyWacc {
  def runJsonifyWacc(args: Array[String]): Unit = {
    if (args.length == 0) {
      println("Usage: JsonifyWacc <input-file> or JsonifyWacc --batch <wacc-examples-dir> <output-dir>")
      System.exit(1)
    }

    // Check if we're in batch mode
    if (args(0) == "--batch") {
      if (args.length != 3) {
        println("Batch mode usage: JsonifyWacc --batch <wacc-examples-dir> <output-dir>")
        System.exit(1)
      }
      val examplesDir = args(1)
      val outputDir = args(2)
      processBatch(examplesDir, outputDir)
    } else {
      // Single file mode
      val inputFile = args(0)
      processFile(inputFile, inputFile.replaceAll("\\.wacc$", ".json"))
    }
  }

  def processFile(inputFile: String, outputFile: String): Boolean = {
    Parser.parse(inputFile) match {
      case Success(program) =>
        // Convert AST to JSON
        val jsonOutput = ASTJsonify.toJson(program)
        
        // Write to file
        val writer = new PrintWriter(new File(outputFile))
        try {
          writer.write(jsonOutput)
          println(s"Successfully parsed and saved JSON to $outputFile")
          true
        } catch {
          case e: Exception =>
            println(s"Error writing to file $outputFile: ${e.getMessage}")
            false
        } finally {
          writer.close()
        }

      case Failure(msg) =>
        println(s"Parsing failed for $inputFile: $msg")
        false
    }
  }

  def processBatch(examplesDir: String, outputDir: String): Unit = {
    // Create output directory if it doesn't exist
    val outputDirFile = new File(outputDir)
    if (!outputDirFile.exists()) {
      outputDirFile.mkdirs()
    }

    // Find all .wacc files recursively
    val waccFiles = findWaccFiles(new File(examplesDir))
    
    println(s"Found ${waccFiles.size} WACC files to process")
    
    // Process each file
    var successCount = 0
    for (file <- waccFiles) {
      val relativePath = file.getPath.replace(examplesDir, "").replaceAll("^/", "")
      // Replace slashes with underscores to flatten the directory structure
      val flattenedName = relativePath.replaceAll("/", "_")
      val outputFile = s"$outputDir/$flattenedName.json"
      
      if (processFile(file.getPath, outputFile)) {
        successCount += 1
      }
    }
    
    println(s"Successfully processed $successCount out of ${waccFiles.size} WACC files")
  }

  def findWaccFiles(dir: File): List[File] = {
    val files = ListBuffer[File]()
    
    if (dir.exists && dir.isDirectory) {
      for (file <- dir.listFiles) {
        if (file.isDirectory) {
          files ++= findWaccFiles(file)
        } else if (file.getName.endsWith(".wacc")) {
          files += file
        }
      }
    }
    
    files.toList
  }
}
