CREATE PROC [Housekeeping].[usp_HKGuestTickets_IncidentReportNEW] --1144,77
			@TicketId int=null,
			@UserId INT	=null,
			@ReservationID INT=null,
			@LocationID int=null
				
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON	
			DECLARE @CREATEDBY nvarchar(100);
			DECLARE @PrintBy nvarchar(100);
			set @CREATEDBY=(Select CD.FirstName from [Housekeeping].[GuestTickets]  hgt
							inner join app.[User] au on hgt.CreatedBy=au.UserID
							inner join [contact].[Details] CD on au.ContactID=CD.ContactID where hgt.TicketId=@TicketId)
			set @PrintBy=(Select CD.FirstName from [Housekeeping].[GuestTickets]  hgt
							inner join app.[User] au on hgt.CreatedBy=au.UserID
							inner join [contact].[Details] CD on au.ContactID=CD.ContactID where hgt.TicketId=@TicketId)

			SELECT hgt.TicketId,hgt.TicketTypeId,hgt.GuestTypeId,hgt.RoomId,hgt.ReservationNo,hgt.Guestname,
				hgt.RequestFor,hgt.Subject,hgt.Description,hgt.RequestDate,hgt.RequestTime,hgt.Assignee,
				hgt.Status,hgt.ActionBy,hgt.ActionDate,hgt.ActionNarration,hgt.CreatedOn,hgt.LocationId,
				rrv.ReservationTypeID,rrv.ReservationModeID,rrv.ActualCheckIn,
				CASE WHEN rrv.ReservationStatusID=4 THEN rrv.ActualCheckOut ELSE rrv.ExpectedCheckOut END AS CheckOutDate,
				CASE WHEN RRV.ReservationTypeID > 1 THEN 
					(SELECT CompanyName FROM [guest].[GuestCompany] where CompanyID=rrv.CompanyTypeID) 	
				ELSE 'Normal Booking'		END		BookerName,
				ggt.ContactID, cdt.dob,cdt.IDCardTypeID,cdt.IDCardNumber,cad.Email,cad.PhoneNumber,
				--cad.Street,cad.City,cad.State,
				--CONCAT_WS(', ', NULLIF(cad.Street, ''), NULLIF(cad.City, ''), NULLIF(cad.State, '')) AS Address,
				NULLIF(cad.Street, '') + ', ' + NULLIF(cad.City, '') + ', ' + NULLIF(cad.State, '') AS Address,
				@CREATEDBY As CreatedBy ,@PrintBy As PrintBy,rrm.ReservationMode
		
			FROM [Housekeeping].[GuestTickets] hgt
			INNER JOIN  [reservation].[Reservation] rrv on hgt.ReservationNo=rrv.ReservationID
			INNER JOIN guest.Guest ggt on rrv.GuestID=ggt.GuestID
			INNER JOIN contact.Details cdt on ggt.ContactID=cdt.ContactID
			INNER JOIN contact.Address cad on ggt.ContactID=cad.ContactID
			INNER JOIN [reservation].[ReservationMode] rrm on rrv.ReservationModeID=rrm.ReservationModeID
			Where hgt.TicketId=@TicketId
	
	 
END	