import pandas as pd
import os
from sqlalchemy import create_engine, inspect


connection_url = f'postgresql://user:123@127.0.0.1:5444/airline'

data_dir = './db/data'

def extract_data(data_dir):
    data_dict = {}
    for file_name in os.listdir(data_dir):
        if file_name.endswith('.csv'):
            table_name = file_name.replace('.csv', '')
            file_path = os.path.join(data_dir, file_name)
            df = pd.read_csv(file_path)
            data_dict[table_name] = df
    return data_dict



def database_loader(url, df, table_name):
    try:
        engine = create_engine(url)
        with engine.connect() as connection:
            if not inspect(engine).has_table(table_name):
                df.to_sql(table_name, con=connection, index=False)
                print(f"Data loaded into table '{table_name}' successfully.")
            else:
                print(f"Table '{table_name}' already exists. No data loaded.")
    except Exception as e:
        print(f"Error while loading data: {e}")

def main():
    data_dict = extract_data(data_dir)
    for table_name, df in data_dict.items():
        database_loader(connection_url, df, table_name)
if __name__ == "__main__":
    main()
    print("Data loading completed.")


