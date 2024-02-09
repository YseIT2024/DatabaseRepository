CREATE FUNCTION [account].[GetAccountingDateIsActive] 
(
	@DrawerID int
)
RETURNS int
AS
BEGIN
	Declare @AccountingDateId int
	Select @AccountingDateId = account.AccountingDates.AccountingDateId FROM  account.AccountingDates 
		  WHERE (account.AccountingDates.DrawerID = @DrawerID) AND (account.AccountingDates.IsActive = 1)
    return @AccountingDateId
END





