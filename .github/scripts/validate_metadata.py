import os
import sys
import yaml
from pathlib import Path

REQUIRED_FIELDS = {'name', 'description', 'version', 'author'}
VALID_TARGETS = {'agy', 'claude', 'ghcp', 'cursor'}

def validate_file(filepath):
    errors = []
    try:
        with open(filepath, 'r') as f:
            data = yaml.safe_load(f)
    except Exception as e:
        return [f"Failed to parse YAML: {e}"]
    
    if not isinstance(data, dict):
        return ["YAML file must contain a dictionary at the root."]

    # Check required fields
    for field in REQUIRED_FIELDS:
        if field not in data or not data[field]:
            errors.append(f"Missing required field: '{field}'")
            
    # Check targets match subdirectories
    targets = set(data.get('targets', []))
    
    # Find harness subdirectories
    dir_path = Path(filepath).parent
    actual_dirs = set()
    for item in dir_path.iterdir():
        if item.is_dir() and item.name in VALID_TARGETS:
            actual_dirs.add(item.name)
            
    if targets != actual_dirs:
        errors.append(f"Targets mismatch. Declared in yaml: {targets}, Actual dirs: {actual_dirs}")
        
    # Name must match directory name
    expected_name = dir_path.name
    if data.get('name') != expected_name:
        errors.append(f"Name field '{data.get('name')}' does not match directory name '{expected_name}'")
        
    return errors

def main():
    has_errors = False
    
    for root, _, files in os.walk('.'):
        for file in files:
            if file in ('skill.yaml', 'agent.yaml', 'rule.yaml'):
                filepath = os.path.join(root, file)
                errors = validate_file(filepath)
                if errors:
                    print(f"Validation failed for {filepath}:")
                    for error in errors:
                        print(f"  - {error}")
                    has_errors = True
                else:
                    print(f"Validated {filepath} successfully.")
                    
    if has_errors:
        sys.exit(1)
    else:
        print("All metadata files passed validation.")
        sys.exit(0)

if __name__ == '__main__':
    main()
