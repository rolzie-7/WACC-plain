#!/usr/bin/env python3

# Simple module for tracking assembly label symbols across files

# The global label table - maps label names to unique integer IDs
_label_table = {}
_next_id = 1  # Start IDs from 1 (0 can be reserved for "no label")

def get_label_id(label_name, create_if_missing=True):
    """
    Get the unique ID for a label. If the label doesn't exist:
    - If create_if_missing is True, assign a new ID
    - If create_if_missing is False, return None
    """
    global _next_id
    
    if label_name in _label_table:
        return _label_table[label_name]
    
    if create_if_missing:
        # Assign new ID and increment counter
        label_id = _next_id
        _label_table[label_name] = label_id
        _next_id += 1
        return label_id
    
    return None

def reset_label_table():
    """Reset the label table and ID counter. Call this for each new file."""
    global _label_table, _next_id
    _label_table = {}
    _next_id = 1

def get_all_labels():
    """Return a copy of the current label table."""
    return _label_table.copy() 