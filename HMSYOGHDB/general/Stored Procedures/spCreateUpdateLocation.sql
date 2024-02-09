

CREATE PROCEDURE [general].[spCreateUpdateLocation] 
(
@UserID int,
@LocationID int = null,
@LocationTypeID int,
@ParentID int = null,
@LocationCode varchar(5),
@LocationName varchar(50),
@CountryID int,
@ReportAddress varchar(150),
@Remarks varchar(250),
@CheckInTime time(7),
@CheckOutTime time(7),
@IsActive bit,
@ReportLogo nvarchar(max)
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

			IF(@LocationID = 0 or @LocationID is null)
				BEGIN	
				
				IF EXISTS (SELECT 1 FROM [general].[Location] WHERE [LocationCode] = @LocationCode )
				BEGIN
					SET @Message = 'Location Code already exists.';
					SET @IsSuccess = 0; 
				END
				Else IF EXISTS (SELECT 1 FROM [general].[Location] WHERE [LocationName] = @LocationName)
				BEGIN
					SET @Message = 'Location Name already exists.';
					SET @IsSuccess = 0; 
				END
				Else 
				BEGIN
					INSERT INTO [general].[Location]
						([LocationTypeID],[ParentID],[LocationCode],[LocationName],[CountryID],[ReportAddress],[Remarks],[CheckInTime],
						[CheckOutTime],[IsActive],[MainCurrencyID],[RateCurrencyID],[HotelCashFigureHasToBeZero],CommonReportLogo)
						VALUES(@LocationTypeID,@ParentID,@LocationCode,@LocationName,@CountryID,@ReportAddress,@Remarks,@CheckInTime,
						@CheckOutTime,@IsActive,1,3,0,@ReportLogo)
					

					SET @Message = 'New location has been added successfully.';
					SET @IsSuccess = 1; --success

					SET @Title = 'Location: ' + @LocationName + ' - ' + @LocationCode + ' has added'
					SET @NotDesc = @Title + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
					EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc		
				END

							
			    END
			ELSE
				BEGIN	
					IF EXISTS (SELECT 1 FROM [general].[Location] WHERE [LocationCode] = @LocationCode and [LocationID] <> @LocationID )
						BEGIN
							SET @Message = 'Location Code already exists.';
							SET @IsSuccess = 0; 
						END
				   Else IF EXISTS (SELECT 1 FROM [general].[Location] WHERE [LocationName] = @LocationName and [LocationID] <> @LocationID )
					   BEGIN
							SET @Message = 'Location Name already exists.';
							SET @IsSuccess = 0; 
						END
					Else 
						BEGIN
							UPDATE [general].[Location]
							SET [LocationTypeID] = @LocationTypeID
							,[ParentID] = @ParentID
							,[LocationCode] = @LocationCode
							,[LocationName] = @LocationName
							,[CountryID] = @CountryID
							,[ReportAddress] = @ReportAddress
							,[Remarks] = @Remarks
							,[CheckInTime] = @CheckInTime
							,[CheckOutTime] = @CheckOutTime
							,[IsActive] = @IsActive
							,[CommonReportLogo] = @ReportLogo
							WHERE [LocationID] = @LocationID
									

							SET @Message = 'Location has been updated successfully.';
							SET @IsSuccess = 1; --success

							SET @Title = 'Location: ' + @LocationName + ' - ' + @LocationCode + ' has updated'
							SET @NotDesc = @Title + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
							EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc		
						END	
				END		
					
		COMMIT TRANSACTION	
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  

			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error			
		END;    
    
		--IF (XACT_STATE() = 1)  
		--BEGIN  			
		--	COMMIT TRANSACTION;   
		--	SET @IsSuccess = 1; --success 

		--	IF(@LocationID = 0)
		--		BEGIN 
		--			SET @Message = 'New Location has been added successfully.';
		--		END
		--	ELSE
		--		BEGIN
		--			SET @Message = 'Location has been updated successfully.';
		--		END
		--END;  
		
		--------------Insert into activity log----------------------	
		DECLARE @Act VARCHAR(MAX) = @Message-- (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]6,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END
