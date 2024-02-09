
-- =============================================
-- Author:		<Arabinda>
-- Create date: <3/30/2023 7:35:49 PM>
-- Description:	<To Load Blacklist Creation Lookup Edit>
-- =============================================

CREATE PROCEDURE [guest].[usp_Blacklist_Load] 
(
@CustomerId varchar (15) =null
)

AS
BEGIN	

	SET NOCOUNT ON;

	--Get Blacklist Type
   SELECT  [BlackListTypeID],[BlackListTypeName]  FROM [HMSYOGH].[guest].[BlackListTypes]

   --Get Requested by
	select GE.EmployeeID, CD.ContactId, CD.Firstname + ' ' + CD.Lastname AS [Name] 
	from [contact].[Details] CD 
	INNER JOIN [general].[Employee] GE ON CD.ContactID=GE.ContactID
	--WHERE CD.DesignationID=16 -- Driver

	select CreatedOn, bt.BlackListTypeName ,
	  bl.REASON,bl.EFFECTIVEFROM,bl.BLSTATUS	 
	  from [guest].[Blacklist] bl 
	  INNER JOIN [general].[Customer] gc on gc.CustomerID=bl.CUSTOMERID
	   Inner join [guest].[BlackListTypes] bt on bl.BLTYPEID=bt.BlackListTypeID 
	  where gc.CustomerNo=@CustomerId  --'CUS1031'
	  union
	  select CreatedOn, bt.BlackListTypeName ,
	  bl.REASON,bl.EFFECTIVEFROM,bl.BLSTATUS	 
	  from [guest].[Blacklist_History] bl 
	  INNER JOIN [general].[Customer] gc on gc.CustomerID=bl.CUSTOMERID
	   Inner join [guest].[BlackListTypes] bt on bl.BLTYPEID=bt.BlackListTypeID 
	  where gc.CustomerNo= @CustomerId  --'CUS1031'

END
