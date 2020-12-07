# folio.load.inventory
Scripts and tools to load inventory data (instances, holdings, items, instanceRelationships) in format FOLIO-Json into Folio.

Example to load a complete sample sequence of connected instances, holdings and items into Folio.
- with instance relationships (parent and child relations)

## Sample inventory data
The sample inventory data in sample_inventory/ will create the following inventory, when loaded to Folio:

- 1 multipart monograph, hrid 1890 (uuid 7433...)

- 2 serials (volumes), both belonging to hrid 1890:
  - hrid 1891 (uuid cbcf...) with 2 holdings:
    - holding 10000001 in location: main library, with 1 item:
      - item hrid 31364
    - holding 10000002 in location: second floor, with 1 item:
      - item hrid 91512

  - hrid 1893 (uuid 503b...) with 1 holding:
    - holding 10000003 in location: main library, with 2 items:
      - item hrid 31366 with copy nr 001 and call number type: shelving control number
      - item hrid 91514 with copy nr 002 and call number type: other


- 1 single unit, hrid 211492 (uuid d7ac...) with 1 holding:
  - holding 10000004 in location: annex, with 1 item:
    - item hrid 4711
    
## Creating ID Labels and Mapping Table
The sample inventory data contains labels for UUIDs instead of the plain UUIDs. This is true for the Folio reference data (identifier types, status definitions and other system relevant identifiers).  
You can create the labels which are being used in your Folio instance by running the script `createIdLabels.pl`. This script will read the reference data from your Folio instance and create one line in a mapping table for each piece of reference data. This mapping table is being written to the file `scripts_out/IdLabelsMap.csv` by default.  

Run this command to get the help page of the script:
```
cd scripts/
perl createIdLabels.pl -h
```
Create a file `login.json` with credentials to connect to your Folio tenant as described in the help page of the script.  
Then execute
``` 
perl createIdLabels.pl -t mytenant -u myokapiurl
```

`scripts_out/IdLabelsMap.csv` contains a sample mapping file for Goldenrod standard reference data. It doesn't contain any custom reference data.

## Replace ID Labels in Sample Data
To replace the ID labels in the sample data with real UUIDs, based on the mapping table `scripts_out/IdLabelsMap.csv` do
```
cd scripts/
perl replaceIdLabels.pl -d ../sample_inventory
```
This will create the files `sample_inventory/*/*.json` beside the corresponding files `sample_inventory/*/*.idlabels` in the sample data directory. The files `*.json` do not contain ID labels anymore, but plain UUIDs, and might be loaded into a Folio instance as they are.

Read the help page of the script to learn how to use it to convert your own data:
```
cd scripts/
perl replaceIdLabels.pl -h
```
