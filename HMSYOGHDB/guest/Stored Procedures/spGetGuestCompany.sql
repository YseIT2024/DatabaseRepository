CREATE PROCEDURE [guest].[spGetGuestCompany] 
(	
	@ReservationTypeId int = 0,	
	@GuestCompanyID int = 0,
	@UserId varchar(50)	
)
AS
BEGIN
	
	--SET NOCOUNT ON prevents the sending of DONEINPROC messages to the client for each statement in a stored procedure
	SET NOCOUNT ON;

	--DECLARE @IsSuccess bit = 0;
	--DECLARE @Message varchar(max) = '';	

	--SET @Message = 'Company has been added successfully.';

	IF(@GuestCompanyID <> 0)
		BEGIN
		SELECT	[CompanyID] ,[CompanyName],[CompanyAddress],[CompanyStreet]
      ,[CompanyCity],[CompanyState],[CompanyCountryId],[CompanyZIP]
      ,[CompanyPhoneNumber],[CompanyEmail],[POCName],[POCDisignation]
      ,[POCPhone],[POCEmail],[CreatedBy],[CreatedOn]
      ,[Para1],[Para2],[Para3],[Para4]
      ,[Para5],[Para6],[ReservationTypeId]
      ,[IsActive],ISNULL(IntrestPercentageAfterCreditPeriod,0) as IntrestPercentageAfterCreditPeriod FROM [guest].[GuestCompany] WHERE [CompanyID] =@GuestCompanyID 
	 
		END
	ELSE IF(@ReservationTypeId <> 0)
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
	ELSE
		BEGIN
		--SELECT	[CompanyID],[CompanyName],[CompanyAddress],[CompanyStreet]
		--  ,[CompanyCity],[CompanyState],[CompanyCountryId],[CompanyZIP]
		--  ,[CompanyPhoneNumber],[CompanyEmail],[POCName],[POCDisignation]
		--  ,[POCPhone],[POCEmail],[CreatedBy],[CreatedOn]
		--  ,[Para1],[Para2],[Para3],[Para4]
		--  ,[Para5],[Para6],[ReservationTypeId]
		--  ,[IsActive] FROM [guest].[GuestCompany]

		--SELECT [SubCategoryID] as RoomTypeID,[Name] as RoomType 
		--FROM  [Products].[SubCategory] where [CategoryID] = 1 


		--SELECT [CompanyID] as CustomerID,[CompanyName] as CustomerName FROM [guest].[GuestCompany]  Commented by Arabinda on 17-04-2023

		SELECT GC.[CompanyID] as CustomerID,GC.[CompanyName] + '-' +  rt.ReservationType as CustomerName  ,RT.ReservationTypeID
		FROM [guest].[GuestCompany] GC
		INNER join Reservation.ReservationType RT on GC.ReservationTypeId=RT.ReservationTypeID
		where GC.IsActive=1
		ORDER BY RT.ReservationTypeID, GC.CompanyName

		SELECT [SubCategoryID] as RoomTypeID,[Name] as RoomType 
		FROM  [Products].[SubCategory] where [CategoryID] = 1 and IsActive=1

		END
END	


			
