-- All Speakers
-- This report lets you view all speaker details


	SELECT 	
	K.spkrfn+' '+K.spkrln AS 'Speaker'
	,K.SpkrCounter AS 'SpkrCounter'
	FROM TBLSPEAKERS K
    ORDER BY 1