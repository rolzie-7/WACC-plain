import wacc.ast._
import Statements._
import Functions._
import Literals._
import wacc.SymbolTable._

case class interpreter() {
    def interpret(ast: Any): Unit = {
        ast match {
            case Program(functions, main) =>
                functions.foreach(interpret)
                interpret(main)
            case StmtList(stmt1, stmt2) =>
                interpret(stmt1)
                interpret(stmt2)
            // Skip - do nothing statement
            case Skip(_) =>
                // No operation needed, just continue
                
            // Declarations and assignments
            case Declare(typ, id, rhs) =>
                // Create variable with id.name in current scope
                // Evaluate rhs and assign the result to the variable
                val rhsValue = evaluate(rhs)
                val trueName = id.trueName
                val varInfo = globalLookup(trueName) match {
                    case Some(info) => info
                    case None => throw new Exception(s"Variable $trueName not found")
                }
                varInfo.value = Some(rhsValue)
            case Assign(lhs, rhs) =>
                // Evaluate right-hand side
                // Resolve left-hand side location
                // Assign the value to the location
                val rhsValue = evaluate(rhs)
                assign(lhs, rhsValue)
                
            case Print(expr) =>
                // Evaluate expression
                // Output the result to stdout without newline
                
            case Println(expr) =>
                // Evaluate expression
                // Output the result to stdout with newline
                
            // Memory management
            case Free(expr) =>
                // Evaluate expr to get reference to heap object
                // Deallocate memory for the object
                
            // Control flow
            case Return(expr) =>
                // Evaluate expression
                // Return value from current function
                
            case Exit(expr) =>
                // Evaluate expr to get exit code
                // Exit the program with the specified code
                
            case IfThenElse(cond, thenStmt, elseStmt) =>
                // Evaluate condition
                // If true, interpret thenStmt
                // If false, interpret elseStmt
                
            case WhileDo(cond, body) =>
                // Evaluate condition
                // While condition is true, interpret body
                
            case BeginEnd(stmt) =>
                // Create new scope
                // Interpret statement
                // Exit scope
                
            // Function-related
            case Func(returnType, name, params, body) =>
                // Store function definition in function table
                // (No execution at definition time)
                
            case Call(function, args) =>
                // Resolve function definition
                // Evaluate arguments
                // Create function scope with parameters
                // Execute function body
                
            case _ =>
                throw new Exception("Invalid statement")
        }
    }

    def evaluate(expr: Rvalue): Any = {
        expr match {
            case IntLit(value) => value
            case BoolLit(value) => value
            case CharLit(value) => value
            case StrLit(value) => value

            case _ => throw new Exception("Invalid expression")
        }
    }

    def assign(lhs: Lvalue, rhsValue: Any): Unit = {
        lhs match {
            case id @ Ident(name) =>
                // Handle variable assignment
                val trueName = id.trueName
                val varInfo = globalLookup(trueName) match {
                    case Some(info) => info
                    case None => throw new Exception(s"Variable $trueName not found")
                }
                varInfo.value = Some(rhsValue)
            case p@ Pairs.Fst(pair) =>
                copyPair(p, rhsValue)
            case p@ Pairs.Snd(pair) =>
                copyPair(p, rhsValue)
            case arrayElem @ Arrays.ArrayElem(id, indices) =>
                // Get the base array
                var currentArray = getVarRuntimeValue(id)
                
                // Navigate through all indices except the last one
                for (i <- 0 until indices.size - 1) {
                    val index = evaluate(indices(i)).asInstanceOf[Int]
                    currentArray = currentArray.asInstanceOf[Array[Any]](index)
                }
                
                // Assign to the element at the final index
                val finalIndex = evaluate(indices.last).asInstanceOf[Int]
                currentArray.asInstanceOf[Array[Any]](finalIndex) = rhsValue
            case _ => throw new Exception("Invalid left-hand side")
        }
    }

    def copyPair(pair: Lvalue, rhsValue: Any): Any = {
        pair match {
            case Pairs.Fst(id @ Ident(name)) =>
                (rhsValue, getVarRuntimeValue(id).asInstanceOf[(Any, Any)]._2)
            case Pairs.Snd(id @ Ident(name)) =>
                (getVarRuntimeValue(id).asInstanceOf[(Any, Any)]._1, rhsValue)
            case Pairs.Fst(pair) =>
                (copyPair(pair, rhsValue), getLvalueRuntimeValue(pair).asInstanceOf[(Any, Any)]._2)
            case Pairs.Snd(pair) =>
                (getLvalueRuntimeValue(pair).asInstanceOf[(Any, Any)]._1, copyPair(pair, rhsValue))
            case _ => throw new Exception("Invalid pair")
        }
    }

    def getLvalueRuntimeValue(pair: Lvalue): Any = {
        pair match {
            case id @ Ident(name) =>
                getVarRuntimeValue(id)
            case Pairs.Fst(pair) =>
                getLvalueRuntimeValue(pair).asInstanceOf[(Any, Any)]._1
            case Pairs.Snd(pair) =>
                getLvalueRuntimeValue(pair).asInstanceOf[(Any, Any)]._2
            case Arrays.ArrayElem(id, indices) =>
                getLvalueRuntimeValue(id).asInstanceOf[Array[Any]]
            case _ => throw new Exception("Invalid left-hand side")
        }
    }
    def getVarRuntimeValue(id: Ident): Any = {
        val varInfo = globalLookup(id.trueName) match {
            case Some(info) => info
            case None => throw new Exception(s"Variable ${id.trueName} not found")
        }
        varInfo.value.getOrElse(throw new Exception(s"Variable ${id.trueName} has no value"))
    }
}
