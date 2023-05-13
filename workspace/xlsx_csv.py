import os
import sys
import pandas as pd


def valid_headers():
    try:
        if len(sys.argv) < 2:
            return print("Error: Debe proporcionar un archivo Excel como argumento.")
        df = pd.read_excel(sys.argv[1], skiprows=2)
        df = df.dropna(axis=1, how='all')
        # types_column = df.iloc[0].values.tolist()
        df.drop([0], axis=0, inplace=True)
        process_data_path = "./process_data"
        if not os.path.exists(process_data_path):
            os.makedirs(process_data_path)
        df.to_csv(f"{process_data_path}/new_csv.csv")
        # sys.exit(types_column)

    except OSError as e:
        print(f"Error: El archivo: {sys.argv[1]} no existe")
        print(e.strerror)


if __name__ == '__main__':
    valid_headers()
