CREATE PROC [reservation].[usp_ReservationServices_IU]    
    @ReservationID int,
    @ServiceId int,
    @ServiceDate datetime,
    @ServiceQty int,
    @GuestQty int,
    @ServiceTimeId int=null,
    @ServiceType int,
    @Status varchar(6),
    @ServiceRate decimal,
    @UserID int,
    @DateTime datetime=null,
    @IsActive int,
    @LocationId int,
    @RoomId int=null,
    @LocationName nchar(100)=null,
    @RoomDescription nvarchar(100)=null,
	@RoomService VARCHAR (6),
	@Amount decimal(18,3)=0
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	DECLARE @IsSuccess BIT = 0;
	DECLARE @Message VARCHAR(MAX);
	DECLARE @Remarks VARCHAR(MAX);
	DECLARE @TaxId int =0;  -- (SELECT  isnull(TaxID,'0')as TaxID  FROM [service].ServiceTax WHERE ServiceTypeID=1 and IsActive=1)   ---- Commented By Chandra
	DECLARE @TaxPer decimal(8, 2) = 0;  -- (SELECT TaxRate FROM general.Tax WHERE TaxID=@TaxId and IsActive=1)   ---- Commented By Chandra
	DECLARE @FolioNumber int;
	DECLARE @ServiceTypeId int;
	DECLARE @OrderDetailId int;
	DECLARE @TotalAmountBeforeTax decimal(8, 2);
	DECLARE @TotalAmountAfterTax decimal(8, 2);
	DECLARE @TransId int;
	

	BEGIN TRY

	Set @FolioNumber= (select FolioNumber from Reservation.Reservation where ReservationID=@ReservationID);

	Set @TotalAmountBeforeTax=@Amount ;

	SET @TotalAmountAfterTax = @TotalAmountBeforeTax + (@TotalAmountBeforeTax * (@TaxPer / 100));	

    BEGIN TRANSACTION
		IF (@ReservationID>0)
			BEGIN
						INSERT INTO reservation.ReservationServices (ReservationID, ServiceId, ServiceDate, ServiceQty, 
															 GuestQty, ServiceTimeId, ServiceType, Status, ServiceRate, 
															 UserID, DateTime, IsActive, LocationId, RoomId, LocationName, 
															 RoomDescription,RoomService,Amount)
						SELECT @ReservationID, @ServiceId, @ServiceDate, @ServiceQty, @GuestQty, @ServiceTimeId, 
					   @ServiceType, @Status, @ServiceRate, @UserID, getdate(), @IsActive, @LocationId, @RoomId, 
					   @LocationName, @RoomDescription,@RoomService,@Amount

				Set @TransId=SCOPE_IDENTITY();
   				     

				SET @Message = 'Service Booking Done Successfully ';
				SET @IsSuccess = 1;		
			END
				
		ELSE  
		    Begin
		

				INSERT INTO [reservation].[ReservationServices]
					   ([ReservationID]           ,[ServiceId]           ,[ServiceDate]           ,[ServiceQty]           ,[GuestQty]
					   ,[ServiceTimeId]           ,[ServiceType]         ,[Status]                ,[ServiceRate]          ,[UserID]
					   ,[DateTime]                ,[IsActive]            ,[LocationId]            ,[RoomId]               ,[LocationName]
					   ,[RoomDescription]           ,[RoomService]) 
				SELECT HRR.[ReservationID],HPI.FeatureId, HRR.[NightDate],HRR.[Adults] + HRR.[ExtraAdults] + HRR.[Children] + HRR.[ExtraChildren], HRR.[Adults] + HRR.[ExtraAdults] + HRR.[Children] + HRR.[ExtraChildren]
					,1,1,'P',0,3
					,GETDATE(),1,1,HRR.[ItemID],HRR.[ItemID]
					,(SELECT iTEMnAME FROM PRODUCTS.Item WHERE ItemId=HRR.[ItemID]) as RoomDescription,'N'
				 from [HMSYOGH].[reservation].[ReservationDetails] HRR
				  LEFT JOIN  [HMSYOGH].[PRODUCTS].[ItemFeatures] HPI on HRR.ItemID=HPI.ItemID
				  WHERE HRR.ReservationID=@ReservationID AND HRR.NightDate=@DateTime --'2022-01-01'

				   Set @TransId=SCOPE_IDENTITY();
			End
				        SET @Remarks=(select Name from service.Item where ItemID=@ServiceId)
					    SET @Remarks='Service-Item Name:' + @Remarks  + ' ,Order Ref#:'+STR(@ServiceId)

						EXEC [reservation].[usp_GuestFolioDetails_IU]
						@FolioNumber = @FolioNumber,
						@ServiceId = 1,
						@Transrefno = @TransId,
						@AmtBeforeTax = @TotalAmountBeforeTax,
						@taxId = @TaxId,
						@taxper = @TaxPer,
						@AmtAfterTax = @TotalAmountAfterTax,
						@PaidStatus = 1,
						@TransStatus = 1,
						@Remarks = @Remarks,
						@IsActive = @IsActive,
						@LocationID = @LocationID,
						@userId = @userId;

				  SET @Message = 'Service Booking Done Successfully ';
				  SET @IsSuccess = 1;		
				  
				
									 			  	
     COMMIT TRANSACTION
	END TRY
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --Error			
		END;        
		IF (XACT_STATE() = 1)  
		BEGIN  			
			COMMIT TRANSACTION;   
			SET @IsSuccess = 1; --Success  			
		END;  		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
	END CATCH;  
	SELECT @IsSuccess [IsSuccess], @Message [Message]
END