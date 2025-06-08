import json
from transformers import transform_ast
from typing import Dict, Any

def flatten_stmt_list(node):
    statements = []
    
    # Base case: not a StmtList
    if not node or node.get('type') != 'StmtList':
        if node:  # if node exists and isn't a StmtList, it's a real statement
            statements.append(node)
        return statements
    
    # Recursive case: is a StmtList
    # Add first's statements
    statements.extend(flatten_stmt_list(node.get('first')))
    # Add second's statements
    statements.extend(flatten_stmt_list(node.get('second')))
    
    return statements

def process_ast(filename: str) -> Dict[str, Any]:
    with open(filename) as f:
        ast = json.load(f)
        transformed_ast = transform_ast(ast)
        return transformed_ast

# Example usage:
if __name__ == "__main__":
    transformed = process_ast('src/main/wacc/ast2py/null.json')
    print(json.dumps(transformed, indent=2))

