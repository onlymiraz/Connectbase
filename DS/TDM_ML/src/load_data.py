import numpy as np
import pandas as pd
import glob
import os
import logging
import json
import sys

def detect_path_type(file_path):
    """Detect whether input is a file or directory.
    Not currently in use. TODO
    Args:
        file_path: str, path to file or directory
    Returns:
        str, 'file' or 'dir'
    """
    if os.path.isfile(file_path):
        return 'file'
    elif os.path.isdir(file_path):
        return 'dir'
    else:
        raise ValueError('Invalid file path')
    

def load_m6(config):
    """Load in M6 data from Arlindo's SQL pulls.
    Args:
        file_path: str, path to file or directory
    Returns:
        m6: pandas.DataFrame
    """

    m6_cd = config.get("M6")

    m6_all_files = glob.glob(os.path.join(m6_cd, "*.csv"))
    m6_all_files = [f.replace("\\", "/") for f in m6_all_files]
    m6 = pd.concat((pd.read_csv(f, dtype=str) for f in m6_all_files), ignore_index=True)

    m6["LAST_MODIFIED_DATE"] = pd.to_datetime(m6["LAST_MODIFIED_DATE"])
    m6 = m6.sort_values(["LAST_MODIFIED_DATE"], ascending=False)

    # Dropping dupes where speed is null
    drop_indx = m6[(m6.duplicated(["CLEAN_ID"], keep=False)) & (m6["CIR"].isnull())][
        "CLEAN_ID"
    ].index
    m6f = m6.drop(index=drop_indx)

    # Then dropping dupes by using latest record LAST_MODIFIED_DATE
    m6f = m6f.drop_duplicates(["CLEAN_ID"], keep="first")[["CLEAN_ID", "CIR"]].copy()

    # Extracting number portion of speed
    m6f["M6_SPEED"] = m6f["CIR"].str.extract("(\d+)").astype(float)
    # Need to multiply by 1000 if speed units is in GB
    m6f["M6_SPEED"] = np.where(
        m6f["CIR"].str.contains("G", na=False), m6f["M6_SPEED"] * 10**3, m6f["M6_SPEED"]
    )
    m6f["M6_SPEED"] = np.where(
        m6f["CIR"].str.contains("M", na=False), m6f["M6_SPEED"] * 1, m6f["M6_SPEED"]
    )
    return m6f


def load_hierarchy(config):
    """Load in Hierarchy data from Arlindo's SQL pulls.
    Args:
        file_path: str, path to file or directory
    Returns:
        hierarchy: pandas.DataFrame
    """

    hier_all_files = glob.glob(os.path.join(config.get("Hierarchy"), "*.csv"))
    hier_all_files = [f.replace("\\", "/") for f in hier_all_files]
    hier = pd.concat((pd.read_csv(f) for f in hier_all_files), ignore_index=True)

    # Loading EVC speed from hierarchy
    hier["LAST_MODIFIED_DATE"] = pd.to_datetime(hier["LAST_MODIFIED_DATE"])
    hier = hier.sort_values(["LAST_MODIFIED_DATE"], ascending=False)

    # Taking out NNIs
    hierf = hier[hier["UNI_NNI"] != "NNI"].copy()

    # Dropping dupes where speed is null
    drop_indx = hierf[
        (hierf.duplicated(["CLEAN_EVC_ID"], keep=False)) & (hierf["EVC_SPEED"].isnull())
    ]["CLEAN_EVC_ID"].index
    hierf = hierf.drop(index=drop_indx)

    # Then dropping dupes by using latest record LAST_MODIFIED_DATE
    hierf = hierf.drop_duplicates(["CLEAN_EVC_ID"], keep="first")[
        ["CLEAN_EVC_ID", "EVC_SPEED"]
    ].copy()
    hierf.columns = ["CLEAN_ID", "EVC_SPEED"]

    return hierf

def load_louis_file(config):
    """Load in FIRST LAST MRC REPORT.
    Args:
        file_path: str, path to file or directory
    Returns:
        firstlast: pandas.DataFrame
    """
    # FIRST_LAST_MRC report from Louis
    info = pd.read_excel(
        config.get("Louis_First_Last")
    )

    # Loading speed from Louis Report
    # Separating the EVC and UNI rows
    # Getting mean speed if multiple values
    infof = pd.merge(
        info[info["SVC_GROUP"] == "ETH_EVC"]
        .groupby(["CLEAN_ID"])["EVC_MBPS"]
        .mean()
        .to_frame("EVC_MBPS2")
        .reset_index(),
        info[info["SVC_GROUP"] == "ETH_UNI"]
        .groupby(["CLEAN_ID"])["UNI_MBPS"]
        .mean()
        .to_frame("UNI_MBPS2")
        .reset_index(),
        on=["CLEAN_ID"],
        how="outer",
    )

    return infof
    

def load_cabs(config):
    """Load in CABs data from Arlindo's SQL pulls.
    TODO: pull from more reproducible source, like s3 or sharepoint
    Args:
        file_path: str, path to file or directory
    Returns:
        cabs: pandas.DataFrame
    """
    # check file path
    #path_type = detect_path_type(file_path)

    # Load CABS 2019-2023
    # using 2019 for padding + feature calculation - won't be used for training
    # CABs 2019 - | sep
    # CABs after 2019 - , sep

    file_path = config.get("CABs")
    cabs19_cd = file_path + "2019"
    cabs20_cd = file_path + "2020"
    cabs21_cd = file_path + "2021"

    # loading in cabs 2019 files separately due to separator being | instead of ,
    cabs19_files = glob.glob(os.path.join(cabs19_cd, "*.txt"))
    cabs19_files = [f.replace('\\' , '/') for f in cabs19_files]
    cabs19 = pd.concat((pd.read_csv(f, sep='|', dtype=str) for f in cabs19_files), ignore_index=True)

    # get a list of all files in these directories
    all_files = glob.glob(os.path.join(cabs20_cd, "*.txt"))
    all_files += glob.glob(os.path.join(cabs21_cd, "*.txt"))

    # join in raw file path - should give us rest of the files after 2021
    all_files += glob.glob(os.path.join(file_path, "*.txt"))

    logging.debug("Loading CABs")

    all_files = [f.replace("\\", "/") for f in all_files]
    cabs = pd.concat((pd.read_csv(f) for f in all_files), ignore_index=True)

    # add cabs19 to rest
    cabs = pd.concat([cabs19, cabs], ignore_index=True)

    # sort by bill_month_dt
    cabs = cabs.sort_values(["BILL_MONTH_DT"])

    return cabs

def load_urban_rural(config):
    """Load in Urban/Rural data"""
    urbanrural = pd.read_csv(config.get("Urban_Rural"))
    urbanrural.rename(columns={"CLEANID": "CLEAN_ID"}, inplace=True)
    return urbanrural