/**
 * @description Test class for TokenExpiryBatch.
 */
@IsTest
private class TokenExpiryBatchTest {

    @TestSetup
    static void makeData() {
        List<Token__c> tokens = new List<Token__c>{
            new Token__c(ExpiryDate__c = Datetime.now().addDays(-2), Status__c = 'Active'),
            new Token__c(ExpiryDate__c = Datetime.now().addDays(-1), Status__c = 'Active'),
            new Token__c(ExpiryDate__c = Datetime.now().addDays(7), Status__c = 'Active')
        };
        insert tokens;
    }

    @IsTest
    static void testBatch_expiresTokensWithPastExpiry() {
        // Identify tokens with past expiry before batch runs
        Datetime now = Datetime.now();
        List<Token__c> pastTokens = [SELECT Id FROM Token__c WHERE Status__c = 'Active' AND ExpiryDate__c <= :now];
        System.assertNotEquals(0, pastTokens.size(), 'Should have past-expiry tokens');

        Test.startTest();
        Database.executeBatch(new TokenExpiryBatch(), 200);
        Test.stopTest();

        // After batch, past-expiry tokens should be Expired
        Set<Id> pastIds = new Map<Id, Token__c>(pastTokens).keySet();
        List<Token__c> expired = [SELECT Id, Status__c FROM Token__c WHERE Id IN :pastIds];
        for (Token__c t : expired) {
            System.assertEquals('Expired', t.Status__c, 'Past-expiry token should be Expired after batch');
        }
    }

    @IsTest
    static void testBatch_doesNotExpireFutureTokens() {
        Datetime future = Datetime.now().addDays(1);
        List<Token__c> futureTokens = [SELECT Id FROM Token__c WHERE Status__c = 'Active' AND ExpiryDate__c >= :future];
        System.assertNotEquals(0, futureTokens.size(), 'Should have future tokens');

        Test.startTest();
        Database.executeBatch(new TokenExpiryBatch(), 200);
        Test.stopTest();

        Set<Id> futureIds = new Map<Id, Token__c>(futureTokens).keySet();
        List<Token__c> checked = [SELECT Status__c FROM Token__c WHERE Id IN :futureIds];
        for (Token__c t : checked) {
            System.assertEquals('Active', t.Status__c, 'Future-expiry token should remain Active');
        }
    }

    @IsTest
    static void testBatch_emptyScope_noErrors() {
        // Delete all tokens to simulate empty scope
        delete [SELECT Id FROM Token__c];
        Test.startTest();
        Database.executeBatch(new TokenExpiryBatch(), 200);
        Test.stopTest();
        System.assert(true, 'Batch with empty scope should complete without error');
    }
}
