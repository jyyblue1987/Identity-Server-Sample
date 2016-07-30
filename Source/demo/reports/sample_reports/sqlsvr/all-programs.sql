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

	SELECT 	
	PROGRAM.PROGRAMID 
	,PROGRAM.PROGDATE AS 'Program Date'
	,L.VENDOR AS 'Location'
	,L.LCITY as 'Loc City'
	,L.LSTATE AS 'Loc St'
	,B.REPFN + ' ' + B.REPLN AS 'Rep Name'
	,B.Territory
	,IsNull(Reps.REPADD,'n/a') AS 'Rep Addr'
	,IsNull(Reps.REPCITY,'') AS 'Rep City'
	,IsNull(Reps.REPSTATE,'') AS 'Rep St'
	,IsNull(Reps.REPZIP,'')  AS 'Rep Zip'
	,Reps.REPPHONE AS 'Rep Phone'
	,Reps.REPEMAIL AS 'Rep Email'
	,K.spkrfn+' '+K.spkrln AS 'Speaker'
	,K.SpkrCounter AS 'SpkrCounter'
	FROM Program 
	LEFT JOIN Budget B 	
	ON PROGRAM.PROGRAMID = B.PROGRAMID
	LEFT JOIN Location_Info L 
	ON PROGRAM.PROGRAMID = L.PROGRAMID
	LEFT JOIN TBLSPEAKERS K
	ON PROGRAM.PROGRAMID = K.PROGRAMID
	JOIN dbo.Territory_Reps Reps
	ON B.TERRITORY = REPS.TERR
	--LEFT JOIN 	GETFROMTBLSPEAKERSORCALLLISTORTBA C
	--			ON PROGRAM.PROGRAMID = C.PROGRAMID
	WHERE 
	--PROGRAM.PROGRAMID = COALESCE(@ProgramID,PROGRAM.PROGRAMID)
	--AND B.Territory = COALESCE(@Terr,B.Territory)
	PROGRAM.CANCELLED = 0
	AND B.HOSTREP = 1
	AND L.CATEGORY = 'Program Location'
	AND K.ID = (SELECT MIN(TBLSPEAKERS.ID) FROM TBLSPEAKERS 
	WHERE TBLSPEAKERS.PROGRAMID = PROGRAM.PROGRAMID)
	ORDER BY PROGRAM.PROGRAMID
	SELECT 	
	PROGRAM.PROGRAMID 
	,PROGRAM.PROGDATE AS 'Program Date'
	,L.VENDOR AS 'Location'
	,L.LCITY as 'Loc City'
	,L.LSTATE AS 'Loc St'
	,B.REPFN + ' ' + B.REPLN AS 'Rep Name'
	,B.Territory
	,IsNull(Reps.REPADD,'n/a') AS 'Rep Addr'
	,IsNull(Reps.REPCITY,'') AS 'Rep City'
	,IsNull(Reps.REPSTATE,'') AS 'Rep St'
	,IsNull(Reps.REPZIP,'')  AS 'Rep Zip'
	,Reps.REPPHONE AS 'Rep Phone'
	,Reps.REPEMAIL AS 'Rep Email'
	,K.spkrfn+' '+K.spkrln AS 'Speaker'
	,K.SpkrCounter AS 'SpkrCounter'
	FROM Program 
	LEFT JOIN Budget B 	
	ON PROGRAM.PROGRAMID = B.PROGRAMID
	LEFT JOIN Location_Info L 
	ON PROGRAM.PROGRAMID = L.PROGRAMID
	LEFT JOIN TBLSPEAKERS K
	ON PROGRAM.PROGRAMID = K.PROGRAMID
	JOIN dbo.Territory_Reps Reps
	ON B.TERRITORY = REPS.TERR
	WHERE 
    PROGRAM.PROGDATE BETWEEN "{{ range.start }}" AND "{{ range.end }}"
	AND PROGRAM.CANCELLED = 0
	AND B.HOSTREP = 1
	AND L.CATEGORY = 'Program Location'
	AND K.ID = (SELECT MIN(TBLSPEAKERS.ID) FROM TBLSPEAKERS 
	WHERE TBLSPEAKERS.PROGRAMID = PROGRAM.PROGRAMID)
	ORDER BY PROGRAM.PROGRAMID
