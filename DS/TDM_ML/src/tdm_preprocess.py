from common import *

def check_specific_clean_id(df):
    # search for CLEAN_ID == 104T1FBRPTCT01K01BRPTCT01WP2
    # if we find it, print that it was dropped

    # if df[df["CLEAN_ID"] == "104T1FBRPTCT01K01BRPTCT01WP2"].shape[0] < 1:
    #     print("104T1FBRPTCT01K01BRPTCT01WP2 not in df, look at current step")

    ids = ['114T1FBRPTCT01K01BRPTCT01WP2', '22HCCA340906FRGA',
       '136T1ZFFSMFRCT01K02SMFRCT01WP4', '135T1ZFFSMFRCT01K02SMFRCT01WP4',
       '137T1ZFFSMFRCT01K02SMFRCT01WP4', '104T1FBRPTCT01K01BRPTCT01WP2',
       '104T1FSMFRCT01K02SMFRCT01WP4']
    
    for i in ids:
        if df[df["CLEAN_ID"] == i].shape[0] < 1:
            print(f"{i} not in df, look at current step")

    


def calculate_status2(tdm, cabs, start_dt, end_dt, tdm_svc_groups):
    # TODO: could generalize better for ethernet usage later
    # ethernet doesnt take a list of svc groups to filter (currently), so the logic to filter to tdm would have to be put into a
    # separate function where we choose between ethernet and tdm

    logging.debug("Calculating status2 variable")

    # different version of status
    # bigger window of checking with this one
    # catches more edge cases

    end_dt_plus_one = (pd.to_datetime(end_dt) + pd.DateOffset(months=1)).strftime("%Y-%m-%d")

    # Including 2024-May for status2 computation
    # dc = cabs[(cabs["SVC_GROUP"].isin(tdm_svc_groups))\
    #         & (cabs["BILL_MONTH_DT"] >= start_dt) & (cabs["BILL_MONTH_DT"] <= end_dt_plus_one)\
    #         ].sort_values(["CLEAN_ID", "TOTAL_MRC","CARRIER_LAST_MO_SAME","LAST_BILL_MONTH_DT", "PRIMARY_CARRIER_NAME"], ascending=True).drop_duplicates(["CLEAN_ID"], keep='last') 
    #         # TODO check this - changed sort_values
    #         # TODO is drop duplicates right here?

    # TODO testing this now - from Arlindo email 7/1
    # reverting to .sort_values(["BILL_MONTH_DT"]).drop_duplicates(["CLEAN_ID"], keep='last')
    dc = cabs[(cabs["SVC_GROUP"].isin(tdm_svc_groups))\
            & (cabs["BILL_MONTH_DT"] >= start_dt) & (cabs["BILL_MONTH_DT"] <= end_dt_plus_one)\
            ].sort_values(["BILL_MONTH_DT"]).drop_duplicates(["CLEAN_ID"], keep='last')


            #.sort_values(["BILL_MONTH_DT"]).drop_duplicates(["CLEAN_ID"], keep='last'

    dc2 = dc[["CLEAN_ID", "BILL_MONTH_DT"]].copy()
    dc2["STATUS2"] = "DC"

    # merge tdm2 and dc2 to fill in remainder of status2 variable
    tdm2 = pd.merge(tdm, dc2, on=["CLEAN_ID", "BILL_MONTH_DT"], how='left')
    tdm2["STATUS2"] = tdm2["STATUS2"].fillna("ACTIVE")

    return tdm2

def tdm_product_filter(cabs, tdm_svc_groups):
    """Filter to correct TDM products.
    Args:
        cabs: pandas.DataFrame
        tdm_svc_groups: list, list of TDM SVC Groups
    Returns:
        cabs: pandas.DataFrame, all products. Needed for STATUS2 calculation
        tdm: pandas.DataFrame, TDM only products"""
    
    logging.debug("Filtering to TDM products")

    # Filters for billing month and product
    tdm = cabs[(cabs["SVC_GROUP"].isin(tdm_svc_groups))].copy()
    
    return cabs, tdm



def preprocess_tdm_cabs(cabs, start_dt, end_dt):
    """Preprocess CABS data.
    Args:
        cabs: pandas.DataFrame
        start_dt: str, start date for filtering
        end_dt: str, end date for filtering
    Returns:
        cabs: pandas.DataFrame
    """

    # svc groups - will be used to filter products
    tdm_svc_groups = ['TDM_DS1', 'TDM_DS1_mux', 'TDM_DS1_noEU',
                  'TDM_DS3', 'TDM_DS3_mux', 'TDM_DS3_noEU']
    
    # drop att
    #cabs = drop_att(cabs) TODO add back

    # enforce formatting
    cabs = enforce_formatting(cabs)

    # Sorting billing by bill month
    # TODO changed to add clean id to this sort
    cabs.sort_values(["CLEAN_ID", "BILL_MONTH_DT"], inplace=True)

    # check for carrier changes for same clean id
    # TODO may need to do after rename?
    # TODO this was just changed - check results on rerun?
    cabs = check_carrier_previous_month(cabs)

    # filter only to tdm
    # will end up with cabs and tdm dataframes
    # we need cabs checkpoint to check whether circuits churned to other products later on
    cabs, tdm = tdm_product_filter(cabs, tdm_svc_groups)

    # filter to appropriate dates, only for tdm
    # do not pass cabs through this yet - need an extra month for status2 calculation later
    tdm = filter_dates(tdm, start_dt, end_dt)

    # create status variable
    tdm = create_status_variable(tdm)

    # shorten company names
    tdm = change_top_names(tdm)

    # get vta
    tdm = get_vta(tdm)

    # handle dupes
    tdm = handle_other_cmpy_counts(tdm)

    # end date, pnum steps
    tdm = get_orig_end_dt_and_pnum(tdm)

    # merge files together
    # TODO implement this separately for ethernet
    #cabs = merge_files(cabs, m6, hier, firstlast)

    # more company count preprocessing
    tdm = handle_cmpy_count_less_than_1(product_df=tdm, cabs=cabs)

    # get status2 variable - new step
    tdm = calculate_status2(tdm=tdm, cabs=cabs, start_dt=start_dt, end_dt=end_dt, tdm_svc_groups=tdm_svc_groups)

    # get dnr and shift ids
    #tdm.to_csv("tdm_before_dnr_shift_ids.csv")
    tdm = get_dnr_and_shift_ids(tdm)


    logging.debug("---Preprocessing finished---")
    
    return tdm


def main():

    # to call file:
    # python tdm_preprocess.py --start_dt=2019-01-01 --end_dt=2024-04-01 --config=config.json

    logging.basicConfig(level=logging.DEBUG)

    args = handle_args()
    start_dt = args.start_dt
    end_dt = args.end_dt
    config_file_name = args.config

    logging.debug("Loading all data sources")
    # open config
    with open(config_file_name, 'r') as f:
        config = json.load(f)

    cabs = load_cabs(config)

    tdm = preprocess_tdm_cabs(cabs, start_dt = start_dt, end_dt = end_dt)
    check_specific_clean_id(tdm)

    # ensure correct paths
    # not currently very important - will be more relevant when entire pipeline is run from another file
    create_paths_if_not_exist()

    logging.debug("Saving cleaned TDM file to data folder")
    
    # save cabs to data folder
    #tdm.to_csv(f"{product_filter}/data/cabs.csv")
    tdm.to_csv("tdm-preprocessed-6-28.csv")

    logging.debug("Save completed - dataset ready for frame_target")
    exit(0)



if __name__ == "__main__":
    main()

