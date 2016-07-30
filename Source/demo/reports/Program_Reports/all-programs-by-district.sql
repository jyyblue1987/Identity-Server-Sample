-- District Tracking - Programs (PRODUCTION)
-- This report lets you view all programs by district within a specified time period.
-- OPTIONS: {database: "sqlsvrprod"}
-- VARIABLE: { name: "region", display:"Region", type:"select", database_options:{table:"tblDistricts", column:"REGION",all:"true"}}
-- CHART: {
--	"columns": ["Region", "NUMCOMPLETED"],"type": "BarChart", "dataset":1, "title": "Completed Programs by Region","width": "600px", "height": "400px"
--}
-- FILTER: { 
--      "dataset":0,
--      "column": "District", 
--      "filter": "drilldown",
--      "params": {
--          macros: { "district": { column: "District" }, "when":"All" },
--          report: "drilldown/district-programs.sql"}
--      }

-- @dataset true
-- @title By District
SELECT 
  DM.DISTRICT District, 
  ISNULL(DM.DMFN + ' ' + DM.DMLN, 'Vacant') AS DM, 
  B.TERRITORY Territory, 
  convert(varchar(2), RM.REGION) Region, 
  ISNULL(
    REPS.REPFN + ' ' + REPS.REPLN, 'Vacant'
  ) AS REP, 
  COUNT(
    CASE WHEN P.CANCELLED = 1 THEN P.PROGRAMID END
  ) AS NUMCANCELLED, 
  COUNT(
    CASE WHEN P.PROGDATE <= GETDATE() 
    AND P.CANCELLED = 0 THEN P.PROGRAMID END
  ) AS NUMCOMPLETED, 
  COUNT(
    CASE WHEN P.PROGDATE > GETDATE() 
    AND P.CANCELLED = 0 THEN P.PROGRAMID END
  ) AS NUMSCHEDULED, 
  DM.DMCOUNTER, 
  RM.RMCOUNTER, 
  Reps.REPCOUNTER, 
  ISNULL(RM.RMFN + ' ' + RM.RMLN, 'Vacant') AS RM, 
  SD.SalesArea, 
  ISNULL(SD.SDFn + ' ' + SD.SDLn, 'Vacant') as SD, 
  SD.SDCounter 
FROM 
  PROGRAM P 
  JOIN (
    Budget B 
    JOIN (
      Territory_Reps REPS 
      JOIN (
        District_Managers DM 
        JOIN (
          Regional_Managers RM 
          LEFT JOIN Sales_Directors SD ON RM.SalesArea = SD.SalesArea
        ) ON DM.Region = RM.Region
      ) ON REPS.District = DM.District
    ) ON B.Territory = REPS.Terr
  ) ON P.PROGRAMID = B.PROGRAMID 
WHERE 
  B.HOSTREP = 1 
		 {% if region != "ALL" %}
		 AND RM.REGION Like '{{region}}%'
		 {% endif %}
AND B.TERRITORY <> '00000'
AND DM.DISTRICT IS NOT NULL
GROUP BY 
DM.DISTRICT
, ISNULL(DM.DMFN + ' ' + DM.DMLN,'Vacant')
, B.TERRITORY
, ISNULL(REPS.REPFN + ' ' + REPS.REPLN,'Vacant')
, DM.DMFN + ' ' + DM.DMLN
, B.DRUG
, RM.REGION
, DM.DMCOUNTER
, RM.RMCOUNTER
, REPS.REPCOUNTER
, ISNULL(RM.RMFN + ' ' + RM.RMLN,'Vacant')
, SD.SalesArea
, ISNULL(SD.SDFn + ' ' + SD.SDLn,'Vacant')
, SD.SDCounter
ORDER BY B.TERRITORY,DM.DISTRICT,RM.REGION,B.DRUG;

-- @dataset true
-- @title By Region
SELECT 
  convert(varchar(2), RM.REGION)+':' Region, 
  COUNT(
    CASE WHEN P.CANCELLED = 1 THEN P.PROGRAMID END
  ) AS NUMCANCELLED, 
  COUNT(
    CASE WHEN P.PROGDATE <= GETDATE() 
    AND P.CANCELLED = 0 THEN P.PROGRAMID END
  ) AS NUMCOMPLETED, 
  COUNT(
    CASE WHEN P.PROGDATE > GETDATE() 
    AND P.CANCELLED = 0 THEN P.PROGRAMID END
  ) AS NUMSCHEDULED, 
  RM.RMCOUNTER, 
  ISNULL(RM.RMFN + ' ' + RM.RMLN, 'Vacant') AS RM, 
  SD.SalesArea, 
  ISNULL(SD.SDFn + ' ' + SD.SDLn, 'Vacant') as SD, 
  SD.SDCounter 
FROM 
  PROGRAM P 
  JOIN (
    Budget B 
    JOIN (
      Territory_Reps REPS 
      JOIN (
        District_Managers DM 
        JOIN (
          Regional_Managers RM 
          LEFT JOIN Sales_Directors SD ON RM.SalesArea = SD.SalesArea
        ) ON DM.Region = RM.Region
      ) ON REPS.District = DM.District
    ) ON B.Territory = REPS.Terr
  ) ON P.PROGRAMID = B.PROGRAMID 
WHERE 
  B.HOSTREP = 1 
		 {% if region != "ALL" %}
		 AND RM.REGION Like '{{region}}%'
		 {% endif %}
AND B.TERRITORY <> '00000'
AND DM.DISTRICT IS NOT NULL
GROUP BY 
 B.DRUG
, convert(varchar(2), RM.REGION)+':'  
, RM.REGION
, RM.RMCOUNTER
, ISNULL(RM.RMFN + ' ' + RM.RMLN,'Vacant')
, SD.SalesArea
, ISNULL(SD.SDFn + ' ' + SD.SDLn,'Vacant')
, SD.SDCounter
ORDER BY RM.REGION,B.DRUG;
