import os
import sys

def parse_lcov(file_path):
    coverage = {}
    current_file = None
    
    if not os.path.exists(file_path):
        print(f"Error: {file_path} not found")
        return None

    with open(file_path, 'r') as f:
        for line in f:
            line = line.strip()
            if line.startswith('SF:'):
                current_file = line[3:]
                coverage[current_file] = {'total': 0, 'covered': 0}
            elif line.startswith('LF:'):
                coverage[current_file]['total'] = int(line[3:])
            elif line.startswith('LH:'):
                coverage[current_file]['covered'] = int(line[3:])
    
    return coverage

def get_summary(coverage):
    summary = {}
    for path, data in coverage.items():
        # Get directory name relative to lib
        # Normalize path for multi-platform
        path = path.replace('\\', '/')
        parts = path.split('/')
        if 'lib' in parts:
            lib_index = parts.index('lib')
            if len(parts) > lib_index + 1:
                category = parts[lib_index + 1]
            else:
                category = 'root'
        else:
            category = 'other'
            
        if category not in summary:
            summary[category] = {'total': 0, 'covered': 0, 'files': 0}
            
        summary[category]['total'] += data['total']
        summary[category]['covered'] += data['covered']
        summary[category]['files'] += 1
        
    return summary

def print_table(summary):
    print("| Category | Files | Total Lines | Covered Lines | Coverage % |")
    print("| --- | --- | --- | --- | --- |")
    
    grand_total_lines = 0
    grand_covered_lines = 0
    grand_total_files = 0
    
    for cat, data in sorted(summary.items(), key=lambda x: x[0]):
        percentage = (data['covered'] / data['total'] * 100) if data['total'] > 0 else 0
        print(f"| {cat} | {data['files']} | {data['total']} | {data['covered']} | {percentage:.2f}% |")
        
        grand_total_lines += data['total']
        grand_covered_lines += data['covered']
        grand_total_files += data['files']
        
    total_percentage = (grand_covered_lines / grand_total_lines * 100) if grand_total_lines > 0 else 0
    print(f"| **TOTAL** | **{grand_total_files}** | **{grand_total_lines}** | **{grand_covered_lines}** | **{total_percentage:.2f}%** |")

if __name__ == "__main__":
    lcov_file = 'coverage/lcov.info'
    if len(sys.argv) > 1:
        lcov_file = sys.argv[1]
        
    cov_data = parse_lcov(lcov_file)
    if cov_data:
        summary = get_summary(cov_data)
        print_table(summary)
