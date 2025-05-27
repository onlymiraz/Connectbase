import os

import pandas as pd


def combine_top_models(run_date):
    dfs = []
    file_index = 0
    for index, (root, dirs, files) in enumerate(os.walk(f'./output/{str(run_date)}/')):
        for file in files:
            if file.endswith('top_model.csv'):

                print(index)
                print(file)
                carrier, service = file.split("_")[0:2]
                print(f'{carrier}_{service}')
                file_path = os.path.join(root, file)
                print(file_path)

                df_temp = pd.read_csv(file_path)
                df_temp.iloc[:, -1] = df_temp.iloc[:, -1].astype(int)
                original_pred_name = df_temp.columns[-1]
                print(original_pred_name)
                if service != 'every':
                    df_temp.columns = ['BILL_MONTH_DT',
                                       f'{carrier}_{service}_actual',
                                       f'{carrier}_{service}_{original_pred_name}']
                else:
                    df_temp.columns = ['BILL_MONTH_DT',
                                       f'{carrier}_other_actual',
                                       f'{carrier}_other_{original_pred_name}']

                if file_index == 0:
                    dfs.append(df_temp)
                else:
                    dfs.append(df_temp.iloc[:, -2:])
                file_index += 1

    df_top = pd.concat(dfs, axis=1)

    df_top = df_top.iloc[:, [0,               # date
                             1, 2, 3, 4,      # att
                             13, 14, 15, 16,  # verizon
                             9, 10, 11, 12,   # lumen
                             5, 6, 7, 8]]     # other

    df_top.to_csv(f'./output/{str(run_date)}/{run_date}_top_models.csv', index=False)
