CREATE PROC [reservation].[usp_ReservationCard_Select]
	@DocumentType varchar(16),
    @ReservationId int = null,
    @UserID int,    
	@LocationID int,
	@DrawerID int 
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @LocationCode VARCHAR(10);
	DECLARE @CardNo int=0;
			
	BEGIN TRY
		Select @CardNo=isnull(max(CardNo),0) + 1 from [reservation].[ReservationCard] where [DocumentType]=@DocumentType

			--select max(cardno) + 1 from [reservation].[ReservationCard] where [DocumentType]='Form'
			if @CardNo=0 or @CardNo =NULL
				BEGIN
					set @CardNo=1
				END
		BEGIN TRANSACTION		

			INSERT INTO [reservation].[ReservationCard]
						([CardNo],[DocumentType],[ReservationID],[LocationID],[CreatedBy],[CreatedOn])
					VALUES
						(@CardNo, @DocumentType, @ReservationId, @LocationID,@UserID,getdate())		

				SET @IsSuccess = 1; --success 
				SET @Message = 'Card Number Added';			  
	  
		COMMIT TRANSACTION
    
	SELECT @CardNo as CardNo

    if(@DocumentType ='1')
		Begin
			exec [reservation].[spGetReservationView]  @ReservationId,@LocationID,@DrawerID	

			
		
			--SELECT STRING_AGG(PR.RoomNo, ',') AS RoomNumbers FROM [reservation].[ReservedRoom] RR
			--inner join [Products].[Room] PR On RR.RoomID = PR.RoomID
			--where ReservationID = @ReservationId

			SELECT 
    STUFF(
        (
            SELECT ',' + CAST(PR.RoomNo AS VARCHAR(10))
            FROM [reservation].[ReservedRoom] RR
            INNER JOIN [Products].[Room] PR ON RR.RoomID = PR.RoomID
            WHERE RR.ReservationID = 6624
            FOR XML PATH('')
        ), 1, 1, '') AS RoomNumbers;


		END

	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error
			
		END;    
    
		IF (XACT_STATE() = 1)  
		BEGIN  			
			COMMIT TRANSACTION;   
			SET @IsSuccess = 1; --success  
			SET @Message = '';
		END;  
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
	END CATCH; 	

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message] 
END