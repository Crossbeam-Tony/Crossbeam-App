import re
import os

# Set the number of users currently in local_users.dart
USER_COUNT = 21  # Update this to match your actual user count

# List of files to process
FILES = [
    'lib/data/dummy_projects.dart',
    'lib/data/seed_events.dart',
    'lib/data/dummy_marketplace.dart',
]

# Patterns to match localUsers[XX] and 'uXX'
INDEX_PATTERN = re.compile(r'localUsers\[(\d+)\]')
ID_PATTERN = re.compile(r"'u(\d+)'")


def remap_index(match):
    idx = int(match.group(1))
    new_idx = idx % USER_COUNT
    return f'localUsers[{new_idx}]'


def remap_id(match):
    idx = int(match.group(1))
    new_idx = ((idx - 1) % USER_COUNT) + 1
    return f"'u{new_idx}'"


def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    content = INDEX_PATTERN.sub(remap_index, content)
    content = ID_PATTERN.sub(remap_id, content)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Remapped user references in {filepath}')


def main():
    for file in FILES:
        if os.path.exists(file):
            process_file(file)
        else:
            print(f'File not found: {file}')

if __name__ == '__main__':
    main() 