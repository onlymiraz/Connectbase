if __name__ == '__main__':
    import pandas as pd
    from datetime import datetime
    from multiprocessing import freeze_support

    from preprocess import query_and_clean
    from time_series import aggregate_churn, future_months, time_series
    from taper_mape import tape_mape
    from top_models import combine_top_models

    freeze_support()

    todays_date = datetime.today()
    run_date = todays_date.strftime("%Y-%m-%d")

    first_date = datetime(todays_date.year - 5,
                          todays_date.month - 1,
                          todays_date.day - todays_date.day + 1
                          ).strftime("%Y-%m-%d")

    last_date = (datetime(todays_date.year,
                          todays_date.month - 1,
                          todays_date.day - todays_date.day + 1
                          ) - pd.DateOffset(days=1)).strftime("%Y-%m-%d")

    # full process:
    df_tdm_cleaned = query_and_clean(run_date=run_date, first_date=first_date, last_date=last_date)

    # skip query (to test models on existing dataset)
    # df_tdm_cleaned = pd.read_csv(f'./output/2024-09-20/tdm_cleaned.csv')

    dict_churn_dfs = aggregate_churn(run_date=run_date, cleaned_data=df_tdm_cleaned,
                                     overall=False,
                                     ds1=False, ds1_mux=False, ds1_noeu=False,
                                     ds3=False, ds3_mux=False, ds3_noeu=False,
                                     ocn=False, carrier=False,
                                     att_ds1=False, att_ds3=False,
                                     att_ds1_every=True, att_ds3_every=True,
                                     verizon_ds1_every=True, verizon_ds3_every=True,
                                     lumen_ds1_every=True, lumen_ds3_every=True,
                                     ds1_every=True, ds3_every=True)

    lst_fcast_months = future_months(cleaned_data=df_tdm_cleaned,
                                     date_column='BILL_MONTH_DT', target_date='2033-12-31')

    time_series(run_date=run_date, cleaned_data=df_tdm_cleaned,
                dict_of_dfs=dict_churn_dfs, fcast_months=lst_fcast_months)

    tape_mape(run_date=run_date)

    combine_top_models(run_date=run_date)
