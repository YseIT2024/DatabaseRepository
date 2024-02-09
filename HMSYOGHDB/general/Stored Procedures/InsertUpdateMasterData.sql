-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [general].[InsertUpdateMasterData] 
(
	@TableId int,
	@ID int,
	@Description varchar(100),
	@UserID int,
	@LocationID int
) AS
BEGIN
    declare @Message varchar(100)='Record Added Successfullly';
	set @Description=ltrim(rtrim(@Description))
	--if(@ID>0)
	--	set @Message= 'Record Updated Successfullly';

	IF(@TableId=1)
	BEGIN
		if(@ID>0)
			begin
				update general.Department set [Department]=@Description where DepartmentID=@ID		
				set @Message= 'Department Updated Successfullly'
			end
		else IF NOT EXISTS(SELECT * FROM general.Department where UPPER([Department]) = UPPER(@Description) ) 
			begin
				INSERT INTO general.Department(Department) VALUES(@Description);	
				set @Message= 'Department Added Successfullly'
			end
		--ELSE
			--set @Message= 'Record already exist'
		--	set @Message= 'Department Added Successfullly'
	END 	
	Else IF(@TableId=2)
	BEGIN
		if(@ID>0)
			begin		
				update general.Designation set Designation=@Description where DesignationID=@ID				
				set @Message= 'Designation Updated Successfullly'
			end
		else IF NOT EXISTS(SELECT * FROM general.Designation where UPPER(Designation) = UPPER(@Description)) 
			begin
			INSERT INTO general.Designation(Designation) VALUES(@Description);	   
		--ELSE
			set @Message= 'Designation Added Successfullly'
			end
	END 
	Else If(@TableId = 3)
	BEGIN
	  if(@ID>0)
		begin
			update app.Roles set Role=@Description where RoleId=@ID
			set @Message= 'Roles updated Successfullly'
		end
		else IF NOT EXISTS(SELECT * FROM app.Roles where UPPER(Role) = UPPER(@Description)) 
			begin
				INSERT INTO app.Roles(Role,IsActive) VALUES(@Description,1);	   
		--ELSE
				set @Message= 'Record already exist'
			end
	END 
	Else If(@TableId = 6)
	BEGIN
		IF(@ID>0)--Update
			BEGIN
				IF EXISTS(SELECT * FROM [Products].[FoodGroup] where UPPER([Description]) = UPPER(@Description) and [FoodGroupID] <> @ID) 
					BEGIN
						SET @Message= 'Food Group already exists.'						
					END
				ELSE
					BEGIN
						update [Products].[FoodGroup] set [Description] = @Description where [FoodGroupID] = @ID
						SET @Message= 'Food Group updated successfully.'
					END
			END
		ELSE 
			BEGIN
				IF EXISTS(SELECT * FROM [Products].[FoodGroup] where UPPER([Description]) = UPPER(@Description)) 
					BEGIN
						SET @Message= 'Food Group already exists.'						
					END
				ELSE
					BEGIN
						INSERT INTO [Products].[FoodGroup]([Description], [CreatedBy], [CreateDate]) VALUES(@Description, @UserID, GETDATE());	   
						SET @Message= 'Food Group added successfully.'
					END
			END
		END
	Else If(@TableId = 7)
	BEGIN
		IF(@ID>0)--Update
			BEGIN
				IF EXISTS(SELECT * FROM [Products].[CuisineType] where UPPER([Name]) = UPPER(@Description) and [CuisineTypeID] <> @ID) 
					BEGIN
						SET @Message= 'Cuisine Type already exists.'						
					END
				ELSE
					BEGIN
						update [Products].[CuisineType] set [Name] = @Description where [CuisineTypeID] = @ID
						SET @Message= 'Cuisine Type updated successfully.'
					END
			END
		ELSE 
			BEGIN
				IF EXISTS(SELECT * FROM [Products].[CuisineType] where UPPER([Name]) = UPPER(@Description)) 
					BEGIN
						SET @Message= 'Cuisine Type already exists.'						
					END
				ELSE
					BEGIN
						INSERT INTO [Products].[CuisineType] ([Name], [CreatedBy], [CreateDate]) VALUES(@Description, @UserID, GETDATE());	   
						SET @Message= 'Cuisine Type added successfully.'
					END
			END
	END
	Else If(@TableId = 10)
	BEGIN
		IF(@ID>0)--Update
			BEGIN
				IF EXISTS(SELECT * FROM [Products].[Brand] where UPPER([Description]) = UPPER(@Description) and [BrandID] <> @ID) 
					BEGIN
						SET @Message= 'Brand already exists.'						
					END
				ELSE
					BEGIN
						update [Products].[Brand] set [Description] = @Description where [BrandID] = @ID
						SET @Message= 'Brand updated successfully.'
					END
			END
		ELSE 
			BEGIN
				IF EXISTS(SELECT * FROM [Products].[Brand] where UPPER([Description]) = UPPER(@Description)) 
					BEGIN
						SET @Message= 'Brand already exists.'						
					END
				ELSE
					BEGIN
						INSERT INTO [Products].[Brand] ([Description], [CreatedBy], [CreateDate]) VALUES(@Description, @UserID, GETDATE());	   
						SET @Message= 'Brand added successfully.'
					END
			END
	END
	Else If(@TableId = 11)
	BEGIN
		IF(@ID>0)--Update
			BEGIN
				IF EXISTS(SELECT * FROM [general].[Tax] where UPPER([TaxName]) = UPPER(@Description) and [TaxID] <> @ID) 
					BEGIN
						SET @Message= 'Tax Name already exists.'						
					END
				ELSE
					BEGIN
						update [general].[Tax] set [TaxName] = @Description where [TaxID] = @ID
						SET @Message= 'Tax updated successfully.'
					END
			END
		ELSE 
			BEGIN
				IF EXISTS(SELECT * FROM [general].[Tax] where UPPER([TaxName]) = UPPER(@Description)) 
					BEGIN
						SET @Message= 'Tax Name already exists.'						
					END
				ELSE
					BEGIN
						INSERT INTO [general].[Tax] ([TaxName], [CreatedBy], [CreateDate]) VALUES(@Description, @UserID, GETDATE());	   
						SET @Message= 'Tax added successfully.'
					END
			END
	END
	 
	Select @Message
END
