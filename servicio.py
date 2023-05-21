import locale
from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text
import psycopg2

app = Flask(__name__)
USERNAME = 'postgres'
PASSWORD = 'password'
HOST = 'localhost'
PORT = '5432'
DATABASE = 'bous_debit'
POSTGRESQL = f'postgresql+psycopg2://{USERNAME}:{PASSWORD}@{HOST}:{PORT}/{DATABASE}?client_encoding=utf8'
app.config['SQLALCHEMY_DATABASE_URI'] = POSTGRESQL
db = SQLAlchemy(app)
locale.setlocale(locale.LC_ALL, '')

data_calculations_query_text = text(
    '''
    SELECT run_id, 
           total_debits, 
           rows 
    FROM challenge_bous.data_calculations 
    WHERE run_id = :run_id
    ''')
data_cities_query_text = text(
    '''
    SELECT challenge_bous.data_cities.fk_city_id, 
           challenge_bous.cities.name, 
           SUM(debit), 
           SUM(percentage) 
    FROM challenge_bous.data_cities 
    INNER JOIN challenge_bous.cities 
    ON challenge_bous.cities.id = challenge_bous.data_cities.fk_city_id 
    WHERE fk_data_calculate_id = :run_id 
    GROUP BY challenge_bous.cities.id, challenge_bous.data_cities.fk_city_id;
    ''')
data_companies_query_text = text(
    '''
    SELECT challenge_bous.data_companies.fk_company_id, 
           challenge_bous.companies.name, 
           SUM(debit), 
           SUM(percentage) 
    FROM challenge_bous.data_companies 
    INNER JOIN challenge_bous.companies 
    ON challenge_bous.companies.id = challenge_bous.data_companies.fk_company_id 
    WHERE fk_data_calculate_id = :run_id 
    GROUP BY challenge_bous.companies.id, challenge_bous.data_companies.fk_company_id;''')


@app.route('/<run_id>')
def hello_world(run_id):
    data_calculations = db.session.execute(data_calculations_query_text, {'run_id': run_id}).fetchone()

    data_cities = db.session.execute(data_cities_query_text, {'run_id': run_id}).fetchall()
    data_cities = list(
        map(lambda city_info: {"id": city_info[0], "city": city_info[1],
                               "debit": locale.currency(float(city_info[2]), grouping=True),
                               "percentage": f"{city_info[3]}%"},
            data_cities))

    data_companies = db.session.execute(data_companies_query_text, {'run_id': run_id}).fetchall()
    data_companies = list(
        map(lambda company_info: {"id": company_info[0], "company": company_info[1],
                                  "debit": locale.currency(float(company_info[2]), grouping=True),
                                  "percentage": f"{company_info[3]}%"},
            data_companies))

    response = {
        "data": {
            "folio": data_calculations[0],
            "total_debits": locale.currency(float(data_calculations[1]), grouping=True),
            "total_rows": data_calculations[2],
            "cities_debits": data_cities,
            "companies_debits": data_companies
        }
    }
    response = jsonify(response)
    response.status_code = 200
    return response


if __name__ == '__main__':
    app.run()
