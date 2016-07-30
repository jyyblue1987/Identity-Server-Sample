-- Cost per Attendee
-- This report lets you view all cost per attendee by program and program type.

select p.ProgramID, p.ProgDate, SUM(e.ExpenseAmt) as [ExpenseTotal], p.ActualAtt, SUM(e.ExpenseAmt) / p.ActualAtt as [Meal Cost Per Attendee],
	case when p.Dinner = 1 then 'Out-of-Office Dinner' else 
		case when p.in_office_dinner = 1 then 'In-Office Dinner' else
			case when p.out_of_office_luncheon = 1 then 'Out-of-Office Luncheon' else
				case when p.in_office_luncheon = 1 then 'In-Office Luncheon' else
					case when p.out_office_breakfast = 1 then 'Out-of-Office Breakfast' else
						case when p.in_office_breakfast = 1 then 'In-Office Breakfast' else
							case when p.Out_Office_Teleconference = 1 then 'Out-of-Office Teleconference' else
								case when p.In_Office_Teleconference = 1 then 'In-Office Teleconference' else
									case when p.Out_Office_Webinar = 1 then 'Out-of-Office Webinar' else
										case when p.In_Office_Webinar = 1 then 'In-Office Webinar' end
									end
								end
							end
						end
					end
				end
			end
		end
	end as [Program Type]
	from Program p 
		inner join Expenses e on p.ProgramID = e.ProgramID and e.ExpenseType = 'Catering'
	where p.Out_Office_Webinar <> 1 
		and p.In_Office_Webinar <> 1 
		and p.cancelled <> 1 
		and p.DoneDeal = 1
		and p.ProgramID not like '0000%'
		and p.ProgramID not like 'KPA%'
	group by p.ProgramID, p.ProgDate, p.ActualAtt,
		p.Dinner, p.in_office_dinner, p.out_of_office_luncheon, p.in_office_luncheon,
		p.out_office_breakfast, p.in_office_breakfast, p.Out_Office_Teleconference,
		p.In_Office_Teleconference, p.Out_Office_Webinar, p.In_Office_Webinar
