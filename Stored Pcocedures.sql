  
CREATE PROCEDURE [dbo].[OrganizationGet]  
@Id int  
AS  
BEGIN  
  SELECT O.*,S.Name AS SiteName FROM [Organization]  O 
  INNER JOIN Sites S ON S.Id=O.SiteId
  Where O.Id = @Id And O.Status != 2  
END  
GO

/****** Object:  StoredProcedure [dbo].[OrganizationGetAll]    Script Date: 9/17/2024 10:32:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

    
    
    
CREATE  PROCEDURE [dbo].[OrganizationGetAll]    
    @SiteId INT= NULL,    
 @PageSize INT=20,    
 @PageNumber INT=1    
AS    
BEGIN    
 DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;    
 WITH CTE AS(    
  SELECT    
   ROW_NUMBER() OVER (ORDER BY O.Id DESC) AS RowNum,    
   COUNT(O.ID) OVER() Total,S.Name AS SiteName,O.*    
  FROM [Organization] O    
  INNER JOIN Sites s on s.Id=O.SiteId  

  WHERE O.Status<> 2
  AND (@SiteId IS NULL OR S.Id=@SiteId)   
  )    
 SELECT * FROM CTE    
 WHERE RowNum > @Offset AND RowNum <= @Offset + @PageSize ORDER BY RowNum DESC    
END 
GO

/****** Object:  StoredProcedure [dbo].[OrganizationGetAllBySite]    Script Date: 9/17/2024 10:32:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

    
    
    
CREATE PROCEDURE [dbo].[OrganizationGetAllBySite]    
    @SiteIds NVARCHAR(MAX) = NULL  
     
AS    
BEGIN    
 DECLARE @Sites TABLE (Id INT)
	INSERT @Sites
	SELECT Item FROM DBO.SplitString(@SiteIds, ',');
 
  SELECT      
    S.Name AS SiteName
   ,SiteId=S.Id
   ,O.Name
   ,OrganizationId=O.Id
  FROM [Organization] O    
  INNER JOIN Sites s on s.Id=O.SiteId  
  WHERE O.Status<> 2   AND (@SiteIds IS NULL OR SiteId IN (SELECT ID FROM @Sites)) Order By S.Name,O.Name
END 
GO

/****** Object:  StoredProcedure [dbo].[OrganizationImportRollback]    Script Date: 9/17/2024 10:32:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OrganizationImportRollback]
    @ImportLogId INT = NULL
AS
BEGIN
	DECLARE CursorToRollback CURSOR FOR
		SELECT Id FROM Organization
			WHERE ImportLogId = @ImportLogId;

	DECLARE @IdToRollback INT;
	OPEN CursorToRollback;
	FETCH NEXT FROM CursorToRollback INTO @IdToRollback;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF EXISTS(SELECT ID FROM Organization WHERE ID = @IdToRollback AND ModifiedOn IS NULL)
			DELETE FROM Organization WHERE Id = @IdToRollback;
		ELSE
			BEGIN
				DECLARE @PreviousId INT
				SET @PreviousId = (SELECT MAX(Id) FROM TelHistory.dbo.Organization WHERE (ImportLogId IS NULL OR ISNULL(ImportLogId, -1) != @ImportLogId) AND OrganizationId = @IdToRollback)
				UPDATE Organization
					SET 
						SiteId = T.SiteId,
						[Name] = T.[Name],
						AbbreviatedName = T.AbbreviatedName,
						PhysicalStreetAddress = T.PhysicalStreetAddress,
						PhysicalPostalCode = T.PhysicalPostalCode,
						PhysicalState = T.PhysicalState,
						PhysicalCity = T.PhysicalCity,
						PhysicalTown = T.PhysicalTown,
						ShippingStreetAddress = T.ShippingStreetAddress,
						ShippingPostalCode = T.ShippingPostalCode,
						ShippingState = T.ShippingState,
						ShippingCity = T.ShippingCity,
						ShippingTown = T.ShippingTown,
						TelephoneNumber = T.TelephoneNumber,
						FaxNumber = T.FaxNumber,
						ProjectCodeRequired = T.ProjectCodeRequired,
						[Status] = T.[Status],
						ImportLogId = T.ImportLogId,
						CreatedBy = T.CreatedBy,
						CreatedOn = T.CreatedOn,
						ModifiedBy = T.ModifiedBy,
						ModifiedOn = T.ModifiedOn
				FROM TelHistory.dbo.Organization T
				WHERE Tel.dbo.Organization.Id = T.OrganizationId AND T.Id = @PreviousId
			END
		FETCH NEXT FROM CursorToRollback INTO @IdToRollback;
	END

	CLOSE CursorToRollback;
	DEALLOCATE CursorToRollback;

END
GO

/****** Object:  StoredProcedure [dbo].[OrganizationSet]    Script Date: 9/17/2024 10:32:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OrganizationSet]
    @Id int,
    @SiteId int=null,
	@SiteName nvarchar(50)=null,
    @Name nvarchar(max),
    @AbbreviatedName nvarchar(max),
    @PhysicalStreetAddress nvarchar(max),
    @PhysicalPostalCode nvarchar(max),
    @PhysicalState nvarchar(max),
    @PhysicalCity nvarchar(max),
    @PhysicalTown nvarchar(max),
    @ShippingStreetAddress nvarchar(max),
    @ShippingPostalCode nvarchar(max),
    @ShippingState nvarchar(max),
    @ShippingCity nvarchar(max),
    @ShippingTown nvarchar(max),
    @TelephoneNumber nvarchar(max),
    @FaxNumber nvarchar(max),
    @ProjectCodeRequired tinyint=1,
    @Status tinyint=0,
    @ImportLogId int = null,
    @CreatedBy int = null,
    @ModifiedBy int = null,
	@IndexNumber int = 0,
@ErrorMessage NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
DECLARE @CreatedOn SMALLDATETIME = GETUTCDATE();
DECLARE @ModifiedOn SMALLDATETIME = GETUTCDATE();
DECLARE @Modified BIT = 1;

IF @SiteId IS NULL
      BEGIN
          SELECT TOP 1  @SiteId = Id
          FROM Sites
          WHERE [Name] =  TRIM(UPPER(@SiteName));
      END

IF @SiteId IS NULL
	BEGIN
		SET @ErrorMessage = 'Row '+ CAST(@IndexNumber AS nvarchar(10)) + ' '+@SiteName+' is name is incorrect.'			
		RETURN
	END

IF EXISTS(SELECT Id FROM Organization WHERE [Name]=@Name AND SiteId=@SiteId AND Id != ISNULL(@Id, 0))
	BEGIN			
	    IF @ImportLogId is NULL
			 BEGIN 
					SET @ErrorMessage = 'Row '+ CAST(@IndexNumber AS nvarchar(10)) + ' Organization Name '+@Name+' is already exist.'			
					RETURN
			 END
		ELSE
			 BEGIN
					SET @ErrorMessage = 'Organization Name '+@Name+' is already exist.'			
					RETURN
			 END
	END

BEGIN TRY
BEGIN TRANSACTION Trn26Organization
DECLARE @OutputTbl TABLE (Id INT)

IF ISNULL(@ID, 0) > 0
BEGIN
	IF NOT EXISTS(SELECT * FROM Organization WHERE 
            [SiteId] = @SiteId AND
            [Name] = @Name AND
            [AbbreviatedName] = @AbbreviatedName AND
            [PhysicalStreetAddress] = @PhysicalStreetAddress AND
            [PhysicalPostalCode] = @PhysicalPostalCode AND
            [PhysicalState] = @PhysicalState AND
            [PhysicalCity] = @PhysicalCity AND
            [PhysicalTown] = @PhysicalTown AND
            [ShippingStreetAddress] = @ShippingStreetAddress AND
            [ShippingPostalCode] = @ShippingPostalCode AND
            [ShippingState] = @ShippingState AND
            [ShippingCity] = @ShippingCity AND
            [ShippingTown] = @ShippingTown AND
            [TelephoneNumber] = @TelephoneNumber AND
            [FaxNumber] = @FaxNumber AND
            [ProjectCodeRequired] = @ProjectCodeRequired AND
            [Status] = ISNULL(@Status, [Status]) AND
            ID = @ID)
    UPDATE Organization SET
        [SiteId] = @SiteId,
        [Name] = @Name,
        [AbbreviatedName] = @AbbreviatedName,
        [PhysicalStreetAddress] = @PhysicalStreetAddress,
        [PhysicalPostalCode] = @PhysicalPostalCode,
        [PhysicalState] = @PhysicalState,
        [PhysicalCity] = @PhysicalCity,
        [PhysicalTown] = @PhysicalTown,
        [ShippingStreetAddress] = @ShippingStreetAddress,
        [ShippingPostalCode] = @ShippingPostalCode,
        [ShippingState] = @ShippingState,
        [ShippingCity] = @ShippingCity,
        [ShippingTown] = @ShippingTown,
        [TelephoneNumber] = @TelephoneNumber,
        [FaxNumber] = @FaxNumber,
        [ProjectCodeRequired] = @ProjectCodeRequired,
        [Status] = ISNULL(@Status, [Status]) ,
        [ImportLogId] = @ImportLogId,
        [ModifiedBy] = @ModifiedBy,
        [ModifiedOn] = @ModifiedOn
	WHERE ID = @ID
 ELSE
	SET @Modified = 0;
	SELECT @CreatedBy = CreatedBy, @CreatedOn = CreatedOn FROM Organization WHERE ID = @ID
 END
 ELSE
  BEGIN
    INSERT INTO [dbo].[Organization]([SiteId],[Name],[AbbreviatedName],[PhysicalStreetAddress],[PhysicalPostalCode],[PhysicalState],[PhysicalCity],[PhysicalTown],[ShippingStreetAddress],[ShippingPostalCode],[ShippingState],[ShippingCity],[ShippingTown],[TelephoneNumber],[FaxNumber],[ProjectCodeRequired],[Status],[ImportLogId],[CreatedBy],[CreatedOn])
     OUTPUT INSERTED.ID INTO @OutputTbl(Id)
    VALUES(@SiteId,@Name,@AbbreviatedName,@PhysicalStreetAddress,@PhysicalPostalCode,@PhysicalState,@PhysicalCity,@PhysicalTown,@ShippingStreetAddress,@ShippingPostalCode,@ShippingState,@ShippingCity,@ShippingTown,@TelephoneNumber,@FaxNumber,@ProjectCodeRequired,@Status,@ImportLogId,@CreatedBy,@CreatedOn)
  SET @Id = (SELECT TOP 1 ID FROM @OutputTbl)
 END
	IF @Modified = 1
    INSERT INTO [TelHistory].[dbo].[Organization](OrganizationId,[SiteId],[Name],[AbbreviatedName],[PhysicalStreetAddress],[PhysicalPostalCode],[PhysicalState],[PhysicalCity],[PhysicalTown],[ShippingStreetAddress],[ShippingPostalCode],[ShippingState],[ShippingCity],[ShippingTown],[TelephoneNumber],[FaxNumber],[ProjectCodeRequired],[Status],[ImportLogId],[CreatedBy],[CreatedOn],[ModifiedBy],[ModifiedOn])
    VALUES(@Id,@SiteId,@Name,@AbbreviatedName,@PhysicalStreetAddress,@PhysicalPostalCode,@PhysicalState,@PhysicalCity,@PhysicalTown,@ShippingStreetAddress,@ShippingPostalCode,@ShippingState,@ShippingCity,@ShippingTown,@TelephoneNumber,@FaxNumber,@ProjectCodeRequired,@Status,@ImportLogId,@CreatedBy,@CreatedOn,@ModifiedBy,@ModifiedOn)
COMMIT TRANSACTION Trn26Organization
END TRY
  BEGIN CATCH
    IF (@@TRANCOUNT > 0)
        BEGIN
            ROLLBACK TRANSACTION Trn26Organization
            PRINT 'Error detected, all changes reversed'
        END
        SET @ErrorMessage = ERROR_MESSAGE()
    END CATCH
END
GO


