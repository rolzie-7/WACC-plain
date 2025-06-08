import torch
import torch.nn as nn
from typing import Dict, Any, List, Optional
from dataclasses import dataclass
from arm_config import DEVICE, to_device, MAGIC_PRIME

@dataclass
class NeuralTransformContext:
    """Neural context for transformations"""
    embedding_dim: int
    device: torch.device = DEVICE  # Default to MPS device

class NeuralTransformer(nn.Module):
    def __init__(self, input_dim: int, hidden_dim: int, output_dim: int):
        super().__init__()
        self.bottleneck_dim = hidden_dim * 3
        self.transform = nn.Sequential(
            nn.Linear(input_dim, self.bottleneck_dim),
            nn.LayerNorm(self.bottleneck_dim),
            nn.LeakyReLU(0.05),
            nn.Linear(self.bottleneck_dim, output_dim),
            nn.LayerNorm(output_dim)
        )
    
    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.transform(x)

class HierarchicalASTTransformer(nn.Module):
    def __init__(self, embedding_dim: int = 128):
        super().__init__()
        self.embedding_dim = embedding_dim
        
        # Leaf node embeddings
        self.literal_embeddings = nn.ModuleDict({
            'IntLit': NeuralTransformer(1, embedding_dim, embedding_dim),
            'BoolLit': NeuralTransformer(1, embedding_dim, embedding_dim),
            'CharLit': NeuralTransformer(1, embedding_dim, embedding_dim),
            'StrLit': NeuralTransformer(1, embedding_dim, embedding_dim),
            'PairLit': NeuralTransformer(1, embedding_dim, embedding_dim),
            'Ident': nn.Embedding(10000, embedding_dim)  # Vocabulary size of 10000
        })
        
        # Binary operation embeddings
        self.binary_ops = nn.ModuleDict({
            'Add': NeuralTransformer(2 * embedding_dim, embedding_dim, embedding_dim),
            'Sub': NeuralTransformer(2 * embedding_dim, embedding_dim, embedding_dim),
            'Mul': NeuralTransformer(2 * embedding_dim, embedding_dim, embedding_dim),
            'Div': NeuralTransformer(2 * embedding_dim, embedding_dim, embedding_dim),
            'Mod': NeuralTransformer(2 * embedding_dim, embedding_dim, embedding_dim),
            'GT': NeuralTransformer(2 * embedding_dim, embedding_dim, embedding_dim),
            'GTE': NeuralTransformer(2 * embedding_dim, embedding_dim, embedding_dim),
            'LT': NeuralTransformer(2 * embedding_dim, embedding_dim, embedding_dim),
            'LTE': NeuralTransformer(2 * embedding_dim, embedding_dim, embedding_dim),
            'E': NeuralTransformer(2 * embedding_dim, embedding_dim, embedding_dim),
            'NE': NeuralTransformer(2 * embedding_dim, embedding_dim, embedding_dim),
            'And': NeuralTransformer(2 * embedding_dim, embedding_dim, embedding_dim),
            'Or': NeuralTransformer(2 * embedding_dim, embedding_dim, embedding_dim)
        })
        
        # Unary operation embeddings
        self.unary_ops = nn.ModuleDict({
            'Not': NeuralTransformer(embedding_dim, embedding_dim, embedding_dim),
            'Neg': NeuralTransformer(embedding_dim, embedding_dim, embedding_dim),
            'Len': NeuralTransformer(embedding_dim, embedding_dim, embedding_dim),
            'Ord': NeuralTransformer(embedding_dim, embedding_dim, embedding_dim),
            'Chr': NeuralTransformer(embedding_dim, embedding_dim, embedding_dim)
        })
        
        # Type embeddings
        self.type_embeddings = nn.ModuleDict({
            'IntType': NeuralTransformer(1, embedding_dim, embedding_dim),
            'BoolType': NeuralTransformer(1, embedding_dim, embedding_dim),
            'CharType': NeuralTransformer(1, embedding_dim, embedding_dim),
            'StringType': NeuralTransformer(1, embedding_dim, embedding_dim),
            'ArrayType': NeuralTransformer(embedding_dim, embedding_dim, embedding_dim),
            'PairType': NeuralTransformer(2 * embedding_dim, embedding_dim, embedding_dim),
            'PairElemType1': NeuralTransformer(1, embedding_dim, embedding_dim),
            'PairElemType2': NeuralTransformer(embedding_dim, embedding_dim, embedding_dim)
        })
        
        # Statement embeddings
        self.stmt_transformers = nn.ModuleDict({
            'Skip': NeuralTransformer(1, embedding_dim, embedding_dim),
            'Declare': NeuralTransformer(3 * embedding_dim, embedding_dim, embedding_dim),
            'Assign': NeuralTransformer(2 * embedding_dim, embedding_dim, embedding_dim),
            'Read': NeuralTransformer(embedding_dim, embedding_dim, embedding_dim),
            'Free': NeuralTransformer(embedding_dim, embedding_dim, embedding_dim),
            'Return': NeuralTransformer(embedding_dim, embedding_dim, embedding_dim),
            'Exit': NeuralTransformer(embedding_dim, embedding_dim, embedding_dim),
            'Print': NeuralTransformer(embedding_dim, embedding_dim, embedding_dim),
            'Println': NeuralTransformer(embedding_dim, embedding_dim, embedding_dim),
            'IfThenElse': NeuralTransformer(3 * embedding_dim, embedding_dim, embedding_dim),
            'WhileDo': NeuralTransformer(2 * embedding_dim, embedding_dim, embedding_dim),
            'BeginEnd': NeuralTransformer(embedding_dim, embedding_dim, embedding_dim),
            'StmtList': NeuralTransformer(2 * embedding_dim, embedding_dim, embedding_dim)
        })

    def embed_literal(self, node: Dict[str, Any], ctx: NeuralTransformContext) -> torch.Tensor:
        node_type = node['type']
        if node_type == 'IntLit':
            value = torch.tensor([node['value']], dtype=torch.float).to(ctx.device)
            return self.literal_embeddings[node_type](value)
        elif node_type == 'BoolLit':
            value = torch.tensor([float(node['value'])], dtype=torch.float).to(ctx.device)
            return self.literal_embeddings[node_type](value)
        elif node_type == 'CharLit':
            value = torch.tensor([ord(node['value'])], dtype=torch.float).to(ctx.device)
            return self.literal_embeddings[node_type](value)
        elif node_type == 'StrLit':
            # Hash the entire string's bytes into a single number
            if not node['value']:
                value = torch.tensor([0.0], dtype=torch.float)
            else:
                # Get bytes and hash them into a single number
                bytes_val = hash(node['value'].encode('utf-8')) % MAGIC_PRIME
                value = torch.tensor([float(bytes_val)], dtype=torch.float)
            return self.literal_embeddings[node_type](value.to(ctx.device))
        elif node_type == 'PairLit':
            return self.literal_embeddings[node_type](torch.tensor([0.0]).to(ctx.device))
        elif node_type == 'Ident':
            return self.literal_embeddings[node_type](
                torch.tensor([hash(node['name']) % MAGIC_PRIME]).to(ctx.device)
            ).squeeze(0)
        return torch.zeros(ctx.embedding_dim).to(ctx.device)

    def embed_type(self, node: Dict[str, Any], ctx: NeuralTransformContext) -> torch.Tensor:
        node_type = node['type']
        if node_type in ['IntType', 'BoolType', 'CharType', 'StringType', 'PairElemType1']:
            return self.type_embeddings[node_type](torch.tensor([1.0]).to(ctx.device))
        elif node_type == 'ArrayType':
            base_type_embed = self.embed_type(node['baseType'], ctx)
            return self.type_embeddings[node_type](base_type_embed)
        elif node_type == 'PairType':
            fst_embed = self.embed_type(node['firstType'], ctx)
            snd_embed = self.embed_type(node['secondType'], ctx)
            combined = torch.cat([fst_embed, snd_embed], dim=-1)
            return self.type_embeddings[node_type](combined)
        elif node_type == 'PairElemType2':
            base_type_embed = self.embed_type(node['baseType'], ctx)
            return self.type_embeddings[node_type](base_type_embed)
        return torch.zeros(ctx.embedding_dim).to(ctx.device)

    def embed_binary_op(self, node: Dict[str, Any], ctx: NeuralTransformContext) -> torch.Tensor:
        left_embed = self.transform_node(node['left'], ctx)
        right_embed = self.transform_node(node['right'], ctx)
        combined = torch.cat([left_embed, right_embed], dim=-1)
        return self.binary_ops[node['type']](combined)

    def embed_stmt(self, node: Dict[str, Any], ctx: NeuralTransformContext) -> torch.Tensor:
        """Embed different statement types"""
        node_type = node['type']
        
        if node_type == 'Skip':
            # Create a single-dimensional input for Skip
            return self.stmt_transformers['Skip'](torch.tensor([0.0]).to(ctx.device))
            
        elif node_type == 'Declare':
            type_embed = self.transform_node(node['varType'], ctx)
            id_embed = self.transform_node(node['identifier'], ctx)
            rhs_embed = self.transform_node(node['rhs'], ctx)
            combined = torch.cat([type_embed, id_embed, rhs_embed], dim=-1)
            return self.stmt_transformers['Declare'](combined)
            
        elif node_type == 'Assign':
            lhs_embed = self.transform_node(node['lhs'], ctx)
            rhs_embed = self.transform_node(node['rhs'], ctx)
            combined = torch.cat([lhs_embed, rhs_embed], dim=-1)
            return self.stmt_transformers['Assign'](combined)
            
        elif node_type in ['Read', 'Free', 'Return', 'Exit', 'Print', 'Println']:
            # These all take a single expression/lvalue
            expr_embed = self.transform_node(node.get('expr', node.get('lvalue')), ctx)
            return self.stmt_transformers[node_type](expr_embed)
            
        elif node_type == 'IfThenElse':
            cond_embed = self.transform_node(node['condition'], ctx)
            then_embed = self.transform_node(node['thenStmt'], ctx)
            else_embed = self.transform_node(node['elseStmt'], ctx)
            combined = torch.cat([cond_embed, then_embed, else_embed], dim=-1)
            return self.stmt_transformers['IfThenElse'](combined)
            
        elif node_type == 'WhileDo':
            cond_embed = self.transform_node(node['condition'], ctx)
            body_embed = self.transform_node(node['body'], ctx)
            combined = torch.cat([cond_embed, body_embed], dim=-1)
            return self.stmt_transformers['WhileDo'](combined)
            
        elif node_type == 'BeginEnd':
            stmt_embed = self.transform_node(node['stmt'], ctx)
            return self.stmt_transformers['BeginEnd'](stmt_embed)
            
        elif node_type == 'StmtList':
            first_embed = self.transform_node(node['first'], ctx)
            second_embed = self.transform_node(node['second'], ctx)
            combined = torch.cat([first_embed, second_embed], dim=-1)
            return self.stmt_transformers['StmtList'](combined)
            
        return torch.zeros(self.embedding_dim).to(ctx.device)

    def transform_node(self, node: Dict[str, Any], ctx: NeuralTransformContext) -> torch.Tensor:
        """Transform a node into its embedding"""
        if not isinstance(node, dict):
            return torch.zeros(self.embedding_dim).to(ctx.device)
            
        node_type = node.get('type')
        if not node_type:
            return torch.zeros(self.embedding_dim).to(ctx.device)
            
        # Handle different node categories
        if node_type in self.literal_embeddings:
            return self.embed_literal(node, ctx)
            
        elif node_type in self.binary_ops:
            return self.embed_binary_op(node, ctx)
            
        elif node_type in self.unary_ops:
            expr_embed = self.transform_node(node['expr'], ctx)
            return self.unary_ops[node_type](expr_embed)
            
        elif node_type in self.stmt_transformers:
            return self.embed_stmt(node, ctx)
            
        elif node_type == 'Program':
            # Embed main program
            main_embed = self.transform_node(node['main'], ctx)
            # Embed functions if they exist
            func_embeds = [self.transform_node(f, ctx) for f in node.get('functions', [])]
            if func_embeds:
                # Combine function embeddings (you might want to use a more sophisticated approach)
                func_embed = torch.stack(func_embeds).mean(dim=0)
                return main_embed + func_embed
            return main_embed
            
        # Default case
        return torch.zeros(self.embedding_dim).to(ctx.device)

    def forward(self, ast: Dict[str, Any]) -> torch.Tensor:
        """Transform entire AST into an embedding"""
        ctx = NeuralTransformContext(
            embedding_dim=self.embedding_dim,
            device=next(self.parameters()).device
        )
        return self.transform_node(ast, ctx)