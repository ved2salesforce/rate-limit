/**
 * @description Test class for TokenSelector.
 */
@IsTest
private class TokenSelectorTest {

    // Store inserted Ids for use across test methods via static maps
    static Map<String, Id> tokenIds = new Map<String, Id>();

    @TestSetup
    static void makeData() {
        List<Token__c> tokens = new List<Token__c>{
            new Token__c(ExpiryDate__c = Datetime.now().addDays(7), Status__c = 'Active'),
            new Token__c(ExpiryDate__c = Datetime.now().addDays(14), Status__c = 'Active'),
            new Token__c(ExpiryDate__c = Datetime.now().addDays(-1), Status__c = 'Expired'),
            new Token__c(ExpiryDate__c = Datetime.now().addDays(-2), Status__c = 'Revoked')
        };
        insert tokens;
    }

    @IsTest
    static void testGetActiveTokens_returnsActiveOnly() {
        TokenSelector sel = new TokenSelector();
        Test.startTest();
        List<Token__c> result = sel.getActiveTokens();
        Test.stopTest();
        System.assertNotEquals(0, result.size(), 'Expected active tokens');
        for (Token__c t : result) {
            System.assertEquals('Active', t.Status__c, 'All returned tokens should be Active');
        }
    }

    @IsTest
    static void testGetExpiredTokens_returnsExpiredOnly() {
        TokenSelector sel = new TokenSelector();
        Test.startTest();
        List<Token__c> result = sel.getExpiredTokens();
        Test.stopTest();
        System.assertNotEquals(0, result.size(), 'Expected expired tokens');
        for (Token__c t : result) {
            System.assertEquals('Expired', t.Status__c, 'All returned tokens should be Expired');
        }
    }

    @IsTest
    static void testGetTokenById_returnsCorrectToken() {
        Token__c existing = [SELECT Id FROM Token__c WHERE Status__c = 'Active' LIMIT 1];
        TokenSelector sel = new TokenSelector();
        Test.startTest();
        Token__c result = sel.getTokenById(existing.Id);
        Test.stopTest();
        System.assertNotEquals(null, result, 'Token should be found');
        System.assertEquals(existing.Id, result.Id, 'Token Id should match');
    }

    @IsTest
    static void testGetTokenById_returnsNullForUnknownId() {
        // Use a syntactically valid but non-existent Id
        Id fakeId = '001000000000001AAA';
        TokenSelector sel = new TokenSelector();
        Test.startTest();
        Token__c result = sel.getTokenById(fakeId);
        Test.stopTest();
        System.assertEquals(null, result, 'Should return null for unknown Id');
    }

    @IsTest
    static void testGetActiveExpiredTokens_returnsActiveWithPastExpiry() {
        // Insert an active token with past expiry date
        Token__c pastToken = new Token__c(
            ExpiryDate__c = Datetime.now().addDays(-1),
            Status__c = 'Active'
        );
        insert pastToken;

        TokenSelector sel = new TokenSelector();
        Test.startTest();
        List<Token__c> result = sel.getActiveExpiredTokens();
        Test.stopTest();
        System.assertNotEquals(0, result.size(), 'Should return active tokens with past expiry');
        for (Token__c t : result) {
            System.assertEquals('Active', t.Status__c, 'Token should be Active');
        }
    }

    @IsTest
    static void testGetActiveTokens_emptyWhenNoneExist() {
        // Update all active tokens to Revoked
        List<Token__c> actives = [SELECT Id FROM Token__c WHERE Status__c = 'Active'];
        for (Token__c t : actives) {
            t.Status__c = 'Revoked';
        }
        update actives;
        TokenSelector sel = new TokenSelector();
        Test.startTest();
        List<Token__c> result = sel.getActiveTokens();
        Test.stopTest();
        System.assertEquals(0, result.size(), 'Should return empty list when no active tokens');
    }
}
