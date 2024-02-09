CREATE Proc [reservation].[spUpdateTaxExemptNo]
(
@TaxRefNo varchar(50)=Null,
@UserID int = null,
@ReservationID int = NULL

)
AS
Declare @Success Bit =0,
@Message varchar(100)= Null
Begin
	if NOT Exists (Select 1 From reservation.TaxExemptionDetails TED  Where TED.ReservationID = @ReservationID)
	Begin
		Insert into  reservation.TaxExemptionDetails ( [TaxRefNo], [CreatedDate], [UserId], [ReservationID])
		Values
	(@TaxRefNo, GetDate(), @UserID, @ReservationID)


		Set @Success=1
		Set @Message = 'Tax Ref No Has Been Inserted.'

		

	
	End
	Else 
	Begin
		Update  reservation.TaxExemptionDetails Set [TaxRefNo] =@TaxRefNo, [CreatedDate]= GetDate(), [UserId]= @UserID
		Where [ReservationID]= @ReservationID


		Set @Success=1
		Set @Message = 'Tax Ref No Has Been Updated.'
		
	End
		----------Added By Somnath---------------
		--SET @Message ='New TAX Certificate created successfully';
		Declare  @Acts nVarchar(MAX) = 'TAX Certificate created successfully for the ReservationID- : '+ Cast(@ReservationID AS Varchar(20))+ ' With tax Reference No As ' +Cast(@TaxRefNo AS Varchar(20))+ ' On Date- ' +  Cast(GETDATE() AS Varchar(20))+' By UserID- '+Cast(@UserID AS Varchar(20));
		EXEC [app].[spInsertActivityLog] 40,1,@Acts,@UserID,@Message
		----------Added By Somnath---------------

	Select @Success [IsSuccess], @Message [Message]
END 