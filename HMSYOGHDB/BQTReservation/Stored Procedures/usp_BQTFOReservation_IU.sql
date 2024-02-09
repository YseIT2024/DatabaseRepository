CREATE PROCEDURE [BQTReservation].[usp_BQTFOReservation_IU]
    
    @UserId Int=null,
	@LocationId int=null,
	@BQTEVENTReservation AS [BQTReservation].[BQTFOReservationDetails] READONLY
  
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IsSuccess bit = 0;
    DECLARE @Message varchar(max) = '';

    BEGIN TRY
        BEGIN TRANSACTION

        --IF EXISTS (SELECT * FROM [BQTReservation].[BQTRoomReservation] WHERE BQTRoomReservationId = @BQTRoomReservationId)
        --BEGIN
        --    UPDATE [BQTReservation].[BQTRoomReservation] SET
        --        BookingID = @BookingID,
        --        ArrivalDate = @ArrivalDate,
        --        DepartureDate = @DepartureDate,
        --        SubCategoryId = @SubCategoryId,
        --        NumberofRooms = @NumberofRooms,
        --        RoomRate = @RoomRate,
        --        ModifiedBy =@UserId,
        --        ModifiedDate = GETDATE(),
        --        IsActive = @IsActive
        --    WHERE BQTRoomReservationId = @BQTRoomReservationId;

        --    SET @IsSuccess = 1; -- success 
        --    SET @Message = 'BQTRoomReservation Updated Successfully.';
        --END
        --ELSE
        BEGIN
            INSERT INTO [BQTReservation].[BQTRoomReservation] (
                BookingID,
                ArrivalDate,
                DepartureDate,
                SubCategoryId,
                NumberofRooms,
                RoomRate,
                CreatedBy,
                CreatedDate,
                IsActive
            )
            select BookingID,Arrival,Departure,RoomType,NumberofRooms,Rate,@UserId,GETDATE(),1
									from @BQTEVENTReservation


            --SET @BQTRoomReservationId = SCOPE_IDENTITY();
            SET @IsSuccess = 1; -- success
            SET @Message = 'BQTRoomReservation Inserted successfully.';
        END
      EXEC [app].[spInsertActivityLog] 7, @LocationID, @UserId;
        COMMIT TRANSACTION;
       END TRY
       BEGIN CATCH
        IF (XACT_STATE() = -1) 
        BEGIN
            ROLLBACK TRANSACTION;  
            SET @Message = ERROR_MESSAGE();
            SET @IsSuccess = 0; -- error            
        END;     

        --DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());        
        --EXEC [app].[spInsertActivityLog] 20, @LocationID, @Act, @UserId;
    END CATCH;  

    SELECT @IsSuccess AS [IsSuccess], @Message AS [Message];
END
