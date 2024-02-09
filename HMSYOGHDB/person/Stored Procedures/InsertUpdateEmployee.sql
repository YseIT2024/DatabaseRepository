CREATE PROCEDURE [person].[InsertUpdateEmployee] 
(
    @EmployeeID int=0,
    @TitleID int = NULL,
    @FirstName VARCHAR(50) = NULL,
    @LastName VARCHAR(100) = NULL,    
    @Street VARCHAR(50) = NULL,
    @City VARCHAR(30) = NULL,
    @State VARCHAR(30) = NULL,
    @ZipCode VARCHAR(10) = NULL,
    @CountryID int = NULL,
    @OfficialEmail VARCHAR(50) = NULL,
    @PersonalMail VARCHAR(50) = NULL,
    @DOB date = NULL,
    @DOJ date = NULL,
    @PhoneNumber VARCHAR(15) = NULL,    
    @MaritalStatusID int = NULL,
    @LanguageID int = NULL,
    @IDCardTypeID int = NULL,
    @IDCardNumber VARCHAR(30) = NULL,
    @ImageID  int=0 ,
    @ImageUrl VARCHAR(100) = NULL,
    @LocationID int = NULL,
    @LocationIDs as [app].[dtID] readonly,
    @DesignationID int = NULL,        
    @DepartmentID int = NULL,
    @AddressTypeID int = NULL,
    @AddressID int=0,
    @UserID int = NULL,
    @IsActive bit = NULL,
    @Remarks varchar(255) = null,
    @HrmsEmpID int=0 
)
AS
BEGIN
    SET XACT_ABORT ON; 
    DECLARE @IsSuccess bit = 0;
    DECLARE @Message varchar(max) = '';
    DECLARE @ContactID int;
    DECLARE @GenderID int;
    DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location  WHERE LocationID = @LocationID )
    DECLARE @Title varchar(200);
    DECLARE @Actvity varchar(max);
    BEGIN TRY  
        IF(@EmployeeID <= 0)
        BEGIN
            -- Check if HrmsEmpID already exists
            IF EXISTS (SELECT 1 FROM general.Employee WHERE HrmsEmpID = @HrmsEmpID)
            BEGIN
                -- HrmsEmpID already exists, set @IsSuccess to 0 and provide an error message
                SET @IsSuccess = 0;
                SET @Message = 'Employee with HrmsEmpID ' + CAST(@HrmsEmpID AS varchar(10)) + ' already exists.';
            END
            ELSE
            BEGIN
                -- Proceed with inserting the new employee record
                BEGIN TRANSACTION
                SET @GenderID = (SELECT GenderID FROM person.Title WHERE TitleID = @TitleID);

                Insert Into general.Image(ImageUrl) values(@ImageUrl);
                SET @ImageID = SCOPE_IDENTITY();

                Insert Into contact.Details([TitleID], [FirstName], [LastName], [GenderID], [DOB], [MaritalStatusID], [LanguageID], 
                                             [IDCardTypeID], [IDCardNumber],[DepartmentID],[DesignationID],[ImageID])
                Values (@TitleID,@FirstName,@LastName,@GenderID,@DOB,
                        (CASE WHEN @MaritalStatusID = 0 THEN NULL ELSE @MaritalStatusID END),
                        @LanguageID,
                        (CASE WHEN @IDCardTypeID = 0 THEN NULL ELSE @IDCardTypeID END),
                        @IDCardNumber,@DepartmentID,@DesignationID,@ImageID)

                SET @ContactID = SCOPE_IDENTITY();

                SET @EmployeeID=( Select isnull(max(EmployeeId),0) +1 from general.Employee )

                INSERT INTO general.[Employee]
                    (EmployeeID,[ContactID], OfficialEmail, [JoiningDate], [IsActive],Remarks,[CreatedBy],[CreatedDate],[HrmsEmpID])
                    VALUES( @EmployeeID,@ContactID, @OfficialEmail,@DOJ, @IsActive,@Remarks,@UserID,GETDATE(),@HrmsEmpID);

                INSERT INTO [general].[EmployeeAndLocation]
                ([EmployeeID], [LocationID])
                SELECT @EmployeeID, t.ID
                FROM @LocationIDs t

                INSERT INTO [contact].[Address]
                ([AddressTypeID], [ContactID], [Street], [City], [State], [ZipCode], [CountryID], [Email], [PhoneNumber], [IsDefault])
                VALUES(@AddressTypeID, @ContactID, @Street, @City, @State, @ZipCode, @CountryID, @PersonalMail, @PhoneNumber, 1);

                SET @IsSuccess = 1; -- Success
                SET @Message = 'New employee record has been saved successfully.'

                SET @Title  = 'Employee: ' + @FirstName + ' ' + @LastName + ' has been added'
                SET @Actvity = @Title + ' at ' + @Location +  '. By User ID:' + CAST(@UserID as varchar(10));
                EXEC [app].[spInsertActivityLog] 7,@LocationID, @Actvity,@UserID
                COMMIT TRANSACTION
            END
        END
        ELSE
        BEGIN
            -- Check if HrmsEmpID already exists for a different employee
            --IF EXISTS (SELECT 1 FROM general.Employee WHERE HrmsEmpID = @HrmsEmpID AND EmployeeID != @EmployeeID)
            --BEGIN
            --    -- HrmsEmpID already exists for another employee, set @IsSuccess to 0 and provide an error message
            --    SET @IsSuccess = 0;
            --    SET @Message = 'Employee with HrmsEmpID ' + CAST(@HrmsEmpID AS varchar(10)) + ' already exists for another employee.';
            --END
            --ELSE
            BEGIN
                -- Proceed with updating the employee record
                BEGIN TRANSACTION
                SET @GenderID = (SELECT GenderID FROM person.Title WHERE TitleID = @TitleID);

                SET @ContactID = (Select ContactID from general.Employee Where EmployeeID = @EmployeeID and HrmsEmpID=@HrmsEmpID)

                UPDATE general.Image Set ImageUrl=@ImageUrl where ImageID = @ImageID

                UPDATE [contact].[Details]
                SET [TitleID] = @TitleID
                    ,[FirstName] = @FirstName
                    ,[LastName] = @LastName
                    ,[GenderID] = @GenderID
                    ,[DOB] = @DOB,
					 [MaritalStatusID] = CASE WHEN @MaritalStatusID = 0 THEN NULL ELSE @MaritalStatusID END
                    --,[MaritalStatusID] = @MaritalStatusID
                    ,[LanguageID] = @LanguageID
                    --,[IDCardTypeID] = @IDCardTypeID
					,[IDCardTypeID] = CASE WHEN @IDCardTypeID = 0 THEN NULL ELSE @IDCardTypeID END
                    ,[IDCardNumber] = @IDCardNumber
                    ,[DepartmentID] = @DepartmentID
                    ,[DesignationID] = @DesignationID
                    WHERE ContactID = @ContactID

                UPDATE general.[Employee]
                SET OfficialEmail = @OfficialEmail,
                    [JoiningDate] = @DOJ,
                    ResignationDate = CASE WHEN @IsActive = 0 THEN GETDATE() ELSE null END,
                    IsActive  = @IsActive ,
                    Remarks = @Remarks,
                    CreatedBy = @UserID ,
                    CreatedDate = GETDATE()
                WHERE EmployeeID = @EmployeeID

                DELETE FROM [general].[EmployeeAndLocation]
                WHERE EmployeeID = @EmployeeID             

                INSERT INTO [general].[EmployeeAndLocation]
                ([EmployeeID], [LocationID])
                SELECT @EmployeeID, t.ID
                FROM @LocationIDs t

                Update [contact].[Address] 
                SET AddressTypeID = @AddressTypeID ,
                    Street = @Street ,
                    City = @City , 
                    State = @State ,
                    ZipCode = @ZipCode ,
                    CountryID = @CountryID ,
                    Email = @PersonalMail ,
                    PhoneNumber = @PhoneNumber 
                Where AddressID = @AddressID

                SET @IsSuccess = 1; -- Success
                SET @Message = 'Employee record has been updated successfully.'

                SET @Title  = 'Employee: ' + @FirstName + ' ' + @LastName + ' has been updated'
                SET @Actvity  = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
                EXEC [app].[spInsertActivityLog] 7,@LocationID, @Actvity,@UserID
                COMMIT TRANSACTION
            END
        END
    END TRY  
    BEGIN CATCH    
        IF (XACT_STATE() = -1) 
        BEGIN              
            ROLLBACK TRANSACTION;  
            SET @Message = ERROR_MESSAGE();
            SET @IsSuccess = 0; -- Error
        END;    

        IF (XACT_STATE() = 1)  
        BEGIN              
            COMMIT TRANSACTION;   
        END;  
    END CATCH; 

    SELECT @IsSuccess AS IsSuccess, @Message as [Message], @EmployeeID as [EmployeeID]
END
