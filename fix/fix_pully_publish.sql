DECLARE @baseProject integer = 1

DELETE FROM [dbo].[CoupeTextFeature_CTF] WHERE IdCUP_CTF IN (SELECT Id_CUP FROM [dbo].[CoupeFeature_CUP] WHERE (SELECT COUNT(*) FROM [dbo].[CoupeFeatureVersion_CUPV] WHERE [RacineGuid_CUPV] = [Guid_CUP]) = 0)


DELETE FROM [dbo].[CoupeLinkFeatureVersion_KYFV] WHERE [IdPRJ_KYFV] = @baseProject AND RacineGuid_KYFV IN (SELECT RacineGuid_KYFV FROM [dbo].[CoupeLinkFeatureVersion_KYFV] WHERE [IdPRJ_KYFV] IN (128, 55));
DELETE FROM [dbo].[CoupeLinkFeatureVersion_KYFV] WHERE [IdPRJ_KYFV] IN (128, 55) AND [State_KYFV] = 2;
UPDATE [dbo].[CoupeLinkFeatureVersion_KYFV] SET [IdPRJ_KYFV] = @baseProject WHERE [IdPRJ_KYFV] IN (128, 55)
DELETE FROM [dbo].[CoupeLinkFeature_KYF] WHERE (SELECT COUNT(*) FROM [dbo].[CoupeLinkFeatureVersion_KYFV] WHERE [RacineGuid_KYFV] = [Guid_KYF]) = 0;

DELETE FROM [dbo].[BrancheFeatureVersion_BRFV] WHERE [IdPRJ_BRFV] = @baseProject AND RacineGuid_BRFV IN (SELECT RacineGuid_BRFV FROM [dbo].[BrancheFeatureVersion_BRFV] WHERE [IdPRJ_BRFV] IN (128, 55));
DELETE FROM [dbo].[BrancheFeatureVersion_BRFV] WHERE [IdPRJ_BRFV] IN (128, 55) AND [State_BRFV] = 2;
UPDATE [dbo].[BrancheFeatureVersion_BRFV] SET [IdPRJ_BRFV] = @baseProject WHERE [IdPRJ_BRFV] IN (128, 55);
DELETE FROM [dbo].[BrancheFeature_BRF] WHERE (SELECT COUNT(*) FROM [dbo].[BrancheFeatureVersion_BRFV] WHERE [RacineGuid_BRFV] = [Guid_BRF]) = 0;

DELETE FROM [dbo].[CoupeTextFeatureVersion_CTFV] WHERE [IdPRJ_CTFV] = @baseProject AND RacineGuid_CTFV IN (SELECT RacineGuid_CTFV FROM [dbo].[CoupeTextFeatureVersion_CTFV] WHERE [IdPRJ_CTFV] IN (128, 55));
DELETE FROM [dbo].[CoupeTextFeatureVersion_CTFV] WHERE [IdPRJ_CTFV] IN (128, 55) AND [State_CTFV] = 2;
UPDATE [dbo].[CoupeTextFeatureVersion_CTFV] SET [IdPRJ_CTFV] = @baseProject WHERE [IdPRJ_CTFV] IN (128, 55);
DELETE FROM [dbo].[CoupeTextFeature_CTF] WHERE (SELECT COUNT(*) FROM [dbo].[CoupeTextFeatureVersion_CTFV] WHERE [RacineGuid_CTFV] = [Guid_CTF]) = 0;

DELETE FROM [dbo].[CoupeFeatureVersion_CUPV] WHERE [IdPRJ_CUPV] = @baseProject AND RacineGuid_CUPV IN (SELECT RacineGuid_CUPV FROM [dbo].[CoupeFeatureVersion_CUPV] WHERE [IdPRJ_CUPV] IN (128, 55));
DELETE FROM [dbo].[CoupeFeatureVersion_CUPV] WHERE [IdPRJ_CUPV] IN (128, 55) AND [State_CUPV] = 2;
UPDATE [dbo].[CoupeFeatureVersion_CUPV] SET [IdPRJ_CUPV] = @baseProject WHERE [IdPRJ_CUPV] IN (128, 55);
DELETE FROM [dbo].[CoupeFeature_CUP] WHERE (SELECT COUNT(*) FROM [dbo].[CoupeFeatureVersion_CUPV] WHERE [RacineGuid_CUPV] = [Guid_CUP]) = 0;
