/**
 * @description Batch class to expire Token__c records whose ExpiryDate__c has passed.
 *              Processes records in batches of 200.
 */
public with sharing class TokenExpiryBatch implements Database.Batchable<SObject> {

    private static final TokenService service = new TokenService();

    /**
     * @description Returns a query locator for active tokens that have passed their expiry date.
     * @param bc The batch context
     * @return Database.QueryLocator for eligible records
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime now = Datetime.now();
        return Database.getQueryLocator(
            [SELECT Id, Name, Value__c, ExpiryDate__c, Status__c
             FROM Token__c
             WHERE Status__c = 'Active'
             AND ExpiryDate__c <= :now]
        );
    }

    /**
     * @description Calls TokenService.expireTokens for each scope batch.
     * @param bc The batch context
     * @param scope The list of Token__c records to process
     */
    public void execute(Database.BatchableContext bc, List<Token__c> scope) {
        service.expireTokens(scope);
    }

    /**
     * @description Finish method - no-op.
     * @param bc The batch context
     */
    public void finish(Database.BatchableContext bc) {
        // No post-processing needed
    }
}
