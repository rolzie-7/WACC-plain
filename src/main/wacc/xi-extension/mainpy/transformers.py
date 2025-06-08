from typing import Any, Dict, List, Optional
from dataclasses import dataclass

@dataclass
class TransformContext:
    """Context passed during transformation"""
    # Add any context needed during transformation
    pass

class BaseTransformer:
    def transform(self, node: Dict[str, Any], ctx: TransformContext) -> Dict[str, Any]:
        return node

# Dictionary mapping node types to their transformers
TRANSFORMERS = {
    # Statements
    'Skip': BaseTransformer(),
    'Declare': BaseTransformer(),
    'Assign': BaseTransformer(),
    'Read': BaseTransformer(),
    'Free': BaseTransformer(),
    'Return': BaseTransformer(),
    'Exit': BaseTransformer(),
    'Print': BaseTransformer(),
    'Println': BaseTransformer(),
    'IfThenElse': BaseTransformer(),
    'WhileDo': BaseTransformer(),
    'BeginEnd': BaseTransformer(),
    'StmtList': BaseTransformer(),
    
    # Expressions - Binary Ops
    'Add': BaseTransformer(),
    'Sub': BaseTransformer(), 
    'Mul': BaseTransformer(),
    'Div': BaseTransformer(),
    'Mod': BaseTransformer(),
    'GT': BaseTransformer(),
    'GTE': BaseTransformer(),
    'LT': BaseTransformer(),
    'LTE': BaseTransformer(),
    'E': BaseTransformer(),
    'NE': BaseTransformer(),
    'And': BaseTransformer(),
    'Or': BaseTransformer(),

    # Expressions - Unary Ops
    'Not': BaseTransformer(),
    'Neg': BaseTransformer(),
    'Len': BaseTransformer(),
    'Ord': BaseTransformer(),
    'Chr': BaseTransformer(),

    # Literals
    'IntLit': BaseTransformer(),
    'BoolLit': BaseTransformer(),
    'CharLit': BaseTransformer(),
    'StrLit': BaseTransformer(),
    'PairLit': BaseTransformer(),
    'Ident': BaseTransformer(),

    # Arrays
    'ArrayLit': BaseTransformer(),
    'ArrayElem': BaseTransformer(),

    # Pairs
    'NewPair': BaseTransformer(),
    'Fst': BaseTransformer(),
    'Snd': BaseTransformer(),

    # Types
    'IntType': BaseTransformer(),
    'BoolType': BaseTransformer(),
    'CharType': BaseTransformer(),
    'StringType': BaseTransformer(),
    'ArrayType': BaseTransformer(),
    'PairType': BaseTransformer(),
    'PairElemType1': BaseTransformer(),
    'PairElemType2': BaseTransformer(),

    # Functions
    'Program': BaseTransformer(),
    'Function': BaseTransformer(),
    'Call': BaseTransformer(),
    'Param': BaseTransformer(),
}

def transform_node(node: Dict[str, Any], ctx: TransformContext) -> Dict[str, Any]:
    """Transform a single node and its children"""
    if not isinstance(node, dict):
        return node
        
    node_type = node.get('type')
    if not node_type:
        return node

    # Transform children first based on node type
    if node_type in ['StmtList']:
        node['first'] = transform_node(node['first'], ctx)
        node['second'] = transform_node(node['second'], ctx)
    elif node_type in ['IfThenElse']:
        node['condition'] = transform_node(node['condition'], ctx)
        node['thenStmt'] = transform_node(node['thenStmt'], ctx)
        node['elseStmt'] = transform_node(node['elseStmt'], ctx)
    elif node_type in ['WhileDo']:
        node['condition'] = transform_node(node['condition'], ctx)
        node['body'] = transform_node(node['body'], ctx)
    elif node_type in ['Program']:
        node['functions'] = [transform_node(f, ctx) for f in node['functions']]
        node['main'] = transform_node(node['main'], ctx)
    # Handle binary operations
    elif node_type in ['Add', 'Sub', 'Mul', 'Div', 'Mod', 'GT', 'GTE', 'LT', 'LTE', 'E', 'NE', 'And', 'Or']:
        node['left'] = transform_node(node['left'], ctx)
        node['right'] = transform_node(node['right'], ctx)
    # Handle unary operations
    elif node_type in ['Not', 'Neg', 'Len', 'Ord', 'Chr']:
        node['expr'] = transform_node(node['expr'], ctx)
    # Handle array operations
    elif node_type == 'ArrayElem':
        node['array'] = transform_node(node['array'], ctx)
        node['indices'] = [transform_node(idx, ctx) for idx in node['indices']]
    elif node_type == 'ArrayLit':
        if node.get('elements'):
            node['elements'] = [transform_node(e, ctx) for e in node['elements']]

    # Apply the transformer for this node type
    transformer = TRANSFORMERS.get(node_type)
    if transformer:
        return transformer.transform(node, ctx)
    return node

def transform_ast(ast: Dict[str, Any]) -> Dict[str, Any]:
    """Transform an entire AST"""
    ctx = TransformContext()
    return transform_node(ast, ctx) 