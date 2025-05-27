import logging
import sys
import warnings

from connect import odbc_read, odbc_write
from process_raw_addresses import clean_addresses, parse_addresses


warnings.simplefilter(action='ignore', category=FutureWarning)

# for sql server input/output:
if __name__ == '__main__':

    logging.basicConfig(filename='address_matching_log.txt', level=logging.INFO,
                        format='%(asctime)s - %(levelname)s - %(message)s')

    logging.info('Address matching process BEGIN')
    print('Address matching process BEGIN')

    # read in data
    try:
        df_sql_l = odbc_read(table='left')  # left: [WAD_PRD_02].[CB_MS].[TBL_CB_MS_COMBINED]
    except Exception as e:
        logging.warning(f'Left select query failed because: {e}')
        print(f'Left select query failed because: {e}')
        sys.exit(1)

    try:
        df_sql_r = odbc_read(table='right')  # right: [WAD_PRD_02].[LZ].[TBL_WABB_SERVICE_ORDERS]
    except Exception as e:
        logging.warning(f'Right select query failed because: {e}')
        print(f'Right select query failed because: {e}')
        sys.exit(1)

    # clean and prepare address columns
    try:
        df_L, df_R = clean_addresses(df_sql_l, df_sql_r)
    except Exception as e:
        logging.warning(f'Cleaning address columns failed because: {e}')
        print(f'Cleaning address columns failed because: {e}')
        sys.exit(1)

    # parse addresses and match tables
    try:
        df_match = parse_addresses(df_L, df_R)
    except Exception as e:
        logging.warning(f'Parsing address columns failed because: {e}')
        print(f'Parsing address columns failed because: {e}')
        sys.exit(1)

    # save matched table to sql
    try:
        odbc_write(df=df_match)  # output: [WAD_PRD_02].[LZ].[TBL_PY_OUTPUT]
    except Exception as e:
        logging.warning(f'Writing output table failed because: {e}')
        print(f'Writing output table failed because: {e}')
        sys.exit(1)

    logging.info('Address matching process COMPLETE')
    print('Address matching process COMPLETE')
    sys.exit(0)
