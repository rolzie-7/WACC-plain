import pytest
import torch as t
from pathlib import Path
import sys

# Add the parent directory to the path so we can import the module
sys.path.append(str(Path(__file__).parent.parent))
from vector2arm import ArmResult, INSTRUCTION_TYPES, REGISTERS

class TestArmResultFromStr:
    """Unit tests for ArmResult.from_str method"""
    
    def test_basic_instructions(self):
        """Test basic instruction parsing"""
        result = ArmResult.from_str("add x0, x1, x2")
        assert result.instruction_type.argmax().item() == INSTRUCTION_TYPES['add']
        assert result.registers[0].argmax().item() == REGISTERS['x0']
        assert result.registers[1].argmax().item() == REGISTERS['x1']
        assert result.registers[2].argmax().item() == REGISTERS['x2']
        
        result = ArmResult.from_str("sub w3, w4, w5")
        assert result.instruction_type.argmax().item() == INSTRUCTION_TYPES['sub']
        assert result.registers[0].argmax().item() == REGISTERS['w3']
        assert result.registers[1].argmax().item() == REGISTERS['w4']
        assert result.registers[2].argmax().item() == REGISTERS['w5']
    
    def test_immediate_values(self):
        """Test instructions with immediate values"""
        result = ArmResult.from_str("add x0, x1, #42")
        assert result.instruction_type.argmax().item() == INSTRUCTION_TYPES['add']
        assert result.registers[0].argmax().item() == REGISTERS['x0']
        assert result.registers[1].argmax().item() == REGISTERS['x1']
        assert result.literal == 42
        
        result = ArmResult.from_str("sub x0, x1, #-10")
        assert result.literal == -10
    
    def test_shift_operations(self):
        """Test instructions with shift operations"""
        result = ArmResult.from_str("add x0, x1, x2, lsl #2")
        assert result.instruction_type.argmax().item() == INSTRUCTION_TYPES['add']
        assert result.shift_type.argmax().item() == 0  # lsl
        assert result.literal == 2
        
        result = ArmResult.from_str("add x0, x1, x2, lsr #3")
        assert result.shift_type.argmax().item() == 1  # lsr
        assert result.literal == 3
    
    def test_extend_operations(self):
        """Test instructions with extend operations"""
        result = ArmResult.from_str("add x0, x1, w2, uxtw")
        assert result.instruction_type.argmax().item() == INSTRUCTION_TYPES['add']
        assert result.extend_type.argmax().item() == 2  # uxtw
        
        result = ArmResult.from_str("add x0, x1, w2, sxtw")
        assert result.extend_type.argmax().item() == 6  # sxtw
    
    def test_load_store_instructions(self):
        """Test load/store instructions with different addressing modes"""
        # Basic load
        result = ArmResult.from_str("ldr x0, [x1]")
        assert result.instruction_type.argmax().item() == INSTRUCTION_TYPES['ldr']
        assert result.addressing_mode.argmax().item() == 0  # immediate
        
        # Pre-indexed
        result = ArmResult.from_str("ldr x0, [x1, #16]!")
        assert result.addressing_mode.argmax().item() == 1  # pre_indexed
        assert result.literal == 16
        
        # Post-indexed
        result = ArmResult.from_str("ldr x0, [x1], #16")
        assert result.addressing_mode.argmax().item() == 2  # post_indexed
        assert result.literal == 16
    
    def test_condition_codes(self):
        """Test instructions with condition codes"""
        result = ArmResult.from_str("b.eq label")
        assert result.condition.argmax().item() == 0  # eq
        assert result.has_label[0].item() == 1
        
        result = ArmResult.from_str("b.ne label")
        assert result.condition.argmax().item() == 1  # ne
    
    def test_branch_instructions(self):
        """Test branch instructions"""
        result = ArmResult.from_str("b label")
        assert result.has_label[0].item() == 1
        
        result = ArmResult.from_str("bl function")
        assert result.has_label[0].item() == 1


class TestArmResultIntegration:
    """Integration tests for ArmResult.from_str with complete assembly files"""
    
    @pytest.fixture
    def sample_assembly(self):
        """Sample assembly code for testing"""
        return [
            "add x0, x1, #42",
            "sub x2, x3, x4, lsl #2",
            "ldr x5, [x6, #16]",
            "str x7, [x8, #32]!",
            "cmp x9, x10",
            "b.eq .label1",
            "mov x11, x12",
            "add x13, x14, w15, uxtw"
        ]
    
    def test_sample_assembly(self, sample_assembly):
        """Test parsing a sequence of assembly instructions"""
        results = [ArmResult.from_str(line) for line in sample_assembly]
        
        # Check first instruction (add with immediate)
        assert results[0].instruction_type.argmax().item() == INSTRUCTION_TYPES['add']
        assert results[0].literal == 42
        
        # Check second instruction (sub with shift)
        assert results[1].instruction_type.argmax().item() == INSTRUCTION_TYPES['sub']
        assert results[1].shift_type.argmax().item() == 0  # lsl
        
        # Check third instruction (ldr with offset)
        assert results[2].instruction_type.argmax().item() == INSTRUCTION_TYPES['ldr']
        assert results[2].literal == 16
        
        # Check fourth instruction (str with pre-indexed)
        assert results[3].instruction_type.argmax().item() == INSTRUCTION_TYPES['str']
        assert results[3].addressing_mode.argmax().item() == 1  # pre_indexed
        
        # Check fifth instruction (cmp)
        assert results[4].instruction_type.argmax().item() == INSTRUCTION_TYPES['cmp']
        
        # Check sixth instruction (b.eq with label)
        assert results[5].condition.argmax().item() == 0  # eq
        assert results[5].has_label[0].item() == 1
    
    def test_actual_assembly_file(self, tmp_path):
        """Test parsing an actual assembly file from disk"""
        # Create a sample assembly file
        asm_file = tmp_path / "test.s"
        asm_content = """
        .global _start
        
        _start:
            mov x0, #0
            mov x1, #1
        loop:
            add x0, x0, x1
            add x1, x1, #1
            cmp x1, #10
            b.le loop
            ret
        """
        asm_file.write_text(asm_content)
        
        # Parse each line
        results = []
        with open(asm_file) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('.') and not line.endswith(':'):
                    results.append(ArmResult.from_str(line))
        
        # Verify we parsed 7 instructions
        assert len(results) == 7
        
        # Check specific instructions
        assert results[0].instruction_type.argmax().item() == INSTRUCTION_TYPES['mov']
        assert results[0].literal == 0
        
        assert results[2].instruction_type.argmax().item() == INSTRUCTION_TYPES['add']
        
        assert results[4].instruction_type.argmax().item() == INSTRUCTION_TYPES['cmp']
        assert results[4].literal == 10
        
        assert results[5].condition.argmax().item() == 15  # le
        assert results[5].has_label[0].item() == 1


if __name__ == "__main__":
    pytest.main(["-v", __file__])