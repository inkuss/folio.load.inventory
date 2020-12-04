# folio.load.inventory
Scripts and tools to load inventory data (instances, holdings, items, instanceRelationships) in format FOLIO-Json into Folio

## Sample inventory data
The sample inventory data in sample_inventory/ will create the following inventory, when loaded to Folio:

- 1 multipart monograph, hrid 1890 (uuid 7433...)

- 2 serials (volumes), both belonging to hrid 1890:
-- hrid 1891 (uuid cbcf...) with 2 holdings:
--- holding 10000001 in location: main library, with 1 item:
---- item hrid 31364
--- holding 10000002 in location: second floor, with 1 item:
---- item hrid 91512

-- hrid 1893 (uuid 503b...) with 1 holding:
--- holding 10000003 in location: main library, with 2 items:
---- item hrid 31366 with copy nr 001 and call number type: shelving control number
---- item hrid 91514 with copy nr 002 and call number type: other


- 1 single unit, hrid 211492 (uuid d7ac...) with 1 holding:
-- holding 10000004 in location: annex, with 1 item:
---- item hrid 4711
