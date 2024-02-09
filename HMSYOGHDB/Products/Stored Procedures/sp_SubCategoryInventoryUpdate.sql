CREATE PROCEDURE [Products].[sp_SubCategoryInventoryUpdate] --39,'ONE BEDROOM APARTMENT', 5,2,'12/22/2023', '12/22/2023', 85,1
(
    @SubCategoryID INT=Null,
	@Name varchar(100),
	@TotalInventary int,
    @Online_Listing INT,  
   -- @OffLineInventory INT,
    @EffectiveFrom DATETIME,
    @EffectiveTo DATETIME,
	@UserId int,
	@LocationId int
)
AS
BEGIN
SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @Title varchar(200);	
	DECLARE @UserName varchar(200);	
	DECLARE @SubCategoryName varchar(200);	
	DECLARE @NotDesc varchar(MAX);	
    DECLARE @OldonlineInventory int;	
	DECLARE @NewonlineInventory int;
	DECLARE @OldofflineInventory int;
	DECLARE @NewofflineInventory int;

	

	Set @OldonlineInventory=(Select Online_Listing from [Products].[SubCategory] Where SubCategoryID=@SubCategoryID)
	Set @OldofflineInventory=(Select TotalInventory-Online_Listing from [Products].[SubCategory] Where SubCategoryID=@SubCategoryID)

    -- Check if the record already exists in the table
    IF EXISTS (SELECT 1 FROM [Products].[SubCategory] WHERE SubCategoryID = @SubCategoryID)
    BEGIN


        -- Update the existing record
        UPDATE [Products].[SubCategory]
        SET             
			Name=@Name,
			TotalInventory=@TotalInventary,
			Online_Listing = @Online_Listing, 
           -- OffLineInventory = @OffLineInventory,
            EffectiveFrom = @EffectiveFrom,
            EffectiveTo = @EffectiveTo
         WHERE SubCategoryID = @SubCategoryID
		SET @IsSuccess = 1; -- success 
        SET @Message = 'SubCategory Inventory Updated Successfully ';
		SET @NewonlineInventory=(Select @Online_Listing from [Products].[SubCategory] Where SubCategoryID=@SubCategoryID)
		Set @NewofflineInventory=(Select TotalInventory-@Online_Listing from [Products].[SubCategory] Where SubCategoryID=@SubCategoryID)
    END

	----------------------------
	set @SubCategoryName=(SELECT Name FROM Products.SubCategory WHERE SubCategoryID=@SubCategoryID)
	--set @UserName=(SELECT u.UserName FROM app.[user] u WHERE u.UserId=@UserId)
	Set @UserName=(SELECT TL.[Title] + ' ' + CD.[FirstName] + (CASE WHEN LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END)
            FROM app.[User] au
            INNER JOIN [contact].[Details] CD ON au.ContactID = CD.ContactID
            INNER JOIN [person].[Title] TL ON CD.TitleID = TL.TitleID
            WHERE au.UserID = @UserId);

	SET @NotDesc = 'Inventory count changed for: '+ CAST(@SubCategoryID as varchar(100)) + '-' + CAST(@SubCategoryName as varchar(100)) 
	+'  Online Quantity from '+CAST(@OldonlineInventory as varchar(100)) +' To ' +CAST(@NewonlineInventory as varchar(100))+
	+'  Offline Quantity from '+CAST(@OldofflineInventory as varchar(100)) +' To ' +CAST(@NewofflineInventory as varchar(100))+  ' on ' 
	+ FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User: ' + CAST(@UserId as varchar(100)) + '-' +  CAST(@UserName as varchar(100));

    EXEC [app].[spInsertActivityLog] 44,1, @NotDesc,@UserID---------------------
	 SELECT @IsSuccess AS [IsSuccess], @Message AS [Message];
   
END