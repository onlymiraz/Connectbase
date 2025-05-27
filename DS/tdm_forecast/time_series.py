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
from darts.models import RegressionEnsembleModel

from darts.utils.utils import ModelMode, SeasonalityMode
from scipy.signal import savgol_filter


def aggregate_churn(run_date, cleaned_data, overall=False,
                    ds1=False, ds1_mux=False, ds1_noeu=False,
                    ds3=False, ds3_mux=False, ds3_noeu=False,
                    ocn=False, carrier=False,
                    att_ds1=False, att_ds3=False,
                    ds1_every=True, ds3_every=True,
                    verizon_ds1_every=True, verizon_ds3_every=True,
                    att_ds1_every=True, att_ds3_every=True,
                    lumen_ds1_every=True, lumen_ds3_every=True):
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

    if ds1_every:
        df_ds1_every = (cleaned_data.loc[cleaned_data['PROD_TYPE']
                        .isin(['TDM_DS1', 'TDM_DS1_mux', 'TDM_DS1_noEU']) &
                                         (~cleaned_data['PRIMARY_CARRIER_NAME']
                                          .isin(['VERIZON', 'AT&T', 'LUMEN TECHNOLOGIES'])),
                        :]
                        .groupby('BILL_MONTH_DT')['CLEAN_ID']
                        .nunique()
                        .reset_index()
                        .rename(columns={'CLEAN_ID': 'TDM_Count'}))
        if np.sum(df_ds1_every['TDM_Count'], axis=0) > 1300:
            dict_dfs['ds1_every'] = df_ds1_every

    if ds3_every:
        df_ds3_every = (cleaned_data.loc[cleaned_data['PROD_TYPE']
                        .isin(['TDM_DS3', 'TDM_DS3_mux', 'TDM_DS3_noEU']) &
                                         (~cleaned_data['PRIMARY_CARRIER_NAME']
                                          .isin(['VERIZON', 'AT&T', 'LUMEN TECHNOLOGIES'])),
                        :]
                        .groupby('BILL_MONTH_DT')['CLEAN_ID']
                        .nunique()
                        .reset_index()
                        .rename(columns={'CLEAN_ID': 'TDM_Count'}))
        if np.sum(df_ds3_every['TDM_Count'], axis=0) > 1300:
            dict_dfs['ds3_every'] = df_ds3_every

    if verizon_ds1_every:
        df_verizon_ds1_every = ((cleaned_data.loc[cleaned_data['PROD_TYPE']
                                 .isin(['TDM_DS1', 'TDM_DS1_mux', 'TDM_DS1_noEU']) &
                                                  (cleaned_data['PRIMARY_CARRIER_NAME'] == 'VERIZON'),
                                 :]
                                 .groupby('BILL_MONTH_DT')['CLEAN_ID']
                                 .nunique()
                                 .reset_index()
                                 .rename(columns={'CLEAN_ID': 'TDM_Count'})))
        if np.sum(df_verizon_ds1_every['TDM_Count'], axis=0) > 1300:
            dict_dfs['verizon_ds1_every'] = df_verizon_ds1_every

    if verizon_ds3_every:
        df_verizon_ds3_every = ((cleaned_data.loc[cleaned_data['PROD_TYPE']
                                 .isin(['TDM_DS3', 'TDM_DS3_mux', 'TDM_DS3_noEU']) &
                                                  (cleaned_data['PRIMARY_CARRIER_NAME'] == 'VERIZON'),
                                 :]
                                 .groupby('BILL_MONTH_DT')['CLEAN_ID']
                                 .nunique()
                                 .reset_index()
                                 .rename(columns={'CLEAN_ID': 'TDM_Count'})))
        if np.sum(df_verizon_ds3_every['TDM_Count'], axis=0) > 1300:
            dict_dfs['verizon_ds3_every'] = df_verizon_ds3_every

    if att_ds1_every:
        df_att_ds1_every = ((cleaned_data.loc[cleaned_data['PROD_TYPE']
                             .isin(['TDM_DS1', 'TDM_DS1_mux', 'TDM_DS1_noEU']) &
                                              (cleaned_data['PRIMARY_CARRIER_NAME'] == 'AT&T'),
                             :]
                             .groupby('BILL_MONTH_DT')['CLEAN_ID']
                             .nunique()
                             .reset_index()
                             .rename(columns={'CLEAN_ID': 'TDM_Count'})))
        if np.sum(df_att_ds1_every['TDM_Count'], axis=0) > 1300:
            dict_dfs['att_ds1_every'] = df_att_ds1_every

    if att_ds3_every:
        df_att_ds3_every = ((cleaned_data.loc[cleaned_data['PROD_TYPE']
                             .isin(['TDM_DS3', 'TDM_DS3_mux', 'TDM_DS3_noEU']) &
                                              (cleaned_data['PRIMARY_CARRIER_NAME'] == 'AT&T'),
                             :]
                             .groupby('BILL_MONTH_DT')['CLEAN_ID']
                             .nunique()
                             .reset_index()
                             .rename(columns={'CLEAN_ID': 'TDM_Count'})))
        if np.sum(df_att_ds3_every['TDM_Count'], axis=0) > 1300:
            dict_dfs['att_ds3_every'] = df_att_ds3_every

    if lumen_ds1_every:
        df_lumen_ds1_every = ((cleaned_data.loc[cleaned_data['PROD_TYPE']
                               .isin(['TDM_DS1', 'TDM_DS1_mux', 'TDM_DS1_noEU']) &
                                                (cleaned_data['PRIMARY_CARRIER_NAME'] == 'LUMEN TECHNOLOGIES'),
                               :]
                               .groupby('BILL_MONTH_DT')['CLEAN_ID']
                               .nunique()
                               .reset_index()
                               .rename(columns={'CLEAN_ID': 'TDM_Count'})))
        if np.sum(df_lumen_ds1_every['TDM_Count'], axis=0) > 1300:
            dict_dfs['lumen_ds1_every'] = df_lumen_ds1_every

    if lumen_ds3_every:
        df_lumen_ds3_every = ((cleaned_data.loc[cleaned_data['PROD_TYPE']
                               .isin(['TDM_DS3', 'TDM_DS3_mux', 'TDM_DS3_noEU']) &
                                                (cleaned_data['PRIMARY_CARRIER_NAME'] == 'LUMEN TECHNOLOGIES'),
                               :]
                               .groupby('BILL_MONTH_DT')['CLEAN_ID']
                               .nunique()
                               .reset_index()
                               .rename(columns={'CLEAN_ID': 'TDM_Count'})))
        if np.sum(df_lumen_ds3_every['TDM_Count'], axis=0) > 1300:
            dict_dfs['lumen_ds3_every'] = df_lumen_ds3_every

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

        # build models - store predictions in here
        dict_preds = {}

        print(f'{grp} - ES')
        model_es = ExponentialSmoothing(trend=ModelMode.NONE,
                                        seasonal=SeasonalityMode.NONE)
        model_es.fit(train)
        pred_es = model_es.predict(num_preds, num_samples=1000)
        smoothed_es = savgol_filter([np.median(i) for i in pred_es.all_values()],
                                    window_length=20,
                                    polyorder=2)
        # dict_preds['pred_es'] = [np.median(i) for i in pred_es.all_values()]
        dict_preds['pred_es'] = list(smoothed_es)

        print(f'{grp} - CES')
        # model_complex_es = StatsForecastAutoCES(season_length=12, model="Z")
        model_complex_es = StatsForecastAutoCES(season_length=1, model='N')  # updated to eliminate waviness
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
        # model_kalman = KalmanForecaster(dim_x=12)
        model_kalman = KalmanForecaster(dim_x=1)  # updated to eliminate waviness
        model_kalman.fit(train)
        pred_kalman = model_kalman.predict(num_preds, num_samples=1)
        dict_preds['pred_kalman'] = [np.median(i) for i in pred_kalman.all_values()]

        print(f'{grp} - FFT')
        model_fourier = FFT(nr_freqs_to_keep=100,  # higher is smoother
                            trend='poly',
                            trend_poly_degree=2)
        model_fourier.fit(train)
        pred_fourier = model_fourier.predict(num_preds, num_samples=1)
        smoothed_fourier = savgol_filter([np.median(i) for i in pred_fourier.all_values()],
                                         window_length=20,
                                         polyorder=2)
        dict_preds['pred_fourier'] = list(smoothed_fourier)
        # dict_preds['pred_fourier'] = [np.median(i) for i in pred_fourier.all_values()]

        print(f'{grp} - Prophet')
        model_prophet = Prophet(changepoint_prior_scale=0.01,  # default=0.05, lower is smoother
                                seasonality_prior_scale=30.0,  # default=10, higher is smoother
                                n_changepoints=10,  # default=25, lower is smoother
                                weekly_seasonality=False,  # updated to eliminate waviness
                                daily_seasonality=False)  # updated to eliminate waviness
        model_prophet.fit(train)
        pred_prophet = model_prophet.predict(num_preds, num_samples=1)
        smoothed_prophet = savgol_filter([np.median(i) for i in pred_prophet.all_values()],
                                         window_length=20,
                                         polyorder=2)
        dict_preds['pred_prophet'] = list(smoothed_prophet)
        # dict_preds['pred_prophet'] = [np.median(i) for i in pred_prophet.all_values()]

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
        # model_tbats = TBATS(use_trend=True)
        model_tbats = TBATS(use_trend=True, use_damped_trend=True,
                            use_box_cox=True, box_cox_bounds=(0, 1),
                            use_arma_errors=False)
        model_tbats.fit(train)
        pred_tbats = model_tbats.predict(num_preds, num_samples=1)
        dict_preds['pred_tbats'] = [np.median(i) for i in pred_tbats.all_values()]

        # ensembles

        # naive
        lst_base_preds = [dict_preds['pred_es'],
                          dict_preds['pred_complex_es'],
                          dict_preds['pred_arima'],
                          dict_preds['pred_croston'],
                          dict_preds['pred_kalman'],
                          dict_preds['pred_fourier'],
                          dict_preds['pred_prophet'],
                          dict_preds['pred_theta'],
                          dict_preds['pred_four_theta'],
                          dict_preds['pred_tbats']]

        ensemble_naive_median = np.median(lst_base_preds, axis=0)
        dict_preds['pred_ens_naive_median'] = list(ensemble_naive_median)

        ensemble_naive_mean = np.mean(lst_base_preds, axis=0)
        dict_preds['pred_ens_naive_mean'] = list(ensemble_naive_mean)

        # learned regression
        # lst_base_models = [model_es,
        #                    model_complex_es,
        #                    model_arima,
        #                    model_croston,
        #                    model_kalman,
        #                    model_fourier,
        #                    model_prophet,
        #                    model_theta,
        #                    model_four_theta,
        #                    model_tbats]

        lst_base_models_unfitted = [
            ExponentialSmoothing(trend=ModelMode.NONE, seasonal=SeasonalityMode.NONE),
            StatsForecastAutoCES(season_length=1, model='N'),
            AutoARIMA(start_p=8, max_p=12, start_q=1),
            Croston(version='optimized'),
            KalmanForecaster(dim_x=1),
            FFT(nr_freqs_to_keep=100, trend='poly', trend_poly_degree=2),
            Prophet(changepoint_prior_scale=0.01, seasonality_prior_scale=30.0, n_changepoints=10,
                    weekly_seasonality=False, daily_seasonality=False),
            StatsForecastAutoTheta(season_length=12),
            FourTheta(theta=2),
            TBATS(use_trend=True, use_damped_trend=True, use_box_cox=True, box_cox_bounds=(0, 1), use_arma_errors=False)
        ]

        # model_ensemble_learned_50 = RegressionEnsembleModel(lst_base_models_unfitted,
        #                                                     regression_train_n_points=50)
        # model_ensemble_learned_50.fit(train)
        # preds_ensemble_learned_50 = model_ensemble_learned_50.predict(num_preds, num_samples=1)
        # dict_preds['pred_ens_learned_50'] = savgol_filter(
        #     [np.median(i) for i in preds_ensemble_learned_50.all_values()], window_length=20, polyorder=2)

        model_ensemble_learned_10 = RegressionEnsembleModel(lst_base_models_unfitted,
                                                            regression_train_n_points=10)
        model_ensemble_learned_10.fit(train)
        preds_ensemble_learned_10 = model_ensemble_learned_10.predict(num_preds, num_samples=1)
        dict_preds['pred_ens_learned_10'] = savgol_filter(
            [np.median(i) for i in preds_ensemble_learned_10.all_values()], window_length=20, polyorder=2)

        # model_ensemble_learned_100 = RegressionEnsembleModel(lst_base_models,
        #                                                      regression_train_n_points=100,
        #                                                      train_forecasting_models=False)
        # preds_ensemble_learned_100 = model_ensemble_learned_100.predict(num_preds, num_samples=1)
        # dict_preds['pred_ens_learned_100'] = savgol_filter(
        #     [np.median(i) for i in preds_ensemble_learned_100.all_values()],
        #     window_length=20,
        #     polyorder=2)

        # model_ensemble_learned_10 = RegressionEnsembleModel(lst_base_models,
        #                                                     regression_train_n_points=10,
        #                                                     train_forecasting_models=False)
        # preds_ensemble_learned_10 = model_ensemble_learned_10.predict(num_preds, num_samples=1)
        # dict_preds['pred_ens_learned_10'] = savgol_filter(
        #     [np.median(i) for i in preds_ensemble_learned_10.all_values()],
        #     window_length=20,
        #     polyorder=2)

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
