SELECT 'CREATE DATABASE bous_debit' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'bous_debit')\gexec

\c bous_debit

DROP SCHEMA IF EXISTS challenge_bous CASCADE;
CREATE SCHEMA challenge_bous;

CREATE TABLE challenge_bous.work_table(
    id INT PRIMARY KEY,
    client VARCHAR(75),
    contract_num VARCHAR(5),
    purchase_date DATE,
    city VARCHAR(15),
    company VARCHAR(30),
    debit DECIMAL(10,2)
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