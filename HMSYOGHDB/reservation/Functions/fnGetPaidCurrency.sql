CREATE FUNCTION [reservation].[fnGetPaidCurrency] 
(	
	@ReservationId int	
)
RETURNS varchar(255)
AS	
BEGIN
	declare @strPaidCurrency varchar(255);

	
			--set @strPaidCurrency =(SELECT STRING_AGG(CC.CurrencyCode, ',')  FROM [currency].[Currency] CC 
			--where cc.CurrencyID in (select distinct ActualCurrencyID  FROM [account].[Transaction] 
			--where reservationid=@ReservationId))

			SELECT @strPaidCurrency = COALESCE(CC.CurrencyCode, ',')  FROM [currency].[Currency] CC 
			where cc.CurrencyID in (select distinct ActualCurrencyID  FROM [account].[Transaction] 
			where reservationid=@ReservationId)



			RETURN @strPaidCurrency
END

------------------ LIVE DB-------------------------------------
		--ALTER FUNCTION [reservation].[fnGetReserveredRoom] 
		--(	
		--	@ReservationId int	
		--)
		--RETURNS varchar(255)
		--AS	
		--BEGIN
		--	declare @strCurrency varchar(255);

		--	SELECT @strCurrency = COALESCE(@strCurrency + ',', '') 
		--FROM [account].[Transaction] ATR
		--inner join [currency].[Currency] CC On ATR.ActualCurrencyID=CC.CurrencyID
		--	where ATR.reservationid= @ReservationId

		--	RETURN @strCurrency;
		--END