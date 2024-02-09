CREATE Proc [guest].[usp_GuestLuggage_Select] 
	
	@BellBoyId INT=null,
	@FromDate datetime=null,
	@ToDate datetime=null	

AS
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	--PLEASE DO NOT CHANGE THE SEQUENCE OF SELECT STATEMENT--------
   	
	--IF (@BellboyId <> 0)
		SELECT GL.LuggageTagID, GL.GuestID, 
			(SELECT  CD.FirstName + ' ' + CD.LastName FROM [HMSYOGH].[contact].[Details] CD
			INNER JOIN [HMSYOGH].[guest].[Guest] GG ON CD.ContactID=GG.ContactID
			WHERE GG.GuestID=GL.GuestID) AS GuestName,
		GL.ReservationID,  GL.BellBoyId, GL.LuggageNo, GL.LuggageType, GL.TagDescription, GL.TagQRCode, 
		GL.TagPrintingStatus, GL.IsActive, GL.CreatedBy, GL.CreatedOn,
		R.FolioNumber,R.ExpectedCheckIn,
			(SELECT top 1 PR.ROOMNO -- TODO Top 1 has to be removed and it should be room wise dat fetching
			FROM [reservation].[ReservedRoom] RR 
			INNER JOIN [HMSYOGH].[Products].[Room] PR ON RR.RoomID=PR.RoomID		
			WHERE RR.ReservationID=GL.ReservationID) AS RoomNo
		FROM   guest.GuestLuggage GL
		INNER JOIN reservation.Reservation r ON GL.ReservationID=R.ReservationID		
		WHERE  BellBoyId = @BellBoyId 

		SELECT E.EmployeeID, E.ContactID,CD.FirstName + ' ' + CD.LastName AS BellBoy FROM [HMSYOGH].[general].[Employee] E
		INNER JOIN [HMSYOGH].[contact].[Details] CD ON CD.ContactID=E.ContactID
		WHERE E.IsActive=1  AND CD.DesignationID=15
END


	
