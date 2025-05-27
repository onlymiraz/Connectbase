from load_data import *
import argparse

# function to see if primary carrier name is the same as previous month for each clean ID
def check_carrier_previous_month(cabs):
    """Create new column to denote if PRIMARY_CARRIER_NAME is the same in previous month.
    If yes, value is 1.
    If no, value is 0."""

    logging.debug("Checking if carrier is the same as previous month")
    
    # Sort by CLEAN_ID and BILL_MONTH_DT to ensure correct chronological order
    cabs = cabs.sort_values(by=["CLEAN_ID", "BILL_MONTH_DT"])
    
    # Group by CLEAN_ID and shift to check if PRIMARY_CARRIER_NAME is the same as previous month
    # check if PRIMARY_CARRIER_NAME is the same as in any row in the previous month for the same clean ID
    cabs["CARRIER_LAST_MO_SAME"] = (cabs["PRIMARY_CARRIER_NAME"] == cabs.groupby("CLEAN_ID")["PRIMARY_CARRIER_NAME"].shift())
    cabs["CARRIER_LAST_MO_SAME"] = cabs["CARRIER_LAST_MO_SAME"].astype(int)
    
    # For each CLEAN_ID, initialize the first occurrence to 1
    first_occurrence_mask = cabs["CLEAN_ID"] != cabs["CLEAN_ID"].shift()
    cabs.loc[first_occurrence_mask, "CARRIER_LAST_MO_SAME"] = 1
    
    # Exporting for testing (optional)
    cabs.to_csv("cabs_after_previous_mo_calculation.csv", index=False)

    return cabs




def get_dnr_and_shift_ids(product_df):
    """Handle instances where a circuit disconnects and reconnects, or there is a product shift."""

    logging.debug("Handling DNR and shift IDs finished")

    # TODO test for ethernet generalizability
    # The following happens when there is some sort of product shift, or SQL last bill month not working
    # TODO theres some more lines of code in the notebook - these are sanity checks we can use for test cases
    shift_ids = product_df[ (product_df["STATUS"] != "DC") & (product_df["STATUS2"] == "DC")]["CLEAN_ID"].unique()

    # The following happens when a circuit disconnect and reconnects, i.e DNR
    dnr_ids = product_df[ (product_df["STATUS"] == "DC") & (product_df["STATUS2"] != "DC")]["CLEAN_ID"].unique()

    # Filtering out these edge cases from our training set
    filtered_product_df = product_df[~(product_df["CLEAN_ID"].isin(shift_ids)) & ~(product_df["CLEAN_ID"].isin(dnr_ids))]\
    [['CLEAN_ID', 'BILL_MONTH_DT', 'FIRST_BILL_MONTH_DT', 'LAST_BILL_MONTH_DT', 'CMPY_NO_COUNT', 'STATE', 'TOTAL_MRC', 
    'PRIMARY_CARRIER_NAME', 'PLAN_ID', 'WIRELESS', 'SVC_GROUP', 'PRODUCT', 'SWC8',
    'INSTALL_DT', 'DISCONNECT_DT', 'TERM_START_DT', 'TERM_END_DT', 'ORIG_END_DT',
    'PNUM', 'MO_LEFT', 'SEM_LEFT', 'STATUS', 'CARRIER_LAST_MO_SAME']].copy()

    return filtered_product_df


def filter_dates(cabs, start_dt, end_dt):
    """Filter CABs data to appropriate dates.
    Args:
        cabs: pandas.DataFrame
        start_dt: str, start date, inclusive
        end_dt: str, end date, inclusive
    Returns:
        cabs: pandas.DataFrame"""

    return cabs[(cabs["BILL_MONTH_DT"] >= start_dt) & (cabs["BILL_MONTH_DT"] <= end_dt)]

def drop_att(cabs):
    """Drop AT&T records.
    We do this because a lot of AT&T's features are irrelevant.
    For example - we will see a lot of price hikes, but they are reimbursed at the end of the year.
    A lot of their features and targets will not be correct.
    args:
        cabs: pandas.DataFrame
    Returns:
        cabs: pandas.DataFrame"""
    
    cabs = cabs[cabs["PRIMARY_CARRIER_NAME"] != "AT&T"]
    return cabs

def create_paths_if_not_exist():
    """Create paths if they do not exist.
    Args:
        paths: list of str, list of paths to create"""
    logging.debug("Checking for correct output paths")

    if not os.path.exists("tdm/data"):
        os.makedirs("tdm/data")
    
    if not os.path.exists("ethernet/data"):
        os.makedirs("ethernet/data")

def handle_args():
    """Handle command line arguments.
    Returns:
        args: argparse.Namespace"""
    parser = argparse.ArgumentParser(description="Preprocess ML data.")
    parser.add_argument("--start_dt", type=str, help="Start date")
    parser.add_argument("--end_dt", type=str, help="End date")
    parser.add_argument("--config", type=str, help="Path to config file")

    # check length of sys.argv
    if len(sys.argv) != 4:
        parser.print_help(sys.stderr)
        sys.exit(1)
    return parser.parse_args()


def create_status_variable(cabs):
    """Create STATUS variable, denoting if a circuit is ACTIVE or DC in a given month.
    Args:
        cabs: pandas.DataFrame
    Returns:
        cabs: pandas.DataFrame"""
    
    logging.debug("Creating status variable")

    # DC if LAST_BILL_MONTH_DT is null
    # ACTIVE if LAST_BILL_MONTH_DT is populated
    cabs["STATUS"] = np.where(~cabs["LAST_BILL_MONTH_DT"].isnull(), "DC", "ACTIVE" )

    return cabs


def change_top_names(cabs):
    """Change top9 carrier names to more generalized versions.
    Args:
        cabs: pandas.DataFrame
    Returns:
        cabs: pandas.DataFrame"""
    
    logging.debug("Changing top carrier names")
    
    cabs["PRIMARY_CARRIER_NAME"] = cabs["PRIMARY_CARRIER_NAME"].replace("TPX COMMUNICATIONS", "TPX")
    cabs["PRIMARY_CARRIER_NAME"] = cabs["PRIMARY_CARRIER_NAME"].replace("NITEL, INC", "NITEL")
    cabs["PRIMARY_CARRIER_NAME"] = cabs["PRIMARY_CARRIER_NAME"].replace("SPRINT COMMUNICATIONS COMPANY LP", "SPRINT")
    cabs["PRIMARY_CARRIER_NAME"] = cabs["PRIMARY_CARRIER_NAME"].replace("GRANITE TELECOMMUNICATIONS", "GRANITE")
    cabs["PRIMARY_CARRIER_NAME"] = cabs["PRIMARY_CARRIER_NAME"].replace("GTT COMMUNICATIONS", "GTT")
    cabs["PRIMARY_CARRIER_NAME"] = cabs["PRIMARY_CARRIER_NAME"].replace("CENTURYLINK", "LUMEN")
    cabs["PRIMARY_CARRIER_NAME"] = cabs["PRIMARY_CARRIER_NAME"].replace("AT&T MOBILITY", "AT&T")


    return cabs

def get_vta(cabs):
    """Get VTA variable using PLAN_ID in CABs.
    Args:
        cabs: pandas.DataFrame
    Returns:
        cabs: pandas.DataFrame"""
    
    logging.debug("Getting VTA variable")

    # Calculate VTA variables using above function
    cabs["VTA_P"] = cabs["PLAN_ID"].apply(planidvta)

    # Calculated VTA
    cabs["VTA_C"] = cabs["TERM_END_DT"] - cabs["TERM_START_DT"]
    cabs["VTA"] = np.round(cabs["VTA_C"].dt.days / 365.25, 1) * 12
    cabs["VTA"] = np.where(cabs["VTA"] < 12, cabs["VTA_P"], cabs["VTA"])

    # Filling null vta with PLAN_ID vta
    cabs["VTA"] = cabs["VTA"].fillna(cabs["VTA_P"]).fillna(36)

    # Verifying that VTA only taking allowed values (multiples of 12)
    vta_df = cabs.groupby(["VTA"]).size().to_frame("COUNT").reset_index()
    vta_df["VTA_ADJ"]  = 12 * np.round(vta_df["VTA"] / 12, 0)
    vta_df["VTA_DIFF"] = np.round(np.abs(vta_df["VTA_ADJ"] - vta_df["VTA"]), 1) 

    ### Arlindo incorporated this
    # Map invalid VTAs to nearest multiple of 12
    cabs = pd.merge(cabs, vta_df[["VTA", "VTA_ADJ"]], on=["VTA"], how='left')
    # Overwrite existing VTA column
    # Make sure whole number
    cabs["VTA"] = np.round(cabs["VTA_ADJ"], 0)

    return cabs

def get_orig_end_dt_and_pnum(cabs):
    """Get the original end date and pnum for each circuit.
    Args:
        cabs: pandas.DataFrame
    Returns:
        cabs: pandas.DataFrame
    """

    logging.debug("Getting original end date and pnum")

    # Vectorized code edition of adding VTA months to a given date
    # Code adds VTA to update years-month first, then brings back in the day portion 
    # -1 is needed because converting from year-month back to year-month-day adds in one day
    # e.g. 2018-05 -> 2018-05-01
    cabs['ORIG_END_DT'] = \
    (cabs["INSTALL_DT"].values.astype('M8[M]') + cabs["VTA"].values * np.timedelta64(1, 'M')).astype('M8[D]') +\
    (cabs["INSTALL_DT"].dt.day.values - 1) * np.timedelta64(1, 'D')

    # Vectorized code edition of adding VTA months to a given date
    # Code adds VTA to update years-month first, then brings back in the day portion 
    # -1 is needed because converting from year-month back to year-month-day adds in one day
    # e.g. 2018-05 -> 2018-05-01
    cabs['ORIG_END_DT'] = \
    (cabs["INSTALL_DT"].values.astype('M8[M]') + cabs["VTA"].values * np.timedelta64(1, 'M')).astype('M8[D]') +\
    (cabs["INSTALL_DT"].dt.day.values - 1) * np.timedelta64(1, 'D')


    cabs["PNUM"] = cabs["PLAN_ID"].apply(lambda x: x.split("-")[0] if type(x) == str else np.nan)
    # Adding na=false here, otherwise null PNUMs was showing as true
    cabs["PNUM_NEW"] = np.where(cabs["PNUM"].str.contains("EIAV|EPAV|FLATF|SEW|EOS", na=False), True, False)

    # if pnum == new, use cabs term end date, if old use orig
    cabs["NEW_END_DT"] = np.where(cabs["PNUM_NEW"], cabs["TERM_END_DT"], cabs["ORIG_END_DT"])

    cabs["MO_LEFT"] = np.round((cabs["NEW_END_DT"] - cabs["BILL_MONTH_DT"]).dt.days/30, 0)
    # If no data, might as well use the orig end date (install date is always filled in)
    cabs["MO_LEFT_fill"] = cabs["MO_LEFT"].fillna(np.round((cabs["ORIG_END_DT"] - cabs["BILL_MONTH_DT"]).dt.days/30, 0))

    cabs["SEM_LEFT"] = np.round((cabs["NEW_END_DT"] - cabs["BILL_MONTH_DT"]).dt.days/(365.25/2), 0)
    cabs["SEM_LEFT_fill"] = cabs["SEM_LEFT"].fillna(np.round((cabs["ORIG_END_DT"] - cabs["BILL_MONTH_DT"]).dt.days/(365.25/2), 0))

    return cabs

def handle_other_cmpy_counts(cabs):
    """Dropping dupes if CMPY_NO_COUNT is 1, keeping highest MRC.
    Args:
        cabs: pandas.DataFrame
    Returns:
        cabs: pandas.DataFrame"""
    
    logging.debug("Handling CMPY_NO_COUNT < 1")

    # TODO do we need both this and the other company count handling function?

    # e.g. if CMPY_NO_COUNT = 0.5, we should expect another 0.5 duplicate where the MRC billing is cumulative 
    # TODO check here changed this
    p1 = cabs[cabs["CMPY_NO_COUNT"]==1.0].sort_values(["CLEAN_ID", "TOTAL_MRC","CARRIER_LAST_MO_SAME","LAST_BILL_MONTH_DT"], ascending=True)\
                .drop_duplicates(["CLEAN_ID", "BILL_MONTH_DT"], keep='last')
    p2 = cabs[cabs["CMPY_NO_COUNT"]!=1.0].copy()
    conc = pd.concat([p1, p2], axis=0).sort_values(["BILL_MONTH_DT"])

    return conc


def handle_cmpy_count_less_than_1(product_df, cabs): # TODO clean this up, check order
    # TODO: implement product_df logic
    # order different in arlindo's file - do whatever is in the notebook
    """Handle CMPY_NO_COUNT < 1 rows in CABs data.
    Args:
        cabs: pandas.DataFrame
        product_df: pandas.DataFrame, Ethernet or TDM filtered + further preprocessed
    Returns:
        cabs: pandas.DataFrame
        product_df_cleaned: pandas.DataFrame, Ethernet or TDM"""
    
    logging.debug("Handling other CMPY_NO_COUNT < 1 rows")

    # Extracting them - remaining dupes should be CMPY_NO_COUNT < 1 rows 
    mul_billed = product_df[product_df.duplicated(["CLEAN_ID", "BILL_MONTH_DT"], keep=False)].copy()

    # This makes sure we add two rows if CMPY_NO_COUNT = 0.5, three rows if CMPY_NO_COUNT = 0.33, etc.
    # A different CMPNY_NO means the carrier was billed separately for each different one 
    mul_billed = mul_billed.sort_values(["CLEAN_ID", "TOTAL_MRC","CARRIER_LAST_MO_SAME","LAST_BILL_MONTH_DT"], ascending=True)\
                .drop_duplicates(["CLEAN_ID", "BILL_MONTH_DT", "CMPY_NO"], keep='last')
                # TODO check here changed

    # Adding the MRCs of duplicated rows together
    mul_billed_mrc = mul_billed.groupby(['CLEAN_ID', 'BILL_MONTH_DT']).agg(
        TOTAL_MRC=('TOTAL_MRC', 'sum')).reset_index()

    # For the remaining (not MRC) columns, use those of the highest billed row
    # Aggregation not worth it here
    mul_billed_new = mul_billed.sort_values(["CLEAN_ID", "TOTAL_MRC","CARRIER_LAST_MO_SAME","LAST_BILL_MONTH_DT"], ascending=True)\
                .drop_duplicates(["CLEAN_ID", "BILL_MONTH_DT"], keep='last').drop(columns=["TOTAL_MRC"])
                # TODO check here

    # Adding the new MRC column back
    mul_billed_new = pd.merge(mul_billed_new, mul_billed_mrc, on=["CLEAN_ID", "BILL_MONTH_DT"], how='left')

    # Adding the two parts together 
    product_df_cleaned = pd.concat( [ product_df[~product_df.duplicated(["CLEAN_ID", "BILL_MONTH_DT"], keep=False)], mul_billed_new  ], axis=0)\
                    .sort_values(["BILL_MONTH_DT"])

    return product_df_cleaned

def enforce_formatting(cabs):
    """Enforce formatting on CABs data.
    Args:
        cabs: pandas.DataFrame
    Returns:
        cabs: pandas.DataFrame"""
    
    logging.debug("Enforcing formatting")

    
    # Changing "?" to NaN
    # occurs frequently in date columns
    cabs = cabs.replace("?", np.nan)

    # Adding SWC8
    cabs["SWC8"] = cabs["SWC"].str[:8]

    # Enforce date format
    # TODO add tests for this - point where errors can happen
    cabs["BILL_MONTH_DT"]         = pd.to_datetime(cabs['BILL_MONTH_DT'])
    cabs["TERM_START_DT"]         = pd.to_datetime(cabs['TERM_START_DT'])
    cabs["TERM_END_DT"]           = pd.to_datetime(cabs['TERM_END_DT'])
    cabs["INSTALL_DT"]            = pd.to_datetime(cabs['INSTALL_DT'])
    cabs["DISCONNECT_DT"]         = pd.to_datetime(cabs['DISCONNECT_DT'])
    cabs["FIRST_BILL_MONTH_DT"]   = pd.to_datetime(cabs['FIRST_BILL_MONTH_DT'])
    cabs["LAST_BILL_MONTH_DT"]    = pd.to_datetime(cabs['LAST_BILL_MONTH_DT'])

    # enforce numeric formatting
    # EVC/UNI speed will only be relevant for ethernet
    cabs["EVC_MBPS"]              = cabs["EVC_MBPS"].astype(float)
    cabs["UNI_MBPS"]              = cabs["UNI_MBPS"].astype(float)
    cabs["CMPY_NO_COUNT"]         = cabs["CMPY_NO_COUNT"].astype(float)
    cabs["TOTAL_MRC"]             = cabs["TOTAL_MRC"].astype(float)

    return cabs

    
# Function to get VTA from Plan_ID
def planidvta(plan_id):
    """Get VTA from Plan ID
    Args:
        plan_id: str, Plan ID
    Returns:
        int, VTA"""
    if type(plan_id) == float:
        return np.nan
    if '-120-' in plan_id or 'VTA120' in plan_id:
        return 120   
    if '-108-' in plan_id or 'VTA108' in plan_id:
        return 108
    if '-96-'  in plan_id or 'VTA96' in plan_id:
        return 108    
    if '-84-'  in plan_id or 'VTA84' in plan_id:
        return 84
    if '-72-'  in plan_id or 'VTA72' in plan_id:
        return 72    
    if '-60-'  in plan_id or 'VTA60' in plan_id:
        return 60    
    if '-48-'  in plan_id or 'VTA48' in plan_id:
        return 48
    if '-36-'  in plan_id or 'VTA36' in plan_id:
        return 36   
    if '-24-'  in plan_id or 'VTA24' in plan_id:
        return 24    
    if '-12-'  in plan_id or 'VTA12' in plan_id:
        return 12
    if '-01-' in plan_id:
        return 36
    else:
        return np.nan
    

# dictionary to convert state to region
# used for feature engineering
state_to_region = {
    "FL": "Southeast",
    "CA": "West",
    "AL": "Southeast",
    "NC": "Southeast",
    "SC": "Southeast",
    "IN": "Midwest",
    "IL": "Midwest",
    "GA": "Southeast",
    "WV": "Southeast",
    "TN": "Southeast",
    "NV": "West",
    "AZ": "West",
    "TX": "South",
    "CT": "Northeast",
    "UT": "West",
    "PA": "Northeast",
    "NY": "Northeast",
    "OH": "Midwest",
    "MI": "Midwest",
    "MN": "Midwest",
    "IA": "Midwest",
    "WI": "Midwest",
    "NM": "West",
    "NE": "Midwest",
    "MS": "Southeast",
}
