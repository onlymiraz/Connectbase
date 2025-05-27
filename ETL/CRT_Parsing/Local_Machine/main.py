import logging
import os
import numpy as np
import pandas as pd
import xlrd

from datetime import datetime


# PREPARE #

# Set up logging for errors
logging.basicConfig(filename='crt_extract_fail_log.txt', level=logging.ERROR)

# Set input directory path
input_dir = 'C:/Users/jss7571/OneDrive - Frontier Communications/Documents/Jupyter_Notebooks/CRT_AI/Sample CRT Workbooks'

# Set output/run date path
run_date = datetime.today().strftime("%Y-%m-%d")
output_dir = f'./output/{str(run_date)}/'
if not os.path.exists(output_dir):
    os.makedirs(output_dir + 'raw/')
    os.makedirs(output_dir + 'extracted/')

# Default is 8 builds per sheet
lst_builds = []
max_builds = 8
for i in range(1, max_builds + 1):
    lst_builds.append(f'OSP Build Inquiry {i}')
print(lst_builds)

# Extracted values will be stored in this dictionary
dict_json = {}


# BEGIN DATA EXTRACTION #

# Loop through all xls files in input directory
for filename in os.listdir(input_dir):
    if filename.endswith(".xls"):
        file_path = os.path.join(input_dir, filename)
        print(f"Processing file: {filename}")

        # Open workbook using xlrd
        wb = xlrd.open_workbook(file_path)

        # Loop through sheets
        for sheet_name in wb.sheet_names():

            # EQUIPMENT EXPENSES #
            if sheet_name == "Equipment Expenses":
                print(f"Found sheet: {sheet_name}")

                # Extract data from sheet
                sheet = wb.sheet_by_name(sheet_name)
                data = []
                for row in range(sheet.nrows):
                    data.append([sheet.cell(row, col).value for col in range(sheet.ncols)])

                # Convert data to pandas DataFrame
                df_equip = pd.DataFrame(data)

                # Save raw df to csv
                df_equip.to_csv(f'{output_dir}raw/{filename}_{sheet_name}.csv', index=False)

                # Filter equipment table
                try:
                    df_equip = df_equip.iloc[4:35, 2:]

                    new_header = df_equip.iloc[0]  # store first row for header
                    df_equip = df_equip[1:]  # drop first row
                    df_equip.columns = new_header  # set header to stored values
                    df_equip = df_equip.drop(df_equip.columns[-2], axis=1)  # drop empty hidden column

                    # Save extracted df to csv
                    df_equip.to_csv(f'{output_dir}extracted/{filename}_{sheet_name}.csv', index=False)

                except Exception as e:
                    logging.error(f'Failed: {filename} - {sheet_name}: {e}')
                    print(f'Failed: {filename} - {sheet_name}: {e}')
                    continue

            # NEW OSP BUILD #
            elif sheet_name == "New OSP Build":
                print(f"Found sheet: {sheet_name}")

                # Extract data from sheet
                sheet = wb.sheet_by_name(sheet_name)
                data = []
                for row in range(sheet.nrows):
                    data.append([sheet.cell(row, col).value for col in range(sheet.ncols)])

                # Convert data to pandas DataFrame
                df_osp = pd.DataFrame(data)

                # Save raw df to csv
                df_osp.to_csv(f'{output_dir}raw/{filename}_{sheet_name}.csv', index=False)

                # Filter OSP build inquiries
                try:
                    build_id = filename.split('.')[0]

                    dict_json[build_id] = {
                        "Build_ID": build_id,
                        "Special_Material_Loading_Pct": df_osp.iloc[3, 9],
                    }

                    # Using engineer name to determine if any/all 8 request forms are filled out
                    for index, build_number in enumerate(lst_builds):
                        mask = df_osp.eq(build_number)
                        iloc = np.where(mask)[0][0] + 1, np.where(mask)[1][0] + 1
                        engineer_name = df_osp.iloc[iloc[0], iloc[1]]
                        if engineer_name == "":
                            continue

                        # Get the rows below the "OSP Build Inquiry X" cell
                        rows_below = df_osp.iloc[iloc[0] + 1:, iloc[1] - 1]

                        # Find the first match of "Material:"
                        mask_material = rows_below.eq('Material:')
                        iloc_material = np.where(mask_material)[0][0] + iloc[0] + 1

                        # Find the first match of "Placing and Engineering:"
                        mask_placing = rows_below.eq('Placing and Engineering:')
                        iloc_placing = np.where(mask_placing)[0][0] + iloc[0] + 1

                        # Find the first match of "Splicing:"
                        mask_splicing = rows_below.eq('Splicing:')
                        iloc_splicing = np.where(mask_splicing)[0][0] + iloc[0] + 1

                        # Find the first match of "Removal:"
                        mask_removal = rows_below.eq('Removal:')
                        iloc_removal = np.where(mask_removal)[0][0] + iloc[0] + 1

                        material_data = {}
                        placing_data = {}
                        splicing_data = {}
                        removal_data = {}

                        # Loop through the rows below the "Material:" cell
                        material_subtotal = 0
                        material_loadings = None
                        for i in range(1, 100):  # arbitrary large number
                            if (df_osp.iloc[iloc_material + i, iloc[1]] == "" and
                                    df_osp.iloc[iloc_material + i + 1, iloc[1]] == ""):
                                break
                            elif df_osp.iloc[iloc_material + i, iloc[1]] == "":
                                if material_loadings is None:
                                    material_loadings = df_osp.iloc[iloc_material + i, iloc[1] + 4]
                                continue
                            material_data[f"Material_Description_{i}"] = df_osp.iloc[iloc_material + i, iloc[1]]
                            material_data[f"Material_Unit_{i}"] = df_osp.iloc[iloc_material + i, iloc[1] + 1]
                            material_data[f"Material_Quantity_{i}"] = df_osp.iloc[iloc_material + i, iloc[1] + 2]
                            material_data[f"Material_Cost_{i}"] = df_osp.iloc[iloc_material + i, iloc[1] + 3]
                            material_data[f"Material_Total_{i}"] = round(df_osp.iloc[iloc_material + i, iloc[1] + 4],
                                                                         2)
                            material_subtotal += round(pd.to_numeric(df_osp.iloc[iloc_material + i, iloc[1] + 4],
                                                                     errors='coerce'),
                                                       2)

                            # After the last material description is confirmed
                            last_material_row = iloc_material + i - 1

                        material_total = material_subtotal
                        if material_loadings is not None:
                            material_total += material_loadings

                        # Search down that column for the first instance of the word "Loadings %"
                        if 'material_subtotal' in locals():
                            loadings_col = iloc[1]
                            for j in range(last_material_row + 1, len(df_osp)):
                                if df_osp.iloc[j, loadings_col] == "Loadings %":
                                    # Retrieve the value 1 right of that
                                    material_loadings = df_osp.iloc[j, loadings_col + 1]
                                    break
                        else:
                            material_loadings = 0

                        # Recalculate material_total
                        material_total = material_subtotal + (material_loadings * material_subtotal)

                        # Loop through the rows below the "Placing and Engineering:" cell
                        placing_total = 0
                        for i in range(1, 100):  # arbitrary large number
                            if (df_osp.iloc[iloc_placing + i, iloc[1]] == "" and
                                    df_osp.iloc[iloc_placing + i + 1, iloc[1]] == ""):
                                break
                            elif df_osp.iloc[iloc_placing + i, iloc[1]] == "":
                                continue
                            placing_data[f"Placing_Description_{i}"] = df_osp.iloc[iloc_placing + i, iloc[1]]
                            placing_data[f"Placing_Unit_{i}"] = df_osp.iloc[iloc_placing + i, iloc[1] + 1]
                            placing_data[f"Placing_Quantity_{i}"] = df_osp.iloc[iloc_placing + i, iloc[1] + 2]
                            placing_data[f"Placing_Cost_{i}"] = df_osp.iloc[iloc_placing + i, iloc[1] + 3]
                            placing_data[f"Placing_Total_{i}"] = round(df_osp.iloc[iloc_placing + i, iloc[1] + 4],
                                                                       2)
                            placing_total += round(pd.to_numeric(df_osp.iloc[iloc_placing + i, iloc[1] + 4],
                                                                 errors='coerce'),
                                                   2)

                        # Loop through the rows below the "Splicing:" cell
                        splicing_total = 0
                        for i in range(1, 100):  # arbitrary large number
                            if (df_osp.iloc[iloc_splicing + i, iloc[1]] == "" and
                                    df_osp.iloc[iloc_splicing + i + 1, iloc[1]] == ""):
                                break
                            elif df_osp.iloc[iloc_splicing + i, iloc[1]] == "":
                                continue
                            splicing_data[f"Splicing_Description_{i}"] = df_osp.iloc[iloc_splicing + i, iloc[1]]
                            splicing_data[f"Splicing_Unit_{i}"] = df_osp.iloc[iloc_splicing + i, iloc[1] + 1]
                            splicing_data[f"Splicing_Quantity_{i}"] = df_osp.iloc[iloc_splicing + i, iloc[1] + 2]
                            splicing_data[f"Splicing_Cost_{i}"] = df_osp.iloc[iloc_splicing + i, iloc[1] + 3]
                            splicing_data[f"Splicing_Total_{i}"] = round(df_osp.iloc[iloc_splicing + i, iloc[1] + 4],
                                                                         2)
                            splicing_total += round(pd.to_numeric(df_osp.iloc[iloc_splicing + i, iloc[1] + 4],
                                                                  errors='coerce'),
                                                    2)

                        # Loop through the rows below the "Removal:" cell
                        removal_total = 0
                        for i in range(1, 100):  # arbitrary large number
                            if (df_osp.iloc[iloc_removal + i, iloc[1]] == "" and
                                    df_osp.iloc[iloc_removal + i + 1, iloc[1]] == ""):
                                break
                            elif df_osp.iloc[iloc_removal + i, iloc[1]] == "":
                                continue
                            removal_data[f"Removal_Description_{i}"] = df_osp.iloc[iloc_removal + i, iloc[1]]
                            removal_data[f"Removal_Unit_{i}"] = df_osp.iloc[iloc_removal + i, iloc[1] + 1]
                            removal_data[f"Removal_Quantity_{i}"] = df_osp.iloc[iloc_removal + i, iloc[1] + 2]
                            removal_data[f"Removal_Cost_{i}"] = df_osp.iloc[iloc_removal + i, iloc[1] + 3]
                            removal_data[f"Removal_Total_{i}"] = round(df_osp.iloc[iloc_removal + i, iloc[1] + 4],
                                                                       2)
                            removal_total += round(pd.to_numeric(df_osp.iloc[iloc_removal + i, iloc[1] + 4],
                                                                 errors='coerce'),
                                                   2)

                        dict_json[build_id].update(
                            {f"Build_{index + 1}": {
                                "Engineer": engineer_name,
                                "Contact": df_osp.iloc[iloc[0], iloc[1] + 2],
                                "Description": df_osp.iloc[iloc[0] + 2, iloc[1]],
                                **material_data,
                                "Material_Subtotal": material_subtotal,
                                "Material_Loadings": material_loadings,
                                "Material_Total": material_total,
                                **placing_data,
                                "Placing_Total": placing_total,
                                **splicing_data,
                                "Splicing_Total": splicing_total,
                                **removal_data,
                                "Removal_Total": removal_total,
                            }}
                        )

                    build_count = len([key for key in dict_json[build_id] if key.startswith("Build_")]) - 1
                    dict_json[build_id].update({"Build_Count": build_count})

                except Exception as e:
                    logging.error(f'Failed: {filename} - {sheet_name}: {e}')
                    print(f'Failed: {filename} - {sheet_name}: {e}')
                    continue

df_output = pd.json_normalize(list(dict_json.values()), sep='_')
df_output.to_csv(f'{output_dir}extracted/OSP_BUILDS.csv', index=False)
