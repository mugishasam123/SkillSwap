# SkillSwap Diagram Generator

This tool converts the ASCII diagrams from `APP_STRUCTURE_DIAGRAMS.md` into high-quality PNG images.

## 📋 Prerequisites

- Python 3.7 or higher
- pip (Python package installer)

## 🚀 Quick Start

### Windows Users:
1. Double-click `generate_diagrams.bat`
2. Wait for the script to complete
3. Find the generated PNG files in the current directory

### Unix/Linux/Mac Users:
1. Open terminal in the project directory
2. Run: `chmod +x generate_diagrams.sh`
3. Run: `./generate_diagrams.sh`
4. Find the generated PNG files in the current directory

### Manual Installation:
1. Install dependencies: `pip install -r requirements.txt`
2. Run the generator: `python diagram_generator.py`

## 📊 Generated Diagrams

The script will create 4 high-quality PNG images:

1. **`app_structure_diagram.png`** - Complete Flutter app structure
2. **`bloc_architecture_diagram.png`** - BLoC pattern architecture
3. **`data_flow_diagram.png`** - Data flow between layers
4. **`login_flow_diagram.png`** - User login flow example

## 🎨 Diagram Features

- **High Resolution**: 300 DPI for crisp printing
- **Color Coded**: Different colors for different layers/components
- **Professional Layout**: Clean, organized visual representation
- **Scalable**: Vector-based elements for any size

## 🔧 Customization

You can modify the `diagram_generator.py` file to:
- Change colors and styling
- Add new diagrams
- Modify layout and positioning
- Adjust font sizes and styles

## 📦 Dependencies

- **matplotlib**: For creating the diagrams
- **Pillow**: For image processing
- **numpy**: For numerical operations

## 🐛 Troubleshooting

### Common Issues:

1. **"matplotlib not found"**
   - Run: `pip install matplotlib`

2. **"Permission denied" (Unix/Linux/Mac)**
   - Run: `chmod +x generate_diagrams.sh`

3. **"Python not found"**
   - Install Python from https://python.org
   - Make sure Python is in your PATH

4. **"pip not found"**
   - Install pip: `python -m ensurepip --upgrade`

## 📝 Usage Examples

```bash
# Generate all diagrams
python diagram_generator.py

# Install dependencies only
pip install -r requirements.txt

# Run specific diagram function (in Python)
from diagram_generator import create_app_structure_diagram
create_app_structure_diagram()
```

## 🎯 Output

After running the script, you'll have 4 professional PNG diagrams that can be:
- Used in presentations
- Included in documentation
- Shared with team members
- Printed for reference

The diagrams provide a clear visual representation of your SkillSwap app's architecture and data flow patterns. 