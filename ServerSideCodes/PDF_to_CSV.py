# Import the required Module
import tabula
# Read a PDF File
df = tabula.read_pdf("D:\\Scripts\\test.pdf", pages='all')[0]
# convert PDF into CSV
tabula.convert_into("D:\\Scripts\\test.pdf", "D:\\Scripts\\testPDF_to_Excel.csv", output_format="csv", pages='all')
print(df)
