import neural_transformers as nt
from neural_transformers import HierarchicalASTTransformer as HAST
import torch as t
from torch import nn as nn
from vector2arm import Vector2Arm, ArmResult
from typing import Dict, Any, Union, List
from arm_config import DROPOUT_RATE, DEVICE, to_device, MAX_CYCLES, INSTRUCTION_TYPE_EMBEDDING_DIM

class WorldModel(nn.Module):
    # Initialize the world model
    def __init__(self, embedding_dim: int = 128) -> None:
        super().__init__()
        self.embedding_dim = embedding_dim
        self.embedder = HAST(embedding_dim)
        self.vector2arm = Vector2Arm(embedding_dim)
        self.state = t.zeros(embedding_dim, device=DEVICE)
        self.dropout = nn.Dropout(DROPOUT_RATE)
        self.init_state = t.zeros(embedding_dim, device=DEVICE)
        self.current_cycle_count = 0
        self.instruction_count = 0  # Track number of instructions generated
        self.predicted_instructions = []  # Store predicted instructions

        # cycling
        self.cycler = nn.Sequential(
            nn.Linear(embedding_dim, 2 * embedding_dim),
            nn.ReLU(),
            nn.Linear(2 * embedding_dim, 2 * embedding_dim),
            nn.ReLU(),
            nn.Linear(2 * embedding_dim, embedding_dim),
            nn.Tanh()
        )

        self.halter = nn.Sequential(
            nn.Linear(embedding_dim, 1),
            nn.Sigmoid()
        )
        
        # Adding a component to determine if we should continue generating instructions
        self.sequence_halter = nn.Sequential(
            nn.Linear(embedding_dim, 1),
            nn.Sigmoid()
        )
        
        # Add a proper learnable projection for instruction type
        self.instruction_projector = nn.Linear(INSTRUCTION_TYPE_EMBEDDING_DIM, embedding_dim)
        
        # Mixing parameters
        self.alpha = nn.Parameter(t.tensor(0.8, device=DEVICE))  # State retention factor
        self.beta = nn.Parameter(t.tensor(0.1, device=DEVICE))   # Dropout noise factor
    
    # Embed a program into the world model
    def embed_program(self, program: Union[str, Dict[str, Any]]) -> t.Tensor:
        """
        Embed a program into the world model.
        
        Args:
            program: Program as string or JSON dictionary
            
        Returns:
            Embedded tensor representation
        """
        # No need to convert dict to string, HAST can handle Dict[str, Any] directly
        return self.embedder(program)
    
    # Develop / progress the world model
    def cycle(self) -> t.Tensor:
        halting_prob = self.halter(self.state)
        if halting_prob > 0.5:
            self.keep_cycling = False
        else:
            self.state = self.cycler(self.state) * halting_prob + (1 - halting_prob) * self.state
        return self.state
    
    # Output a result from the world model
    def output_to_arm(self) -> ArmResult:
        # Apply dropout to the state
        return self.vector2arm(self.dropout(self.state))
    
    def forward(self, program: Dict[str, Any]) -> t.Tensor:
        # embed into world model
        x = self.embed_program(program)
        self.init_state = x
        # cycle the world model here
        # Detach state from previous computation graph to avoid backward errors
        self.state = x
        # now cycle passes!
        self.keep_cycling = True
        self.current_cycle_count = 0
        while self.keep_cycling:
            self.cycle()
            self.current_cycle_count += 1
            if self.current_cycle_count > MAX_CYCLES:
                self.keep_cycling = False
        print(f"Cycled {self.current_cycle_count} times")
        return self.state
    
    def generate_instruction_sequence(self, program: Dict[str, Any], max_instructions: int = 10) -> List[ArmResult]:
        """
        Generate a sequence of ARM instructions for the given program.
        
        Args:
            program: The program as a JSON dictionary
            max_instructions: Maximum number of instructions to generate
            
        Returns:
            List of ArmResult objects representing the instruction sequence
        """
        # Reset instruction tracking
        self.predicted_instructions = []
        self.instruction_count = 0
        self.halter_values = []  # Track the values from sequence_halter
        
        # Initial embedding
        x = self.embed_program(program)
        self.state = x
        
        # Generate instructions until we decide to stop or reach max_instructions
        should_continue = True
        while should_continue and self.instruction_count < max_instructions:
            # Cycle the model to generate the next instruction
            self.keep_cycling = True
            self.current_cycle_count = 0
            
            while self.keep_cycling:
                self.cycle()
                self.current_cycle_count += 1
                if self.current_cycle_count > MAX_CYCLES:
                    self.keep_cycling = False
            
            # Generate an instruction from the current state
            arm_result = self.output_to_arm()
            self.predicted_instructions.append(arm_result)
            self.instruction_count += 1
            
            # Decide if we should continue generating instructions
            halter_value = self.sequence_halter(self.state).item()
            self.halter_values.append(halter_value)
            should_continue = halter_value < 0.5
            
            # If we're continuing, modify the state to prepare for the next instruction
            if should_continue:
                # Use proper learnable projection instead of random weights
                instr_type = arm_result.instruction_type
                
                # Project instruction features into embedding space using learnable parameters
                instruction_embedding = self.instruction_projector(instr_type)
                
                # Safe bounded mixing using sigmoid-normalized parameters
                alpha = t.sigmoid(self.alpha)  # Keep between 0 and 1
                beta = t.sigmoid(self.beta) * 0.2  # Keep small for stability
                
                # Stable state update with bounded parameters
                self.state = alpha * self.state + (1-alpha) * instruction_embedding + beta * self.dropout(self.state)
        
        print(f"Generated {self.instruction_count} instructions")
        return self.predicted_instructions