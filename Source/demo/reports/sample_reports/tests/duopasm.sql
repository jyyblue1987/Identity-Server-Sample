-- Duopa Travel Simple
-- test
-- OPTIONS: {database: "sqlsvrduopa"}

select 
                e.EventId,
                isnull(FirstName, '') as "First Name", 
                isnull(LastName, '') as "Last Name",
                isnull(BadgeName, '') as Nickname,
                isnull(TitleDegree, '') as Title,
                isnull(BusinessName, '') as Company,
                isnull(BusinessCity, '') as "Work City",
                isnull(BusinessState, '') as "Work State/Prov."
from Participant p
join Event e 
                on e.CventEventId = p.EventId
join RSVPResponse rr
                on rr.participantId = p.ParticipantId
join Response r
                on r.responseid = rr.responseid
where p.active = 1
  and r.COmpleteDate is not null
order by 1
