import docx
import os
import sys

# Set UTF-8 encoding
sys.stdout.reconfigure(encoding='utf-8')

# Change to the project directory
os.chdir('D:\\NT-project')

# List files to see the exact name
print("Files in directory:")
for file in os.listdir('.'):
    if file.endswith('.docx'):
        print(f"Found: {file}")

# Try to read the file
try:
    # Get the exact filename
    docx_files = [f for f in os.listdir('.') if f.endswith('.docx')]
    if docx_files:
        filename = docx_files[0]
        print(f"\nReading file: {filename}")
        
        doc = docx.Document(filename)
        print("\nAll paragraphs:")
        for i, paragraph in enumerate(doc.paragraphs):
            if paragraph.text.strip():
                print(f"{i+1}: {paragraph.text}")
    else:
        print("No .docx files found")
except Exception as e:
    print(f"Error: {e}")
