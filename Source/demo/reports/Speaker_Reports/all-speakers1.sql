-- All Speakers
-- This report lets you view all speaker details


	SELECT DISTINCT
			S.SpkrCounter, S.Spkrln, S.Spkrfn, rtrim(S.Spkrln) + ', ' + ltrim(S.Spkrfn) + ISNULL(' ' + s.Degree ,'') as Speaker
			, CASE S.CVReceived WHEN 1 THEN 'Y' ELSE '' END as CVStatus
			, S.Spkrcity as City
			, S.Spkrstate as State
			, dbo.uf_getSpeakerRating(S.SpkrCounter) as SpeakerRating
			, CASE WHEN LEN(RTRIM(SpeakerBio))>0 THEN 'Y' ELSE '' END HasBio
			,ISNULL(SpeakerBio,'') as Bio
			,dbo.fn_GetSpeakerReps(s.SpkrCounter) as AssociatedRep
			,dbo.fn_GetTrainedSlidekits(s.SpkrCounter) as TrainedSlidekits

			----,  P.Product  AS Product
	FROM	 Speaker  S with(nolock)
			left join Speaker_Training_Programs  STP  WITH(NOLOCK)
			ON
				STP.SpkrCounter = S.SpkrCounter
			left JOIN TrainingPrograms  TP with(nolock) ON
				STP.TrainingProgramID = TP.TrainingID
			left join Slidekits as SK with(nolock)
				on SK.SlidekitID = TP.SlideKitID 
			left join tblslidesent  as Downloaded with(nolock)
				on Downloaded.SpkrCounter = s.SpkrCounter and 	 Downloaded.KitSent = SK.SlidekitID 
			
	WHERE	S.Inactive <> 1
			AND STP.SpkrCounter  NOT IN (36690,14029,36729)
	order by s.Spkrln; 