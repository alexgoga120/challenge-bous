import sys
import numpy as np
import pandas as pd


def valid_headers():
    try:
        if len(sys.argv) < 2:
            return print("Error: Debe proporcionar un archivo Excel como argumento.")
        print(f"Archivo cargado con exito: {sys.argv[1]}")
        df = pd.read_excel(sys.argv[1], index_col=0, skiprows=2, header=None)
        accept_header = ["Cliente", "# Contrato", "Fecha de Compra", "Ciudad", "Empresa", "Valor adeudado"]
        file_header = df.iloc[0].values.tolist()

        sys.exit(np.array_equiv(accept_header, file_header))

    except OSError as e:
        print(f"Error: El archivo: {sys.argv[1]} no existe")
        print(e.strerror)


if __name__ == '__main__':
    valid_headers()
