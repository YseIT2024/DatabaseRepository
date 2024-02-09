
CREATE PROCEDURE [guest].[spCurrentAccountGetGuestCompany] 
(	
	@ReservationTypeId int = 0,
	@UserId varchar(50)	
)
AS
BEGIN
	
	 
	SET NOCOUNT ON;

	 
  IF(@ReservationTypeId = 1)
  BEGIN
			SELECT	
			GC.GuestID as CompanyID,
			CONCAT(T.Title,' ', CT.FirstName,' ',CT.LastName) as [CompanyName],
			'' AS CompanyAddress,
			A.Street AS [CompanyStreet],
			A.City AS [CompanyCity],
			A.State AS [CompanyState],
			A.ContactID AS  [CompanyCountryId], 
			C.CountryName AS CountryName,
			A.ZipCode AS [CompanyZIP],
			A.PhoneNumber AS [CompanyPhoneNumber],
			A.Email AS [CompanyEmail],
			'' AS [POCName],
			'' AS [POCDisignation],
			'' AS [POCPhone],
			'' AS [POCEmail],
			'' AS [CreatedBy],
			'' AS [CreatedOn],
			0 AS [ReservationTypeId],
			1 AS [IsActive],
			1 AS [IsCredit],
			0 AS [PaymentReceiveTypeID], 
			'' AS PaymentReceiveType,
			0 AS [CreditPeriod],
			'' as IntrestPercentageAfterCreditPeriod
			FROM [guest].Guest GC
			INNER JOIN contact.Details CT on GC.ContactID = CT.ContactID
			INNER JOIN contact.[Address] A on CT.ContactID=A.ContactID
			INNER JOIN [person].[Title] T ON CT.TitleID  = T.TitleID
			INNER JOIN [general].[Country] C on  A.CountryID = C.CountryID
			WHERE gc.GuestID in (select distinct GuestID from reservation.ReservationGuestMates 
			where ReservationID in (select ReservationID from reservation.Reservation where SalesTypeID=2))
		END
	ELSE
		BEGIN
		 SELECT	GC.[CompanyID],GC.[CompanyName],GC.[CompanyAddress],GC.[CompanyStreet]
		  ,GC.[CompanyCity],GC.[CompanyState],GC.[CompanyCountryId], CT.CountryName,GC.[CompanyZIP]
		  ,GC.[CompanyPhoneNumber],GC.[CompanyEmail],GC.[POCName],GC.[POCDisignation]
		  ,GC.[POCPhone],GC.[POCEmail],GC.[CreatedBy],GC.[CreatedOn],GC.[ReservationTypeId]		 
		  ,GC.[IsActive] ,GC.[IsCredit],GC.[PaymentReceiveTypeID], CF.[ConfigValue] as PaymentReceiveType,GC.[CreditPeriod],ISNULL(GC.IntrestPercentageAfterCreditPeriod,0) as IntrestPercentageAfterCreditPeriod
		  FROM [guest].[GuestCompany] GC
		  INNER JOIN [general].[Country] CT on GC.CompanyCountryID = CT.CountryID
		  LEFT JOIN [general].[Config] CF on GC.PaymentReceiveTypeID = CF.[ConfigID]
		 WHERE [ReservationTypeId] = @ReservationTypeId  ORDER BY GC.[CompanyID] DESC
		END
END	

