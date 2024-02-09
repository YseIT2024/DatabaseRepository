CREATE FUNCTION [reservation].[fnGetPaidType] 
(	
	@ReservationId int	
)
RETURNS varchar(255)
AS	
BEGIN
	declare @strPaidType varchar(255);	
			
		--SELECT @strPaidType = COALESCE(@strPaidType + ',', '') 
		-- FROM [account].[Transaction] ATR
		--	inner join [account].[TransactionMode] TM On ATR.TransactionModeID =TM.TransactionModeID
		--	where ATR.reservationid= @ReservationId


		--	set @strCurrency =  (SELECT STRING_AGG(TM.TransactionMode, ',')  FROM [account].[TransactionMode] TM
		--where TM.TransactionModeID in (SELECT DISTINCT TransactionModeID FROM  [account].[Transaction]	
		--	where reservationid= @ReservationId))

			Select  @strPaidType = COALESCE(TM.TransactionMode + ',', '')  FROM [account].[TransactionMode] TM
				where TM.TransactionModeID in (SELECT DISTINCT TransactionModeID FROM  [account].[Transaction]	
				where reservationid= @ReservationId)

		--	RETURN @strCurrency



			RETURN @strPaidType
END
