

CREATE PROCEDURE [Products].[ProductItemDetailsTRNS]
(
				@ItemID int=0,
				@CategoryID int=0,
				@SubCategoryID int =0,
				@ProductCode varchar(50)='',
				@ProductName varchar(250)='',
				@ProductTypeID int=2,
				@dtComboItems as [products].[ComboItem] readonly,
				@CuisineTypeId int=0,
				@GroupId int=0,
				@BrandId int=1,
				@UOMId int=1,
				@Currency varchar(50),
				@Price decimal(18,2)=0.0,
				@MaxDiscount int=0,
				@dtFeatures as [app].[dtID] readonly,
				@dtTaxrates as [app].[dtID] readonly,
				@Description varchar(150),
				@dtImages as [products].[Images] readonly,
				@IsActive bit,
				@User int
)
AS
BEGIN
				SET XACT_ABORT ON;

				DECLARE @CURRENCYID INT,@Message VARCHAR(100),@IsSuccess BIT=0,@SETMESSAGE INT
				SELECT @CURRENCYID=CurrencyID FROM currency.Currency WHERE CurrencyCode=@Currency

				
				BEGIN TRY
					BEGIN TRANSACTION
					  IF(@ItemID=0)
						BEGIN
							IF(EXISTS(select ItemCode from Products.Item where ItemCode = @ProductCode))
								BEGIN
									SET @IsSuccess = 0;  
									SET @Message = 'Product Code already exists.';
								END
							ELSE
								BEGIN
								if(@CategoryID=2)
									BEGIN
									INSERT INTO Products.Item(ItemCode,ItemName,CategoryID,SubCategoryID,BrandID,ItemTypeID,CuisineTypeID,GroupID,UOMID,Price,CurrencyId,MaxDiscount,BarcodeValue,Remarks,IsActive,CreateDate,CreatedBy)
									VALUES(@ProductCode,@ProductName,@CategoryID,@SubCategoryID,@BrandId,@ProductTypeID,@CuisineTypeId,@GroupId,@UOMId,@Price,@CURRENCYID,@MaxDiscount,@ProductCode,@Description,@IsActive,GETDATE(),@User)
									END
									ELSE
									BEGIN
									INSERT INTO Products.Item(ItemCode,ItemName,CategoryID,SubCategoryID,BrandID,ItemTypeID,UOMID,Price,CurrencyId,GroupID,MaxDiscount,BarcodeValue,Remarks,IsActive,CreateDate,CreatedBy)
									VALUES(@ProductCode,@ProductName,@CategoryID,@SubCategoryID,@BrandId,@ProductTypeID,@UOMId,@Price,@CURRENCYID,@GroupId,@MaxDiscount,@ProductCode,@Description,@IsActive,GETDATE(),@User)
									END
									

									SET @ItemID=@@IDENTITY;

										IF(@ItemID>0)
										BEGIN
											IF Exists(select * from @dtComboItems)
											BEGIN
												INSERT INTO Products.ItemDetails
												(ParentIemID,ItemID,UOMID,Quantity,Price,CreatedBy,CreateDate)
												SELECT @ItemID,ComboItemID,UOMID,Quantity,dt.Price,@User,GETDATE() 
												FROM @dtComboItems dt
												INNER JOIN Products.Item PRI ON PRI.ItemID=dt.ComboItemID
											END
						
											IF Exists( select * from @dtImages )
											BEGIN
												INSERT INTO Products.ItemImage
												(ItemID,FilePath,CreatedBy,CreateDate)
												SELECT @ItemID,ImagePath,@User,GETDATE() FROM @dtImages
											END

											IF Exists (select * from @dtFeatures )
											BEGIN
												INSERT INTO Products.ItemFeatures
												(FeatureID,ItemID,CreatedBy,CreateDate)
												SELECT ID,@ItemID,@User,GETDATE() FROM @dtFeatures
											END

											IF Exists(select * from @dtTaxrates )
											BEGIN
												INSERT INTO Products.Tax
												(ItemID,TaxID)
												SELECT @ItemID,ID FROM @dtTaxrates
											END
								END
							
									SET @IsSuccess = 1; --success  
									SET @Message = 'Item Created successfully.';
							END
					   END
					   ELSE
							 --  END Commented by Arabinda on 25-04-2023
							--BEGIN
							--	IF(EXISTS(select ItemCode from Products.Item where ItemCode = @ProductCode and ItemID <> @ItemID))
							--		BEGIN
							--			SET @IsSuccess = 0;  
							--			SET @Message = 'Product Code already exists.';
							--		END
							--	ELSE - --  END Commented by Arabinda on 25-04-2023
									BEGIN
									if(@CategoryID=2)
										BEGIN
										UPDATE Products.Item
											SET ItemCode=@ProductCode,
												ItemName=@ProductName,
												SubCategoryID=@SubCategoryID,
												BrandID=@BrandId,
												ItemTypeID=@ProductTypeID,
												CuisineTypeID=@CuisineTypeId,
												GroupID=@GroupId,
												UOMID=@UOMId,
												Price=@Price,
												CurrencyId=@CURRENCYID,
												MaxDiscount=@MaxDiscount,
												BarcodeValue=@ProductCode,
												Remarks=@Description,
												IsActive=@IsActive,
												CreatedBy=@User,
												CreateDate=GETDATE()
												WHERE ItemID=@ItemID
										END
										ELSE
											BEGIN
											UPDATE Products.Item
											SET ItemCode=@ProductCode,
												ItemName=@ProductName,
												SubCategoryID=@SubCategoryID,
												BrandID=@BrandId,
												ItemTypeID=@ProductTypeID,
												UOMID=@UOMId,
												Price=@Price,
												GroupID=@GroupId,
												CurrencyId=@CURRENCYID,
												MaxDiscount=@MaxDiscount,
												BarcodeValue=@ProductCode,
												Remarks=@Description,
												IsActive=@IsActive,
												CreatedBy=@User,
												CreateDate=GETDATE()
												WHERE ItemID=@ItemID
											END


											DELETE FROM Products.ItemDetails WHERE ParentIemID=@ItemID
											IF Exists(select * from @dtComboItems)
											BEGIN
												INSERT INTO Products.ItemDetails
												(ParentIemID,ItemID,UOMID,Quantity,Price,CreatedBy,CreateDate)
												SELECT @ItemID,ComboItemID,UOMID,Quantity,dt.Price,@User,GETDATE() 
												FROM @dtComboItems dt
												INNER JOIN Products.Item PRI ON PRI.ItemID=dt.ComboItemID
											END
											DELETE FROM Products.ItemImage WHERE ItemID=@ItemID
											IF Exists( select * from @dtImages )
											BEGIN
												INSERT INTO Products.ItemImage
												(ItemID,FilePath,CreatedBy,CreateDate)
												SELECT @ItemID,ImagePath,@User,GETDATE() FROM @dtImages
											END

											DELETE FROM Products.ItemFeatures WHERE ItemID=@ItemID
											IF Exists (select * from @dtFeatures )
											BEGIN
												INSERT INTO Products.ItemFeatures
												(FeatureID,ItemID,CreatedBy,CreateDate)
												SELECT ID,@ItemID,@User,GETDATE() FROM @dtFeatures
											END

											DELETE FROM Products.Tax WHERE ItemID=@ItemID
											IF Exists(select * from @dtTaxrates )
											BEGIN
												INSERT INTO Products.Tax
												(ItemID,TaxID)
												SELECT @ItemID,ID FROM @dtTaxrates
											END									
											SET @IsSuccess = 1; --success  
											SET @Message = 'Item Updated successfully.';
							END	 
					 --  END Commented by Arabinda on 25-04-2023
					COMMIT TRANSACTION
					---------------------------- Insert into activity log---------------	
					DECLARE @Title VARCHAR(MAX) = 'Item Created with Id' + convert(varchar(50), @ItemID) + 'By User' +@User;		
					EXEC [app].[spInsertActivityLog]14,1,@Title,@User	
					
				END TRY
				BEGIN CATCH
				IF (XACT_STATE() = -1) 
					BEGIN  			
						ROLLBACK TRANSACTION;  
						SET @Message = ERROR_MESSAGE();
						SET @IsSuccess = 0; --error
					END;    
    
				END CATCH

				SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
			   			 			
END
