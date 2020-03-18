USE [test]
GO

BEGIN TRAN

DECLARE @RandomCtr INT 

	-- Generate Random integer: between 100 to 200
	SELECT  @RandomCtr = 100 + ABS(CHECKSUM(CAST(NEWID() AS VARCHAR(100))) % 100)

	-- Table [dbo].[Servers]: Generate Random amount of IDs:
	;WITH IDs AS (
					SELECT TOP (@RandomCtr) 
						   ABS(CHECKSUM(CAST(NEWID() AS VARCHAR(100))))  AS [Id]
					  FROM sys.all_objects AS [A] CROSS JOIN sys.all_objects AS [B] 
				 ) 
	INSERT INTO [dbo].[Servers]
		 ( [ServerId] ) 
	SELECT DISTINCT [Id] 
	  FROM IDs;

	-- Table [dbo].[Users]: Generate Random amount of IDs: 
	;WITH IDs AS (
					SELECT TOP (@RandomCtr*1000) 
						   ABS(CHECKSUM(CAST(NEWID() AS VARCHAR(100))))  AS [Id]
					  FROM sys.all_objects AS [A] CROSS JOIN sys.all_objects AS [B] 
				 ) 
	INSERT INTO [dbo].[Users]
		  ( [UserId] ) 
	SELECT DISTINCT [Id] 
	  FROM IDs;
GO

 	-- Table [dbo].[UserDetails]: Generate random Data
	;WITH NewRows AS (
			SELECT [ServerId] = (SELECT TOP 1 [ServerId] FROM [dbo].[Servers]  ORDER BY NEWID())
				  ,[UserId]
 			  FROM [dbo].[Users] 
			  )

	INSERT INTO [dbo].[UserDetails] (
		     [ServerId]
		   , [UserId]
		   , [HomeAddress]
		   , [IsActive])
	  SELECT [ServerId]
			,[UserId]
  	  		,[HomeAddress] = LOWER(REPLACE(CAST(NEWID() AS VARCHAR(100)), '-', ' ')) -- just random string "6E1D162F 1FF1 4916 B498 6A1F596C6E27"
			,[IsActive] =  ABS(CHECKSUM(CAST(NEWID() AS VARCHAR(100)))) % 2 -- 0 or 1
		FROM (
			SELECT TOP (30) PERCENT 
				   U.[ServerId]
				  ,U.[UserId]
 			  FROM NewRows AS U
   LEFT OUTER JOIN [dbo].[UserDetails] UD 
				ON U.[ServerId] = UD.[ServerId]
			   AND U.[UserId] = UD.[UserId]
			 WHERE UD.UserId IS NULL
			 ) AS UD;

	--WHERE CHECKSUM(CAST(NEWID() AS VARCHAR(100))) % 3 = 0 
	--ORDER BY NEWID() -- the Order is random;

	SELECT (SELECT COUNT(*) FROM [dbo].[Servers]),
		   (SELECT COUNT(*) FROM [dbo].[Users]),
		   (SELECT COUNT(*) FROM [dbo].[UserDetails]);

COMMIT
