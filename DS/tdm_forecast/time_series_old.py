import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

from darts import TimeSeries
from darts.models import ExponentialSmoothing
from darts.models import StatsForecastAutoCES
from darts.models import AutoARIMA
from darts.models import Croston
from darts.models import KalmanForecaster
from darts.models import FFT
from darts.models import Prophet
from darts.models import StatsForecastAutoTheta
from darts.models import FourTheta
from darts.models import TBATS


def aggregate_churn(run_date, cleaned_data, overall=True,
                    ds1=True, ds1_mux=True, ds1_noeu=True,
                    ds3=True, ds3_mux=True, ds3_noeu=True,
                    ocn=True, carrier=True,
                    att_ds1=True, att_ds3=True):
    dict_dfs = {}

    if carrier:
        cleaned_data['PRIMARY_CARRIER_NAME'] = (cleaned_data['PRIMARY_CARRIER_NAME'].str.strip()
                                                .str.replace(r'[, ]', '_', regex=True)
                                                .str.replace(r'[,./\\]', '_', regex=True))

        lst_carriers = list(sorted(cleaned_data['PRIMARY_CARRIER_NAME'].dropna().unique()))
        print(lst_carriers)

        for carr in lst_carriers:
            df_car = (cleaned_data.loc[cleaned_data['PRIMARY_CARRIER_NAME'] == carr, :]
                      .groupby('BILL_MONTH_DT')['CLEAN_ID']
                      .nunique()
                      .reset_index()
                      .rename(columns={'CLEAN_ID': 'TDM_Count'}))
            if np.sum(df_car['TDM_Count'], axis=0) > 2000:
                dict_dfs[f'carrier_{str(carr)}'] = df_car

    if overall:
        df_all = (cleaned_data.loc[cleaned_data['PRIMARY_CARRIER_NAME'] != 'AT&T', :]
                  .groupby('BILL_MONTH_DT')['CLEAN_ID']
                  .nunique()
                  .reset_index()
                  .rename(columns={'CLEAN_ID': 'TDM_Count'}))
        dict_dfs['all'] = df_all

    if ds1:
        df_ds1 = (cleaned_data.loc[(cleaned_data['SVC_GROUP'] == 'TDM_DS1') &
                                   (cleaned_data['PRIMARY_CARRIER_NAME'] != 'AT&T'), :]
                  .groupby('BILL_MONTH_DT')['CLEAN_ID']
                  .nunique()
                  .reset_index()
                  .rename(columns={'CLEAN_ID': 'TDM_Count'}))
        if np.sum(df_ds1['TDM_Count'], axis=0) > 1300:
            dict_dfs['ds1'] = df_ds1

    if ds1_mux:
        df_ds1_mux = (cleaned_data.loc[(cleaned_data['SVC_GROUP'] == 'TDM_DS1_mux') &
                                       (cleaned_data['PRIMARY_CARRIER_NAME'] != 'AT&T'), :]
                      .groupby('BILL_MONTH_DT')['CLEAN_ID']
                      .nunique()
                      .reset_index()
                      .rename(columns={'CLEAN_ID': 'TDM_Count'}))
        if np.sum(df_ds1_mux['TDM_Count'], axis=0) > 1300:
            dict_dfs['ds1_mux'] = df_ds1_mux

    if ds1_noeu:
        df_ds1_noeu = (cleaned_data.loc[(cleaned_data['SVC_GROUP'] == 'TDM_DS1_noEU') &
                                        (cleaned_data['PRIMARY_CARRIER_NAME'] != 'AT&T'), :]
                       .groupby('BILL_MONTH_DT')['CLEAN_ID']
                       .nunique()
                       .reset_index()
                       .rename(columns={'CLEAN_ID': 'TDM_Count'}))
        if np.sum(df_ds1_noeu['TDM_Count'], axis=0) > 1300:
            dict_dfs['ds1_noeu'] = df_ds1_noeu

    if ds3:
        df_ds3 = (cleaned_data.loc[(cleaned_data['SVC_GROUP'] == 'TDM_DS3') &
                                   (cleaned_data['PRIMARY_CARRIER_NAME'] != 'AT&T'), :]
                  .groupby('BILL_MONTH_DT')['CLEAN_ID']
                  .nunique()
                  .reset_index()
                  .rename(columns={'CLEAN_ID': 'TDM_Count'}))
        if np.sum(df_ds3['TDM_Count'], axis=0) > 1300:
            dict_dfs['ds3'] = df_ds3

    if ds3_mux:
        df_ds3_mux = (cleaned_data.loc[(cleaned_data['SVC_GROUP'] == 'TDM_DS3_mux') &
                                       (cleaned_data['PRIMARY_CARRIER_NAME'] != 'AT&T'), :]
                      .groupby('BILL_MONTH_DT')['CLEAN_ID']
                      .nunique()
                      .reset_index()
                      .rename(columns={'CLEAN_ID': 'TDM_Count'}))
        if np.sum(df_ds3_mux['TDM_Count'], axis=0) > 1300:
            dict_dfs['ds3_mux'] = df_ds3_mux

    if ds3_noeu:
        df_ds3_noeu = (cleaned_data.loc[(cleaned_data['SVC_GROUP'] == 'TDM_DS1_noEU') &
                                        (cleaned_data['PRIMARY_CARRIER_NAME'] != 'AT&T'), :]
                       .groupby('BILL_MONTH_DT')['CLEAN_ID']
                       .nunique()
                       .reset_index()
                       .rename(columns={'CLEAN_ID': 'TDM_Count'}))
        if np.sum(df_ds3_noeu['TDM_Count'], axis=0) > 1300:
            dict_dfs['ds3_noeu'] = df_ds3_noeu

    if ocn:
        df_ocn = (cleaned_data.loc[(cleaned_data['SVC_GROUP'] == 'OCN') &
                                   (cleaned_data['PRIMARY_CARRIER_NAME'] != 'AT&T'), :]
                  .groupby('BILL_MONTH_DT')['CLEAN_ID']
                  .nunique()
                  .reset_index()
                  .rename(columns={'CLEAN_ID': 'TDM_Count'}))
        if np.sum(df_ocn['TDM_Count'], axis=0) > 1300:
            dict_dfs['ocn'] = df_ocn

    if att_ds1:
        df_att_ds1 = (cleaned_data.loc[(cleaned_data['SVC_GROUP'] == 'TDM_DS1') &
                                       (cleaned_data['PRIMARY_CARRIER_NAME'] == 'AT&T'), :]
                      .groupby('BILL_MONTH_DT')['CLEAN_ID']
                      .nunique()
                      .reset_index()
                      .rename(columns={'CLEAN_ID': 'TDM_Count'}))
        if np.sum(df_att_ds1['TDM_Count'], axis=0) > 1300:
            dict_dfs['att_ds1'] = df_att_ds1

    if att_ds3:
        df_att_ds3 = (cleaned_data.loc[(cleaned_data['SVC_GROUP'] == 'TDM_DS3') &
                                       (cleaned_data['PRIMARY_CARRIER_NAME'] == 'AT&T'), :]
                      .groupby('BILL_MONTH_DT')['CLEAN_ID']
                      .nunique()
                      .reset_index()
                      .rename(columns={'CLEAN_ID': 'TDM_Count'}))
        if np.sum(df_att_ds3['TDM_Count'], axis=0) > 1300:
            dict_dfs['att_ds3'] = df_att_ds3

    for k, value in dict_dfs.items():
        if not os.path.exists(f'./output/{str(run_date)}/{k}/'):
            os.makedirs(f'./output/{str(run_date)}/{k}/')
        tr_sz, te_sz = value['TDM_Count'][:-12].sum(), value['TDM_Count'][-12:].sum()
        fig, ax = plt.subplots(figsize=(12, 8))
        ax.plot(value[:-12]['BILL_MONTH_DT'], value[:-12]['TDM_Count'],
                linewidth=4, label='Model_Train', color='blue')
        ax.plot(value[-12:]['BILL_MONTH_DT'], value[-12:]['TDM_Count'],
                linewidth=4, label='Model_Test', color='black')
        plt.xticks(rotation=90)
        plt.legend()
        if k != 'carrier_AT&T':
            ax.set_title(
                f'Historical Churn: {str(k).upper()} TDM Circuits (AT&T Removed)\n'
                f'Train Size: {tr_sz:,} - Test Size: {te_sz:,}')
        else:
            ax.set_title(
                f'Historical Churn: {str(k).upper()} TDM Circuits\n'
                f'Train Size: {tr_sz:,} - Test Size: {te_sz:,}')
        ax.set_xlabel('Year-Month')
        ax.set_ylabel('TDM Circuit Count')
        print(f'Saving Historical Plot for: {k}')
        plt.savefig(f'./output/{str(run_date)}/{k}/{k}_plot_historical.png', dpi=1200)
        plt.close()

    return dict_dfs


def future_months(cleaned_data, date_column='BILL_MONTH_DT', target_date='2033-12-31'):
    max_month = pd.to_datetime(cleaned_data[date_column].max())
    first_month = pd.to_datetime(max_month + pd.DateOffset(months=1)).strftime('%Y-%m')
    last_month = pd.to_datetime(pd.to_datetime(target_date) + pd.DateOffset(months=1)).strftime('%Y-%m')

    lst_new_months = list(pd.date_range(start=first_month, end=last_month, freq='M').strftime('%Y-%m'))
    print(f'Forecasting months from {lst_new_months[0]} to {lst_new_months[-1]}')

    return lst_new_months


def time_series(run_date, cleaned_data, dict_of_dfs, fcast_months):
    # store final results
    dict_results = {}

    num_preds = len(fcast_months) + 12

    # make predictions
    for grp, df in dict_of_dfs.items():
        # put df into ts format
        series = TimeSeries.from_dataframe(df,
                                           'BILL_MONTH_DT',
                                           'TDM_Count')

        # set aside last 12 months for test
        train, test = series[:-12], series[-12:]

        # # build models - store predictions in here
        dict_preds = {}

        print(f'{grp} - ES')
        model_es = ExponentialSmoothing()
        model_es.fit(train)
        pred_es = model_es.predict(num_preds, num_samples=1000)
        dict_preds['pred_es'] = [np.median(i) for i in pred_es.all_values()]

        print(f'{grp} - CES')
        model_complex_es = StatsForecastAutoCES(season_length=12, model="Z")
        model_complex_es.fit(train)
        pred_complex_es = model_complex_es.predict(num_preds, num_samples=1)
        dict_preds['pred_complex_es'] = [np.median(i) for i in pred_complex_es.all_values()]

        print(f'{grp} - ARIMA')
        model_arima = AutoARIMA(start_p=8, max_p=12, start_q=1)
        model_arima.fit(train)
        pred_arima = model_arima.predict(num_preds, num_samples=1)
        dict_preds['pred_arima'] = [np.median(i) for i in pred_arima.all_values()]

        print(f'{grp} - Croston')
        model_croston = Croston(version='optimized')
        model_croston.fit(train)
        pred_croston = model_croston.predict(num_preds, num_samples=1)
        dict_preds['pred_croston'] = [np.median(i) for i in pred_croston.all_values()]

        print(f'{grp} - Kalman')
        model_kalman = KalmanForecaster(dim_x=12)
        model_kalman.fit(train)
        pred_kalman = model_kalman.predict(num_preds, num_samples=1)
        dict_preds['pred_kalman'] = [np.median(i) for i in pred_kalman.all_values()]

        print(f'{grp} - FFT')
        model_fourier = FFT(nr_freqs_to_keep=20, trend='poly', trend_poly_degree=2)
        model_fourier.fit(train)
        pred_fourier = model_fourier.predict(num_preds, num_samples=1)
        dict_preds['pred_fourier'] = [np.median(i) for i in pred_fourier.all_values()]

        print(f'{grp} - Prophet')
        model_prophet = Prophet(add_seasonalities={'name': 'monthly_seasonality',
                                                           'seasonal_periods': 12,
                                                           'fourier_order': 5})
        model_prophet.fit(train)
        pred_prophet = model_prophet.predict(num_preds, num_samples=1)
        dict_preds['pred_prophet'] = [np.median(i) for i in pred_prophet.all_values()]

        print(f'{grp} - Theta')
        model_theta = StatsForecastAutoTheta(season_length=12)
        model_theta.fit(train)
        pred_theta = model_theta.predict(num_preds, num_samples=1)
        dict_preds['pred_theta'] = [np.median(i) for i in pred_theta.all_values()]

        print(f'{grp} - Fourrier Theta')
        model_four_theta = FourTheta(theta=2)
        model_four_theta.fit(train)
        pred_four_theta = model_four_theta.predict(num_preds, num_samples=1)
        dict_preds['pred_four_theta'] = [np.median(i) for i in pred_four_theta.all_values()]

        print(f'{grp} - TBATS')
        model_tbats = TBATS(use_trend=True)
        model_tbats.fit(train)
        pred_tbats = model_tbats.predict(num_preds, num_samples=1)
        dict_preds['pred_tbats'] = [np.median(i) for i in pred_tbats.all_values()]

        # store predictions in df
        df_preds = pd.DataFrame(dict_preds)
        # 12 months + additional months to go until 2028
        df_preds['BILL_MONTH_DT'] = (sorted(cleaned_data['BILL_MONTH_DT'].unique())[-12:] +
                                     fcast_months)
        # for plotting, y should have nans for when observed data ends
        df_preds['y'] = [e for e in df.tail(12)['TDM_Count']] + [e for e in [np.nan] * len(fcast_months)]

        dict_results[grp] = df_preds

    for key, value in dict_results.items():
        file_label = f'{key}_initial_predictions.csv'
        print(f'Saving Initial Pred CSV for: {key}')
        value.to_csv(f'./output/{str(run_date)}/{key}/{file_label}', index=False)
