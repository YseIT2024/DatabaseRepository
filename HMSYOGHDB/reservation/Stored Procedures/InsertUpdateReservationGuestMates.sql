CREATE PROC [reservation].[InsertUpdateReservationGuestMates]
    @GuestMatesID int,
    @ReservationID int,
    @FirstName varchar(100),
    @MiddleName varchar(100) = null,
    @LastName varchar(100) = null,
	@CountryID int,
    @GenderID int,
	@GuestTypeID int,    
	--@PIDTypeID int,     
    --@PIDNo varchar(50),
	@DOB datetime,
    @ActualCheckIn datetime =  null,
    @ExpectedCheckOut datetime =  null,
    @ActualCheckOut datetime =  null,
    @UserID int,
	@LocationID int,
    @IsActive int,
	@GuestID int,
	@RoomID int
	--,@dtReservationProofDocs as [reservation].[ReservationProofDocs] readonly
AS 
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @NotDesc varchar(max) = '';
	DECLARE @Title varchar(max) = '';

    BEGIN TRY	
		
		IF(@GuestMatesID < 1)
		BEGIN
				if(NOT EXISTS(select * from reservation.ReservationGuestMates where ReservationID=@ReservationID and GuestID=@GuestID))
				BEGIN
					INSERT INTO reservation.ReservationGuestMates ( ReservationID, FirstName, MiddleName, 
																   LastName, Gender, DOB, GuestType, Nationality, 
																   /*PIDType,PIDNo,*/ ActualCheckIn, ExpectedCheckOut, ActualCheckOut, 
																   UserID, CreatedDate, IsActive,GuestID,RoomID)
					Values( @ReservationID, @FirstName, @MiddleName, @LastName, @GenderID, @DOB, @GuestTypeID, 
						   @CountryID, /*@PIDTypeID, @PIDNo,*/ @ActualCheckIn, @ExpectedCheckOut, @ActualCheckOut, @UserID, 
						   GetDate(), @IsActive,@GuestID,@RoomID)

						   SET @GuestMatesID = SCOPE_IDENTITY();

					SET @IsSuccess = 1; --success 
					SET @Message = 'Co-Guest added successfully.';	
					SET @Title = 'Guest mates data for Reservation: ' + Cast(@ReservationID AS Varchar(20)) + ' added';
				END
				ELSE
				BEGIN
					SET @IsSuccess = 1; --success 
					SET @Message = 'Guest Already Existed.';	
					SET @Title = '';
				END

		END
		ELSE
		BEGIN	
		declare @PrimaryGuestId int=(select GuestID from reservation.Reservation where ReservationID=@ReservationID);
		if((select GuestID from reservation.ReservationGuestMates WHERE GuestMatesID = @GuestMatesID) = @PrimaryGuestId)
		BEGIN
				UPDATE reservation.ReservationGuestMates
					SET    UserID = @UserID, CreatedDate = GetDate(), RoomID=@RoomID
					WHERE  GuestMatesID = @GuestMatesID
				
					SET @IsSuccess = 1; --success 
					SET @Message = 'Being a Primary guest only room no is modified..!';	
					SET @Title = '';		
		END
		ELSE
		BEGIN
			if(EXISTS(select * from reservation.ReservationGuestMates where ReservationID=@ReservationID and GuestID=@GuestID))
				BEGIN
					UPDATE reservation.ReservationGuestMates
					SET   FirstName = @FirstName, MiddleName = @MiddleName, LastName = @LastName, 
						   Gender = @GenderID, DOB = @DOB, GuestType = @GuestTypeID, Nationality = @CountryID, /*PIDType = @PIDTypeID, 
						   PIDNo = @PIDNo,*/ ActualCheckIn = @ActualCheckIn, ExpectedCheckOut = @ExpectedCheckOut, ActualCheckOut = @ActualCheckOut, 
						   UserID = @UserID, CreatedDate = GetDate(), IsActive = @IsActive, GuestID=@GuestID,RoomID=@RoomID
					WHERE  GuestMatesID = @GuestMatesID

					SET @IsSuccess = 1; --success 
					SET @Message = 'Co-Guest updated successfully.';	
					SET @Title = 'Guest mates data for Reservation: ' + Cast(@ReservationID AS Varchar(20)) + ' updated';
				END
				ELSE
				BEGIN
					SET @IsSuccess = 1; --success 
					SET @Message = 'Co-Guest Already Existed.';	
					SET @Title = '';
				END
			END
		END

		 
		SET @NotDesc = @Message+ @Title + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
		EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
      EXEC [app].[spInsertActivityLog]41,@LocationID,@NotDesc,@UserID,@Title
    END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION; 			
			SET @Message = ERROR_MESSAGE();			
			SET @IsSuccess = 0; --error			
		END; 		
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]41,@LocationID,@Act,@UserID	, @Message
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message];
END
