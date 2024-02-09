

CREATE Proc [Restaurant].[spSaveMenuMaster]
(
@User int=0,
@LocationID int=0,
@Remarks varchar(255)='',
@dtMenuItems [Restaurant].[dtMenuItem] readonly
)
as

Begin
  Begin Try
	Begin Transaction
		--Declare @LocationID int=2,
		--@User int=1,
		--@Remarks varchar(255)='Chinese',
		--@dtMenuItems [Restaurant].[dtMenuItem]
		--insert into @dtMenuItems values(17,'YG-F','Chicken',10.00,'Chinese-Non-veg','Number'),(18,'YG-F','Chicken',10.00,'Chinese-Non-veg','Number')

		Declare @MenuID int=0,
		@Message varchar(50)='',
		@IsSuccess bit=0,
		@Title varchar(255)=''

		if  not exists(select MenuID from  Restaurant.MenuMaster where LocationID=@LocationID)
			begin
				insert into  Restaurant.MenuMaster(LocationID,Remarks,ALTERdBy,ALTERDate)
				values(@LocationID,@Remarks,@User,GETDATE())
				set @MenuID=@@identity;
				if(@MenuID>0)
					begin
					set @Title='Restaurant Menu ALTERd';
					EXEC [app].[spInsertActivityLog]13,@LocationID,@Title,@User
					--insert into app.ActivityLog (ActivityTypeID,LocationID,DateTime,Activity,UserID) values (13,@LocationID,GETDATE(),'Restaurant Menu ALTERd',@User)
					end
			end
		else
			begin
				
				select @MenuID = MenuID from  Restaurant.MenuMaster where LocationID=@LocationID
				if(@MenuID>0)
					begin
					update  Restaurant.MenuMaster set Remarks=@Remarks where LocationID=@LocationID;
					set @Title='Restaurant Menu Updated';
					EXEC [app].[spInsertActivityLog]13,@LocationID,@Title,@User
					--insert into app.ActivityLog (ActivityTypeID,LocationID,DateTime,Activity,UserID) values (13,@LocationID,GETDATE(),'Restaurant Menu Updated',@User)
					end
			end
		if(@MenuID>0)
			begin
				delete from  Restaurant.MenuDetails where MenuID=@MenuID

				insert into  Restaurant.MenuDetails
				select @MenuID,ItemID from @dtMenuItems

			end
	COMMIT TRANSACTION
	SET @IsSuccess = 1; --success  			
		SET @Message = 'Menu Successfully Saved';
End try
Begin Catch
BEGIN  			
			ROLLBACK TRANSACTION;  

			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error
		END;    
End Catch
SELECT @IsSuccess 'IsSuccess', @Message 'Message';
end




