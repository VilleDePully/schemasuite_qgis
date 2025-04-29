DELETE FROM [dbo].[CoupeFeatureVersion_CUPV] WHERE [IdPRJ_CUPV] = 1 AND RacineGuid_CUPV IN (SELECT RacineGuid_CUPV FROM [dbo].[CoupeFeatureVersion_CUPV] WHERE [IdPRJ_CUPV] = 1182); 
DELETE FROM [dbo].[CoupeFeatureVersion_CUPV] WHERE [IdPRJ_CUPV] = 1182 AND [State_CUPV] = 2; UPDATE [dbo].[CoupeFeatureVersion_CUPV] SET [IdPRJ_CUPV] = 1182 WHERE [IdPRJ_CUPV] = 1182;

DELETE FROM CoupeLinkFeature_KYF WHERE CoupeLinkFeature_KYF.IdCUP_KYF IN (SELECT [CoupeFeature_CUP].Id_CUP  FROM [dbo].[CoupeFeature_CUP] WHERE (SELECT COUNT(*) FROM [dbo].[CoupeFeatureVersion_CUPV] WHERE [RacineGuid_CUPV] = [Guid_CUP]) = 0); 
DELETE FROM CoupeTextFeature_CTF WHERE CoupeTextFeature_CTF.IdCUP_CTF IN (SELECT [CoupeFeature_CUP].Id_CUP  FROM [dbo].[CoupeFeature_CUP] WHERE (SELECT COUNT(*) FROM [dbo].[CoupeFeatureVersion_CUPV] WHERE [RacineGuid_CUPV] = [Guid_CUP]) = 0); 

DELETE FROM [dbo].[CoupeFeature_CUP] WHERE (SELECT COUNT(*) FROM [dbo].[CoupeFeatureVersion_CUPV] WHERE [RacineGuid_CUPV] = [Guid_CUP]) = 0; 


