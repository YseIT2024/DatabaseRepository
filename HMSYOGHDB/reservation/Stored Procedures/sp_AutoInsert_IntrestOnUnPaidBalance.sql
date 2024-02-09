

create PROCEDURE [reservation].[sp_AutoInsert_IntrestOnUnPaidBalance]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @TotalReceivedAmount decimal(18,3);
DECLARE @TotalAmount decimal(18,3);
DECLARE @TotalPendingAmount decimal(18,3);


DECLARE @CheckOutDate  date;
DECLARE @IntrestDate  date;
DECLARE @CreditPeriod int;
DECLARE @FolioNumber int;
DECLARE @IntrestPercentage int;
DECLARE @TotalIntrestAmount Decimal(18,3);
DECLARE @Remark nvarchar(100);
DECLARE @ReservationId int;


-- Cursor Start 
DECLARE @ReservationBalanceId INT;
DECLARE myCursormyReservationBalance CURSOR FOR SELECT ReservationBalanceId FROM [reservation].[ReservationBalance] WHERE CONVERT(VARCHAR, FollowupDate, 103) = CONVERT(VARCHAR, GETDATE(), 103) AND BalanceAmount>0
OPEN myCursormyReservationBalance;
FETCH NEXT FROM myCursormyReservationBalance INTO @ReservationBalanceId;
WHILE @@FETCH_STATUS = 0
BEGIN


SELECT @ReservationID=ReservationID FROM [reservation].[ReservationBalance] WHERE ReservationBalanceId=@ReservationBalanceId;
SELECT @FolioNumber=FolioNumber FROM reservation.Reservation WHERE ReservationID=@ReservationID
set @TotalReceivedAmount =ISNULL((SELECT sum(ActualAmount) FROM account.[Transaction] WHERE ReservationID=@ReservationID),0);
set @TotalAmount=ISNULL((SELECT sum(AmtAfterTax) FROM [account].[GuestLedgerDetails] WHERE FolioNo=@FolioNumber),0);
set @TotalPendingAmount=@TotalAmount-@TotalReceivedAmount;

 --PRINT @TotalPendingAmount
 
	IF(EXISTS(SELECT ReservationID FROM [reservation].[ReservationBalance]  WHERE ReservationBalanceId=@ReservationBalanceId and BalanceAmount!=@TotalPendingAmount))
	BEGIN
		UPDATE [reservation].[ReservationBalance] SET BalanceAmount=@TotalPendingAmount,ModifiedDate=GETDATE() WHERE ReservationBalanceId=@ReservationBalanceId
		PRINT 'New Balance Amount Updated'
	END

	IF(@TotalPendingAmount>0)
		BEGIN
			SELECT 
			@ReservationId=ReservationID,
			@CreditPeriod=CreditPeriod,
			@IntrestPercentage=InterestPercentage,
			@CheckOutDate=FollowupDate
			FROM [reservation].[ReservationBalance] where ReservationBalanceId=@ReservationBalanceId AND BalanceAmount>0


			SET @TotalIntrestAmount=(@TotalPendingAmount/100) *	 @IntrestPercentage

				--set @Remark='Interest On UnPaid Balance, @ ('+CAST(@IntrestPercentage AS NVARCHAR(150))+'% ) and '+	CAST(@TotalIntrestAmount AS NVARCHAR(150));
				set @Remark='Interest On UnPaid Balance, @ ('+CAST(@IntrestPercentage AS NVARCHAR(150))+'% )';
				--INSERT GUEST LEDGER TABLE
					INSERT INTO [account].GuestLedgerDetails
					(FolioNo,TransDate,ServiceId,TransRefNo,AmtBeforeTax,TaxId,TaxPer,AmtTax,AmtAfterTax,PaidStatus,TransStatus,Remarks,IsActive,CreatedBy,CreatedOn)
					VALUES
					(@FolioNumber,GETDATE(),0,@ReservationID,@TotalIntrestAmount,3,NULL,0,@TotalIntrestAmount,0,0,@Remark,1,0,GETDATE())

				PRINT 'Guest Ledger, Data Inserted Successfull '+ CAST(@ReservationID AS NVARCHAR(150));


				DECLARE @TODAY_DATE DATE=GETDATE();
				--PRINT  @TODAY_DATE
				SET @IntrestDate = DATEADD(DAY, @CreditPeriod, @CheckOutDate) 
				
				UPDATE [reservation].[ReservationBalance] SET FollowupDate=@IntrestDate,ModifiedDate=GETDATE() WHERE ReservationBalanceId=@ReservationBalanceId
				PRINT 'Updated Next Follow-Up Date'
		END
			 
FETCH NEXT FROM myCursormyReservationBalance INTO @ReservationBalanceId;
END
CLOSE myCursormyReservationBalance;
DEALLOCATE myCursormyReservationBalance;

--Cursor End



END
