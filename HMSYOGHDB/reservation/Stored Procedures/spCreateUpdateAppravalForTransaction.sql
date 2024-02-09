
CREATE PROCEDURE [reservation].[spCreateUpdateAppravalForTransaction]
(
	 @ProcesstypeId INT
	,@LocatioId INT
	,@CreatedBy INT
	,@RefrenceNo INT
	,@ApprovalStatus INT
	,@ModifiedOn DATETIME=NULL
	,@ModifiedBy INT= NULL
	,@ToUserId INT
	,@Remark NVARCHAR(250)=NULL
	,@Descripion NVARCHAR(250)=NULL
	,@OldRate NVARCHAR(250)=NULL
	,@NewRate NVARCHAR(250)=NULL
	,@IsApprovalVisible INT=1
)
AS
BEGIN

		SET NOCOUNT ON;

  
		DECLARE @IsSuccess bit = 0;
		DECLARE @Message varchar(max) = '';

		DECLARE @ApprovalDescripion NVARCHAR(150);

		DECLARE @ToRoleId INT;
		DECLARE @LogLevel INT;

			IF(@ToUserId=0)
			BEGIN
				SET @ToUserId=NULL;
			END
			IF (@ProcesstypeId=1)
			BEGIN
				SET @ApprovalDescripion ='Sales Price Changed - Approval awaiting for  ' + @Descripion
				UPDATE reservation.Reservation SET AuthorizedFlag=1 WHERE ReservationID=@RefrenceNo
			END
			IF (@ProcesstypeId=2)
			BEGIN
				SET @ApprovalDescripion ='Additional Discount Provided - Approval awaiting for '  + @Descripion
				UPDATE reservation.Reservation SET AuthorizedFlag=1 WHERE ReservationID=@RefrenceNo
			END
			IF (@ProcesstypeId=3)
			BEGIN
				SET @ApprovalDescripion =@Descripion  --'Exchange Rate Changed'
			END
			IF (@ProcesstypeId=4)
			BEGIN
				SET @ApprovalDescripion =@Descripion --'Room/Meal Plan Tariff Changed'
			END
			IF (@ProcesstypeId=5)
			BEGIN
				--SET @ApprovalDescripion ='Company Advance Payment - Approval awaiting for ' + @Descripion
				SET @ApprovalDescripion = @Descripion
				UPDATE reservation.Reservation SET AuthorizedFlag=1 WHERE ReservationID=@RefrenceNo
			END
			IF (@ProcesstypeId=6)
			BEGIN
				SET @ApprovalDescripion = @Descripion
				UPDATE reservation.Reservation SET AuthorizedFlag=1 WHERE ReservationID=@RefrenceNo
			END
			IF (@ProcesstypeId=7)
			BEGIN
				SET @ApprovalDescripion = @Descripion
				UPDATE reservation.Reservation SET AuthorizedFlag=1 WHERE ReservationID=@RefrenceNo
			END

			--SELECT @ApprovalDescripion=ProcessType FROM reservation.ProcessType WHERE ProcessTypeId=@ProcesstypeId
			--UPDATE reservation.Reservation SET AuthorizedFlag=1 WHERE ReservationID=@RefrenceNo

			SET @ToRoleId=(SELECT RoleID FROM app.UsersAndRoles WHERE UserID=@ToUserId)
			SET @LogLevel=(ISNULL((SELECT  TOP(1) LogLevel FROM [reservation].[ApprovalLog] WHERE RefrenceNo=@RefrenceNo ORDER BY LogLevel DESC),0)+1)
			
				 
			INSERT INTO [reservation].[ApprovalLog]
			(
				[ProcesstypeId],[LocatioId],[CreatedOn],[CreatedBy],[ApprovalDescription],[RefrenceNo],[ApprovalStatus],[ToRoleId],[ToUserId],[LogLevel],[Remark],[OldRate],[NewRate],[IsApprovalVisible]
			)
			VALUES
			(	
				@ProcesstypeId,@LocatioId,GETDATE(),@CreatedBy,@ApprovalDescripion,@RefrenceNo,@ApprovalStatus,@ToRoleId,@ToUserId,@LogLevel,@Remark,@OldRate,@NewRate,@IsApprovalVisible
			)
			
		 
	    
END

