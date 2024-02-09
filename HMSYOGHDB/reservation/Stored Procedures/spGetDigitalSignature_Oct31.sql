
-- =============================================
-- Author:		VASANTHAKUMAR
-- Create date: 23/08/2023
-- Description:	Get Guest Digital Signature 
-- =============================================
Create PROCEDURE [reservation].[spGetDigitalSignature_Oct31]
(
	@InvoiceNo int
	--@SignatureRequest int null,
	--@UserId int null
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 
	--SELECT 
	--   [GuestSignatureID]
 --     ,[InvoiceNo]
 --     ,[GuestSugnature]
 --     ,[GuestName] from [reservation].[GuestSignature] where [InvoiceNo]=@InvoiceNo
	if (@InvoiceNo > 0)
	Begin
		Update [reservation].[InvoiceSignatureTickets]
		set [Status]=0

		INSERT INTO [reservation].[InvoiceSignatureTickets]
           ([InvoiceNo],[Status],[CreatedOn])          
		VALUES
           (@InvoiceNo,1,getdate())     
	 
	  SELECT 
			RI.[InvoiceNo],
			RI.[InvoiceDate],
			RI.[FolioNumber],
			RI.[GRCNo],
			RI.[GSTIN],
			RI.[TotalAmountBeforeTax],
			RI.[ServiceTaxAmount] as VatAmount,
			RI.[VatAmount] as ServiceTaxAmount,
			RI.[TotalAmountAfterTax],
			RI.[AdditionalDiscount],
			RI.[RoundOffAmount],
			RI.[TotalAmountNet],
			RI.[InvoiceStatus] as InvoiceStatus,
			RI.[PrintStatus] as PrintStatus,
			RI.[Remarks],RI.[CreatedBy],
			RI.[CreatedBy]
			,FORMAT(RI.[CreatedOn],'dd-MMM-yyyy hh:mm tt')as [CreatedOn]
			,RS.[GuestID],gc.CompanyName  as BillTo,
			TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS [GuestName],	
			RS.[ReservationStatusID],FORMAT(RS.[ActualCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckIn]	,FORMAT(RS.[ActualCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckOut]	
			,FORMAT(RS.[ExpectedCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckIn],FORMAT(RS.[ExpectedCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckOut],								
			RT.[ReservationTypeID]	,RT.[ReservationType],RM.[ReservationMode],	
			RS.Rooms,RS.Nights,RS.Adults, RS.Children
			,AD.[PhoneNumber]
			,(CASE When LEN(AD.[Street]) > 0 THEN Ad.[Street] +', ' ELSE '' END) + (CASE When LEN(AD.[City]) > 0 THEN AD.[City] +', ' ELSE '' END)
			+ (CASE When LEN(AD.[State]) > 0 THEN AD.[State] +', ' ELSE '' END) + CN.[CountryName] + (CASE When LEN(AD.[ZipCode]) > 0 THEN ', '+ AD.[ZipCode]  ELSE '' END) as [Address],
			(select GuestSignature from [reservation].[GuestSignature]  where InvoiceNo=@InvoiceNo and IsActive=1) as GuestSignature,
			(select ManagerSignature from [reservation].[GuestSignature]  where InvoiceNo=@InvoiceNo and IsActive=1) as ManagerSignature
			FROM [reservation].[Invoice] RI
			INNER JOIN [reservation].[Reservation] RS ON RI.FolioNumber=RS.FolioNumber
			inner join [reservation].[ReservationType] RT on RS.ReservationTypeID = RT.ReservationTypeID
			inner join [reservation].[ReservationMode] RM on RS.ReservationModeID = RM.ReservationModeID
			
			inner join [guest].[Guest] GT on RI.GuestID = GT.GuestID
			inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
			inner join [contact].[Address] AD on  CD.ContactID = AD.ContactID
			inner join [general].[Country] CN on AD.CountryID = CN.CountryID
			inner join [person].[Title] TL on CD.TitleID = TL.TitleID
			inner join [general].[Location] LC on RS.LocationID = LC.LocationID
			inner join [general].[company] gc on rs.CompanyID=gc.CompanyID
			WHERE RI.InvoiceNo=@InvoiceNo 


			End
			ELSE
			BEGIN

			 SELECT 
			RI.[InvoiceNo],
			RI.[InvoiceDate],
			RI.[FolioNumber],
			RI.[GRCNo],
			RI.[GSTIN],
			RI.[TotalAmountBeforeTax],
			RI.[ServiceTaxAmount] as VatAmount,
			RI.[VatAmount] as ServiceTaxAmount,
			RI.[TotalAmountAfterTax],
			RI.[AdditionalDiscount],
			RI.[RoundOffAmount],
			RI.[TotalAmountNet],
			RI.[InvoiceStatus] as InvoiceStatus,
			RI.[PrintStatus] as PrintStatus,
			RI.[Remarks],RI.[CreatedBy],
			RI.[CreatedBy]
			,FORMAT(RI.[CreatedOn],'dd-MMM-yyyy hh:mm tt')as [CreatedOn]
			,RS.[GuestID],gc.CompanyName  as BillTo,
			TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS [GuestName],	
			RS.[ReservationStatusID],FORMAT(RS.[ActualCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckIn]	,FORMAT(RS.[ActualCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckOut]	
			,FORMAT(RS.[ExpectedCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckIn],FORMAT(RS.[ExpectedCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckOut],								
			RT.[ReservationTypeID]	,RT.[ReservationType],RM.[ReservationMode],	
			RS.Rooms,RS.Nights,RS.Adults, RS.Children
			,AD.[PhoneNumber]
			,(CASE When LEN(AD.[Street]) > 0 THEN Ad.[Street] +', ' ELSE '' END) + (CASE When LEN(AD.[City]) > 0 THEN AD.[City] +', ' ELSE '' END)
			+ (CASE When LEN(AD.[State]) > 0 THEN AD.[State] +', ' ELSE '' END) + CN.[CountryName] + (CASE When LEN(AD.[ZipCode]) > 0 THEN ', '+ AD.[ZipCode]  ELSE '' END) as [Address],
			(select GuestSignature from [reservation].[GuestSignature]  where InvoiceNo=RI.InvoiceNo and IsActive=1) as GuestSignature,
			(select ManagerSignature from [reservation].[GuestSignature]  where InvoiceNo=RI.InvoiceNo and IsActive=1) as ManagerSignature
			FROM [reservation].[Invoice] RI
			INNER JOIN [reservation].[Reservation] RS ON RI.FolioNumber=RS.FolioNumber
			inner join [reservation].[ReservationType] RT on RS.ReservationTypeID = RT.ReservationTypeID
			inner join [reservation].[ReservationMode] RM on RS.ReservationModeID = RM.ReservationModeID
			
			inner join [guest].[Guest] GT on RI.GuestID = GT.GuestID
			inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
			inner join [contact].[Address] AD on  CD.ContactID = AD.ContactID
			inner join [general].[Country] CN on AD.CountryID = CN.CountryID
			inner join [person].[Title] TL on CD.TitleID = TL.TitleID
			inner join [general].[Location] LC on RS.LocationID = LC.LocationID
			inner join [general].[company] gc on rs.CompanyID=gc.CompanyID
			WHERE RI.InvoiceNo=(SELECT TOP(1) InvoiceNo FROM [reservation].[InvoiceSignatureTickets] WHERE Status=1 ORDER BY InvoiceNo DESC) 

			END


END


