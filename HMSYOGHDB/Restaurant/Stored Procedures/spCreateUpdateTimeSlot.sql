

CREATE Proc [Restaurant].[spCreateUpdateTimeSlot] 
(
@TimeSlotsID int = null,
@CategoryID int,
@LocationID int ,
@FromTime time(7),
@MealTypeID int,
@UserID int
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @Title varchar(max) = '';	
	DECLARE @NotDesc varchar(max) = '';
	

	BEGIN TRY	
	
		BEGIN TRANSACTION	

					IF(@TimeSlotsID = 0 or @TimeSlotsID is null)
						BEGIN	
							--IF(Exists(select [TimeSlotsID] from  [HMSMASTER].[Restaurant].[TimeSlots]
							-- where ((FromTime between @FromTime and @ToTime) or
							-- (ToTime between  @FromTime and @ToTime) 	 or
							-- (FromTime < @FromTime and ToTime > @ToTime) or
							-- (FromTime > @FromTime and ToTime < @ToTime))
							--  and [LocationId] = @LocationID))

							IF(Exists(select [TimeSlotsID] from  [HMSMASTER].[Restaurant].[TimeSlots]
							 where (((DATEDIFF(MINUTE, FromTime,@FromTime) < 15) and (DATEDIFF(MINUTE, FromTime,@FromTime) >= 0))
									 OR
								   ((DATEDIFF(MINUTE, @FromTime, FromTime) < 15) and (DATEDIFF(MINUTE, @FromTime, FromTime) >= 0)))
									and [LocationId] = @LocationID))

								BEGIN

									 SET @Message = 'Please have minimum 15 minutes difference with exisisting time slots.';
									 SET @IsSuccess = 0;

								END
							ELSE
								BEGIN

									INSERT INTO [HMSMASTER].[Restaurant].[TimeSlots]
										([LocationId], [CategoryID], [FromTime], [MealTypeID], [CreatedBy], [CreatedDate])
										VALUES(@LocationID,@CategoryID,@FromTime,@MealTypeID,@UserID,GETDATE())
					

									SET @Message = 'New time slot has been added successfully.';
									SET @IsSuccess = 1; --success

									SET @Title = 'Location: ' + STR(@LocationID) + '- added with new time slot'
									SET @NotDesc = @Title + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
									EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
							END
						END

					ELSE
						BEGIN	
							--IF(Exists(select [TimeSlotsID] from  [HMSMASTER].[Restaurant].[TimeSlots]
							-- where ((FromTime between @FromTime and @ToTime) or
							-- (ToTime between  @FromTime and @ToTime) 	 or
							-- (FromTime < @FromTime and ToTime > @ToTime) or
							-- (FromTime > @FromTime and ToTime < @ToTime))
							--  and [LocationId] = @LocationID and [TimeSlotsID] <> @TimeSlotsID))-- No need to consider updating Table Slot in update

								IF(Exists(select [TimeSlotsID] from  [HMSMASTER].[Restaurant].[TimeSlots]
								 where (((DATEDIFF(MINUTE, FromTime,@FromTime) < 15) and (DATEDIFF(MINUTE, FromTime,@FromTime) >= 0))
									     OR
								       ((DATEDIFF(MINUTE, @FromTime, FromTime) < 15) and (DATEDIFF(MINUTE, @FromTime, FromTime) >= 0)))
									   AND [LocationId] = @LocationID 
									   AND [TimeSlotsID] <> @TimeSlotsID))
									BEGIN

									 SET @Message = 'Please have minimum 15 minutes difference with exisisting time slots.';
									 SET @IsSuccess = 0;

									END
								ELSE
									BEGIN
										UPDATE [HMSMASTER].[Restaurant].[TimeSlots]
										SET [FromTime] = @FromTime
										,[MealTypeID] = @MealTypeID							
										WHERE [LocationID] = @LocationID and [TimeSlotsID] = @TimeSlotsID
									

										SET @Message = 'Time slot has been updated successfully.';
										SET @IsSuccess = 1; --success

										SET @Title = 'Location: ' + STR(@LocationID) + '- time slot updated'
										SET @NotDesc = @Title + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
										EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc	
									END
						END	
					
	     	EXEC [app].[spInsertActivityLog]24,@LocationID,@Message,@UserID	
		COMMIT TRANSACTION	
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

			IF(@LocationID = 0)
				BEGIN 
					SET @Message = 'New Location has been added successfully.';
				END
			ELSE
				BEGIN
					SET @Message = 'Location has been updated successfully.';
				END
		END;  
		
		--------------Insert into activity log----------------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]24,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END

