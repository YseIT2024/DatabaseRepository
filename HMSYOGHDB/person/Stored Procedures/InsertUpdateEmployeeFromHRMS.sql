CREATE PROCEDURE [person].[InsertUpdateEmployeeFromHRMS] 
(       
    @EmployeeID int=0,  
    @TitleID int = NULL,
    @FirstName VARCHAR(100) = NULL,
    @LastName VARCHAR(100) = NULL,  
	@FullName VARCHAR(100) = NULL, 
	@Gender VARCHAR(50) = NULL,
    @Street VARCHAR(50) = NULL,  --Address   
    @PersonalMail VARCHAR(50) = NULL, --Email
    @DOB date = NULL,	--DateOfBirth
    @DOJ date = NULL,	--DateOfJoin
    @PhoneNumber VARCHAR(15) = NULL,    --Mobile   
    @IDCardNumber VARCHAR(30) = NULL,  --GovtId 
	@EmployeeImage VARCHAR(max) = NULL, -- byte=null 
    @LocationID int = NULL, --LocationId
	@Location VARCHAR(100) = NULL,
    @DesignationID int = NULL, 
	@Position VARCHAR(100) = NULL,
    @DepartmentID int = NULL,
	@Department VARCHAR(100) = NULL, 
    @UserID int = NULL,
    @IsActive bit = NULL,
    @Remarks varchar(500) = null, --'Imported through API'
	@CompanyName  VARCHAR(100) = NULL,
    @CompanyId int = NULL,
	@HrmsEmpID int=0 --EmpId
  
)
AS
BEGIN
    SET XACT_ABORT ON; 
    DECLARE @IsSuccess bit = 0;
    DECLARE @Message varchar(max) = '';
    DECLARE @ContactID int;
    DECLARE @GenderID int;
    DECLARE @Title varchar(200);
    DECLARE @Actvity varchar(max);
	DECLARE @LocationCode varchar(20);
	DECLARE @ImageID INT;
	
    BEGIN TRY	

		IF(@EmployeeID = 0)
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
				

				SET @EmployeeImage='YsecIT'
                Insert Into general.Image(ImageUrl) values(@EmployeeImage);
				
                SET @ImageID = SCOPE_IDENTITY();

				-------------INSERT INTO DEPARTMENT IF NOT EXIST TO GET THE CODE-----------------
				--SET @DepartmentID=(SELECT DepartmentID  FROM general.Department WHERE DEPARTMENT=@Department)
				SET @DepartmentID=(SELECT DepartmentID FROM general.Department WHERE DEPARTMENT = @Department)

				IF @DepartmentID IS NULL
					BEGIN
						INSERT INTO general.Department (DEPARTMENT)
						VALUES (@Department)

						SET @DepartmentID = SCOPE_IDENTITY()
					END
				---------------------------------------------------------------------------------

				-------------INSERT INTO DESIGFNATION IF NOT EXIST TO GET THE CODE-----------------
				--SET @DesignationID=(SELECT DesignationID  FROM general.Designation WHERE Designation=@Position)
				SET @DesignationID=(SELECT DesignationID FROM general.Designation WHERE Designation = @Position)

				IF @DesignationID IS NULL
					BEGIN
						INSERT INTO general.Designation (Designation)
						VALUES (@Position)

						SET @DesignationID = SCOPE_IDENTITY()
					END
				---------------------------------------------------------------------------------
				
				SET @GenderID = (SELECT GenderID FROM person.Gender WHERE lower(Gender) =lower(@Gender));
			
				
				SET @TitleID=@GenderID;
                Insert Into contact.Details([TitleID], [FirstName], [LastName], [GenderID], [DOB], [MaritalStatusID], [LanguageID], 
                                             [IDCardTypeID], [IDCardNumber],[DepartmentID],[DesignationID],[ImageID])
                Values (@TitleID,@FirstName,@LastName,@GenderID,@DOB,null,NULL,NULL,                     
                        @IDCardNumber,@DepartmentID,@DesignationID,NULL)

                SET @ContactID = SCOPE_IDENTITY();

                SET @EmployeeID=( Select isnull(max(EmployeeId),0) +1 from general.Employee )



                INSERT INTO general.[Employee]
                    (EmployeeID,[ContactID], OfficialEmail, [JoiningDate], [IsActive],Remarks,[CreatedBy],[CreatedDate],[HrmsEmpID])
                    VALUES( @EmployeeID,@ContactID,@PersonalMail ,@DOJ, 1,@Remarks,@UserID,GETDATE(),@HrmsEmpID);

				------------------TO GET THE LOCATION-----------------			
				
				IF EXISTS (SELECT LocationCode FROM general.Location WHERE LocationName=@Location )
					BEGIN
						Set  @LocationID  = (SELECT LocationID FROM general.Location  WHERE LocationName=@Location );
					END
				else
					BEGIN	
						SET @LocationID = 1;
						--INSERT INTO [general].[Location]
						--	   ([LocationTypeID],[ParentID],[LocationCode],[LocationName]
						--	   ,[CountryID],[MainCurrencyID],[ReportAddress],[ReportLogo]
						--	   ,[HotelCashFigureHasToBeZero],[AllowNegativeStock],[CheckInTime],[CheckOutTime]
						--	   ,[IsActive],[Remarks],[RateCurrencyID],[CasinoRateCurrencyID]
						--	   ,[CasinoCashFigureHasToBeZero])
						-- VALUES
						--	   (<LocationTypeID, int,>,<ParentID, int,>,<LocationCode, varchar(5),>,<LocationName, varchar(50),>
						--	   ,<CountryID, int,>,<MainCurrencyID, int,>,<ReportAddress, varchar(150),>,<ReportLogo, varchar(100),>
						--	   ,<HotelCashFigureHasToBeZero, bit,>,<AllowNegativeStock, bit,>,<CheckInTime, time(7),>,<CheckOutTime, time(7),>
						--	   ,<IsActive, bit,>,<Remarks, varchar(250),>,<RateCurrencyID, int,>,<CasinoRateCurrencyID, int,>
						--	   ,<CasinoCashFigureHasToBeZero, bit,>)

						--SET @LocationID = SCOPE_IDENTITY();
					END		
				
				
				-----------------------END----------------------------   

				INSERT INTO [general].[EmployeeAndLocation]
                ([EmployeeID], [LocationID])
				VALUES(@EmployeeID,@LocationID)
               

                INSERT INTO [contact].[Address]
                ([AddressTypeID], [ContactID], [Street], [City], [State], [ZipCode], [CountryID], [Email], [PhoneNumber], [IsDefault])
                VALUES(1, @ContactID, @Street, NULL, NULL, NULL, 164, @PersonalMail, @PhoneNumber, 1);

                SET @IsSuccess = 1; -- Success
                SET @Message = 'New employee record has been saved successfully.'

                SET @Title  = 'Employee: ' + @FirstName + ' ' + @LastName + ' has been added'
                SET @Actvity = @Title + ' at ' + @Location +  '. By User ID:' + CAST(@UserID as varchar(10));
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

