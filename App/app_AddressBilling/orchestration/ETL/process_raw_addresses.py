# app_AddressBilling/orchestration/ETL/process_raw_addresses.py

from datetime import date
import pandas as pd
import pandas_usaddress as padd

def clean_addresses(df_l, df_r):
    """
    Cleans addresses for maximum accuracy in matching between two tables.
    Steps:
      * Removes .0 from zip codes
      * Removes NA words
      * Replaces NaN with '' for string concatenation
      * ...
    """
    df_l['ZIP'] = df_l['ZIP'].astype(str).str.replace('.0', '')
    df_r['ZIP'] = df_r['ZIP'].astype(str).str.replace('.0', '')

    lst_address_cols = ['ADDRESS','CITY','STATE','ZIP']
    lst_na_words = [
        'undefined','unknown','blank','missing','pending','none','null',
        'void','unavailable','unspecified','undetermined','tbd','na',
        'n/a','nan','<na>','	','.',',','-','_','?','n/r','n/e'
    ]
    for address_col in lst_address_cols:
        df_l[address_col].fillna('', inplace=True)
        df_r[address_col].fillna('', inplace=True)
        for NA_word in lst_na_words:
            df_l.loc[df_l[address_col].str.lower() == NA_word, address_col] = ''
            df_r.loc[df_r[address_col].str.lower() == NA_word, address_col] = ''

    df_l['full_address'] = (
        df_l['ADDRESS'].astype(str).str.lower().str.strip() + ' ' +
        df_l['CITY'].astype(str).str.lower().str.strip() + ' ' +
        df_l['STATE'].astype(str).str.lower().str.strip() + ' ' +
        df_l['ZIP'].astype(str).str.lower().str.strip()
    )
    df_r['full_address'] = (
        df_r['ADDRESS'].astype(str).str.lower().str.strip() + ' ' +
        df_r['CITY'].astype(str).str.lower().str.strip() + ' ' +
        df_r['STATE'].astype(str).str.lower().str.strip() + ' ' +
        df_r['ZIP'].astype(str).str.lower().str.strip()
    )

    df_l = df_l.dropna(subset=['full_address'])
    df_r = df_r.dropna(subset=['full_address'])

    df_l = df_l.loc[df_l['full_address'] != '', :]
    df_r = df_r.loc[df_r['full_address'] != '', :]

    df_l['index'] = df_l.reset_index().index
    df_r['index'] = df_r.reset_index().index
    return df_l, df_r


def parse_addresses(df_l, df_r):
    """
    Takes full_address columns, tags them, merges with multiple criteria.
    """
    df_l_usaddr = padd.tag(
        df_l, ['full_address'],
        granularity='high',
        standardize=True
    )
    df_r_usaddr = padd.tag(
        df_r, ['full_address'],
        granularity='high',
        standardize=True
    )

    lst_padd_fields = [
        'AddressNumber','BuildingName','OccupancyType','OccupancyIdentifier','PlaceName',
        'Recipient','StateName','StreetName','StreetNamePreDirectional','StreetNamePreModifier',
        'StreetNamePreType','StreetNamePostDirectional','StreetNamePostModifier','StreetNamePostType',
        'SubaddressIdentifier','SubaddressType','USPSBoxID','USPSBoxType','ZipCode'
    ]

    df_l_usaddr.dropna(how='all', subset=lst_padd_fields, inplace=True)
    df_r_usaddr.dropna(how='all', subset=lst_padd_fields, inplace=True)

    for i in lst_padd_fields:
        df_l_usaddr[i] = df_l_usaddr[i].astype(str)
        df_r_usaddr[i] = df_r_usaddr[i].astype(str)

    abbrev_state = {
        'alabama':'al','alaska':'ak','arizona':'az','arkansas':'ar','california':'ca',
        'colorado':'co','connecticut':'ct','delaware':'de','florida':'fl','georgia':'ga',
        'hawaii':'hi','idaho':'id','illinois':'il','indiana':'in','iowa':'ia','kansas':'ks',
        'kentucky':'ky','louisiana':'la','maine':'me','maryland':'md','massachusetts':'ma',
        'michigan':'mi','minnesota':'mn','mississippi':'ms','missouri':'mo','montana':'mt',
        'nebraska':'ne','nevada':'nv','new hampshire':'nh','new jersey':'nj','new mexico':'nm',
        'new york':'ny','north carolina':'nc','north dakota':'nd','ohio':'oh','oklahoma':'ok',
        'oregon':'or','pennsylvania':'pa','rhode island':'ri','south carolina':'sc',
        'south dakota':'sd','tennessee':'tn','texas':'tx','utah':'ut','vermont':'vt',
        'virginia':'va','washington':'wa','west virginia':'wv','wisconsin':'wi','wyoming':'wy'
    }
    def convert_state(state):
        if len(state) == 2:
            return state
        elif state in abbrev_state:
            return abbrev_state[state]
        else:
            return ''

    df_l_usaddr['StateName'] = df_l_usaddr['StateName'].apply(convert_state)
    df_r_usaddr['StateName'] = df_r_usaddr['StateName'].apply(convert_state)

    df_l_usaddr = df_l_usaddr.add_suffix('_l')
    df_r_usaddr = df_r_usaddr.add_suffix('_r')

    df_usaddr_match_compl = pd.merge(
        df_l_usaddr, df_r_usaddr, how='inner',
        left_on=[col+'_l' for col in lst_padd_fields],
        right_on=[col+'_r' for col in lst_padd_fields]
    )

    lst_basic = ['AddressNumber','StreetName','PlaceName','StateName','ZipCode']
    df_usaddr_match_basic = pd.merge(
        df_l_usaddr, df_r_usaddr, how='inner',
        left_on=[f'{c}_l' for c in lst_basic],
        right_on=[f'{c}_r' for c in lst_basic]
    )
    lst_prdir = [
        'AddressNumber','StreetName','StreetNamePreDirectional','PlaceName','StateName','ZipCode'
    ]
    df_usaddr_match_prdir = pd.merge(
        df_l_usaddr, df_r_usaddr, how='inner',
        left_on=[f'{c}_l' for c in lst_prdir],
        right_on=[f'{c}_r' for c in lst_prdir]
    )
    lst_nozip = [
        'AddressNumber','StreetName','StreetNamePreDirectional','PlaceName','StateName'
    ]
    df_usaddr_match_nozip = pd.merge(
        df_l_usaddr, df_r_usaddr, how='inner',
        left_on=[f'{c}_l' for c in lst_nozip],
        right_on=[f'{c}_r' for c in lst_nozip]
    )
    lst_onzip = [
        'AddressNumber','StreetName','StreetNamePreDirectional','ZipCode'
    ]
    df_usaddr_match_onzip = pd.merge(
        df_l_usaddr, df_r_usaddr, how='inner',
        left_on=[f'{c}_l' for c in lst_onzip],
        right_on=[f'{c}_r' for c in lst_onzip]
    )

    df_usaddr_match = pd.concat([
        # df_usaddr_match_basic, # optional if you want
        df_usaddr_match_prdir,
        df_usaddr_match_compl,
        df_usaddr_match_onzip,
        df_usaddr_match_nozip
    ], axis=0)

    df_usaddr_match.drop_duplicates(subset=['index_l','index_r'], inplace=True)
    df_usaddr_match.fillna('NULL', inplace=True)
    df_usaddr_match.replace(r'^nan$', 'NULL', inplace=True, regex=True)
    df_usaddr_match['MODEL_RUN'] = date.today().strftime('%Y-%m-%d')
    return df_usaddr_match
