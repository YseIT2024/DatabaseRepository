
CREATE Proc [account].[spGetTransactionDetailsPageLoad] --1,6327
(
   @DrawerID INT,
   @ReservationID INT =0
)
AS
BEGIN

DECLARE @CompanyID int=0;
DECLARE @CompanyTypeID int=0;
DECLARE @GuestTypeID int =1;


    SET @CompanyID=(Select CompanyTypeID from reservation.Reservation where ReservationID=@ReservationID)
	SET @CompanyTypeID=(Select ReservationTypeID from reservation.Reservation where ReservationID=@ReservationID)
	--SET @GuestTypeID=(Select ReservationTypeID from reservation.Reservation where ReservationID=@ReservationID)
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	    
	SELECT AccountTypeID
	,'('+CAST(AccountNumber as varchar(10)) +') ' + AccountType [AccountType]
	,ISNULL(TransactionTypeID,0) [TransactionTypeID]
	,AccountGroupID
	,AccountNumber
	FROM [account].[AccountType]
	WHERE ShowInUI = 1
	ORDER BY AccountType

	SELECT c.CurrencyID, c.CurrencyCode
	,er.NewRate [CurrencyRateUSD]
	,er.IsStrongerThanMainCurrency
	FROM [currency].[Currency] c
	INNER JOIN [currency].[ExchangeRateHistory] er ON c.CurrencyID = er.CurrencyID
	WHERE er.IsActive = 1 AND er.DrawerID = @DrawerID

	SELECT TransactionTypeID, TransactionType, TransactionFactor
	FROM [account].[TransactionType]
	WHERE ShowInUI = 1

	SELECT TransactionModeID, TransactionMode 
	FROM [account].[TransactionMode]
	WHERE ShowInUI = 1

	SELECT [MainAccountTypeID],[MainAccountType]
	FROM [account].[MainAccountType]

	SELECT [AccountGroupID], [AccountGroup], [MainAccountTypeID]      
	FROM [account].[AccountGroup]

	;WITH CTE
	AS
	(
		--SELECT cp.[ContactID], [ContactPersonID], 0 [GuestID], 0 [EmployeeID], cd.FirstName +' '+ ISNULL(cd.LastName,'') + ' ('+ ct.ContactType +')' [Name]
		--FROM [contact].[Person] cp
		--INNER JOIN [contact].[ContactType] ct ON cp.ContactTypeID = ct.ContactTypeID
		--INNER JOIN [contact].[Details] cd ON cp.ContactID = cd.ContactID

		--UNION

		SELECT gg.[ContactID], 0 [ContactPersonID], [GuestID], 0 [EmployeeID], cd.FirstName +' '+ ISNULL(cd.LastName,'') + ' (Guest)' [Name]
		FROM [guest].[Guest] gg
		INNER JOIN [contact].[Details] cd ON gg.ContactID = cd.ContactID

		--UNION

		--SELECT pe.[ContactID], 0 [ContactPersonID], 0 [GuestID], pe.[EmployeeID], cd.FirstName +' '+ ISNULL(cd.LastName,'') + ' (Employee)' [Name]
		--FROM [person].[Employee] pe
		--INNER JOIN [person].[Designation] pd ON pe.DesignationID = pd.DesignationID AND pd.DesignationID NOT IN (1,2,3,4,5,6,7,8,9,10)
		--INNER JOIN [contact].[Details] cd ON pe.ContactID = cd.ContactID
		--INNER JOIN person.EmployeeAndLocation eal ON pe.EmployeeID = eal.EmployeeID AND eal.LocationID = 1
		--WHERE pe.IsActive = 1
	)
	SELECT [ContactID], 0 [ContactPersonID], 0 [GuestID], 0 [EmployeeID], FirstName [Name]
	FROM [contact].[Details] WHERE ContactID = 0
	UNION
	SELECT [ContactID], [ContactPersonID], [GuestID], [EmployeeID], [Name] FROM CTE
	ORDER BY [Name]

	SELECT CurrencyID
	,CurrencyCode
	,0.00 Amount
	,0.00 AmountInCurr
	FROM currency.Currency

	SELECT CompanyID, CompanyName
	--FROM company.Company
	FROM general.Company
	WHERE CompanyID > 0

 
   
   
   --select GuestID as GuestIDOrCompanyID , FirstName as NameOrCompany, @GuestTypeID as GuestOrCompanyTypeID   from [reservation].[ReservationGuestMates] where ReservationID=@ReservationID
   --union all
   --select CompanyID as GuestIDOrCompanyID ,CompanyName  as NameOrCompany, @CompanyTypeID as GuestOrCompanyTypeID from guest.GuestCompany where CompanyID=@CompanyID


 --	select  distinct
	--GuestID_CompanyID as GuestIDOrCompanyID, 
	--(select FirstName from [guest].[vwGuestDetails] where GuestID=ota.GuestID_CompanyID) as NameOrCompany,
	--@GuestTypeID as GuestOrCompanyTypeID   
	--from [guest].[OTAServices] ota  where ReservationID=@ReservationID and [Type]='Guest'
 --   union all
 --   select CompanyID as GuestIDOrCompanyID,
	--CompanyName  as NameOrCompany, 
	--@CompanyTypeID as GuestOrCompanyTypeID 
	--from guest.GuestCompany where CompanyID=(select distinct GuestID_CompanyID from [guest].[OTAServices] where ReservationID=@ReservationID and [Type]='Company')
	
	 
	 if(exists(select * from [guest].[OTAServices] where ReservationID=@ReservationID))
	 begin
		select distinct  
		GuestID_CompanyID as GuestIDOrCompanyID,
		case 
		when [Type]='Guest' then (select FirstName from [guest].[vwGuestDetails] where GuestID=GuestID_CompanyID)  
		when [Type]='Company' then (select CompanyName from guest.GuestCompany where CompanyID=GuestID_CompanyID)  
		else '' end as NameOrCompany,
		case 
		when [Type]='Guest' then 1
		when [Type]='Company' then (select ReservationTypeId from guest.GuestCompany where CompanyID=GuestID_CompanyID)  
		else '' end as GuestOrCompanyTypeID
		from [guest].[OTAServices] where ReservationID=@ReservationID 
	 end
	 else
	 begin
		select GuestID as GuestIDOrCompanyID , FirstName as NameOrCompany, @GuestTypeID as GuestOrCompanyTypeID   from [reservation].[ReservationGuestMates] where ReservationID=@ReservationID
		union all
		select CompanyID as GuestIDOrCompanyID ,CompanyName  as NameOrCompany, @CompanyTypeID as GuestOrCompanyTypeID from guest.GuestCompany where CompanyID=@CompanyID
	 end

	 


	SELECT c.CurrencyID, c.CurrencyCode
	,er.NewBRate [NewBRateCurrencyRateUSD]
	,er.IsStrongerThanMainCurrency
	FROM [currency].[Currency] c
	INNER JOIN [currency].[ExchangeRateHistory] er ON c.CurrencyID = er.CurrencyID
	WHERE er.IsActive = 1 AND er.DrawerID = @DrawerID
	
END


