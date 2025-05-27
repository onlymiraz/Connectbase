from sktime.performance_metrics.forecasting import mean_absolute_percentage_error

import os
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
import plotly.express as px
cmap = mpl.colormaps['Paired']


def tape_mape(run_date):

    def taper_preds(input_df, taper_start=95, taper_stop=106, taper_start2=95, taper_stop2=106):
        dict_tapers = {}

        for col in list(input_df.columns)[:-2]:
            for rate in range(taper_start, taper_stop):

                taper_rate = rate / 100
                if taper_rate != 1.0:

                    for rate2 in range(taper_start2, taper_stop2):
                        taper_rate2 = rate2 / 100

                        n = len(input_df[col])
                        tapered_preds = input_df[col].copy()

                        for item in range(n):
                            tapered_preds[item] *= taper_rate ** item * taper_rate2

                        dict_tapers[f'{col}_{str(taper_rate)}_{str(taper_rate2)}'] = tapered_preds

        df_tapers = pd.DataFrame(dict_tapers)
        joined_df = pd.concat([df_tapers, input_df], axis=1)

        return joined_df


    lst_pred_files = []
    lst_pred_fnames = []
    for root, dirs, files in os.walk(f'./output/{str(run_date)}/'):
        for file in files:
            if file.endswith('_predictions.csv'):
                full_path = os.path.join(root, file)
                lst_pred_files.append(full_path)
                lst_pred_fnames.append(file)

    for file_stuff in list(zip(lst_pred_files, lst_pred_fnames)):
        df_grp = pd.read_csv(f'{file_stuff[0]}')
        grp = file_stuff[1].split('_initial_predictions.csv')[0]

        df_tapered_predictions = taper_preds(df_grp)
        df_tapered_predictions[df_tapered_predictions.columns[:-2]] = \
            df_tapered_predictions[df_tapered_predictions.columns[:-2]].clip(lower=0)
        print(f'Saving Tapered Predictions CSV for: {grp}')
        df_tapered_predictions.to_csv(f'./output/{str(run_date)}/{grp}/{grp}_tapers.csv', index=False)

        df_mape = pd.DataFrame({'MAPE': []})

        for tp in df_tapered_predictions.columns[:-2]:
            mape = round(mean_absolute_percentage_error(df_tapered_predictions['y'][:12],
                                                        df_tapered_predictions[tp][:12]),
                         6)
            df_mape.loc[tp] = [mape]

        df_mape.reset_index(inplace=True)
        df_mape.columns = ['Model', 'MAPE']
        df_mape.sort_values('MAPE', ascending=True, inplace=True)
        print(f'Saving MAPE CSV for: {grp}')
        df_mape.to_csv(f'./output/{str(run_date)}/{grp}/{grp}_performances.csv', index=False)

        lst_top_12_models = list(df_mape['Model'][:12])
        fig, ax = plt.subplots(figsize=(18, 12))
        ax.set_prop_cycle(color=cmap.colors)
        ax.plot(df_tapered_predictions['BILL_MONTH_DT'], df_tapered_predictions['y'],
                linewidth=4, label='Model_Test', color='black')
        for i in lst_top_12_models:
            ax.plot(df_tapered_predictions['BILL_MONTH_DT'], df_tapered_predictions[i],
                    linewidth=1.3, label=i)
        plt.xticks(rotation=90)
        plt.legend(fontsize=16)
        ax.set_title(f'Top Model Forecasts: {str(grp).upper()} ETH Wired Circuits', fontsize=20)
        ax.set_xlabel('Year-Month', fontsize=16)
        ax.set_ylabel('ETH Circuit Count', fontsize=16)
        print(f'Saving Results Plot for: {grp}')
        plt.savefig(f'./output/{str(run_date)}/{grp}/{grp}_plot_results.png', dpi=1200)
        plt.close()

        lst_top_50_models = list(df_mape['Model'][:50])
        df_interactive = df_tapered_predictions[lst_top_50_models + ['BILL_MONTH_DT'] + ['y']]
        fig = px.line(df_interactive,
                      x='BILL_MONTH_DT',
                      y=[list(df_interactive.drop('BILL_MONTH_DT',
                                                  axis=1).columns)[-1]] +
                        list(df_interactive.drop('BILL_MONTH_DT',
                                                 axis=1).columns)[:-1],
                      title=f'Top Model Forecasts: {str(grp).upper()} ETH Wired Circuits')
        fig.update_layout(legend_title_text='Model Name', title_font={"size": 20})
        fig.update_xaxes(title_text='Year-Month', title_font={"size": 16})
        fig.update_yaxes(title_text='ETH Circuit Count', title_font={"size": 16})
        fig['data'][0]['line']['width'] = 7
        fig['data'][0]['line']['color'] = 'black'
        fig.write_html(f'./output/{str(run_date)}/{grp}/{grp}_plot_results_interactive.html')
