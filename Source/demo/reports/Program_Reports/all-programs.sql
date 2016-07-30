-- All Programs
-- This report lets you view all programs within a specified time period.
-- You can click on a territory to drill down into all programs for that territory.
-- VARIABLE: { 
--      name: "range", 
--      display: "Report Range",
--      type: "daterange", 
--      default: { start: "yesterday", end: "yesterday" }
-- }
-- FILTER: { 
--      column: "Territory", 
--      filter: "drilldown",
--      params: {
--          macros: { "terr": { column: "Territory" } },
--          report: "drilldown/rep-programs.sql"
--      }
-- }
-- ROLE: Staff

	SELECT TOP 100 PERCENT DM AS 'District Manager',District 
		FROM TBLDISTRICTS WHERE REGION Like '%' AND ACCOUNT= Coalesce(@Account,Account) 
		AND ID > @IDLow AND ID <= @IDHigh
		 AND district <> '00000' ORDER BY ID;
		
		SELECT TOP 100 PERCENT dtw.District, dtw.DM AS 'District Manager',   
			dtw.ProgramID, dtw.Vendor + ', ' + dtw.City as 'Location', dtw.ProgDate, 
			dtw.HOSTREP, dtw.Speaker, IsNull(dtw.ActualAtt,0) as ActualAtt, 
			dtw.CostPerDoc,'$' + Convert(varchar,convert(decimal(15,2),IsNull(TotalCommitted,0))) as TotalCommitted , 
			'$' + convert(varchar,convert(decimal(15,2),IsNull(TotalActual,0))) as TotalActual , 
			Case When Cancelled = 'CANCELLED'  Then 'Cancelled'  When DoneDeal = 'Yes' 
				then 'Completed' Else 'In-progress' End as ProgComp    
		FROM tblDistrictTrackingWeb dtw Left JOIN
		(Select Sum(ApprovedAmount) as TotalActual, Sum(CommittedAmount) as TotalCommitted,ProgramID
		 From tblDistrictTrackingBudgetsWeb Group by ProgramId) BB
		--( select * from District_Track_Core_Total)BB  
		on dtw.ProgramId = BB.ProgramID  
		 WHERE district in ( 
		  SELECT TOP 100 PERCENT district
		 FROM TBLDISTRICTS WHERE REGION Like '%' AND ACCOUNT=Coalesce(@Account,Account)  
		 ORDER BY ID)
		 AND district <> '00000' 
		 AND ACCOUNT=Coalesce(@Account,Account)  ORDER BY ID;
		 
		 
		 SELECT TOP 100 PERCENT dw.District , dw.ProgramID, dw.Territory , 
		 Case When Cancelled = 'CANCELLED'  Then 'Cancelled'  
		 When DoneDeal = 'Yes' then 'Completed' Else 'In-progress' End as ProgComp,    
		 Rep, Case when HOSTREP = Rep Then 'Yes' else 'No' end as HostRep,  
		 Account, Coalesce(ApprovedAmount,0) as ActualBudget, 
		 Coalesce(CommittedAmount,0) as Committed  
		 FROM tblDistrictTrackingBudgetsWeb dw 
		-- left outer join ( Select * from  District_Track_Core ) ST  
		 --on dw.ProgramID = ST.ProgramID and dw.Territory = ST.Territory   
		 WHERE dw.PROGRAMID IN  (SELECT TOP 100 PERCENT ProgramID 
				FROM tblDistrictTrackingWeb WHERE district IN
						( SELECT TOP 100 PERCENT 
						District FROM TBLDISTRICTS 
						WHERE REGION Like '%'  
						AND ACCOUNT=Coalesce(@Account,Account)  
						AND ID > @IDLow AND ID <= @IDHigh ORDER BY ID) 
				AND ACCOUNT=Coalesce(@Account,Account)   ORDER BY ID)  
				AND district <> '00000' 
		 -- AND ACCOUNT=Coalesce(@Account,Account)  
		  ORDER BY dw.ProgramID ; 

SELECT 
DM.DISTRICT
, ISNULL(DM.DMFN + ' ' + DM.DMLN,'Vacant') AS DM
, B.TERRITORY
, RM.REGION
, ISNULL(REPS.REPFN + ' ' + REPS.REPLN,'Vacant') AS REP
, COUNT(CASE WHEN P.CANCELLED = 1 THEN P.PROGRAMID END) AS NUMCANCELLED
, COUNT(CASE WHEN P.PROGDATE <=GETDATE() AND P.CANCELLED = 0 THEN P.PROGRAMID END) AS NUMCOMPLETED
, COUNT(CASE WHEN P.PROGDATE > GETDATE() AND P.CANCELLED = 0 THEN P.PROGRAMID END) AS NUMSCHEDULED
, DM.DMCOUNTER
, RM.RMCOUNTER
, Reps.REPCOUNTER
, ISNULL(RM.RMFN + ' ' + RM.RMLN,'Vacant') AS RM
, SD.SalesArea
, ISNULL(SD.SDFn + ' ' + SD.SDLn,'Vacant') as SD
, SD.SDCounter
FROM PROGRAM P JOIN (Budget B
	JOIN (Territory_Reps REPS 
		JOIN (District_Managers DM 
			JOIN (Regional_Managers RM 
				LEFT JOIN Sales_Directors SD 
				ON RM.SalesArea=SD.SalesArea)
			ON DM.Region = RM.Region)
		ON REPS.District = DM.District)
	ON B.Territory = REPS.Terr)
ON P.PROGRAMID = B.PROGRAMID
WHERE B.HOSTREP = 1 
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
ORDER BY B.TERRITORY,DM.DISTRICT,RM.REGION,B.DRUG
