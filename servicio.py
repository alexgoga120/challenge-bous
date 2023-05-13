import locale
from flask import Flask, jsonify
import psycopg2

app = Flask(__name__)


@app.route('/<run_id>')
def hello_world(run_id):
    try:
        locale.setlocale(locale.LC_ALL, '')

        # Conectarse a la base de datos
        conn = psycopg2.connect(
            host="localhost",
            database="bous_debit",
            user="postgres",
            password="password"
        )
        conn.set_client_encoding("utf8")
        cur = conn.cursor()

        cur.execute(
            f"SELECT run_id, total_debits, rows FROM challenge_bous.data_calculations WHERE run_id = {run_id}")
        data_calculations = cur.fetchone()

        cur.execute(
            f"SELECT challenge_bous.data_cities.fk_city_id, challenge_bous.cities.name, SUM(debit), SUM(percentage) FROM challenge_bous.data_cities INNER JOIN challenge_bous.cities ON challenge_bous.cities.id = challenge_bous.data_cities.fk_city_id WHERE fk_data_calculate_id = {run_id} GROUP BY challenge_bous.cities.id, challenge_bous.data_cities.fk_city_id;")

        data_cities = cur.fetchall()
        data_cities = list(
            map(lambda city_info: {"id": city_info[0], "city": city_info[1],
                                   "debit": locale.currency(float(city_info[2]), grouping=True),
                                   "percentage": f"{city_info[3]}%"},
                data_cities))

        cur.execute(
            f"SELECT challenge_bous.data_companies.fk_company_id, challenge_bous.companies.name, SUM(debit), SUM(percentage) FROM challenge_bous.data_companies INNER JOIN challenge_bous.companies ON challenge_bous.companies.id = challenge_bous.data_companies.fk_company_id WHERE fk_data_calculate_id = {run_id} GROUP BY challenge_bous.companies.id, challenge_bous.data_companies.fk_company_id;")

        data_companies = cur.fetchall()
        data_companies = list(
            map(lambda company_info: {"id": company_info[0], "company": company_info[1],
                                      "debit": locale.currency(float(company_info[2]), grouping=True),
                                      "percentage": f"{company_info[3]}%"},
                data_companies))

        cur.close()
        conn.close()

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
    except Exception as ex:
        error = {
            "error": {
                "message": "Error en servidor",
                "type": ex
            }
        }
        error = jsonify(error)
        error.status_code = 500
        return error


if __name__ == '__main__':
    app.run()
