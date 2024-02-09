-- =============================================
-- Author:		VASANTHAKUMAR R
-- Create date: 11-09-2023
-- Description:	CREATE UPDATE APPROVAL
-- =============================================
Create PROCEDURE [reservation].[spCreateUpdateAppraval_BK]
(
	 @ProcesstypeId INT=NULL
	,@LocatioId INT
	,@CreatedBy INT
	,@RefrenceNo INT=NULL
	,@ApprovalStatus INT
	,@ModifiedOn DATETIME=NULL
	,@ModifiedBy INT= NULL
	,@ToUserId INT
	,@Remark NVARCHAR(250)=NULL
	,@dtApproval as [reservation].[ApprovalLog] readonly
)
AS
BEGIN

	SET XACT_ABORT ON; 

 BEGIN TRY	

		DECLARE @IsSuccess bit = 0;
		DECLARE @Message varchar(max) = '';

		DECLARE @ApprovalDescripion NVARCHAR(150);

		DECLARE @ToRoleId INT;
		DECLARE @LogLevel INT;

		DECLARE @temp TABLE (ID INT IDENTITY(1,1),ProcesstypeId INT,RefrenceNo INT)
		DECLARE @RowNo int = 1;


INSERT INTO @temp(ProcesstypeId,RefrenceNo)
SELECT ProcessTypeId,RefrenceNo FROM @dtApproval




			IF(@ToUserId=0)
			BEGIN
				SET @ToUserId=NULL;
			END


WHILE(@RowNo <= (SELECT COUNT(*) FROM @temp))
BEGIN
SET @ProcesstypeId = (SELECT ProcessTypeId FROM @temp WHERE ID = @RowNo);
SET @RefrenceNo = (SELECT RefrenceNo FROM @temp WHERE ID = @RowNo);


			SET @ApprovalDescripion=(select top(1)ApprovalDescription from  [reservation].[ApprovalLog] where RefrenceNo=@RefrenceNo order by ApprovalLogId asc)

			SET @ToRoleId=(SELECT RoleID FROM app.UsersAndRoles WHERE UserID=@ToUserId)
			SET @LogLevel=(ISNULL((SELECT  TOP(1) LogLevel FROM [reservation].[ApprovalLog] WHERE RefrenceNo=@RefrenceNo ORDER BY LogLevel DESC),0)+1)
			
			IF(@ApprovalStatus=3)
			BEGIN
			 IF EXISTS(Select * from [reservation].[ApprovalLog] where RefrenceNo=@RefrenceNo)
				BEGIN
					UPDATE [reservation].[ApprovalLog] SET Remark=@Remark ,ApprovalStatus=@ApprovalStatus WHERE ApprovalLogId=(SELECT TOP(1) ApprovalLogId FROM [reservation].[ApprovalLog] WHERE [ProcesstypeId]=@ProcesstypeId AND RefrenceNo=@RefrenceNo ORDER BY ApprovalLogId DESC)

					INSERT INTO [reservation].[ApprovalLog]
					(
						[ProcesstypeId],[LocatioId],[CreatedOn],[CreatedBy],[ApprovalDescription],[RefrenceNo],[ApprovalStatus],[ToRoleId],[ToUserId],[LogLevel],[Remark]
					)
					VALUES
					(	
						@ProcesstypeId,@LocatioId,GETDATE(),@CreatedBy,@ApprovalDescripion,@RefrenceNo,0,@ToRoleId,@ToUserId,@LogLevel,''
					)

				END
			END

			IF(@ApprovalStatus=1 or @ApprovalStatus=2)
				BEGIN
					UPDATE [reservation].[ApprovalLog] SET Remark=@Remark ,ApprovalStatus=@ApprovalStatus, ModifiedBy=@CreatedBy,ModifiedOn=GETDATE() WHERE ApprovalLogId=(SELECT TOP(1) ApprovalLogId FROM [reservation].[ApprovalLog] WHERE [ProcesstypeId]=@ProcesstypeId AND RefrenceNo=@RefrenceNo ORDER BY ApprovalLogId DESC)
				END
			
			 --Approved
			 IF(@ApprovalStatus=1)
					BEGIN
						IF (@ProcesstypeId=1)
							BEGIN
								--SET @ApprovalDescripion ='Sales Price Changed'
								IF NOT EXISTS(SELECT * FROM [reservation].[ApprovalLog] WHERE ProcesstypeId=2 AND RefrenceNo=@RefrenceNo AND ApprovalStatus in(0,2,3) AND ApprovalLogId=(SELECT top(1) ApprovalLogId FROM [reservation].[ApprovalLog] WHERE ProcesstypeId=2 AND RefrenceNo=@RefrenceNo order by ApprovalLogId desc))
									BEGIN
										UPDATE reservation.Reservation SET AuthorizedFlag=0 WHERE ReservationID=@RefrenceNo
									END
							END
						IF (@ProcesstypeId=2)
								BEGIN
								--SET @ApprovalDescripion ='Additional Discount Added'
								IF NOT EXISTS(SELECT * FROM [reservation].[ApprovalLog] WHERE ProcesstypeId=1 AND RefrenceNo=@RefrenceNo AND ApprovalStatus in(0,2,3) AND ApprovalLogId=(SELECT top(1) ApprovalLogId FROM [reservation].[ApprovalLog] WHERE ProcesstypeId=1 AND RefrenceNo=@RefrenceNo order by ApprovalLogId desc))
									BEGIN
										UPDATE reservation.Reservation SET AuthorizedFlag=0 WHERE ReservationID=@RefrenceNo
									END
								END
						IF (@ProcesstypeId=3)
							BEGIN
								--SET @ApprovalDescripion ='Exchange Rate Changed'
								 UPDATE  [currency].[ExchangeRate] SET AuthorizedFlag=0 WHERE ID=@RefrenceNo
							END
						IF (@ProcesstypeId=4)
							BEGIN
								--SET @ApprovalDescripion ='Room/Meal Plan Tariff Changed'
								 UPDATE  Products.RoomDayPrice SET AuthorizedFlag=0 WHERE PriceID=@RefrenceNo
							END
						IF (@ProcesstypeId=5)
						BEGIN
							--SET @ApprovalDescripion ='company advance payment'
								UPDATE reservation.Reservation SET AuthorizedFlag=0 WHERE ReservationID=@RefrenceNo
						END
						 
					END
			 --Rejected
			  IF(@ApprovalStatus=2)
					BEGIN
						IF (@ProcesstypeId=1)
							BEGIN
								--SET @ApprovalDescripion ='Sales Price Changed'
								IF NOT EXISTS(SELECT * FROM [reservation].[ApprovalLog] WHERE ProcesstypeId=2 AND RefrenceNo=@RefrenceNo AND ApprovalStatus in(0,2,3) AND ApprovalLogId=(SELECT top(1) ApprovalLogId FROM [reservation].[ApprovalLog] WHERE ProcesstypeId=2 AND RefrenceNo=@RefrenceNo order by ApprovalLogId desc))
									BEGIN
										UPDATE reservation.Reservation SET AuthorizedFlag=2 WHERE ReservationID=@RefrenceNo
									END
							END
						IF (@ProcesstypeId=2)
								BEGIN
								--SET @ApprovalDescripion ='Additional Discount Added'
								IF NOT EXISTS(SELECT * FROM [reservation].[ApprovalLog] WHERE ProcesstypeId=1 AND RefrenceNo=@RefrenceNo AND ApprovalStatus in(0,2,3) AND ApprovalLogId=(SELECT top(1) ApprovalLogId FROM [reservation].[ApprovalLog] WHERE ProcesstypeId=1 AND RefrenceNo=@RefrenceNo order by ApprovalLogId desc))
									BEGIN
										UPDATE reservation.Reservation SET AuthorizedFlag=2 WHERE ReservationID=@RefrenceNo
									END
								END
						IF (@ProcesstypeId=3)
							BEGIN
								--SET @ApprovalDescripion ='Exchange Rate Changed'
								 UPDATE  [currency].[ExchangeRate] SET AuthorizedFlag=2 WHERE ID=@RefrenceNo
							END
						IF (@ProcesstypeId=4)
							BEGIN
								--SET @ApprovalDescripion ='Room/Meal Plan Tariff Changed'
								 UPDATE  Products.RoomDayPrice SET AuthorizedFlag=2 WHERE PriceID=@RefrenceNo
							END
						IF (@ProcesstypeId=5)
						BEGIN
							--SET @ApprovalDescripion ='company advance payment'
								UPDATE reservation.Reservation SET AuthorizedFlag=2 WHERE ReservationID=@RefrenceNo
						END
					END
 
 SET @rowno = @rowno + 1
			
			SET @IsSuccess = 1; 				
			SET @Message = 'Saved Successfully';

END
				COMMIT TRANSACTION

	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; 
		 
		END;    
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
	END