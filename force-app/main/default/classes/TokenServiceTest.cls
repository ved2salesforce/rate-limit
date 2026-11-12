/**
 * @description Test class for TokenService.
 */
@IsTest
private class TokenServiceTest {

    @TestSetup
    static void makeData() {
        List<Token__c> tokens = new List<Token__c>{
            new Token__c(ExpiryDate__c = Datetime.now().addDays(7), Status__c = 'Active'),
            new Token__c(ExpiryDate__c = Datetime.now().addDays(14), Status__c = 'Active')
        };
        insert tokens;
    }

    @IsTest
    static void testCreateToken_createsActiveRecord() {
        TokenService svc = new TokenService();
        Datetime expiry = Datetime.now().addDays(30);
        Test.startTest();
        Token__c result = svc.createToken('new-token-value', expiry);
        Test.stopTest();
        System.assertNotEquals(null, result.Id, 'Token should have an Id');
        Token__c fetched = [SELECT Id, Value__c, ExpiryDate__c, Status__c FROM Token__c WHERE Id = :result.Id];
        System.assertEquals('new-token-value', fetched.Value__c, 'Value should match');
        System.assertEquals('Active', fetched.Status__c, 'Status should be Active');
    }

    @IsTest
    static void testCreateToken_withNullExpiry() {
        TokenService svc = new TokenService();
        Test.startTest();
        Token__c result = svc.createToken('no-expiry-token', null);
        Test.stopTest();
        System.assertNotEquals(null, result.Id, 'Token should have an Id');
        Token__c fetched = [SELECT Id, Status__c, ExpiryDate__c FROM Token__c WHERE Id = :result.Id];
        System.assertEquals('Active', fetched.Status__c);
        System.assertEquals(null, fetched.ExpiryDate__c);
    }

    @IsTest
    static void testRevokeToken_setsStatusRevoked() {
        Token__c existing = [SELECT Id FROM Token__c WHERE Status__c = 'Active' LIMIT 1];
        TokenService svc = new TokenService();
        Test.startTest();
        svc.revokeToken(existing.Id);
        Test.stopTest();
        Token__c updated = [SELECT Status__c FROM Token__c WHERE Id = :existing.Id];
        System.assertEquals('Revoked', updated.Status__c, 'Status should be Revoked');
    }

    @IsTest
    static void testRevokeToken_throwsForUnknownId() {
        Id fakeId = '001000000000001AAA';
        TokenService svc = new TokenService();
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            svc.revokeToken(fakeId);
        } catch (IllegalArgumentException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assert(exceptionThrown, 'Should throw IllegalArgumentException for unknown Id');
    }

    @IsTest
    static void testExpireTokens_setsStatusExpired() {
        List<Token__c> actives = [SELECT Id FROM Token__c WHERE Status__c = 'Active'];
        TokenService svc = new TokenService();
        Test.startTest();
        svc.expireTokens(actives);
        Test.stopTest();
        List<Token__c> updated = [SELECT Status__c FROM Token__c WHERE Id IN :actives];
        for (Token__c t : updated) {
            System.assertEquals('Expired', t.Status__c, 'Status should be Expired');
        }
    }

    @IsTest
    static void testExpireTokens_emptyListNoOp() {
        TokenService svc = new TokenService();
        Test.startTest();
        // Should not throw any exception
        svc.expireTokens(new List<Token__c>());
        Test.stopTest();
        System.assert(true, 'Empty list expiry should not throw');
    }

    @IsTest
    static void testExpireTokens_nullListNoOp() {
        TokenService svc = new TokenService();
        Test.startTest();
        svc.expireTokens(null);
        Test.stopTest();
        System.assert(true, 'Null list expiry should not throw');
    }
}
