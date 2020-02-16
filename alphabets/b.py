import csv

r = csv.CSVReader('thaana_letters.csv')
for line in r.lines:
    print(line)
