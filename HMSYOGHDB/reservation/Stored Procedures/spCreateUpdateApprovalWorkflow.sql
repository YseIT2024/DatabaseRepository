
CREATE PROC [reservation].[spCreateUpdateApprovalWorkflow]-- 0,4,75,1,1,0,0
(@ProcessTypeId int = NULL,
@ApprovalLevel int = NULL,
@UserId int = NULL,
@RoleId int = NULL,
@IsActive int = NULL,
@IsPrimary int = NULL,
@ApprovalWorkflowId int = 0)
AS
BEGIN
  --SET XACT_ABORT ON will cause the transaction to be uncommittable  
  --when the constraint violation occurs.   
  SET XACT_ABORT ON;

  DECLARE @IsSuccess bit = 0;
  DECLARE @Message varchar(max) = '';
  DECLARE @Title varchar(200);

    BEGIN TRY

      BEGIN TRANSACTION

        IF (@ApprovalWorkflowId = 0)
        BEGIN
               
		   IF(@IsPrimary=0)
			 BEGIN
				INSERT INTO [reservation].[ApprovalWorkflow] ([ProcessTypeId], [ApprovalLevel], [UserId], [RoleId], [IsActive], [IsPrimary])
				  VALUES (@ProcessTypeId, @ApprovalLevel, @UserId, @RoleId, @IsActive, @IsPrimary)
				   
				   SET @ApprovalWorkflowId = SCOPE_IDENTITY();

					SET @IsSuccess = 1; -- success
					SET @Message = 'New ApprovalWorkflow has been added successfully';
					SET @Title = 'ApprovalWorkflow : ' + CAST((SELECT
					  ProcessTypeId
					FROM [reservation].[ApprovalWorkflow]
					WHERE ApprovalWorkflowId = @ApprovalWorkflowId)
					AS varchar) + ' has been added '
             END
           IF(@IsPrimary=1)
	       Begin 
			      IF NOT EXISTS (SELECT TOP 1  1 FROM [reservation].[ApprovalWorkflow] WHERE [ProcessTypeId] = @ProcessTypeId AND [ApprovalLevel] = @ApprovalLevel AND [IsPrimary] = 1)
				   Begin
						INSERT INTO [reservation].[ApprovalWorkflow] ([ProcessTypeId], [ApprovalLevel], [UserId], [RoleId], [IsActive], [IsPrimary])
						VALUES (@ProcessTypeId, @ApprovalLevel, @UserId, @RoleId, @IsActive, @IsPrimary)				   
						SET @ApprovalWorkflowId = SCOPE_IDENTITY();
						SET @IsSuccess = 1; -- success
						SET @Message = 'New ApprovalWorkflow has been added successfully';
						SET @Title = 'ApprovalWorkflow : ' + CAST((SELECT ProcessTypeId 
																	FROM [reservation].[ApprovalWorkflow] 
																	WHERE ApprovalWorkflowId = @ApprovalWorkflowId)	AS varchar) + ' has been added '
				   End
				 ELSE
				BEGIN
						Set  @IsSuccess = 0
						SET @Message = 'ApprovalWorkflow Already Exists and is Primary, Can not be added Again.';
						SET @Title = 'ApprovalWorkflow : ' + CAST((SELECT ProcessTypeId
																	FROM [reservation].[ApprovalWorkflow]
																	WHERE ApprovalWorkflowId = @ApprovalWorkflowId)
																	AS varchar) + ' has not been added '					
				END
		   End
      
        END
      ELSE
        BEGIN
          UPDATE [reservation].[ApprovalWorkflow]
          SET [ProcessTypeId] = @ProcessTypeId,
              [ApprovalLevel] = @ApprovalLevel,
              [UserId] = @UserId,
              [RoleId] = @RoleId,
              [IsActive] = @IsActive,
              [IsPrimary] = @IsPrimary
          WHERE ApprovalWorkflowId = @ApprovalWorkflowId

		  SET @IsSuccess = 1; -- success
          SET @Message = 'ApprovalWorkflow has been updated successfully.';
          SET @Title = 'ApprovalWorkflow : ' + CAST((SELECT
            ProcessTypeId
          FROM [reservation].[ApprovalWorkflow]
          WHERE ApprovalWorkflowId = @ApprovalWorkflowId)
          AS varchar) + ' has updated '
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

      IF (XACT_STATE() = 1)
      BEGIN
        COMMIT TRANSACTION;
        SET @IsSuccess = 1; --success 

        IF (@ApprovalWorkflowId = 0)
        BEGIN
          SET @Message = 'New ApprovalWorkflow has been added successfully.';
        END
        ELSE
        BEGIN
          SET @Message = 'ApprovalWorkflow has been updated successfully.';
        END
      END;

    END CATCH



  SELECT
    @IsSuccess AS 'IsSuccess',
    @Message AS 'Message'
END