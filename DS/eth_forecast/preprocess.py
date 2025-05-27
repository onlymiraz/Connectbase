import glob
import os
import pandas as pd
import numpy as np


def import_and_clean(run_date, file_path,
                     first_date='2019-06-01', last_date='2024-05-31'):
    print('Reading Data')
    txt_files = glob.glob(os.path.join(file_path, '*.txt'))

    lst_dfs = []
    for cabs in txt_files:
        df_temp = pd.read_table(cabs)
        df_temp['source_file'] = os.path.basename(cabs)

        # Append the DataFrame to the list
        lst_dfs.append(df_temp)

    df_eth = pd.concat(lst_dfs, ignore_index=True)
    print('Before Preprocessing: ', df_eth.shape)

    df_eth.drop_duplicates(inplace=True)

    # clean date formats
    df_eth['BILL_MONTH_DT'] = pd.to_datetime(df_eth['BILL_MONTH_DT'])
    df_eth['INSTALL_DT'] = pd.to_datetime(df_eth['INSTALL_DT'])

    df_eth.loc[df_eth['TERM_START_DT'] == '?', 'TERM_START_DT'] = np.nan
    df_eth.loc[df_eth['TERM_END_DT'] == '?', 'TERM_END_DT'] = np.nan
    df_eth['TERM_START_DT'] = pd.to_datetime(df_eth['TERM_START_DT'])
    df_eth['TERM_END_DT'] = pd.to_datetime(df_eth['TERM_END_DT'])

    df_eth = df_eth.loc[df_eth['BILL_MONTH_DT'].between(first_date, last_date, inclusive='both')]

    # filter to only include: eth, evc, switched, wired
    df_eth = df_eth.loc[(df_eth['SVC_GROUP'] == 'ETH_EVC') &
                        (df_eth['ETHERNET_TYPE'] == 'Switched Ethernet') &
                        (df_eth['WIRELESS'] == 'WIRELINE'), :]

    df_eth = df_eth[~df_eth['PRODUCT'].str.contains('WIRELESS')]

    # calculate tenure
    df_eth['tenure'] = (df_eth['BILL_MONTH_DT'] - df_eth['INSTALL_DT']).dt.days.astype('Int64')
    df_eth = df_eth.loc[df_eth['tenure'] >= 0, :]
    df_eth['tenure'] = round(df_eth['tenure'] / 365, 2)

    # contract length
    df_eth['contract_length'] = round(
        (df_eth['TERM_END_DT'] - df_eth['TERM_START_DT']).dt.days.astype('Int64') / 365
    ).astype('Int64')

    # bin all EIA, EPATH, drop others
    df_eth.loc[df_eth['PRODUCT'].str.contains('EIA'), 'PRODUCT'] = 'EIA'
    df_eth.loc[df_eth['PRODUCT'].str.contains('EPATH'), 'PRODUCT'] = 'EPATH'
    df_eth = df_eth.loc[df_eth['PRODUCT'].isin(['EIA', 'EPATH']), :]

    # speed
    df_eth.loc[df_eth['EVC_MBPS'] == '?', 'EVC_MBPS'] = np.nan
    df_eth['EVC_MBPS'] = pd.to_numeric(df_eth['EVC_MBPS'], errors='coerce')
    df_eth['EVC_MBPS'] = df_eth['EVC_MBPS'].astype('Int64')

    df_eth['BILL_MONTH_DT'] = df_eth['BILL_MONTH_DT'].dt.strftime('%Y-%m')
    # save
    if not os.path.exists(f'./output/{str(run_date)}/'):
        os.makedirs(f'./output/{str(run_date)}/')
    df_eth.to_csv(f'./output/{str(run_date)}/eth_cleaned.csv', index=False)
    print('After Preprocessing: ', df_eth.shape)

    return df_eth
