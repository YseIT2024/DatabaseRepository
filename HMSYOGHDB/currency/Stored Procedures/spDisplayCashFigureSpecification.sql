
CREATE PROCEDURE [currency].[spDisplayCashFigureSpecification]--1,1
	(
		@DrawerID int,
		@UserId int
	)
AS
BEGIN
	
	DECLARE @CashFigureSpecification TABLE(DenominationTypeID INT, DenominationType VARCHAR(50),DenominationID INT,DenominationValue DECIMAL(18,2),
	DenomQuantity INT,DenomTotalValue DECIMAL(18,2),DenominationTotalMainCurrencyValue DECIMAL(18,2),DenominationValueType VARCHAR(50),UserFullName VARCHAR(200),PrintingDateTime DATETIME,CompanyFullName VARCHAR(100),LocCode VARCHAR(50),CompanyAddress VARCHAR(500),CompanyPhoneNumber VARCHAR(15),CompanyImage VARCHAR(MAX))
	
	Declare @AccountingDateId int
	Declare @AccountingDate Date

	Declare @CompanyFullName Varchar(100)
	Declare @CompanyAddress Varchar(200)
	Declare @CompanyPhoneNumber Varchar(20)

	Declare @UserFullName Varchar(100)

	Declare @PrintinDateTime DateTime = GetDate()

	Declare @LocationCode Varchar(10)
	Declare @CompanyId int
	Declare @CompanyImage Varchar(Max)='N/A'	
	Declare @Drawer Varchar(20) = (Select Drawer From app.Drawer Where DrawerID = @DrawerID)	
	

		SELECT       @AccountingDateId = [account].[AccountingDates].AccountingDateId, @AccountingDate = [account].[AccountingDates].AccountingDate
		FROM      [account].[AccountingDates]    
		WHERE        ([account].[AccountingDates].DrawerID = @DrawerID) AND ([account].[AccountingDates].IsActive = 1)
			
			if(@AccountingDateId IS NULL)
				Begin
					Select 'Your till date is closed. You have to open a new till date to make any transaction in POS.' As ErrorMessage
					return
				End

			SELECT       @UserFullName= contact.Details.FirstName+' '+Isnull(contact.Details.FirstName,'')
			FROM            app.[User] INNER JOIN
									 contact.Details ON app.[User].ContactID = contact.Details.ContactID
			WHERE        (app.[User].UserID = @UserID)

			SELECT @CompanyId = loc.[LocationID] ,@CompanyFullName= loc.[LocationName], @CompanyAddress ='N/A' ,@CompanyPhoneNumber='N/A',@LocationCode= loc.[LocationCode]
			FROM [general].[Location] Loc 
			inner join 
			[app].[Drawer] as appDrawer on Loc.LocationID=appDrawer.LocationID
			where appDrawer.DrawerID = @DrawerID


DECLARE @USDTotalQtyCASH decimal(18,2)

DECLARE @EURTotalQtyCASH decimal(18,2)


DECLARE @SRDTotalQtyCASH decimal(18,2)

DECLARE @USDTotalValCASH decimal(18,2)


DECLARE @EURTotalValCASH decimal(18,2)


DECLARE @SRDTotalValCASH decimal(18,2)

--USD
			SELECT       @USDTotalQtyCASH =  SUM(currency.DenominationStatistics.DenomQuantity), @USDTotalValCASH =  SUM(currency.Denomination.DenominationValue*currency.DenominationStatistics.DenomQuantity)
                        
			FROM            currency.DenominationStatistics INNER JOIN
			currency.Denomination ON currency.DenominationStatistics.DenominationID = currency.Denomination.DenominationID INNER JOIN
			currency.DenominationType ON currency.Denomination.DenominationTypeID = currency.DenominationType.DenominationTypeID INNER JOIN
			currency.Currency ON currency.DenominationType.CurrencyID = currency.Currency.CurrencyID INNER JOIN
			account.AccountingDates ON currency.DenominationStatistics.AccountingDateId = account.AccountingDates.AccountingDateId
			where currency.DenominationStatistics.AccountingDateId = @AccountingDateId and currency.DenominationStatistics.DrawerID=@DrawerID and 
			currency.Currency.CurrencyID = 1

---SRD
			SELECT       @SRDTotalQtyCASH =  SUM(currency.DenominationStatistics.DenomQuantity), @SRDTotalValCASH =  SUM(currency.Denomination.DenominationValue*currency.DenominationStatistics.DenomQuantity)
			FROM            currency.DenominationStatistics INNER JOIN
			currency.Denomination ON currency.DenominationStatistics.DenominationID = currency.Denomination.DenominationID INNER JOIN
			currency.DenominationType ON currency.Denomination.DenominationTypeID = currency.DenominationType.DenominationTypeID INNER JOIN
			currency.Currency ON currency.DenominationType.CurrencyID = currency.Currency.CurrencyID INNER JOIN
			account.AccountingDates ON currency.DenominationStatistics.AccountingDateId = account.AccountingDates.AccountingDateId
			where currency.DenominationStatistics.AccountingDateId = @AccountingDateId and currency.DenominationStatistics.DrawerID=@DrawerID and currency.Currency.CurrencyID = 2

-- EUR
		
			SELECT       @EURTotalQtyCASH =  SUM(currency.DenominationStatistics.DenomQuantity), @EURTotalValCASH =  SUM(currency.Denomination.DenominationValue*currency.DenominationStatistics.DenomQuantity)
			FROM            currency.DenominationStatistics INNER JOIN
			currency.Denomination ON currency.DenominationStatistics.DenominationID = currency.Denomination.DenominationID INNER JOIN
			currency.DenominationType ON currency.Denomination.DenominationTypeID = currency.DenominationType.DenominationTypeID INNER JOIN
			currency.Currency ON currency.DenominationType.CurrencyID = currency.Currency.CurrencyID INNER JOIN
			account.AccountingDates ON currency.DenominationStatistics.AccountingDateId = account.AccountingDates.AccountingDateId
			where currency.DenominationStatistics.AccountingDateId = @AccountingDateId and currency.DenominationStatistics.DrawerID=@DrawerID and currency.Currency.CurrencyID = 3

--USD
SELECT        currency.Denomination.DenominationTypeID, currency.DenominationType.DenominationType, currency.DenominationStatistics.DenominationID, currency.Denomination.DenominationValue, 
                         currency.DenominationStatistics.DenomQuantity, currency.DenominationStatistics.DenomTotalValue, currency.DenominationStatistics.DenominationTotalMainCurrencyValue, 
                         currency.DenominationValueType.DenominationValueType,  @UserFullName AS UserFullName, @PrintinDateTime AS PrintingDateTime,  @CompanyFullName AS CompanyFullName, @CompanyAddress AS CompanyAddress,
						  @CompanyPhoneNumber AS CompanyPhoneNumber, @LocationCode + ' (' + @Drawer +')' AS LocCode, @CompanyImage As CompanyImage
FROM            currency.DenominationValueType INNER JOIN
                         currency.DenominationType ON currency.DenominationValueType.DenominationValueTypeID = currency.DenominationType.DenominationValueTypeID AND 
                         currency.DenominationValueType.DenominationValueTypeID = currency.DenominationType.DenominationValueTypeID INNER JOIN
                         currency.Denomination ON currency.DenominationType.DenominationTypeID = currency.Denomination.DenominationTypeID AND 
                         currency.DenominationType.DenominationTypeID = currency.Denomination.DenominationTypeID INNER JOIN
                         currency.DenominationStatistics ON currency.Denomination.DenominationID = currency.DenominationStatistics.DenominationID AND currency.Denomination.DenominationID = currency.DenominationStatistics.DenominationID
where currency.DenominationStatistics.DrawerID=@DrawerID and currency.DenominationStatistics .AccountingDateId=@AccountingDateId and [currency].[DenominationType].DenominationTypeID=1
 
 union all
 --SRD
SELECT        currency.Denomination.DenominationTypeID, currency.DenominationType.DenominationType, currency.DenominationStatistics.DenominationID, currency.Denomination.DenominationValue, 
                         currency.DenominationStatistics.DenomQuantity, currency.DenominationStatistics.DenomTotalValue, currency.DenominationStatistics.DenominationTotalMainCurrencyValue, 
                         currency.DenominationValueType.DenominationValueType,  @UserFullName AS UserFullName, @PrintinDateTime AS PrintingDateTime,  @CompanyFullName AS CompanyFullName, @CompanyAddress AS CompanyAddress,
						  @CompanyPhoneNumber AS CompanyPhoneNumber, @LocationCode + ' (' + @Drawer +')' AS LocCode, @CompanyImage As CompanyImage
FROM            currency.DenominationValueType INNER JOIN
                         currency.DenominationType ON currency.DenominationValueType.DenominationValueTypeID = currency.DenominationType.DenominationValueTypeID AND 
                         currency.DenominationValueType.DenominationValueTypeID = currency.DenominationType.DenominationValueTypeID INNER JOIN
                         currency.Denomination ON currency.DenominationType.DenominationTypeID = currency.Denomination.DenominationTypeID AND 
                         currency.DenominationType.DenominationTypeID = currency.Denomination.DenominationTypeID INNER JOIN
                         currency.DenominationStatistics ON currency.Denomination.DenominationID = currency.DenominationStatistics.DenominationID AND currency.Denomination.DenominationID = currency.DenominationStatistics.DenominationID
where currency.DenominationStatistics.DrawerID=@DrawerID and currency.DenominationStatistics .AccountingDateId=@AccountingDateId and [currency].[DenominationType].DenominationTypeID=2
 union all
 --EUR
SELECT        currency.Denomination.DenominationTypeID, currency.DenominationType.DenominationType, currency.DenominationStatistics.DenominationID, currency.Denomination.DenominationValue, 
                         currency.DenominationStatistics.DenomQuantity, currency.DenominationStatistics.DenomTotalValue, currency.DenominationStatistics.DenominationTotalMainCurrencyValue, 
                         currency.DenominationValueType.DenominationValueType,  @UserFullName AS UserFullName, @PrintinDateTime AS PrintingDateTime,  @CompanyFullName AS CompanyFullName, @CompanyAddress AS CompanyAddress,
						  @CompanyPhoneNumber AS CompanyPhoneNumber, @LocationCode + ' (' + @Drawer +')' AS LocCode, @CompanyImage As CompanyImage
FROM            currency.DenominationValueType INNER JOIN
                         currency.DenominationType ON currency.DenominationValueType.DenominationValueTypeID = currency.DenominationType.DenominationValueTypeID AND 
                         currency.DenominationValueType.DenominationValueTypeID = currency.DenominationType.DenominationValueTypeID INNER JOIN
                         currency.Denomination ON currency.DenominationType.DenominationTypeID = currency.Denomination.DenominationTypeID AND 
                         currency.DenominationType.DenominationTypeID = currency.Denomination.DenominationTypeID INNER JOIN
                         currency.DenominationStatistics ON currency.Denomination.DenominationID = currency.DenominationStatistics.DenominationID AND currency.Denomination.DenominationID = currency.DenominationStatistics.DenominationID
where currency.DenominationStatistics.DrawerID=@DrawerID and currency.DenominationStatistics .AccountingDateId=@AccountingDateId and [currency].[DenominationType].DenominationTypeID=3

END







