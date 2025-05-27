import pandas as pd
import numpy as np
from common import state_to_region
import logging
import warnings
import json
from collections import deque
from load_data import *



def load_cleaned_data(product):
    """Load cleaned data for the given product"""

    # temporary file I was using from arlindo - leaving here in case we need in the future
    #return pd.read_csv(f"{product}/data/arlindo_files/TDM_CABS_cleaned_040324.csv")

    # for training data
    return pd.read_csv(f"{product}/data/cabs.csv")

def load_geotel_zoominfo(geotel_path, zoominfo_path):
    """Load Geotel and Zoominfo data"""

    geotel = pd.read_csv(geotel_path)
    zoom = pd.read_csv(zoominfo_path)

    return geotel, zoom


def churn(df, end_dt, n_months=6):
    """
    df: DataFrame
    n_months: number of months in advance we'd like to calculate churn

    returns: Series of 1s and 0s indicating churn"""

    # Calculate n_months after bill_month_dt
    df[f"{n_months}_MONTHS_AFTER_BILL_MONTH_DT"] = df["BILL_MONTH_DT"] + pd.DateOffset(
        months=n_months
    )

    # group by and get max bill month date - use this to get churn
    # check for multiple gaps (reconnects) - no jumps in service
        # in between min and max month - should be no missing months
        # ensure no gaps between min and max month

    # TODO: if they leave tdm, this counts as churn
    # maybe leave in place some way to track where TDM products went

    # Check if n_months_after_bill_month_dt is greater than or equal to LAST_BILL_MONTH_DT_FILL
    df[f"CHURN_{n_months}M_TEMP"] = (df[f"{n_months}_MONTHS_AFTER_BILL_MONTH_DT"] >= df["LAST_BILL_MONTH_DT_FILL"]).astype(int)
    # If n_months is in the future with no known data yet, we change the churn target to NaN
    # However, we only do this if there isn't already a known disconnect within the n_months range (cond1)
    cond1 = df[f"CHURN_{n_months}M_TEMP"] != 1
    cond2 = df["BILL_MONTH_DT"] > (pd.to_datetime(end_dt) - pd.DateOffset(months=n_months))
    churn_series = np.where( cond1 & cond2, np.NaN, df[f"CHURN_{n_months}M_TEMP"])

    return churn_series


def fill_last_bill_month(df, current_date):
    """Fill in the LAST_BILL_MONTH_DT column for records where it is missing.
    We expect LAST_BILL_MONTH_DT to always populate when churn occurs.
    As an edge case, we see records where we stop billing but do not have this field populated.
    We will fill this field in for those records."""


    dataframe = df.copy()

    current_date = pd.to_datetime(current_date)
    last_billed_month = pd.to_datetime(dataframe.groupby('CLEAN_ID')['BILL_MONTH_DT'].transform('max'))

    # identify records that should be last billing month
    is_last_billed = dataframe['BILL_MONTH_DT'] == last_billed_month

    # find records where:
    # 1) LAST_BILL_MONTH_DT is null
    # 2) BILL_MONTH_DT is the max BILL_MONTH_DT
    # 3) max BILL_MONTH_DT is not equal to our most recent billing date
    condition = (dataframe['LAST_BILL_MONTH_DT_FILL'].isnull()) & is_last_billed & (last_billed_month < current_date)

    """
    TODO: bug is occuring here
    we're getting records where last_bill_month_dt is null, so this doesn't end up working
    trying with last_bill_month_dt_fill instead
    """

    # save clean IDS where condition
    dataframe[condition]["CLEAN_ID"].to_csv("bad_ids_6-21-24_FILL.csv")

    # delete CLEAN_IDs where condition
    clean_ids_to_delete = dataframe[condition]['CLEAN_ID']
    dataframe = dataframe[~dataframe['CLEAN_ID'].isin(clean_ids_to_delete)]
    # TODO test this updated code
    
    return dataframe


def enforce_date_format(df):
    # ensure month columns have correct format
    df["FIRST_BILL_MONTH_DT"]    = pd.to_datetime(df["FIRST_BILL_MONTH_DT"], format="%Y-%m-%d")
    df["LAST_BILL_MONTH_DT"]     = pd.to_datetime(df["LAST_BILL_MONTH_DT"],  format="%Y-%m-%d")
    df["BILL_MONTH_DT"]          = pd.to_datetime(df["BILL_MONTH_DT"],       format="%Y-%m-%d")
    df["INSTALL_DT"]             = pd.to_datetime(df["INSTALL_DT"],          format="%Y-%m-%d", errors="coerce")
    df["TERM_START_DT"]          = pd.to_datetime(df["TERM_START_DT"],       format="%Y-%m-%d")
    df["TERM_END_DT"]            = pd.to_datetime(df["TERM_END_DT"],         format="%Y-%m-%d")

    return df

def mode(series):
    return series.mode()[0] if not series.mode().empty else None


def resolve_differing_install_dates(df):
    """Handles corner case where install dates are different for the same clean id"""

    # get records where min install dt does not match max install dt
    min_max_install_dates = df.groupby(["CLEAN_ID"]).agg(MIN_INSTALL_DATE = ("INSTALL_DT", "min"), MAX_INSTALL_DATE = ("INSTALL_DT", "max"), MODE_INSTALL_DATE=("INSTALL_DT", lambda x: mode(x)))
    min_max_install_dates["MIN_EQ_MAX"] = min_max_install_dates["MIN_INSTALL_DATE"] == min_max_install_dates["MAX_INSTALL_DATE"]

    # find records where MIN_EQ_MAX is false
    differing_install_dates = min_max_install_dates[min_max_install_dates["MIN_EQ_MAX"] == False].reset_index()

    # get the most common INSTALL_DT value for each clean id (only for differing install dates)
    differing_install_dates["INSTALL_DT_TEMP"] = differing_install_dates["CLEAN_ID"].map(min_max_install_dates["MODE_INSTALL_DATE"])

    # update the install date for the differing install dates
    df = df.merge(differing_install_dates[["CLEAN_ID", "INSTALL_DT_TEMP"]], on="CLEAN_ID", how="left")

    # update the install date
    df["INSTALL_DT"] = df["INSTALL_DT_TEMP"].combine_first(df["INSTALL_DT"])

    # drop the temp column
    df.drop(columns=["INSTALL_DT_TEMP"], inplace=True)

    return df


def clean_bill_month_dts(df):
    # create EARLIEST_BILL_MONTH_DT and LATEST_BILL_MONTH_DT
    # these will help us check that the billing months we interpolate are actually in the range of the customer's billing history
    df["EARLIEST_BILL_MONTH_DT"] = df.groupby(["CLEAN_ID"])["BILL_MONTH_DT"].transform(
        "min"
    )
    df["LATEST_BILL_MONTH_DT"] = df.groupby(["CLEAN_ID"])["BILL_MONTH_DT"].transform("max")

    # fill in LAST_BILL_MONTH_DT null values with the LAST_BILL_MONTH_DT of records with the same CLEAN_ID
    df["LAST_BILL_MONTH_DT_FILL"] = df.groupby(["CLEAN_ID"])[
        "LAST_BILL_MONTH_DT"
    ].transform("min")

    # do the same for FIRST_BILL_MONTH_DT
    df["FIRST_BILL_MONTH_DT_FILL"] = df.groupby(["CLEAN_ID"])[
        "FIRST_BILL_MONTH_DT"
    ].transform("min")

    # keep records where either (LAST_BILL_MONTH_DT_FILL >= BILL_MONTH_DT) OR (LAST_BILL_MONTH_DT_FILL == np.nan)
    df = df[
        (df["LAST_BILL_MONTH_DT_FILL"] >= df["BILL_MONTH_DT"])
        | (df["LAST_BILL_MONTH_DT_FILL"].isnull())
    ]
    logging.debug("FIRST, LAST BILL_MONTH_DT FILL columns created")

    return df


def convert_state_to_region(df):
    df["REGION"] = df["STATE"].map(state_to_region)
    return df

def accrued_mrc(df, n):
    """
    Calculate the total accrued revenue in the last n months for each CLEAN_ID.

    Args:
        df (pd.DataFrame): DataFrame containing CLEAN_ID, BILL_MONTH_DT, and TOTAL_MRC columns.
        n (int): Number of months for the rolling window.

    Returns:
        pd.DataFrame: DataFrame with an additional column for total accrued revenue over the last n months.
    """

    # Calculate rolling sum for 'TOTAL_MRC' within each 'CLEAN_ID'
    df[f"ACCRUED_REVENUE_LAST_{n}_MONTHS"] = df.groupby("CLEAN_ID")["TOTAL_MRC"].rolling(window=n, min_periods=1).sum().reset_index(level=0, drop=True)

    return df

def percent_diff_from_avg(df, n):
    """
    Calculate the percentage difference of each row's TOTAL_MRC from the average of the previous n months.

    Args:
        df (pd.DataFrame): DataFrame containing CLEAN_ID, BILL_MONTH_DT, and TOTAL_MRC columns.
        n (int): Number of months for the rolling window.

    Returns:
        pd.DataFrame: DataFrame with an additional column for the percentage difference from the average of the previous n months.
    """

    # Calculate rolling mean for 'TOTAL_MRC' within each 'CLEAN_ID'
    df[f"AVG_PREV_{n}_MONTHS"] = df.groupby("CLEAN_ID")["TOTAL_MRC"].transform(lambda x: x.shift(1).rolling(window=n, min_periods=1).mean())

    # Calculate the percentage difference
    df[f"PERC_DIFF_AVERAGE_OF_LAST_{n}_MONTHS"] = ((df["TOTAL_MRC"] - df[f"AVG_PREV_{n}_MONTHS"]) / df[f"AVG_PREV_{n}_MONTHS"]) * 100

    # drop first col
    df = df.drop(columns=[f"AVG_PREV_{n}_MONTHS"])

    # fill NA with 0
    df[f"PERC_DIFF_AVERAGE_OF_LAST_{n}_MONTHS"] = df[f"PERC_DIFF_AVERAGE_OF_LAST_{n}_MONTHS"].fillna(0)

    # fill np.inf with 0
    df[f"PERC_DIFF_AVERAGE_OF_LAST_{n}_MONTHS"] = df[f"PERC_DIFF_AVERAGE_OF_LAST_{n}_MONTHS"].replace([np.inf, -np.inf], 0)

    return df

def percent_diff_from_n_months_ago(df, n):
    """
    Calculate the percentage difference of each row's TOTAL_MRC from the TOTAL_MRC n months ago.

    Args:
        df (pd.DataFrame): DataFrame containing CLEAN_ID, BILL_MONTH_DT, and TOTAL_MRC columns.
        n (int): Number of months ago to compare.

    Returns:
        pd.DataFrame: DataFrame with an additional column for the percentage difference from TOTAL_MRC n months ago.
    """
    # Ensure the DataFrame is sorted by CLEAN_ID and BILL_MONTH_DT
    df = df.sort_values(by=["CLEAN_ID", "BILL_MONTH_DT"])

    # Get the TOTAL_MRC value from n months ago
    df[f"TOTAL_MRC_{n}_MONTHS_AGO"] = df.groupby("CLEAN_ID")["TOTAL_MRC"].shift(n)

    # Calculate the percentage difference
    df[f"PERC_DIFF_FROM_{n}_MONTHS_AGO"] = ((df["TOTAL_MRC"] - df[f"TOTAL_MRC_{n}_MONTHS_AGO"]) / df[f"TOTAL_MRC_{n}_MONTHS_AGO"]) * 100

    # Drop the temporary column used for calculation
    df = df.drop(columns=[f"TOTAL_MRC_{n}_MONTHS_AGO"])

    # Fill NA with 0 for the new percentage difference column
    df[f"PERC_DIFF_FROM_{n}_MONTHS_AGO"] = df[f"PERC_DIFF_FROM_{n}_MONTHS_AGO"].fillna(0)

    # fill inf with 0
    df[f"PERC_DIFF_FROM_{n}_MONTHS_AGO"] = df[f"PERC_DIFF_FROM_{n}_MONTHS_AGO"].replace([np.inf, -np.inf], 0)

    return df

def percent_increase_from_first(df):
    """
    Calculate the percentage increase from the first non-zero TOTAL_MRC for each CLEAN_ID.

    Args:
        df (pd.DataFrame): DataFrame containing CLEAN_ID, BILL_MONTH_DT, and TOTAL_MRC columns.

    Returns:
        pd.DataFrame: DataFrame with an additional column for the percentage increase from the first non-zero TOTAL_MRC.
    """

    # Define a function to get the first non-zero TOTAL_MRC
    def first_non_zero(series):
        return series.loc[series != 0].iloc[0] if (series != 0).any() else 0

    # Get the first non-zero TOTAL_MRC for each CLEAN_ID
    first_total_mrc = df.groupby("CLEAN_ID")["TOTAL_MRC"].transform(first_non_zero)

    # Calculate the percentage increase
    df["PERC_INCREASE_FROM_FIRST"] = ((df["TOTAL_MRC"] - first_total_mrc) / first_total_mrc) * 100

    # Replace inf values with NaN, then fill NaN with 0
    df["PERC_INCREASE_FROM_FIRST"].replace([float('inf'), float('-inf')], pd.NA, inplace=True)
    df["PERC_INCREASE_FROM_FIRST"].fillna(0, inplace=True)

    return df

def calculate_all_percent_diff_columns(df):
    """Calculate percent difference from average for 3, 6, 9, and 12 months
    Args:
        df: pd.DataFrame
    Returns:
        df: pd.DataFrame"""

    df = percent_increase_from_first(df)

    # caluculate percent difference from average for 3, 6, 9, 12 months
    df = percent_diff_from_avg(df, 3)
    df = percent_diff_from_avg(df, 6)
    df = percent_diff_from_avg(df, 9)
    df = percent_diff_from_avg(df, 12)

    # calculate percent difference from strictly 3, 6, 9, 12 months ago
    df = percent_diff_from_n_months_ago(df, 3)
    df = percent_diff_from_n_months_ago(df, 6)
    df = percent_diff_from_n_months_ago(df, 9)
    df = percent_diff_from_n_months_ago(df, 12)

    logging.debug("Calculated percent difference columns")

    return df



def calculate_all_accrued_revenue_columns(df):
    """Calculate accrued revenue for 3, 6, 9, and 12 months
    Args:
        df: pd.DataFrame
    Returns:
        df: pd.DataFrame"""

    df = accrued_mrc(df, 3)
    df = accrued_mrc(df, 6)
    df = accrued_mrc(df, 9)
    df = accrued_mrc(df, 12)

    return df

def create_top8_carriers(df):
    top_carriers = (
        df.groupby(["PRIMARY_CARRIER_NAME"])["TOTAL_MRC"].sum().sort_values(ascending=False)
        / df["TOTAL_MRC"].sum()
        * 100
    )

    top_carriers = (
    pd.DataFrame(top_carriers)
    .reset_index()
    .sort_values("TOTAL_MRC", ascending=False)
    .head(8)
)
    # list of top 8 characters
    top_carriers_list = top_carriers["PRIMARY_CARRIER_NAME"].tolist()

    df["TOP8"] = df["PRIMARY_CARRIER_NAME"].apply(
    lambda x: 1 if x in top_carriers_list else 0
    )

    # create CARRIER variable - shows PRIMARY_CARRIER_NAME only if TOP8 == 1
    df["CARRIER"] = df["PRIMARY_CARRIER_NAME"].apply(
        lambda x: x if x in top_carriers_list else "Other"
    )

    return df

def find_circuit_days_billed(row):
    # cannot use first bill month dt here - gives us nulls
    if row["EARLIEST_BILL_MONTH_DT"]:
        return (row["BILL_MONTH_DT"] - row["EARLIEST_BILL_MONTH_DT"]).days
    else:
        raise ValueError(
            "error with find_days_billed - FIRST_BILL_MONTH_DT or EARLIEST_BILL_MONTH_DT are not populated"
        )
        exit(1)


def find_circuit_days_since_install(row):
    if row["INSTALL_DT"]:
        days = (row["BILL_MONTH_DT"] - row["INSTALL_DT"]).days
        # bill month dt is always marked on the first of the month
        # install date is more specific
        # for our purposes - call this difference 0 because we don't know the exact billing day
        if days <= 0:
            return 0
        else:
            return days
    else:
        raise ValueError(
            "error with find_circuit_days_since_install - INSTALL_DT is not populated"
        )

def interaction_terms(df):

    # Ignore warning
    warnings.filterwarnings("ignore", message="DataFrame is highly fragmented.*")

    # find all feats with float dtype
    continuous_feats = df.select_dtypes(include=['float64']).columns
    print(continuous_feats)

    # take square, cube, and log base 10 of continuous features
    with np.errstate(divide='ignore'):
        for feat in continuous_feats:
            df[feat + "_squared"] = df[feat] ** 2
            df[feat + "_cubed"] = df[feat] ** 3
            df[feat + "_log10"] = np.log10(df[feat])

    # if any log10 result is -inf, change to 0
    df.replace([np.inf, -np.inf], 0, inplace=True)

    # create interaction terms for all continuous features

    for i in range(len(continuous_feats)):
        for j in range(i + 1, len(continuous_feats)):
            feat1 = continuous_feats[i]
            feat2 = continuous_feats[j]
            df[feat1 + "_" + feat2 + "_interaction"] = df[feat1] * df[feat2]

    return df


def dummy_vars(df):
    variables_to_dummy = [
    "SVC_GROUP",
    "PRODUCT",
    "REGION",
    "CARRIER",
    ]

    df = pd.get_dummies(df, columns=variables_to_dummy, drop_first=False)

    return df


def drop_columns(df, product):


    eth_drop = ["Unnamed: 0", "CLEAN_ID", "CMPY_NO", "CMPY_NO_COUNT", "STATE", "CIRCUIT_NO", "NC_PRODUCT_CD", "NCI", "ACNA", "JURIS_CD", "PRIMARY_CARRIER_NAME", "PLAN_ID", "WIRELESS", "ETHERNET_TYPE", "UNI_MBPS", "ADJ",
             "EVC_MBPS", "NNI", "FIRST_BILL_MONTH_DT", "LAST_BILL_MONTH_DT", "MILEAGE_MRC", "ADDR", "CUST", "IXC_NAME", "SWC", "INSTALL_DT", "DISCONNECT_DT", "TERM_START_DT", "TERM_END_DT", "SW_SPL_IND", "ROWNUM", "SWC8",
             "VTA_P", "VTA_C", "EVC_SPEED", "CIR", "M6_SPEED", "EVC_MBPS2", "UNI_MBPS2", "ORIG_END_DT", "NEW_END_DT", "EARLIEST_BILL_MONTH_DT", "LATEST_BILL_MONTH_DT", "LAST_BILL_MONTH_DT_FILL", "FIRST_BILL_MONTH_DT_FILL", "3_MONTHS_AFTER_BILL_MONTH_DT",
             "6_MONTHS_AFTER_BILL_MONTH_DT", "9_MONTHS_AFTER_BILL_MONTH_DT", "12_MONTHS_AFTER_BILL_MONTH_DT", "BILL_MONTH_DT", "PNUM"]

    # keeping clean id, bill_month_dt for more analysis
    tdm_drop = ["CMPY_NO", "CMPY_NO_COUNT", "CIRCUIT_NO","NC_PRODUCT_CD", "NCI", "ACNA", "JURIS_CD",
                "PLAN_ID", "ETHERNET_TYPE", "UNI_MBPS", "ADJ", "EVC_MBPS", "NNI", "LAST_BILL_MONTH_DT",
                "MILEAGE_MRC", "ADDR", "CUST", "IXC_NAME", "SWC", "DISCONNECT_DT", "TERM_START_DT", "TERM_END_DT", "SW_SPL_IND", "ROWNUM",
                "SWC8", "VTA_P", "VTA_C", "VTA", "EVC_SPEED", "CIR", "M6_SPEED", "EVC_MBPS2", "UNI_MBPS2", "EARLIEST_BILL_MONTH_DT", "LATEST_BILL_MONTH_DT",
                "FIRST_BILL_MONTH_DT", "FIRST_BILL_MONTH_DT_FILL", "3_MONTHS_AFTER_BILL_MONTH_DT", "6_MONTHS_AFTER_BILL_MONTH_DT", "9_MONTHS_AFTER_BILL_MONTH_DT",
                "12_MONTHS_AFTER_BILL_MONTH_DT", "1_MONTHS_AFTER_BILL_MONTH_DT", "FINAL_UNI_MBPS", "FINAL_EVC_MBPS", "SPD_GRP", "PRIMARY_CARRIER_NAME", "STATE", "WIRELINE"]

    

    if product == "ethernet":
        df.drop(columns=eth_drop, inplace=True)

    elif product == 'tdm':
        df.drop(columns=tdm_drop, inplace=True)

    logging.debug("Dropped columns for base df")

    return df



def feature_engineering(df):
    # convert state to region
    df = convert_state_to_region(df)

    # create accrued revenue columns
    df = calculate_all_accrued_revenue_columns(df)

    df = create_top8_carriers(df)
    
    df["CIRCUIT_DAYS_BILLED"] = df.apply(find_circuit_days_billed, axis=1)
    df["CIRCUIT_DAYS_SINCE_INSTALL"] = df.apply(find_circuit_days_since_install, axis=1)

    df["CIRCUIT_MO_BILLED"] = np.round(df["CIRCUIT_DAYS_BILLED"] / 30)
    df["CIRCUIT_MO_SINCE_INSTALL"] = np.round(df["CIRCUIT_DAYS_SINCE_INSTALL"] / 30)


    df = dummy_vars(df)

    # convert PNUM_NEW from true/false to 1/0
    #df["PNUM_NEW"] = df["PNUM_NEW"].astype(int)

    # add in average MRC
    df["AVG_MRC"] = df.groupby("CLEAN_ID").TOTAL_MRC.transform("mean")


    logging.debug("Feature engineering finished")

    return df


def frame_target(df, end_dt):
    # format date
    df = enforce_date_format(df)
    print(f"length after enforce date format: {len(df)}")

    # fix differing install dates
    df = resolve_differing_install_dates(df)
    print(f"length after resolve differing install dates: {len(df)}")

    # clean bill month dts
    df = clean_bill_month_dts(df)
    print(f"length after clean bill month dts: {len(df)}")

    # apply churn - we want to predict 3, 6, 9, 12 months
    df["CHURN_1M"]  = churn(df,  end_dt, n_months=1)
    df["CHURN_3M"]  = churn(df,  end_dt, n_months=3)
    df["CHURN_6M"]  = churn(df,  end_dt, n_months=6)
    df["CHURN_9M"]  = churn(df,  end_dt, n_months=9)
    df["CHURN_12M"] = churn(df,  end_dt, n_months=12)
    logging.debug("Churn for 3, 6, 9, 12 months successfully applied")
    print(f"length after churn: {len(df)}")

    return df


def mrc_increase(df, n_months=1):
    """
    Detects whether MRC increase has occurred in past n months (0 or 1)
    Args:
        n_months: int
    Returns:
        df: pd.DataFrame
    """

    df[f"PREV_MRC{n_months}"] = df.groupby("CLEAN_ID")["TOTAL_MRC"].diff(periods=n_months)

    # For the first month, set MRC_INCREASE to 0 as there's nothing to compare to
    df[f'MRC_INCREASE_{n_months}_MONTHS'] = 0
    
    # Check if there was any increase within the past n_months
    for i in range(1, n_months):
        df[f'MRC_INCREASE_{n_months}_MONTHS'] = np.where(
            df.groupby("CLEAN_ID")["TOTAL_MRC"].shift(i) < df["TOTAL_MRC"], 1, df[f'MRC_INCREASE_{n_months}_MONTHS']
        )

    # For subsequent months, use the regular comparison
    df[f'MRC_INCREASE_{n_months}_MONTHS'] = np.where(
        df[f'PREV_MRC{n_months}'].isnull(), 
        df[f'MRC_INCREASE_{n_months}_MONTHS'], 
        np.where(df[f'PREV_MRC{n_months}'] > 0, 1, 0)
    )

    return df


def price_increase_cols(df):
    """Apply mrc_increase function to detect price increases across time
    Args:
        df: pd.DataFrame
    Returns:
        df: pd.DataFrame"""
    df = df.sort_values(by=['CLEAN_ID', 'BILL_MONTH_DT'], ascending=True)

    # detect price increases across time
    df = mrc_increase(df, 3)
    df = mrc_increase(df, 6)
    df = mrc_increase(df, 9)
    df = mrc_increase(df, 12)

    # drop shifted columns
    columns_to_drop = df.filter(regex=r'^PREV_MRC', axis=1).columns
    df.drop(columns=columns_to_drop, inplace=True)

    logging.debug("Price increase columns created")

    return df


def calculate_months_since_last_price_hike(df):
    """
    Calculate the number of months since the last price hike for each CLEAN_ID.

    Args:
        df (pd.DataFrame): DataFrame sorted by BILL_MONTH_DT and containing TOTAL_MRC and CLEAN_ID columns.

    Returns:
        pd.Series: Series indicating the number of months since the last price hike for each row.
    """
    months_since_hike = {}
    
    def months_since_hike_func(row):
        clean_id = row['CLEAN_ID']
        if clean_id not in months_since_hike:
            # Initialize the first occurrence of the CLEAN_ID
            months_since_hike[clean_id] = {'last_price': row['TOTAL_MRC'], 'months': 0}
            return 0
        else:
            # Check if the current MRC is greater than the last recorded price for this CLEAN_ID
            if row['TOTAL_MRC'] > months_since_hike[clean_id]['last_price']:
                # Reset the month count and update the last price
                months_since_hike[clean_id]['months'] = 0
                months_since_hike[clean_id]['last_price'] = row['TOTAL_MRC']
            else:
                # Increment the month count if the price hasn't increased
                months_since_hike[clean_id]['months'] += 1
                months_since_hike[clean_id]['last_price'] = row['TOTAL_MRC']
            return months_since_hike[clean_id]['months']

    # Apply the function to each row and return the result as a new column
    return df.apply(months_since_hike_func, axis=1)


def calculate_price_hikes_lifetime(df):
    """
    Calculate the total number of price hikes a circuit has experienced across its lifetime.

    Args:
        df (pd.DataFrame): DataFrame sorted by BILL_MONTH_DT and containing TOTAL_MRC and CLEAN_ID columns.

    Returns:
        pd.Series: Series indicating the total number of price hikes a circuit has experienced across its lifetime.
    """
    price_hikes = {}

    def price_hikes_func(row):
        clean_id = row['CLEAN_ID']
        if clean_id not in price_hikes:
            # Initialize the first occurrence of the circuit
            price_hikes[clean_id] = {'index': row.name, 'count': 0}
            return 0
        else:
            # Check if the current MRC is greater than the previous MRC for this circuit
            if row['TOTAL_MRC'] > df.at[price_hikes[clean_id]['index'], 'TOTAL_MRC']:
                # Increment the price hike count and update the index
                price_hikes[clean_id]['count'] += 1
                price_hikes[clean_id]['index'] = row.name
            return price_hikes[clean_id]['count']

    # Apply the function to each row and return the result as a new column
    return df.apply(price_hikes_func, axis=1)

def calculate_price_hikes_last_n_months(df, n):
    """
    Calculate the number of price hikes a circuit has experienced in the last n months,
    considering only the last 12 records for each CLEAN_ID.

    Args:
        df (pd.DataFrame): DataFrame sorted by BILL_MONTH_DT and containing TOTAL_MRC and CLEAN_ID columns.
        n (int): Number of months to consider for calculating the price hikes.

    Returns:
        pd.Series: Series indicating the number of price hikes a circuit has experienced in the last n months.
    """
    # Ensure BILL_MONTH_DT is in datetime format
    df['BILL_MONTH_DT'] = pd.to_datetime(df['BILL_MONTH_DT'])

    price_hikes = {}
    last_12_records = {}

    def price_hikes_func(row):
        clean_id = row['CLEAN_ID']
        current_date = row['BILL_MONTH_DT']
        current_mrc = row['TOTAL_MRC']
        
        if clean_id not in last_12_records:
            last_12_records[clean_id] = deque(maxlen=12)
            price_hikes[clean_id] = {'count': 0}
        
        # Track the previous MRC before adding the new record
        if last_12_records[clean_id]:
            prev_mrc = last_12_records[clean_id][-1][1]
        else:
            prev_mrc = None
        
        # Add the current record to the deque
        last_12_records[clean_id].append((current_date, current_mrc))
        
        # Calculate the number of price hikes in the last n months
        recent_hikes = 0
        for i, (record_date, record_mrc) in enumerate(last_12_records[clean_id]):
            if (current_date - record_date).days <= n * 30:
                if i > 0 and record_mrc > last_12_records[clean_id][i - 1][1]:
                    recent_hikes += 1
        
        return recent_hikes

    return df.apply(price_hikes_func, axis=1)


def calculate_all_price_hikes(df):
    """Calculate price hikes in last 3/6/9/12 months, plus lifetime
    Args:
        df: pd.DataFrame
    Returns:
        df: pd.DataFrame"""

    df["PRICE_HIKES_LIFETIME"] = calculate_price_hikes_lifetime(df)
    df["PRICE_HIKES_LAST_3_MONTHS"] = calculate_price_hikes_last_n_months(df, 3)
    df["PRICE_HIKES_LAST_6_MONTHS"] = calculate_price_hikes_last_n_months(df, 6)
    df["PRICE_HIKES_LAST_9_MONTHS"] = calculate_price_hikes_last_n_months(df, 9)
    df["PRICE_HIKES_LAST_12_MONTHS"] = calculate_price_hikes_last_n_months(df, 12)

    logging.debug("Calculated price hikes in last 3/6/9/12 months, plus lifetime")

    return df

def calculate_mrc_change_lifetime(df):
    """
    Calculate the total MRC change a circuit has experienced across its lifetime.

    Args:
        df (pd.DataFrame): DataFrame sorted by BILL_MONTH_DT and containing TOTAL_MRC and CLEAN_ID columns.

    Returns:
        pd.Series: Series indicating the total MRC change (including decreases) a circuit has experienced across its lifetime.
    """
    mrc_changes = {}

    def mrc_change_func(row):
        clean_id = row['CLEAN_ID']
        current_mrc = row['TOTAL_MRC']
        
        if clean_id not in mrc_changes:
            # Initialize the first occurrence of the circuit
            mrc_changes[clean_id] = {'index': row.name, 'total_change': 0, 'last_mrc': current_mrc}
            return 0
        else:
            previous_mrc = mrc_changes[clean_id]['last_mrc']
            # Calculate the change and update the total change
            change = current_mrc - previous_mrc
            mrc_changes[clean_id]['total_change'] += change
            
            # Update the last MRC regardless of whether there was an increase or decrease
            mrc_changes[clean_id]['last_mrc'] = current_mrc
            
            return mrc_changes[clean_id]['total_change']

    # Apply the function to each row and return the result as a new column
    return df.apply(mrc_change_func, axis=1)
    


def calculate_mrc_change_last_n_months(df, n):
    """
    Calculate the total change in MRC a circuit has experienced in the last n months.

    Args:
        df (pd.DataFrame): DataFrame sorted by BILL_MONTH_DT and containing TOTAL_MRC and CLEAN_ID columns.
        n (int): Number of months to consider for calculating the MRC change.

    Returns:
        pd.Series: Series indicating the total MRC change a circuit has experienced in the last n months.
    """

    n = n + 1 # exclude the current month

    mrc_changes = {}
    last_n_records = {}

    def mrc_change_func(row):
        clean_id = row['CLEAN_ID']
        current_date = row['BILL_MONTH_DT']
        current_mrc = row['TOTAL_MRC']
        
        if clean_id not in last_n_records:
            last_n_records[clean_id] = deque(maxlen=n)
            mrc_changes[clean_id] = {'change': 0}
        
        # Track the previous MRC before adding the new record
        if last_n_records[clean_id]:
            prev_mrc = last_n_records[clean_id][-1][1]
        else:
            prev_mrc = None
        
        # Add the current record to the deque
        last_n_records[clean_id].append((current_date, current_mrc))
        
        # Calculate the total MRC change in the last n months
        if len(last_n_records[clean_id]) == n:
            first_record_date, first_record_mrc = last_n_records[clean_id][0]
            change = current_mrc - first_record_mrc
        else:
            change = 0  # If there are not enough records, set change to 0
        
        return change

    return df.apply(mrc_change_func, axis=1)

def calculate_all_mrc_changes(df):
    """Calculate MRC changes in last 3/6/9/12 months, plus lifetime
    Args:
        df: pd.DataFrame
    Returns:
        df: pd.DataFrame"""

    df['MRC_CHANGE_LIFETIME'] = calculate_mrc_change_lifetime(df)
    df["MRC_CHANGE_LAST_3_MONTHS"] = calculate_mrc_change_last_n_months(df, 3)
    df["MRC_CHANGE_LAST_6_MONTHS"] = calculate_mrc_change_last_n_months(df, 6)
    df["MRC_CHANGE_LAST_9_MONTHS"] = calculate_mrc_change_last_n_months(df, 9)
    df["MRC_CHANGE_LAST_12_MONTHS"] = calculate_mrc_change_last_n_months(df, 12)

    logging.debug("Calculated MRC changes in last 3/6/9/12 months, plus lifetime")

    return df




def drop_interactions(df):
    # separate df that drops anything with "interaction" or "squared" or "cubed" or "log10" in the column name
    df_base = df[
        [
            col
            for col in df.columns
            if ("interaction" not in col)
            and ("squared" not in col)
            and ("cubed" not in col)
            and ("log10" not in col)
        ]
    ]

    return df_base

def geotel_dummies(geotel):
    dummies = ['GeoLevel', 'COMP_LIT']

    dummy_cols = pd.get_dummies(geotel[dummies]
               ).drop(columns='GeoLevel_Not Coded'
                ).replace({True: 1, False: 0})
    
    geo_new = geotel.join(dummy_cols).drop(columns = dummies).drop(columns=['index'])

    return geo_new

def clean_geotel(geotel):
    distcols = ['Closest_Feet', 'ALTICE', 'AT&T', 'BLUEBIRD NETWORK',
       'CITYNET', 'COGENT COMMUNICATIONS', 'COMCAST',
       'CONSOLIDATED COMMUNICATIONS', 'COX COMMUNICATIONS', 'CROWN CASTLE',
       'EVERSTREAM', 'FIBERLIGHT', 'FIRSTLIGHT', 'GRANDE COMMUNICATIONS',
       'LUMEN', 'SEGRA', 'SHENTEL FIBER', 'SPECTRUM', 'SUDDENLINK',
       'SYRINGA NETWORKS', 'UNITI FIBER', 'VERIZON', 'WINDSTREAM', 'ZAYO']
    

    geotel[distcols] = geotel[distcols].fillna(10000)

    # Create a new list of modified column names for columns except the last one
    new_column_names = (geotel.columns[10:-1].str.replace(' ', '_') + '_DIST').to_list()

    # Assign the new list of column names back to the DataFrame
    geotel.columns = list(geotel.columns[:10]) + new_column_names + [geotel.columns[-1]]

    # TODO: see if we can get a feature out of this - may be redundant
    geotel.drop(columns='Closest_Carrier', inplace=True)

    geotel = geotel_dummies(geotel)


    return geotel


def clean_zoominfo(zoom):
    """Clean Zoominfo data"""
    toDummy = ['ADDR_SOURCE', 'FINAL_FLAG', 'FINAL_FLAG_CONF', 'GeoLevel', 'DPI_Addrtype', 
           'Segment_Nm', 'ZI_C_IS_SMALL_BUSINESS']
    TrueFalseto10 = ['LEGAL', 'FINANCE', 'OTHER', 'MEDICAL', 'RETAIL', 'REAL_ESTATE', 
                    'MANUFACT','FOOD', 'TECH', 'EDU', 'ARTS', 'TRANSPORT', 'CONSTRUCT', 'GOV',
                    'TELECOM', 'UTILITIES', 'MEDIA', 'HOTEL', 'AUTO', 'PHARMA','BB_Cap_Ind', 
                    'VOIP_Cap']
    drop = ['index', 'REF_ID', 'FINAL_NAME', 'CASS_Address', 'CASS_City', 'CASS_State', 'CASS_ZIP', 'ZI_C_EMPLOYEE_RANGE',
            'ZI_C_REVENUE_RANGE', 'CASS_Results_Ind', 'Lat', 'Lon', 'ZI_C_NAME_DISPLAY', 'ADDR_SOURCE', 
            'FINAL_FLAG', 'FINAL_FLAG_CONF', 'GeoLevel', 'DPI_Addrtype', 
            'Segment_Nm', 'ZI_C_IS_SMALL_BUSINESS', 'FTR_Industry']
    rename_TFto10 = ['Current_Network', 'BUS_MATCH']

    zoom[TrueFalseto10] = zoom[TrueFalseto10].replace({True: 1, False: 0,'Y': 1, 'N': 0})
    zoom['ZI_C_IS_SMALL_BUSINESS'] = zoom['ZI_C_IS_SMALL_BUSINESS'].map({1: 'TRUE', 0: 'FALSE'})

    zoom[rename_TFto10] = zoom[rename_TFto10].replace(
    {'Fiber': 1, 'EXACT': 1,'Copper': 0, 'MULTI': 0}).rename(
        {'Current_Network':'Current_Network_is_Fiber', 'BUS_MATCH':'BUS_MATCH_EXACT'})
    
    dummiez = pd.get_dummies(zoom[toDummy]
                      ).drop(columns=['ADDR_SOURCE_UNAVAILABLE', 'GeoLevel_Not Coded']
                             ).replace({True: 1, False: 0})
    
    zoom_new = zoom.join(dummiez).drop(columns=drop)

    return zoom_new

def merge_clean_cabs_geotel_zoominfo(df, geotel, zoom):
    """Merge CABS, Geotel, and Zoominfo data"""
    all_cabs = df.merge(geotel, on='CLEAN_ID', how='left').merge(zoom, on='CLEAN_ID', how='left')

    # drop cols with _y
    for col in all_cabs.columns:
        if "_y" in col:
            # remove col
            all_cabs.drop(columns=col, inplace=True)

    # for any col with _x, remove _x
    for col in all_cabs.columns:
        if "_x" in col:
            # replace with an empty string
            new_col = col.replace("_x", "")
            all_cabs.rename(columns={col: new_col}, inplace=True)


    return all_cabs

def merge_clean_urban_rural(cabs, urbanrural):
    cabs = cabs.merge(urbanrural[["CLEAN_ID", "URBAN_FLAG"]], on='CLEAN_ID', how='left')
    cabs["URBAN_FLAG"] = cabs["URBAN_FLAG"].apply(lambda x: 1 if x == "Urban" else 0)
    return cabs

def drop_bad_circuit_ids(df):
    """A small number of circuits have INSTALL_DTs after a circuit is already billing. This function removes those CLEAN IDs"""
    bad_circuit_ids = df[(df["CIRCUIT_DAYS_SINCE_INSTALL"] == 0) & (df["INSTALL_DT"].dt.month != df["FIRST_BILL_MONTH_DT"].dt.month)].CLEAN_ID.unique()
    logging.debug(f"found {len(bad_circuit_ids)} bad circuit ids based on install date")

    df = df[~df["CLEAN_ID"].isin(bad_circuit_ids)]

def aggregate_to_one_clean_id_per_row(df, n):
    """
    Filter the DataFrame to keep the latest BILL_MONTH_DT for each CLEAN_ID where CHURN_{n}M is not null.

    Args:
        df (pd.DataFrame): DataFrame containing CLEAN_ID, BILL_MONTH_DT, and CHURN_{n}M columns.
        n (int): Number of months for the CHURN column.

    Returns:
        pd.DataFrame: Filtered DataFrame.
    """
    churn_col = f"CHURN_{n}M"
    
    # Filter out rows where CHURN_{n}M is null
    df_filtered = df[df[churn_col].notnull()]

    # Sort the DataFrame by BILL_MONTH_DT in descending order
    df_filtered = df_filtered.sort_values(by='BILL_MONTH_DT', ascending=False)

    # Drop duplicates based on CLEAN_ID, keeping the first occurrence (which will be the latest due to sorting)
    df_deduped = df_filtered.drop_duplicates(subset='CLEAN_ID', keep='first')

    # drop any columns with CHURN in them that are not CHURN_{n}M
    df_deduped = df_deduped.drop(df_deduped.filter(regex='CHURN').columns.difference([churn_col]), axis=1)

    logging.debug(f"Aggregated to one CLEAN_ID per row for {n} months")

    return df_deduped

def export_final_results(df, product):
    """Runs aggregation function and exports results to csv
    Args:
        df (pd.DataFrame): DataFrame containing CLEAN_ID, BILL_MONTH_DT, and CHURN_{n}M columns.
    """
    # we want one export for 3, 6, 9, and 12M targets
    # null values will cause final aggregated dates to be different for all of these
    aggregate_to_one_clean_id_per_row(df, 1).to_csv(f"{product}/data/aggregated_churn_datasets/churn_dataset_1m.csv", index=False)
    aggregate_to_one_clean_id_per_row(df, 3).to_csv(f"{product}/data/aggregated_churn_datasets/churn_dataset_3m.csv", index=False)
    aggregate_to_one_clean_id_per_row(df, 6).to_csv(f"{product}/data/aggregated_churn_datasets/churn_dataset_6m.csv", index=False)
    aggregate_to_one_clean_id_per_row(df, 9).to_csv(f"{product}/data/aggregated_churn_datasets/churn_dataset_9m.csv", index=False)
    aggregate_to_one_clean_id_per_row(df, 12).to_csv(f"{product}/data/aggregated_churn_datasets/churn_dataset_12m.csv", index=False)

    logging.debug("Exported final results to csv")


def main():
    logging.basicConfig(level=logging.DEBUG)

    end_dt = pd.to_datetime("2024-03-01")
    product = 'tdm' # may change to user input

    df = load_cleaned_data(product=product)
    logging.debug(f"shape of cabs after load: {df.shape}")

    # final drop duplicates
    df = df.drop_duplicates()


    # end_dt is inclusive
    df = frame_target(df, end_dt=end_dt)
    # TODO: test that end_dt is same across preprocess and frame_target

    # fill incorrect last bill month dts before churn calculation
    # moved this after frame_target
    df = fill_last_bill_month(df, end_dt)

    df = feature_engineering(df)

    # add price increase detection cols
    df = price_increase_cols(df)

    # get months since last price hike, add to df
    df["MONTHS_SINCE_LAST_PRICE_HIKE"] = calculate_months_since_last_price_hike(df)

    # get num prices hikes last 12 months
    df = calculate_all_price_hikes(df)

    # calculate all mrc increase
    df = calculate_all_mrc_changes(df)

    # calculate percent difference columns
    df = calculate_all_percent_diff_columns(df)

    # fillna with 0 for MRC INCREASE columns - some are calculated as nulls if there are no price increases
    mrc_increase_cols = [col for col in df.columns if "MRC_INCREASE_" in col]
    df[mrc_increase_cols] = df[mrc_increase_cols].fillna(0)

    # load in geotel and zoominfo data
    # open config file
    with open('config.json', 'r') as f:
        config = json.load(f)

    # TODO: generalize file paths to work with tdm or eth
    # eth probably won't have geotel/zoominfo for a while - could ignore for now
    # still need to test for segfault
    geotel, zoom = load_geotel_zoominfo(config.get("Geotel"), config.get("Zoominfo"))

    # load in urbanrural
    urbanrural = load_urban_rural(config)

    # geotel clean
    geotel = clean_geotel(geotel)

    # zoominfo clean
    zoom = clean_zoominfo(zoom)

    # merge and clean extraneous columns
    # also drops nulls on Lat
    df = merge_clean_cabs_geotel_zoominfo(df, geotel, zoom)

    # merge and clean urban/rural
    df = merge_clean_urban_rural(df, urbanrural)

    # dropna on lat
    df = df[df['Lat'].notna()].drop(columns=['Unnamed: 0'])

    # drop columns we dont need for model
    df = drop_columns(df, product)

    # get interactions
    #df = interaction_terms(df)

    # separate df for no interaction terms
    df_base = drop_interactions(df)

    logging.debug("Saving files to csv")
    export_final_results(df, product)

    df_base.to_csv(f"{product}/data/aggregated_churn_datasets/churn_dataset_2020_to_2024.csv", index=False)
    

    logging.debug("Save complete - files ready for feature selection + model selection steps.")


if __name__ == '__main__':
    main()


# tests to add
# CHURN - if we add a new target, it should match up with 1) adding a new file name, 2) should show up in multiple functions


# other ideas
# taking only the first disconnect and filtering out reconnect could further intensify the problem of getting mainly churn=1 records
    # if we want to add back more churn=0 records, we should look into factoring in the reconnect/disconnect

# TODO: refactor, get new feature engineering functions into correct feature_engineering() function