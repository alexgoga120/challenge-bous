-- Insertar datos validos
INSERT INTO challenge_bous.valid_debits (fk_work_table_id)
SELECT id
FROM challenge_bous.work_table 
WHERE challenge_bous.valid_header_type(client, contract_num, purchase_date, city, company, debit)
ORDER BY id;

-- Insertar datos invalidos
INSERT INTO challenge_bous.invalid_debits (fk_work_table_id)
SELECT id
FROM challenge_bous.work_table 
WHERE id NOT IN (
    SELECT fk_work_table_id
    FROM challenge_bous.valid_debits
);

--Catalogo de Ciudades
INSERT INTO challenge_bous.cities (name)
SELECT DISTINCT city AS name
FROM challenge_bous.valid_debits 
INNER JOIN challenge_bous.work_table 
ON challenge_bous.valid_debits.fk_work_table_id = challenge_bous.work_table.id
EXCEPT
SELECT name FROM challenge_bous.cities;

--Catalogo de Compañias
INSERT INTO challenge_bous.companies (name)
SELECT DISTINCT company AS name
FROM challenge_bous.valid_debits 
INNER JOIN challenge_bous.work_table 
ON challenge_bous.valid_debits.fk_work_table_id = challenge_bous.work_table.id
EXCEPT
SELECT name FROM challenge_bous.companies;

--Datos generales calculados
INSERT INTO challenge_bous.data_calculations (run_id, rows, total_debits)
SELECT pg_backend_pid(),
       COUNT(*) AS total_rows,
       SUM(challenge_bous.work_table.debit::DECIMAL) AS total_debits
FROM challenge_bous.valid_debits 
INNER JOIN challenge_bous.work_table 
ON challenge_bous.valid_debits.fk_work_table_id = challenge_bous.work_table.id;

--Adeudo y porcentaje de adeudo por ciudad
INSERT INTO challenge_bous.data_cities (debit, percentage, fk_city_id, fk_data_calculate_id)
SELECT SUM(debit::DECIMAL) AS debit,
       ROUND((SUM(debit::DECIMAL) / (SELECT total_debits FROM challenge_bous.data_calculations WHERE run_id = pg_backend_pid() ) * 100), 2) AS percentage,
       (SELECT id FROM challenge_bous.cities WHERE name = city) AS fk_city_id,
       pg_backend_pid() AS fk_data_calculate_id
FROM challenge_bous.valid_debits 
INNER JOIN challenge_bous.work_table 
ON challenge_bous.valid_debits.fk_work_table_id = challenge_bous.work_table.id
GROUP BY city;

--Adeudo y porcentaje de adeudo por empresa
INSERT INTO challenge_bous.data_companies (debit, percentage, fk_company_id, fk_data_calculate_id)
SELECT SUM(debit::DECIMAL) AS debit,
       ROUND((SUM(debit::DECIMAL) / (SELECT total_debits FROM challenge_bous.data_calculations WHERE run_id = pg_backend_pid() ) * 100), 2) AS percentage,
       (SELECT id FROM challenge_bous.companies WHERE name = company) AS fk_company_id,
       pg_backend_pid() AS fk_data_calculate_id
FROM challenge_bous.valid_debits 
INNER JOIN challenge_bous.work_table 
ON challenge_bous.valid_debits.fk_work_table_id = challenge_bous.work_table.id
GROUP BY company;

--Limpiar Tablas de trabajo
--TRUNCATE TABLE challenge_bous.valid_debits CASCADE;
--TRUNCATE TABLE challenge_bous.invalid_debits CASCADE;
--TRUNCATE TABLE challenge_bous.work_table CASCADE;

SELECT pg_backend_pid();