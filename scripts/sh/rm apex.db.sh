#!/bin/bash

filePath="/Users/marcpla/Documents/Feina/Projectes/CaixaBank/.sfdx/tools/254/apex.db"

if [ -f "$filePath" ]; then
    sudo rm "$filePath"
    if [ $? -eq 0 ]; then
        echo "Fitxer eliminat correctament"
    else
        echo "Error eliminant el fitxer"
    fi
else
    echo "El fitxer no existeix"
fi
