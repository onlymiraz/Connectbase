if __name__ == '__main__':
    from datetime import datetime
    from multiprocessing import freeze_support

    from preprocess import import_and_clean
    from time_series import aggregate_churn, future_months, time_series
    from taper_mape import tape_mape

    freeze_support()
    run_date = datetime.today().strftime("%Y-%m-%d")
    fpath = 'C:/Users/jss7571/OneDrive - Frontier Communications/Documents/Jupyter_Notebooks/ETH_Tenure_Avg/cabs_data/'

    df_eth_cleaned = import_and_clean(run_date=run_date, file_path=fpath,
                                      first_date='2019-06-01', last_date='2024-05-31')

    dict_churn_dfs = aggregate_churn(run_date=run_date, cleaned_data=df_eth_cleaned,
                                     overall=True,
                                     carrier=True, contract_length=True,
                                     product=True, speed=True)

    lst_fcast_months = future_months(cleaned_data=df_eth_cleaned,
                                     date_column='BILL_MONTH_DT', target_date='2033-12-31')

    time_series(run_date=run_date, cleaned_data=df_eth_cleaned, dict_of_dfs=dict_churn_dfs,
                fcast_months=lst_fcast_months)

    tape_mape(run_date=run_date)
