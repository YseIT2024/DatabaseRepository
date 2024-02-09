
create PROCEDURE [BQTReservation].[usp_BQTEventDetails_IU]
    @UserId int=null,
	@LocationId int=null,
	@BQTEventDetails AS [BQTReservation].[BQTEvent] READONLY

AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IsSuccess bit = 0;
    DECLARE @Message varchar(max) = '';

			BEGIN TRY
						BEGIN TRANSACTION

						--IF EXISTS (SELECT * FROM [BQTReservation].[BQTEventDetails] WHERE BQTEventDetailsID = @BQTEventDetailsID)
       
								BEGIN
									INSERT INTO [BQTReservation].[BQTEventDetails]
									   (BookingID,FromDate,FromTime,ToDate,ToTime,BookedVenueId,EventTypeId,SetupRequired,TotalPax,CreatedBy,CreatedDate,IsActive)
								     select BookingID,FromDate,CONVERT(TIME,FromTime),[ToDate],CONVERT(TIME,ToTime),BookedVenueId,EventTypeId,Setuprequired,[Pax], @UserId, GETDATE(),1
									from @BQTEventDetails
									 


									--SET @BQTEventDetailsID = SCOPE_IDENTITY();
									SET @IsSuccess = 1; -- success
									SET @Message = 'BQTEventDetails Inserted successfully.';
								END
						EXEC [app].[spInsertActivityLog] 7, @LocationID, @UserId;
						COMMIT TRANSACTION;
			END TRY

    BEGIN CATCH
        IF (XACT_STATE() = -1) 
        BEGIN
            --ROLLBACK TRANSACTION;  
            SET @Message = ERROR_MESSAGE();
            SET @IsSuccess = 0; -- error            
        END;     

        --DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());        
        --EXEC [app].[spInsertActivityLog] 20, @LocationID, @Act, @UserId;
    END CATCH;  

    SELECT @IsSuccess AS [IsSuccess], @Message AS [Message];
END;
