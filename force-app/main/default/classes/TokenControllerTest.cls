/**
 * @description Test class for TokenController.
 */
@IsTest
private class TokenControllerTest {

    @TestSetup
    static void makeData() {
        List<Token__c> tokens = new List<Token__c>{
            new Token__c(ExpiryDate__c = Datetime.now().addDays(7), Status__c = 'Active'),
            new Token__c(ExpiryDate__c = Datetime.now().addDays(14), Status__c = 'Active')
        };
        insert tokens;
    }

    @IsTest
    static void testGetActiveTokens_returnsActiveList() {
        Test.startTest();
        List<Token__c> result = TokenController.getActiveTokens();
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result should not be null');
        for (Token__c t : result) {
            System.assertEquals('Active', t.Status__c, 'Should only return Active tokens');
        }
    }

    @IsTest
    static void testCreateToken_createsRecord() {
        String expiry = Datetime.now().addDays(30).formatGmt('yyyy-MM-dd HH:mm:ss');
        Test.startTest();
        Id tokenId = TokenController.createToken('new-ctrl-token', expiry);
        Test.stopTest();
        System.assertNotEquals(null, tokenId, 'Should return a new token Id');
        Token__c created = [SELECT Status__c, Value__c FROM Token__c WHERE Id = :tokenId];
        System.assertEquals('Active', created.Status__c);
        System.assertEquals('new-ctrl-token', created.Value__c);
    }

    @IsTest
    static void testCreateToken_withBlankExpiry() {
        Test.startTest();
        Id tokenId = TokenController.createToken('no-expiry-ctrl', '');
        Test.stopTest();
        System.assertNotEquals(null, tokenId);
        Token__c created = [SELECT ExpiryDate__c FROM Token__c WHERE Id = :tokenId];
        System.assertEquals(null, created.ExpiryDate__c);
    }

    @IsTest
    static void testRevokeToken_revokesSuccessfully() {
        Token__c existing = [SELECT Id FROM Token__c WHERE Status__c = 'Active' LIMIT 1];
        Test.startTest();
        TokenController.revokeToken(existing.Id);
        Test.stopTest();
        Token__c updated = [SELECT Status__c FROM Token__c WHERE Id = :existing.Id];
        System.assertEquals('Revoked', updated.Status__c);
    }

    @IsTest
    static void testRevokeToken_throwsAuraHandledException() {
        Id fakeId = '001000000000001AAA';
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            TokenController.revokeToken(fakeId);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assert(exceptionThrown, 'Should throw AuraHandledException for unknown Id');
    }

    @IsTest
    static void testCreateToken_throwsAuraHandledExceptionOnBadDate() {
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            TokenController.createToken('bad-token', 'not-a-date');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assert(exceptionThrown, 'Should throw AuraHandledException for invalid date');
    }
}
