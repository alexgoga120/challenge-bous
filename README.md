
# Challenge Backend
Goal: transform xlsx file to cvs file and process data given

## prerequisites

 - python 3
 - pip 23.1.2
 - postgres 15


## Instructions

### Install pandas dependency for xlsx reading

```bash
    pip install pandas
    pip install openpyxl
```

### Install Flask dependency

```bash
    pip install Flask
```

### Install postgres dependency

```bash
    pip install psycopg2
```


### Project base structure


📁 ---> Directory \
📄 ---> File \
🔮 ---> Temp/Future File

```bash
--->📁<project_directory>
        |--->📁workspace
                |--->📄valida_header.py
                |--->📄xlsx_csv.py
                |--->🔮work_excel.xlsx
        |--->📁process_data
                |--->🔮new_csv.csv
        |--->📄carga_y_calculos.sql
        |--->📄challenge.sh
        |--->📄script_base_de_datos.sql
        |--->📄servicio.py
        |--->🔮folios.txt
```

### Run proyect
Script script_base_de_datos.sql will create a "bous_debit" database in case the database was created previously, database will not create , create schema named "challenge_bous" and if already exist drop the entire schema. 

to run proyect execute the following command inside <project_directory> :

```bash
    psql -U <database_username> -f ./script_base_de_datos.sql
        # The user must have permisson to create database and tables 
        # example: psql -U postgres -f ./script_base_de_datos.sql

    bash challenge.sh <excel_path> <database_username>
```

### Test API

for test service use: 

```bash
    python3 ./servicio.py
```

to get response in shell use :

```bash
    curl http://127.0.0.1:5000/<folio>
```

Exmaple JSON:


```bash
    {
        "data": {
            "folio": 00000,
            "total_debits": 000000,
            "total_rows": data_calculations[2],
            "cities_debits": [{
                "city": "XXXXXXX",
                "debit": "$00,000,000.00",
                "id": 0,
                "percentage": "0.00%"
            }],
            "companies_debits": [{
                "company": "XXXXXXX",
                "debit": "$00,000,000.00",
                "id": 0,
                "percentage": "0.00%"
            }]
        }
    }
```
