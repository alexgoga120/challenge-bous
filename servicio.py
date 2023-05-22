import locale
from flask import Flask, jsonify
import psycopg2

app = Flask(__name__)
USERNAME = 'postgres'
PASSWORD = 'password'
HOST = 'localhost'
PORT = '5432'
DATABASE = 'bous_debit'

locale.setlocale(locale.LC_ALL, '')

data_calculations_query_text = '''
    SELECT run_id, 
           total_debits, 
           rows 
    FROM challenge_bous.data_calculations 
    WHERE run_id = %s
    '''
data_cities_query_text = '''
    SELECT challenge_bous.data_cities.fk_city_id, 
           challenge_bous.cities.name, 
           SUM(debit), 
           SUM(percentage) 
    FROM challenge_bous.data_cities 
    INNER JOIN challenge_bous.cities 
    ON challenge_bous.cities.id = challenge_bous.data_cities.fk_city_id 
    WHERE fk_data_calculate_id = %s 
    GROUP BY challenge_bous.cities.id, challenge_bous.data_cities.fk_city_id;
    '''
data_companies_query_text = '''
    SELECT challenge_bous.data_companies.fk_company_id, 
           challenge_bous.companies.name, 
           SUM(debit), 
           SUM(percentage) 
    FROM challenge_bous.data_companies 
    INNER JOIN challenge_bous.companies 
    ON challenge_bous.companies.id = challenge_bous.data_companies.fk_company_id 
    WHERE fk_data_calculate_id = %s 
    GROUP BY challenge_bous.companies.id, challenge_bous.data_companies.fk_company_id;
    '''


@app.route('/<run_id>')
def hello_world(run_id):
    try:
        base_response = {
            "data": {
                "folio": 0,
                "total_debits": "$0.00",
                "total_rows": 0,
                "cities_debits": [],
                "companies_debits": []
            }
        }
        # Conectarse a la base de datos
        conn = psycopg2.connect(
            host=HOST,
            database=DATABASE,
            user=USERNAME,
            password=PASSWORD
        )
        conn.set_client_encoding("utf8")
        cur = conn.cursor()
        cur.execute(data_calculations_query_text, (run_id,))
        data_calculations = cur.fetchone()

        if data_calculations is None:
            return base_response

        base_response['data']['folio'] = data_calculations[0]
        base_response['data']['total_debits'] = locale.currency(float(data_calculations[1]), grouping=True)
        base_response['data']['total_rows'] = data_calculations[2]

        cur.execute(data_cities_query_text, (run_id,))

        data_cities = cur.fetchall()

        if data_cities is None:
            return base_response

        data_cities = list(
            map(lambda city_info: {"id": city_info[0], "city": city_info[1],
                                   "debit": locale.currency(float(city_info[2]), grouping=True),
                                   "percentage": f"{city_info[3]}%"},
                data_cities))
        base_response['data']['cities_debits'] = data_cities

        cur.execute(data_companies_query_text, (run_id,))

        data_companies = cur.fetchall()

        if data_companies is None:
            return data_companies

        data_companies = list(
            map(lambda company_info: {"id": company_info[0], "company": company_info[1],
                                      "debit": locale.currency(float(company_info[2]), grouping=True),
                                      "percentage": f"{company_info[3]}%"},
                data_companies))

        base_response['data']['companies_debits'] = data_companies

        print(base_response)
        cur.close()
        conn.close()

        response = base_response
        response = jsonify(response)
        response.status_code = 200
        return response
    except Exception as ex:
        error = {
            "error": {
                "message": "Error en servidor",
                "type": f'{ex}'
            }
        }
        error = jsonify(error)
        error.status_code = 500
        return error


if __name__ == '__main__':
    app.run()
