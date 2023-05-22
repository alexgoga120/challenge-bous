SELECT 'CREATE DATABASE bous_debit' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'bous_debit')\gexec

\c bous_debit

DROP SCHEMA IF EXISTS challenge_bous CASCADE;
CREATE SCHEMA challenge_bous;
SET SEARCH_PATH TO challenge_bous;

CREATE TABLE challenge_bous.work_table(
    id INT PRIMARY KEY,
    client VARCHAR(75),
    contract_num VARCHAR(5),
    purchase_date VARCHAR(20),
    city VARCHAR(15),
    company VARCHAR(30),
    debit VARCHAR(12)
);

CREATE TABLE challenge_bous.valid_debits(
    id SERIAL PRIMARY KEY,
    fk_work_table_id INTEGER REFERENCES "challenge_bous"."work_table" (id)
);

CREATE TABLE challenge_bous.invalid_debits(
    id SERIAL PRIMARY KEY,
    fk_work_table_id INTEGER REFERENCES "challenge_bous"."work_table" (id)
);

CREATE TABLE challenge_bous.cities(
    id SERIAL PRIMARY KEY,
    name VARCHAR(30) UNIQUE
);

CREATE TABLE challenge_bous.companies(
    id SERIAL PRIMARY KEY,
    name VARCHAR(30) UNIQUE
);

CREATE TABLE challenge_bous.data_calculations(
    run_id INT PRIMARY KEY,
    rows INT NOT NULL,
    total_debits DECIMAL(20,2) NOT NULL
);

CREATE TABLE challenge_bous.data_cities(
    id SERIAL PRIMARY KEY,
    debit DECIMAL(15,2) NOT NULL,
    percentage DECIMAL(5,2) NOT NULL,
    fk_city_id INTEGER REFERENCES "challenge_bous"."cities" (id),
    fk_data_calculate_id INTEGER REFERENCES "challenge_bous"."data_calculations" (run_id)
);

CREATE TABLE challenge_bous.data_companies(
    id SERIAL PRIMARY KEY,
    debit DECIMAL(15,2) NOT NULL,
    percentage DECIMAL(5,2) NOT NULL,
    fk_company_id INTEGER REFERENCES "challenge_bous"."companies" (id),
    fk_data_calculate_id INTEGER REFERENCES "challenge_bous"."data_calculations" (run_id)
);

CREATE OR REPLACE FUNCTION CHALLENGE_BOUS.VALID_HEADER_TYPE(IN CLIENT VARCHAR, IN CONTRACT_NUM VARCHAR, IN PURCHASE_DATE VARCHAR, IN CITY VARCHAR, IN COMPANY VARCHAR, IN DEBIT VARCHAR) RETURNS BOOLEAN AS $$
BEGIN
    BEGIN
        --Cliente no contenga numeros
        if client ~ '\d' OR client IS NULL then
            RETURN FALSE;
        end if;

        --Numero de contrato
        --Buscar caracteres especiales, excepto el guion "-"
        if contract_num ~ '[^a-zA-Z0-9-]' OR contract_num ~ NULL then
            RETURN FALSE;
        end if;

        --fecha de compra que cumpla el formato
        if purchase_date IS NULL then
            RETURN FALSE;
        end if;
        PERFORM to_date(purchase_date, 'YYYY-MM-DD');

        --Ciudad no contenga numeros
        if city ~ '\d' OR city IS NULL then
            RETURN FALSE;
        end if;

        --Compañia
        --Buscar caracteres especiales, excepto un espacio " "
        if company ~ '[^a-zA-Z0-9 ]' OR company IS NULL then
            RETURN FALSE;
        end if;

        -- Eliminar caracteres no numéricos (excepto . y -)
        if debit IS NULL then
            RETURN FALSE;
        end if;
        debit := regexp_replace(debit, '[^\d.-]', '', 'g');

        -- Intenta convertir el valor a decimal
        PERFORM debit::DECIMAL;

        RETURN TRUE;
    EXCEPTION
        WHEN others THEN
            RETURN FALSE;
    END;
END;
$$ LANGUAGE PLPGSQL;