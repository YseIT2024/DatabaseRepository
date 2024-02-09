
CREATE Proc [contact].[spCreateUpdateSupplier]
(	
	@AddressID int,
	@ContactID int,
	@SupplierName varchar(100),	
	@AddressTypeID int,		
	@CountryID int,	
	@PhoneNumber varchar(15),	
	@LocationID int,
	@UserID int,
	@Street varchar(50) = NULL,
	@City varchar(30) = NULL,
	@Email varchar(50) = NULL,		
	@State varchar(30) = NULL,
	@ZipCode varchar(10) = NULL,
	@ContactPersonName varchar(100),
	@DrawerID int,
	@Designation varchar(10) = NULL
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @Drawer varchar(20);
	Declare @SupplierNo varchar(50)

	SELECT @Drawer = Drawer FROM app.Drawer WHERE DrawerID = @DrawerID

	BEGIN TRY		

	
			BEGIN TRANSACTION			

				IF(@ContactID = 0)
				BEGIN
					INSERT INTO [contact].[Details]
					([FirstName])
					VALUES(@SupplierName)

					SET @ContactID = SCOPE_IDENTITY();

					INSERT INTO [contact].[Address]
					([AddressTypeID],[ContactID],[Street],[City],[State],[ZipCode],[CountryID],[Email],[PhoneNumber],[IsDefault])
					VALUES(@AddressTypeID,@ContactID,@Street,@City,@State,@ZipCode,@CountryID,@Email,@PhoneNumber,1)

					Declare @SupplierPrefix varchar(20);
					select @SupplierPrefix= isnull([value],'SUP') from app.Parameter where ParameterID =2

					select @SupplierNo=@SupplierPrefix+convert(varchar, isnull(max(SupplierID),0)+ 1001) 
					from general.Supplier 

					insert into general.Supplier(SupplierNo,ContactID,CreatedBy,CreatedDate,ContactPerson,Designation)
					values(@SupplierNo,@ContactID,@UserID,GETDATE(),@ContactPersonName,@Designation)

					SET @Message = 'New supplier has been added successfully.';
					
					

				END
				ELSE
				BEGIN
					UPDATE [contact].[Details]
					SET 
					[FirstName] = @SupplierName
					WHERE ContactID = @ContactID

					UPDATE [contact].[Address]
					SET [AddressTypeID] = @AddressTypeID
					,[Street] = @Street
					,[City] = @City
					,[State] = @State
					,[ZipCode] = @ZipCode
					,[CountryID] = @CountryID
					,[Email] = @Email
					,[PhoneNumber] = @PhoneNumber
					,[IsDefault] = 1
					WHERE AddressID = @AddressID

					update general.Supplier
					set ContactPerson=@ContactPersonName
					,Designation=@Designation
					where ContactID=@ContactID

					SET @Message = 'Supplier has been updated successfully.';

					

				END						

				SET @IsSuccess = 1; --success
				
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
			IF(@ContactID = 0)
			BEGIN 
				SET @Message = 'New supplier has been added successfully.';
			END
			ELSE
			BEGIN
				SET @Message = 'Supplier has been updated successfully.';
			END
		END;  
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @ContactID as [ContactPersonID]
END











