-- All Program Attendees
-- This report lets you view all program attendees on closed programs.

select p.ProgramID, p.ProgDate, pd.VendorOrHost, pd.SiteInfo, att.LName, att.FName, att.SpkrDegree, att.Specialty from tblAttendees att
	left join Program p on p.ProgramID = att.ProgramID
	left join Program_Details pd on p.ProgramID = pd.Programid
	where p.DoneDeal = 1
		and p.cancelled <> 1
		and pd.Category = 'Program Location'
		and p.ProgramID not like '0000%'
	order by p.ProgDate, p.ProgramID


