@echo off
echo Installing required Python packages...
pip install -r requirements.txt

echo.
echo Generating SkillSwap app diagrams...
python diagram_generator.py

echo.
echo Diagrams generated successfully!
echo Check the current directory for the PNG files.
pause 