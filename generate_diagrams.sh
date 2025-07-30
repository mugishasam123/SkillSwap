#!/bin/bash

echo "Installing required Python packages..."
pip3 install -r requirements.txt

echo ""
echo "Generating SkillSwap app diagrams..."
python3 diagram_generator.py

echo ""
echo "Diagrams generated successfully!"
echo "Check the current directory for the PNG files." 