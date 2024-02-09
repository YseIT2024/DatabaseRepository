CREATE PROCEDURE [reservation].[spGetGuestLedger] ---1,77 
(	
   -- @FolioNumber int null,
	--@ReservationID int null,
	@LocationID int,
	--@DrawerID int,
	@UserId int,
	@FromDate datetime Null,
	@ToDate datetime Null,
	@ReservationStatusId int =0,
	@GuestOrCompanyId int=0,
	@GuestOrCompanyTypeId int=0

	
)
AS
Begin
SET NOCOUNT ON;	

	  DECLARE @Debit decimal=0;
	  DECLARE @Credit decimal=0;
	  DECLARE @Balance int=0;

	 if(@ReservationStatusId >0 )

		Begin
			SELECT DISTINCT RS.[ReservationID] ,RS.[FolioNumber] ,RS.[GuestID],RS.[ReservationStatusID],
				FORMAT([ExpectedCheckIn],'dd-MMM-yyyy HH:mm:ss') AS [ExpectedCheckIn],
				FORMAT([ExpectedCheckOut],'dd-MMM-yyyy HH:mm:ss') AS [ExpectedCheckOut],
				--FORMAT([ExpectedCheckOut],'HH:mm') AS [ExpectedCheckInTime],
				--FORMAT([ExpectedCheckOut],'HH:mm') AS [ExpectedCheckOutTime],
				--RS.Nights
				--,CC.CurrencyCode
				--,RS.Adults
				--,RI.InvoiceNo
				TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS [Name]
				,AD.[PhoneNumber],(select [reservation].[fnGetReserveredRoom](RS.ReservationID)) as RoomNos
				--(select top (1) pr.RoomNo from [reservation].[ReservedRoom] rrr inner join [Products].[Room] pr on rrr.RoomID=pr.RoomID where rrr.reservationid=rs.ReservationID) roomno
				,(CASE When LEN(AD.[Street]) > 0 THEN Ad.[Street] +', ' ELSE '' END) + (CASE When LEN(AD.[City]) > 0 THEN AD.[City] +', ' ELSE '' END)
				+ (CASE When LEN(AD.[State]) > 0 THEN AD.[State] +', ' ELSE '' END) + CN.[CountryName] + (CASE When LEN(AD.[ZipCode]) > 0 THEN ', '+ AD.[ZipCode]  ELSE '' END) as [Address]

				,(SELECT IsNull(SUM(AmtAfterTax),0) FROM [account].[GuestLedgerDetails] WHERE [FolioNo]=RS.[FolioNumber]) AS DebitAmount
			
				,(SELECT IsNull(SUM([Amount]),0) FROM [account].[Transaction] WHERE ReservationID=RS.[ReservationID] and GuestCompanyId=@GuestOrCompanyId and GuestCompanyTypeId=@GuestOrCompanyTypeId) AS CreditAmount

				--,isnull((SELECT SUM(AmtAfterTax) FROM [account].[GuestLedgerDetails] WHERE [FolioNo]=RS.[FolioNumber])-(SELECT SUM([Amount]) FROM [account].[Transaction] WHERE ReservationID=RS.[ReservationID]),0) AS Balance
				,CASE WHEN (SELECT TOP(1)TaxRefNo from [reservation].[TaxExemptionDetails] where  reservationid=RS.ReservationID) IS NOT NULL THEN 
				(SELECT isnull(SUM(AmtAfterTax),0) FROM [account].[GuestLedgerDetails] WHERE [FolioNo]=RS.[FolioNumber])-(SELECT isnull(SUM([Amount]),0) FROM [account].[Transaction] WHERE ReservationID=RS.[ReservationID])-RS.AdditionalDiscountAmount - (SELECT IsNull(SUM(AmtTax),0) FROM [account].[GuestLedgerDetails] WHERE [FolioNo]=RS.[FolioNumber])
				ELSE
				(SELECT isnull(SUM(AmtAfterTax),0) FROM [account].[GuestLedgerDetails] WHERE [FolioNo]=RS.[FolioNumber])-(SELECT isnull(SUM([Amount]),0) FROM [account].[Transaction] WHERE ReservationID=RS.[ReservationID])-RS.AdditionalDiscountAmount END AS Balance
				,RS.AdditionalDiscountAmount
				,RS.AdditionalDiscount
				,RT.ReservationType,RT.ReservationTypeID
				FROM [reservation].[Reservation] RS
				inner join reservation.ReservationStatus RSD on rs.ReservationStatusID=RSD.ReservationStatusID
				inner join [reservation].[ReservationDetails] RD on RS.ReservationID = RD.ReservationID
				inner join [guest].[Guest] GT on RS.GuestID = GT.GuestID
				inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
				inner join [contact].[Address] AD on  CD.ContactID = AD.ContactID
				inner join [general].[Country] CN on AD.CountryID = CN.CountryID
				inner join [person].[Title] TL on CD.TitleID = TL.TitleID
				INNER JOIN currency.Currency CC On CC.CurrencyID=RS.CurrencyID
				INNER JOIN [reservation].[ReservationType] RT On RS.ReservationTypeID=RT.ReservationTypeID
				LEFT JOIN reservation.Invoice RI ON RS.FolioNumber=RI.FolioNumber 
				inner join [general].[Location] LC on RS.LocationID = LC.LocationID where RS.LocationID = 1 
				--And RS.ReservationStatusID not in (17,12,2,1)  commented on 25/12/2023
				and rs.ExpectedCheckIn >=	@FromDate and rs.ExpectedCheckIn<=	@ToDate 
		End
	 else if(@ReservationStatusId is null or @ReservationStatusId=0 )
		Begin	 
	
					SELECT DISTINCT RS.[ReservationID] ,RS.[FolioNumber] ,RS.[GuestID] ,RS.[ReservationStatusID],
				FORMAT([ExpectedCheckIn],'dd-MMM-yyyy HH:mm:ss') AS [ExpectedCheckIn],
				FORMAT([ExpectedCheckOut],'dd-MMM-yyyy HH:mm:ss') AS [ExpectedCheckOut],
				--FORMAT([ExpectedCheckOut],'HH:mm') AS [ExpectedCheckInTime],
				--FORMAT([ExpectedCheckOut],'HH:mm') AS [ExpectedCheckOutTime],
				--RS.Nights
				--,CC.CurrencyCode
				--,RS.Adults,
				--RI.InvoiceNo
	
				TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS [Name]
				,AD.[PhoneNumber],(select [reservation].[fnGetReserveredRoom](RS.ReservationID)) as RoomNos
				--(select top (1) pr.RoomNo from [reservation].[ReservedRoom] rrr inner join [Products].[Room] pr on rrr.RoomID=pr.RoomID where rrr.reservationid=rs.ReservationID) roomno
				,(CASE When LEN(AD.[Street]) > 0 THEN Ad.[Street] +', ' ELSE '' END) + (CASE When LEN(AD.[City]) > 0 THEN AD.[City] +', ' ELSE '' END)
				+ (CASE When LEN(AD.[State]) > 0 THEN AD.[State] +', ' ELSE '' END) + CN.[CountryName] + (CASE When LEN(AD.[ZipCode]) > 0 THEN ', '+ AD.[ZipCode]  ELSE '' END) as [Address]

				,(SELECT IsNull(SUM(AmtAfterTax),0) FROM [account].[GuestLedgerDetails] WHERE [FolioNo]=RS.[FolioNumber]) AS DebitAmount
				
				,(SELECT IsNull(SUM([Amount]),0) FROM [account].[Transaction] WHERE ReservationID=RS.[ReservationID] and GuestCompanyId=@GuestOrCompanyId and GuestCompanyTypeId=@GuestOrCompanyTypeId) AS CreditAmount
				--(SELECT isnull(SUM(AmtAfterTax),0) FROM [account].[GuestLedgerDetails] WHERE [FolioNo]=RS.[FolioNumber])-(SELECT isnull(SUM([Amount]),0) FROM [account].[Transaction] WHERE ReservationID=RS.[ReservationID])
				
				,CASE WHEN (SELECT TOP(1)TaxRefNo from [reservation].[TaxExemptionDetails] where  reservationid=RS.ReservationID) IS NOT NULL THEN 
				(SELECT isnull(SUM(AmtAfterTax),0) FROM [account].[GuestLedgerDetails] WHERE [FolioNo]=RS.[FolioNumber])-(SELECT isnull(SUM([Amount]),0) FROM [account].[Transaction] WHERE ReservationID=RS.[ReservationID])-RS.AdditionalDiscountAmount - (SELECT IsNull(SUM(AmtTax),0) FROM [account].[GuestLedgerDetails] WHERE [FolioNo]=RS.[FolioNumber])
				ELSE
				(SELECT isnull(SUM(AmtAfterTax),0) FROM [account].[GuestLedgerDetails] WHERE [FolioNo]=RS.[FolioNumber])-(SELECT isnull(SUM([Amount]),0) FROM [account].[Transaction] WHERE ReservationID=RS.[ReservationID])-RS.AdditionalDiscountAmount 
				END
				AS Balance
   
				,RS.AdditionalDiscountAmount
				,RS.AdditionalDiscount
				,RT.ReservationType,RT.ReservationTypeID
				FROM [reservation].[Reservation] RS
				inner join reservation.ReservationStatus RSD on rs.ReservationStatusID=RSD.ReservationStatusID
				inner join [reservation].[ReservationDetails] RD on RS.ReservationID = RD.ReservationID
				inner join [guest].[Guest] GT on RS.GuestID = GT.GuestID
				inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
				inner join [contact].[Address] AD on  CD.ContactID = AD.ContactID
				inner join [general].[Country] CN on AD.CountryID = CN.CountryID
				inner join [person].[Title] TL on CD.TitleID = TL.TitleID
				INNER JOIN currency.Currency CC On CC.CurrencyID=RS.CurrencyID
				INNER JOIN [reservation].[ReservationType] RT On RS.ReservationTypeID=RT.ReservationTypeID
				LEFT JOIN reservation.Invoice RI ON RS.FolioNumber=RI.FolioNumber 
				inner join [general].[Location] LC on RS.LocationID = LC.LocationID where RS.LocationID = 1 And RSD.ReservationStatusID=3	
	    End
END
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





