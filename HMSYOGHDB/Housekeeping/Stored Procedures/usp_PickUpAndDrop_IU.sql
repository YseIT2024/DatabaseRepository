CREATE PROC [Housekeeping].[usp_PickUpAndDrop_IU]
	@pickupdropid int null,
	@Type varchar(100),
    @PickupdropDate DateTime,
    @PickupDropAddress varchar(300),	
    @Transport int,
    @VehicleType int,
    @ReservationID int,
    @userId int,   
	@LocationID int,
	@tobeCharge bit,
	@Status varchar(50),
	@complementary bit,
	@Amount decimal(18,2)=0,
	@flightdetails varchar(250),
	@PickUpDropTime DateTime=null
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @FolioNo int = (SELECT FolioNumber FROM reservation.Reservation WHERE ReservationID=@ReservationID)
	DECLARE @TaxId int =0 --0(SELECT  TaxID  FROM service.ServiceTax WHERE ServiceTypeID=84 and IsActive=1)
	DECLARE @TaxPer decimal(8, 2) =0 --(SELECT TaxRate FROM general.Tax WHERE TaxID=@TaxId and IsActive=1)
	
	DECLARE @AmtAfterTax decimal(18, 2)=@Amount;
	DECLARE @LineTotalTax decimal(18, 3)=0;--@Amount/(1+@TaxPer);
	DECLARE @LineTotalBT decimal(18, 3)=@Amount-@LineTotalTax;
	DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location  WHERE LocationID = @LocationID )
	DECLARE @ServicetTypeId int=20
	DECLARE @ServiceDescription varchar(100) 
	SET @ServiceDescription =(SELECT [Description] FROM [service].[Type]  WHERE ServiceTypeid=@ServicetTypeId)
	--SET  @ServiceDescription  = CONCAT(@ServiceDescription, '- ', @PickupDropAddress, ', ', @flightdetails)
	SET  @ServiceDescription  = CONCAT(@PickupDropAddress, ', ', @flightdetails)

	BEGIN TRY	
	BEGIN TRANSACTION

		-- Check if the same reservation ID and type already exist
		
		BEGIN
			IF EXISTS (SELECT * FROM [Housekeeping].[PickupAndDrop] WHERE pickupdropid=@pickupdropid)
			BEGIN
				-- Update existing row
				UPDATE [Housekeeping].[PickupAndDrop]
				SET
					[Type] = @Type, 
					[PickupdropDate] = @PickupdropDate, 					   [PickupDropAddress] = @PickupDropAddress,   
					[Transport] = @Transport, 					   [VehicleType] = @VehicleType, 	 					 
					[ModifiedBy] = @userId, 					   [ModifiedOn] = GETDATE(), 
					[ReservationId]=@ReservationId,					   [LocationId]=@LocationID,
					[TobeCharge]=@tobeCharge,					   [Staus]=@Status,
					[complementary]=@complementary,					   [Amount]=@Amount,
					[FlightDetails]=@flightdetails,
			        [PickUpDropTime] =CONVERT(varchar(5), @PickUpDropTime, 108)
				WHERE [pickupdropid] = @pickupdropid

				SET @IsSuccess = 1; --success 
				SET @Message = 'Updated successfully.';
			END
			ELSE
			BEGIN
			IF EXISTS (	SELECT * FROM [Housekeeping].[PickupAndDrop] WHERE ReservationId = @ReservationID AND [Type] =@Type and [Type]<>'Transport') --IN ('PickUp','Drop')--=@Type )
		     BEGIN
			  SET @IsSuccess = 1; --error
			  SET @Message = 'already exist for this ReservationId.';
		    END
		    ELSE
				-- Insert new row
				INSERT INTO [Housekeeping].[PickupAndDrop]
				([Type],[PickupdropDate],[PickupDropAddress],[Transport],[VehicleType]  
			   ,[CreatedOn],[CreatedBy],[ReservationId],[TobeCharge],[LocationId],
			   [Staus],[complementary],[Amount],[FlightDetails],LineTotalBT,LineTotalTax,PickUpDropTime)
				VALUES
				(@Type,@PickupdropDate,@PickupDropAddress,@Transport,@VehicleType,
				getdate(),@userId,@ReservationId,@tobeCharge,@LocationID,
				@Status,@complementary,@Amount,@flightdetails,@LineTotalBT,@LineTotalTax,CONVERT(varchar(5), @PickUpDropTime, 108))

				SET @pickupdropid = SCOPE_IDENTITY();

				EXEC [reservation].[usp_GuestFolioDetails_IU]	
				@LedgerId = 0,
				@FolioNumber = @FolioNo,
				@ServiceId = @ServicetTypeId,
				@Transrefno =@pickupdropid,
				@AmtBeforeTax = @LineTotalBT,
				@taxId = @TaxId,
				@taxper =@TaxPer,
				@AmtAfterTax = @Amount,
				@PaidStatus = 1,
				@TransStatus = 1,
				--@Remarks = @ServiceDescription + '-' + @PickupDropAddress + @flightdetails ,
			   -- @Remarks = ISNULL(@ServiceDescription, '') + '-' + ISNULL(@PickupDropAddress, '') + ' ' + ISNULL(@flightdetails, ''),
			    @Remarks = @ServiceDescription,  --CONCAT(@ServiceDescription, '- ', @PickupDropAddress, ', ', @flightdetails!),
				@IsActive = 1,
				@LocationID = 1,
				@userId = 1

				SET @IsSuccess = 1; --success
				SET @Message = 'Created successfully.'
			END
		END

		EXEC [app].[spInsertActivityLog] 7,@LocationID,@userId
		COMMIT TRANSACTION	
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error			
		END;
	END CATCH;

	SELECT @IsSuccess AS IsSuccess, @Message AS Message,@pickupdropid as pickupdropid ;-----Added by sravani
END