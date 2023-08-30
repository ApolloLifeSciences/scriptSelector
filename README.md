# scriptSelector
scriptSelector is a Java GUI, created to execute small python or R scripts.
It includes the QC program Particulator.

## Purpose
The intention is to easily deploy different script that tackle small tasks, like renaming files, analyzing data, etc. which would save the regular user time by not having to do that task manually anymore.

scriptSelector was built in IntelliJ

## How to deploy new scripts
To deploy a script, place it in the "scripts" folder. When you open scriptSelector afterwards, the script should appear in the dropdown.

## Script structure
The GUI will display text based on what is written in the script at certain points. This effects lines 1-11. The code below shows what the script in these lines should consist of. You can freely change anything in the brackets.

```
#script explanation: 
"""
[title that will be shown at the top in the GUI]
TARGET FOLDER: [whatever needs to be explained about the folder]
CUSTOM TEXT: [any arguments the user should put in]
"""
#=======================================================
#=======================================================
#=======================================================
SCRIPT = ["renameTiffs"]
[..., rest of the code]
```

## Key people
- Ricardo Guerreiro was once involved with deploying his python script to the scriptSelector
