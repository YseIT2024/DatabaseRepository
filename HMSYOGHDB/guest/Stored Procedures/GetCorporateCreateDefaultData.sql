
-- =============================================
-- Author:          <Vivek>
-- Create date: <01/02/2023>
-- =============================================

CREATE Proc [guest].[GetCorporateCreateDefaultData] 
(		
	@UserId varchar(50)	
)
AS
BEGIN
	
	--SET NOCOUNT ON prevents the sending of DONEINPROC messages to the client for each statement in a stored procedure
	SET NOCOUNT ON;
	
		SELECT [ReservationTypeID],case when ReservationTypeID =1 then 'Guest' else [ReservationType] end [ReservationType] FROM [reservation].[ReservationType] where [IsActive] = 1 and ReservationTypeID in(4,8,11,1)

		SELECT [CountryID] ,[CountryName]
		FROM  [general].[Country] where [IsActive] = 1 

		SELECT [ConfigID] as PaymentReceiveID ,[ConfigValue] as PaymentReceive
		FROM  [general].[Config] where [IsActive] = 1 and [ConfigType] = 1

		
END	
			


