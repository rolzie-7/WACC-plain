import json
from typing import Dict, Any
from transformers import transform_ast, TransformContext, TRANSFORMERS
import pytest
import torch
from neural_transformers import HierarchicalASTTransformer, NeuralTransformContext

# Sample AST nodes for testing
SAMPLE_NODES = {
    "declare": {
        "type": "Declare",
        "varType": {
            "type": "IntType",
            "pos": {"line": 1, "column": 1}
        },
        "identifier": {
            "type": "Ident",
            "name": "x",
            "pos": {"line": 1, "column": 5}
        },
        "rhs": {
            "type": "IntLit",
            "value": 42,
            "pos": {"line": 1, "column": 9}
        },
        "pos": {"line": 1, "column": 1}
    },
    
    "binary_op": {
        "type": "Add",
        "left": {
            "type": "IntLit",
            "value": 1,
            "pos": {"line": 1, "column": 1}
        },
        "right": {
            "type": "IntLit",
            "value": 2,
            "pos": {"line": 1, "column": 5}
        },
        "pos": {"line": 1, "column": 3}
    },

    "if_statement": {
        "type": "IfThenElse",
        "condition": {
            "type": "BoolLit",
            "value": True,
            "pos": {"line": 1, "column": 4}
        },
        "thenStmt": {
            "type": "Skip",
            "pos": {"line": 1, "column": 10}
        },
        "elseStmt": {
            "type": "Skip",
            "pos": {"line": 1, "column": 20}
        },
        "pos": {"line": 1, "column": 1}
    }
}

@pytest.fixture
def transformer():
    model = HierarchicalASTTransformer(embedding_dim=16)
    model.eval()  # Set to evaluation mode
    return model

@pytest.fixture
def ctx():
    return NeuralTransformContext(
        embedding_dim=16,
        device=torch.device('cpu')
    )

def print_embedding(name: str, embedding: torch.Tensor):
    """Helper to print embeddings in a readable format"""
    print(f"\n{name} Embedding:")
    print(f"Shape: {embedding.shape}")
    print(f"First few values: {embedding[:5].tolist()}")
    print(f"Mean: {embedding.mean().item():.4f}")
    print(f"Std: {embedding.std().item():.4f}")

class TestLiteralTransformers:
    def test_int_literal(self, transformer, ctx):
        node = {"type": "IntLit", "value": 42, "pos": (1, 1)}
        embedding = transformer.embed_literal(node, ctx)
        print_embedding("IntLit", embedding)
        assert embedding.shape == (16,)

    def test_bool_literal(self, transformer, ctx):
        node = {"type": "BoolLit", "value": True, "pos": (1, 1)}
        embedding = transformer.embed_literal(node, ctx)
        print_embedding("BoolLit", embedding)
        assert embedding.shape == (16,)

    def test_char_literal(self, transformer, ctx):
        node = {"type": "CharLit", "value": 'a', "pos": (1, 1)}
        embedding = transformer.embed_literal(node, ctx)
        print_embedding("CharLit", embedding)
        assert embedding.shape == (16,)

    def test_str_literal(self, transformer, ctx):
        node = {"type": "StrLit", "value": "hello", "pos": (1, 1)}
        embedding = transformer.embed_literal(node, ctx)
        print_embedding("StrLit", embedding)
        assert embedding.shape == (16,)

    def test_pair_literal(self, transformer, ctx):
        node = {"type": "PairLit", "pos": (1, 1)}
        embedding = transformer.embed_literal(node, ctx)
        print_embedding("PairLit", embedding)
        assert embedding.shape == (16,)

    def test_ident(self, transformer, ctx):
        node = {"type": "Ident", "name": "myVar", "pos": (1, 1)}
        embedding = transformer.embed_literal(node, ctx)
        print_embedding("Ident", embedding)
        assert embedding.shape == (16,)

class TestBinaryOpTransformers:
    @pytest.mark.parametrize("op_type", [
        "Add", "Sub", "Mul", "Div", "Mod", "GT", "GTE", 
        "LT", "LTE", "E", "NE", "And", "Or"
    ])
    def test_binary_ops(self, transformer, ctx, op_type):
        node = {
            "type": op_type,
            "left": {"type": "IntLit", "value": 1, "pos": (1, 1)},
            "right": {"type": "IntLit", "value": 2, "pos": (1, 2)},
            "pos": (1, 1)
        }
        embedding = transformer.embed_binary_op(node, ctx)
        print_embedding(f"Binary {op_type}", embedding)
        assert embedding.shape == (16,)

class TestUnaryOpTransformers:
    @pytest.mark.parametrize("op_type", ["Not", "Neg", "Len", "Ord", "Chr"])
    def test_unary_ops(self, transformer, ctx, op_type):
        node = {
            "type": op_type,
            "expr": {"type": "IntLit", "value": 42, "pos": (1, 1)},
            "pos": (1, 1)
        }
        embedding = transformer.transform_node(node, ctx)
        print_embedding(f"Unary {op_type}", embedding)
        assert embedding.shape == (16,)

class TestTypeTransformers:
    @pytest.mark.parametrize("type_name", [
        "IntType", "BoolType", "CharType", "StringType"
    ])
    def test_basic_types(self, transformer, ctx, type_name):
        node = {"type": type_name, "pos": (1, 1)}
        embedding = transformer.embed_type(node, ctx)
        print_embedding(type_name, embedding)
        assert embedding.shape == (16,)

    def test_array_type(self, transformer, ctx):
        node = {
            "type": "ArrayType",
            "baseType": {"type": "IntType", "pos": (1, 1)},
            "pos": (1, 1)
        }
        embedding = transformer.embed_type(node, ctx)
        print_embedding("ArrayType", embedding)
        assert embedding.shape == (16,)

    def test_pair_type(self, transformer, ctx):
        node = {
            "type": "PairType",
            "firstType": {"type": "IntType", "pos": (1, 1)},
            "secondType": {"type": "BoolType", "pos": (1, 1)},
            "pos": (1, 1)
        }
        embedding = transformer.embed_type(node, ctx)
        print_embedding("PairType", embedding)
        assert embedding.shape == (16,)

class TestStatementTransformers:
    def test_skip(self, transformer, ctx):
        node = {"type": "Skip", "pos": (1, 1)}
        embedding = transformer.embed_stmt(node, ctx)
        print_embedding("Skip", embedding)
        assert embedding.shape == (16,)

    def test_declare(self, transformer, ctx):
        node = {
            "type": "Declare",
            "varType": {"type": "IntType", "pos": (1, 1)},
            "identifier": {"type": "Ident", "name": "x", "pos": (1, 1)},
            "rhs": {"type": "IntLit", "value": 42, "pos": (1, 1)},
            "pos": (1, 1)
        }
        embedding = transformer.embed_stmt(node, ctx)
        print_embedding("Declare", embedding)
        assert embedding.shape == (16,)

    def test_if_then_else(self, transformer, ctx):
        node = {
            "type": "IfThenElse",
            "condition": {"type": "BoolLit", "value": True, "pos": (1, 1)},
            "thenStmt": {"type": "Skip", "pos": (1, 1)},
            "elseStmt": {"type": "Skip", "pos": (1, 1)},
            "pos": (1, 1)
        }
        embedding = transformer.embed_stmt(node, ctx)
        print_embedding("IfThenElse", embedding)
        assert embedding.shape == (16,)

def test_full_program(transformer, ctx):
    program = {
        "type": "Program",
        "functions": [],
        "main": {
            "type": "StmtList",
            "first": {
                "type": "Declare",
                "varType": {"type": "IntType", "pos": (1, 1)},
                "identifier": {"type": "Ident", "name": "x", "pos": (1, 1)},
                "rhs": {"type": "IntLit", "value": 42, "pos": (1, 1)},
                "pos": (1, 1)
            },
            "second": {"type": "Skip", "pos": (1, 1)},
            "pos": (1, 1)
        },
        "pos": (1, 1)
    }
    embedding = transformer.transform_node(program, ctx)
    print_embedding("Full Program", embedding)
    assert embedding.shape == (16,)

@pytest.mark.parametrize("node_type,input_node,expected_output", [
    (
        "Declare",
        SAMPLE_NODES["declare"],
        {
            "type": "Declare",
            "varType": {
                "type": "IntType",
                "pos": {"line": 1, "column": 1}
            },
            "identifier": {
                "type": "Ident",
                "name": "x",
                "pos": {"line": 1, "column": 5}
            },
            "rhs": {
                "type": "IntLit",
                "value": 42,
                "pos": {"line": 1, "column": 9}
            },
            "pos": {"line": 1, "column": 1}
        }
    ),
    (
        "Add",
        SAMPLE_NODES["binary_op"],
        {
            "type": "Add",
            "left": {
                "type": "IntLit",
                "value": 1,
                "pos": {"line": 1, "column": 1}
            },
            "right": {
                "type": "IntLit",
                "value": 2,
                "pos": {"line": 1, "column": 5}
            },
            "pos": {"line": 1, "column": 3}
        }
    ),
    (
        "IfThenElse",
        SAMPLE_NODES["if_statement"],
        {
            "type": "IfThenElse",
            "condition": {
                "type": "BoolLit",
                "value": True,
                "pos": {"line": 1, "column": 4}
            },
            "thenStmt": {
                "type": "Skip",
                "pos": {"line": 1, "column": 10}
            },
            "elseStmt": {
                "type": "Skip",
                "pos": {"line": 1, "column": 20}
            },
            "pos": {"line": 1, "column": 1}
        }
    )
])
def test_node_transformation(node_type: str, input_node: Dict[str, Any], expected_output: Dict[str, Any]):
    """Test helper to verify node transformations"""
    ctx = TransformContext()
    result = TRANSFORMERS[node_type].transform(input_node, ctx)
    assert result == expected_output, f"Transformation failed for {node_type}"

def test_full_ast_transformation():
    """Test transforming a complete AST"""
    sample_program = {
        "type": "Program",
        "functions": [],
        "main": {
            "type": "StmtList",
            "first": SAMPLE_NODES["declare"],
            "second": {
                "type": "Println",
                "expr": SAMPLE_NODES["binary_op"],
                "pos": {"line": 2, "column": 1}
            },
            "pos": {"line": 1, "column": 1}
        },
        "pos": {"line": 1, "column": 1}
    }
    
    transformed = transform_ast(sample_program)
    assert transformed is not None
    assert "type" in transformed
    assert transformed["type"] == "Program"

def test_with_real_file():
    """Test using a real JSON AST file"""
    try:
        with open('src/main/wacc/ast2py/null.json', 'r') as f:
            ast = json.load(f)
            transformed = transform_ast(ast)
            
            # Basic structure checks
            assert transformed is not None
            assert "type" in transformed
            assert transformed["type"] == "Program"
            
            # Check that main block exists
            assert "main" in transformed
            
            # Print the transformed AST for inspection
            print("\nTransformed AST:")
            print(json.dumps(transformed, indent=2))
            
    except FileNotFoundError:
        pytest.skip("Test file not found")

def verify_node_structure(node: Dict[str, Any]):
    """Verify that a node maintains required structure after transformation"""
    assert "type" in node, "Node must have a type"
    assert "pos" in node, "Node must have a position"
    
    # Verify specific node types maintain their required fields
    if node["type"] == "Declare":
        assert "varType" in node
        assert "identifier" in node
        assert "rhs" in node
    elif node["type"] in ["Add", "Sub", "Mul", "Div"]:
        assert "left" in node
        assert "right" in node

def test_structure_preservation():
    """Test that transformations preserve required node structure"""
    for node_name, node in SAMPLE_NODES.items():
        transformed = transform_ast(node)
        verify_node_structure(transformed)

if __name__ == "__main__":
    # Run specific tests
    test_full_ast_transformation()
    test_with_real_file()
    test_structure_preservation()
    
    print("All tests completed successfully!")
    
    pytest.main([__file__, "-v", "-s"]) 