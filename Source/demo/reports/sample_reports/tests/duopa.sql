-- Duopa Travel
-- complex 
-- OPTIONS: {database: "sqlsvrduopa"}
-- VARIABLE: {name:"ev", default:"00057-DI01-15",type:"text"}

 
with ResponseData as (
select 
  a.AnswerId, 
  e.CventEventId as EventId, 
  e.EventId as EventCode, 
  r.ResponseId, 
  rr.RSVPResponseId, 
  left(a.Text, 2000) as [Text], 
  c.FieldName 
from 
  answer a 
  join choice c on c.choiceid = a.choiceid 
  join response r on r.responseid = a.responseid 
  join RSVPResponse rr on rr.responseId = r.responseId 
  join Event e on e.cventeventid = rr.eventid 
where 
  e.EventId = '{{ev}}' 
  and r.CompleteDate is not null 
  and rr.active = 1 
  and c.fieldname in (
    'First_Name', 'Last_Name', 'Email_Address', 
    'Contact_Type', 'Company', 'Additional_Travel_Comments', 
    'Airline_Preference', 'AP_SameAddress', 
    'Business_Fax_Number', 'Business_Phone_Number', 
    'Check_In_Date', 'Check_Out_Date', 
    'Departure_Time', 'Dietary_Restrictions', 
    'DOB', 'Frequent_Flier_Number', 
    'Full_Name', 'Gender', 'LA_State_Question', 
    'License_State', 'MA_State_Question', 
    'MA_State_Question_Yes', 'MN_State_Question', 
    'NPI_Number', 'Overnight_Accommodations', 
    'Preferred_Departure_Airport', 
    'Preferred_Departure_Date', 'Preferred_Return_Airport', 
    'Preferred_Return_Date', 'Prescriber_Business_Address', 
    'Prescriber_Business_City', 'Prescriber_Business_Name', 
    'Prescriber_Business_State', 'Prescriber_Business_Zip', 
    'Prescriber_First_Name', 'Prescriber_Last_Name', 
    'Prescriber_Middle_Initial', 'Prescriber_Specialty', 
    'Reserve_In_AbbVie_Block', 'Return_Time', 
    'Room_Type_Preference', 'Specialty', 
    'State_License_Number', 'Title_Degree_AP', 
    'Title_Degree_Other', 'Title_Degree_Other_AP', 
    'Travel Status', 'Badge_Name_Preference', 
    'Distance_From_Program', 'Travel_Status', 
    'User_Requires_Travel', 'VT_State_Question', 
    'Nickname', 'Professional_Designation', 
    'Title_Degree', 'Participant', 'Government_Employee', 
    'Middle_Initial', 'Cell_Phone_Number', 
    'Business_Fax_Number', 'Business_Phone_Number', 
    'Travel_Verified', 'Internal_Travel_Notes'
  ) 
)  
select 
  e.EventId as "EventCode", 
  FirstName as "First Name", 
  LastName as "Last Name", 
  isnull(aBadge_Name_Preference.Text, '') as "Full Name", 
  p.EmailAddress as "Email Address", 
  isnull(aUser_Requires_Travel.Text, '') as "User Requires Travel", 
  isnull(aTravel_Status.Text, '') as "Travel Status", 
  isnull(aDistance_To_Program.Text, '') as "Distance to Program", 
  isnull(aTravel_Verified.Text, '') as "Travel Verified", 
  isnull(aDOB.Text, '') as DOB, 
  isnull(aGender.Text, '') as Gender, 
  isnull(aAirline_Preference.Text, '') as "Airline Preference", 
  isnull(aFrequent_Flier_Number.Text, '') as "Frequent Flier Number", 
  isnull(
    aPreferred_Departure_Airport.Text, 
    ''
  ) as "Preferred Departure Airport", 
  isnull(
    aPreferred_Departure_Date.Text, 
    ''
  ) as "Preferred Departure Date", 
  isnull(aDeparture_Time.Text, '') as "Departure Time", 
  isnull(
    aPreferred_Return_Airport.Text, 
    ''
  ) as "Preferred Return Airport", 
  isnull(aPreferred_Return_Date.Text, '') as "Preferred Return Date", 
  isnull(aReturn_Time.Text, '') as "Return Time", 
  isnull(
    aReserve_In_AbbVie_Block.Text, ''
  ) as "Reserve in AbbVie Block", 
  isnull(
    aOvernight_Accomodations.Text, ''
  ) as "Overnight Accomodations", 
  isnull(aCheckInDate.Text, '') as "Check In Date", 
  isnull(aCheckOutDate.Text, '') as "Check Out Date", 
  isnull(aRoom_Type_Preference.Text, '') as "Room Type Preference", 
  isnull(
    aAdditional_Travel_Comments.Text, 
    ''
  ) as "Additional Travel Comments", 
  r.StartDate as "Original Response Date", 
  isnull(aMN_State_Question.Text, '') as "MN State Question", 
  isnull(aVT_State_Question.Text, '') as "VT State Question", 
  isnull(aFull_Name.Text, '') as "Legal Name", 
  isnull(aInternal_Travel_Notes.Text, '') as "Internal Travel Notes" 
from 
  Participant p 
  join RSVPResponse rr on rr.ParticipantId = p.ParticipantId 
  join Response r on r.responseId = rr.ResponseId 
  join Event e on e.CventEventId = p.EventId 
  join RSVPSurvey rs on rs.RSVPSurveyVersionId = rr.RSVPSurveyVersionId 
  and rs.eventId = p.eventid 
  join SurveyVersion sv on sv.SurveyVersionId = rs.SurveyVersionId 
  left join ResponseData aInternal_Travel_Notes on aInternal_Travel_Notes.RSVPResponseId = rr.RSVPResponseId 
  and aInternal_Travel_Notes.FieldName = 'Internal_Travel_Notes' 
  left join ResponseData aFull_Name on aFull_Name.RSVPResponseId = rr.RSVPResponseId 
  and aFull_Name.FieldName = 'Full_Name' 
  left join ResponseData aAdditional_Travel_Comments on aAdditional_Travel_Comments.RSVPResponseId = rr.RSVPResponseId 
  and aAdditional_Travel_Comments.FieldName = 'Additional_Travel_Comments' 
  left join ResponseData aAirline_Preference on aAirline_Preference.RSVPResponseId = rr.RSVPResponseId 
  and aAirline_Preference.FieldName = 'Airline_Preference' 
  left join ResponseData aCheckInDate on aCheckInDate.RSVPResponseId = rr.RSVPResponseId 
  and aCheckInDate.FieldName = 'Check_In_Date' 
  left join ResponseData aCheckOutDate on aCheckOutDate.RSVPResponseId = rr.RSVPResponseId 
  and aCheckOutDate.FieldName = 'Check_Out_Date' 
  left join ResponseData aDeparture_Time on aDeparture_Time.RSVPResponseId = rr.RSVPResponseId 
  and aDeparture_Time.FieldName = 'Departure_Time' 
  left join ResponseData aDietary_Restrictions on aDietary_Restrictions.RSVPResponseId = rr.RSVPResponseId 
  and aDietary_Restrictions.FieldName = 'Dietary_Restrictions' 
  left join ResponseData aDistance_To_Program on aDistance_To_Program.RSVPResponseId = rr.RSVPResponseId 
  and aDistance_To_Program.FieldName = 'Distance_From_Program' 
  left join ResponseData aDOB on aDOB.RSVPResponseId = rr.RSVPResponseId 
  and aDOB.FieldName = 'DOB' 
  left join ResponseData aFrequent_Flier_Number on aFrequent_Flier_Number.RSVPResponseId = rr.RSVPResponseId 
  and aFrequent_Flier_Number.FieldName = 'Frequent_Flier_Number' 
  left join ResponseData aGender on aGender.RSVPResponseId = rr.RSVPResponseId 
  and aGender.FieldName = 'Gender' 
  left join ResponseData aLA_State_Question on aLA_State_Question.RSVPResponseId = rr.RSVPResponseId 
  and aLA_State_Question.FieldName = 'LA_State_Question' 
  left join ResponseData aLicenseState on aLicenseState.RSVPResponseId = rr.RSVPResponseId 
  and aLicenseState.FieldName = 'LicenseState' 
  left join ResponseData aMA_State_Question on aMA_State_Question.RSVPResponseId = rr.RSVPResponseId 
  and aMA_State_Question.FieldName = 'MA_State_Question' 
  left join ResponseData aMA_State_Question_Yes on aMA_State_Question_Yes.RSVPResponseId = rr.RSVPResponseId 
  and aMA_State_Question_Yes.FieldName = 'MA_State_Question_Yes' 
  left join ResponseData aMN_State_Question on aMN_State_Question.RSVPResponseId = rr.RSVPResponseId 
  and aMN_State_Question.FieldName = 'MN_State_Question' 
  left join ResponseData aNPI_Number on aNPI_Number.RSVPResponseId = rr.RSVPResponseId 
  and aNPI_Number.FieldName = 'NPI_Number' 
  left join ResponseData aOvernight_Accomodations on aOvernight_Accomodations.RSVPResponseId = rr.RSVPResponseId 
  and aOvernight_Accomodations.FieldName = 'Overnight_Accommodations' 
  left join ResponseData aAP_SameAddress on aAP_SameAddress.RSVPResponseId = rr.RSVPResponseId 
  and aAP_SameAddress.FieldName = 'AP_SameAddress' 
  left join ResponseData aPreferred_Departure_Airport on aPreferred_Departure_Airport.RSVPResponseId = rr.RSVPResponseId 
  and aPreferred_Departure_Airport.FieldName = 'Preferred_Departure_Airport' 
  left join ResponseData aPreferred_Departure_Date on aPreferred_Departure_Date.RSVPResponseId = rr.RSVPResponseId 
  and aPreferred_Departure_Date.FieldName = 'Preferred_Departure_Date' 
  left join ResponseData aPreferred_Return_Airport on aPreferred_Return_Airport.RSVPResponseId = rr.RSVPResponseId 
  and aPreferred_Return_Airport.FieldName = 'Preferred_Return_Airport' 
  left join ResponseData aPreferred_Return_Date on aPreferred_Return_Date.RSVPResponseId = rr.RSVPResponseId 
  and aPreferred_Return_Date.FieldName = 'Preferred_Return_Date' 
  left join ResponseData aPrescriber_Business_Address on aPrescriber_Business_Address.RSVPResponseId = rr.RSVPResponseId 
  and aPrescriber_Business_Address.FieldName = 'Prescriber_Business_Address' 
  left join ResponseData aPrescriber_Business_City on aPrescriber_Business_City.RSVPResponseId = rr.RSVPResponseId 
  and aPrescriber_Business_City.FieldName = 'Prescriber_Business_City' 
  left join ResponseData aPrescriber_Business_Name on aPrescriber_Business_Name.RSVPResponseId = rr.RSVPResponseId 
  and aPrescriber_Business_Name.FieldName = 'Prescriber_Business_Name' 
  left join ResponseData aPrescriber_Business_State on aPrescriber_Business_State.RSVPResponseId = rr.RSVPResponseId 
  and aPrescriber_Business_State.FieldName = 'Prescriber_Business_State' 
  left join ResponseData aPrescriber_Business_Zip on aPrescriber_Business_Zip.RSVPResponseId = rr.RSVPResponseId 
  and aPrescriber_Business_Zip.FieldName = 'Prescriber_Business_Zip' 
  left join ResponseData aPrescriber_First_Name on aPrescriber_First_Name.RSVPResponseId = rr.RSVPResponseId 
  and aPrescriber_First_Name.FieldName = 'Prescriber_First_Name' 
  left join ResponseData aPrescriber_Last_Name on aPrescriber_Last_Name.RSVPResponseId = rr.RSVPResponseId 
  and aPrescriber_Last_Name.FieldName = 'Prescriber_Last_Name' 
  left join ResponseData aPrescriber_Middle_Initial on aPrescriber_Middle_Initial.RSVPResponseId = rr.RSVPResponseId 
  and aPrescriber_Middle_Initial.FieldName = 'Prescriber_Middle_Initial' 
  left join ResponseData aPrescriber_Specialty on aPrescriber_Specialty.RSVPResponseId = rr.RSVPResponseId 
  and aPrescriber_Specialty.FieldName = 'Prescriber_Specialty' 
  left join ResponseData aReserve_In_AbbVie_Block on aReserve_In_AbbVie_Block.RSVPResponseId = rr.RSVPResponseId 
  and aReserve_In_AbbVie_Block.FieldName = 'Reserve_In_AbbVie_Block' 
  left join ResponseData aReturn_Time on aReturn_Time.RSVPResponseId = rr.RSVPResponseId 
  and aReturn_Time.FieldName = 'Return_Time' 
  left join ResponseData aRoom_Type_Preference on aRoom_Type_Preference.RSVPResponseId = rr.RSVPResponseId 
  and aRoom_Type_Preference.FieldName = 'Room_Type_Preference' 
  left join ResponseData aSpecialty on aSpecialty.RSVPResponseId = rr.RSVPResponseId 
  and aSpecialty.FieldName = 'Specialty' 
  left join ResponseData aState_License_Number on aState_License_Number.RSVPResponseId = rr.RSVPResponseId 
  and aState_License_Number.FieldName = 'State_License_Number' 
  left join ResponseData aTitle_Degree_AP on aTitle_Degree_AP.RSVPResponseId = rr.RSVPResponseId 
  and aTitle_Degree_AP.FieldName = 'Title_Degree_AP' 
  left join ResponseData aTitle_Degree_Other on aTitle_Degree_Other.RSVPResponseId = rr.RSVPResponseId 
  and aTitle_Degree_Other.FieldName = 'Title_Degree_Other' 
  left join ResponseData aTitle_Degree_Other_AP on aTitle_Degree_Other_AP.RSVPResponseId = rr.RSVPResponseId 
  and aTitle_Degree_Other_AP.FieldName = 'Title_Degree_Other_AP' 
  left join ResponseData aTravel_Status on aTravel_Status.RSVPResponseId = rr.RSVPResponseId 
  and aTravel_Status.FieldName = 'Travel_Status' 
  left join ResponseData aUser_Requires_Travel on aUser_Requires_Travel.RSVPResponseId = rr.RSVPResponseId 
  and aUser_Requires_Travel.FieldName = 'User_Requires_Travel' 
  left join ResponseData aVT_State_Question on aVT_State_Question.RSVPResponseId = rr.RSVPResponseId 
  and aVT_State_Question.FieldName = 'VT_State_Question' 
  left join ResponseData aNickname on aNickname.RSVPResponseId = rr.RSVPResponseId 
  and aNickname.FieldName = 'Nickname' 
  left join ResponseData aDesignation on aDesignation.RSVPResponseId = rr.RSVPResponseId 
  and aDesignation.FieldName = 'Professional_Designation' 
  left join ResponseData aTitle on aTitle.RSVPResponseId = rr.RSVPResponseId 
  and aTitle.FieldName = 'Title_Degree' 
  left join ResponseData aParticipant on aParticipant.RSVPResponseId = rr.RSVPResponseId 
  and aParticipant.FieldName = 'Participant' 
  left join ResponseData aGovernment_Employee on aGovernment_Employee.RSVPResponseId = rr.RSVPResponseId 
  and aGovernment_Employee.FieldName = 'Government_Employee' 
  left join ResponseData aMiddle_Initial on aMiddle_Initial.RSVPResponseId = rr.RSVPResponseId 
  and aMiddle_Initial.FieldName = 'Middle_Initial' 
  left join ResponseData aCell_Phone_Number on aCell_Phone_Number.RSVPResponseId = rr.RSVPResponseId 
  and aCell_Phone_Number.FieldName = 'Cell_Phone_Number' 
  left join ResponseData aBusiness_Phone_Number on aBusiness_Phone_Number.RSVPResponseId = rr.RSVPResponseId 
  and aBusiness_Phone_Number.FieldName = 'Business_Phone_Number' 
  left join ResponseData aBusiness_Fax_Number on aBusiness_Fax_Number.RSVPResponseId = rr.RSVPResponseId 
  and aBusiness_Fax_Number.FieldName = 'Business_Fax_Number' 
  left join ResponseData aBadge_Name_Preference on aBadge_Name_Preference.RSVPResponseId = rr.RSVPResponseId 
  and aBadge_Name_Preference.FieldName = 'Badge_Name_Preference' 
  left join ResponseData aTravel_Verified on aTravel_Verified.RSVPResponseId = rr.RSVPResponseId 
  and aTravel_Verified.FieldName = 'Travel_Verified' 
where 
  e.EventId = '{{ev}}' 
  and p.Active = 1 
  and r.CompleteDate is not null