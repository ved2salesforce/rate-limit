/**
 * @description Selector class for Token__c queries. Contains no DML.
 *              Runs with sharing for record-level security.
 *              Performs object-level CRUD access check before querying.
 */
public with sharing class TokenSelector {

    /**
     * @description Returns all Token__c records with Status__c = 'Active'.
     * @return List of active Token__c records
     */
    public List<Token__c> getActiveTokens() {
        checkObjectAccessible();
        return [
            SELECT Id, Name, Value__c, ExpiryDate__c, Status__c
            FROM Token__c
            WHERE Status__c = 'Active'
            ORDER BY CreatedDate DESC
        ];
    }

    /**
     * @description Returns all Token__c records with Status__c = 'Expired'.
     * @return List of expired Token__c records
     */
    public List<Token__c> getExpiredTokens() {
        checkObjectAccessible();
        return [
            SELECT Id, Name, Value__c, ExpiryDate__c, Status__c
            FROM Token__c
            WHERE Status__c = 'Expired'
            ORDER BY CreatedDate DESC
        ];
    }

    /**
     * @description Returns a single Token__c by Id.
     * @param tokenId The Id of the Token__c record to retrieve
     * @return The Token__c record, or null if not found
     */
    public Token__c getTokenById(Id tokenId) {
        checkObjectAccessible();
        List<Token__c> tokens = [
            SELECT Id, Name, Value__c, ExpiryDate__c, Status__c
            FROM Token__c
            WHERE Id = :tokenId
            LIMIT 1
        ];
        return tokens.isEmpty() ? null : tokens[0];
    }

    /**
     * @description Returns active Token__c records that have passed their expiry date.
     * @return List of active but past-expiry Token__c records
     */
    public List<Token__c> getActiveExpiredTokens() {
        checkObjectAccessible();
        Datetime now = Datetime.now();
        return [
            SELECT Id, Name, Value__c, ExpiryDate__c, Status__c
            FROM Token__c
            WHERE Status__c = 'Active'
            AND ExpiryDate__c <= :now
            ORDER BY ExpiryDate__c ASC
        ];
    }

    /**
     * @description Checks that the current user has object-level read access to Token__c.
     */
    private void checkObjectAccessible() {
        if (!Schema.sObjectType.Token__c.isAccessible()) {
            throw new System.NoAccessException();
        }
    }
}
