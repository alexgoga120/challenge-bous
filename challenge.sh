#!/bin/bash

# Verificar que se haya proporcionado un argumento
if [ $# -eq 0 ]; then
  echo "Error: Debe proporcionar un archivo Excel como primer argumento y usuario de la base de datos como segundo."
  exit 1
fi

# Verificar que el archivo existe
if [ $# -eq 1 ]; then
  echo "Error: Debe proporcionar un usuario de la base de datos como segundo argumento."
  exit 1
fi

# Verificar que el archivo existe
if [ ! -f "$1" ]; then
  echo "Error: El archivo '$1' no existe."
  exit 1
fi

# Verificar que el archivo existe
if [[ $1 != *.xlsx ]]; then
  echo "Error: El archivo '$1' no es tipo xlsx."
  exit 1
fi

mkdir -p ./workspace && cp $1 ./workspace/work_excel.xlsx

# Validar encabezados

python3 workspace/valida_header.py ./workspace/work_excel.xlsx

headersValid=$?

if [ $headersValid -eq 0 ]; then
  echo "Error: El archivo '$1' no cuenta con encabezados validos."
  exit 1
fi

echo -e "\nEncabezados validos.\n"

#Transformar archivo

typeColumn="$(python3 workspace/xlsx_csv.py ./workspace/work_excel.xlsx)"

#Procesar datos
csv_file="$(pwd)/process_data/new_csv.csv"

colums="id,client,contract_num,purchase_date,city,company,debit"

echo -e "Copiar csv a tabla de trabajo\n"
psql -U $2 -d bous_debit -c "COPY challenge_bous.work_table (${colums}) FROM '${csv_file}' DELIMITER ',' CSV HEADER;" -q
if [ "$?" -ne 0 ]; then
  echo -e "\nLos datos no fueron copiados\n"
  exit 1
else
  echo -e "\nDatos copiados\n"
fi

echo -e "Realizar carga y calculos\n"

result=$(psql -U $2 -d bous_debit -f ./carga_y_calculos.sql -t -q -n 2>&1)

runId=$(echo "$result" | awk -v RS= '{print $NF}')

echo -e "\n\nFolio de la ejecución: $runId"

# Guardar folios en archivo

date=$(date +%Y-%m-%d)

if [ ! -f "./folios.txt" ]; then
  echo -e "[$date]: $runId" > ./folios.txt
else
  echo -e "[$date]: $runId" >> ./folios.txt
fi