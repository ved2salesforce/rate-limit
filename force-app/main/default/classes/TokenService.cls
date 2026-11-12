/**
 * @description Service class for Token__c DML operations.
 *              All queries are delegated to TokenSelector; all DML is in this class only.
 *              Runs with sharing for record-level security.
 *              Performs object-level CRUD checks before DML.
 */
public with sharing class TokenService {

    private static final TokenSelector selector = new TokenSelector();

    /**
     * @description Creates a new Token__c record with Status Active.
     * @param value The token value string
     * @param expiryDate The expiry date/time for the token
     * @return The newly created Token__c record
     */
    public Token__c createToken(String value, Datetime expiryDate) {
        if (!Schema.sObjectType.Token__c.isCreateable()) {
            throw new System.NoAccessException();
        }
        Token__c token = new Token__c(
            Value__c = value,
            ExpiryDate__c = expiryDate,
            Status__c = 'Active'
        );
        insert token;
        return token;
    }

    /**
     * @description Revokes a token by setting its Status__c to 'Revoked'.
     * @param tokenId The Id of the Token__c record to revoke
     */
    public void revokeToken(Id tokenId) {
        if (!Schema.sObjectType.Token__c.isUpdateable()) {
            throw new System.NoAccessException();
        }
        Token__c token = selector.getTokenById(tokenId);
        if (token == null) {
            throw new IllegalArgumentException('Token not found: ' + tokenId);
        }
        token.Status__c = 'Revoked';
        update token;
    }

    /**
     * @description Marks a list of Token__c records as 'Expired'.
     * @param tokens The list of Token__c records to expire
     */
    public void expireTokens(List<Token__c> tokens) {
        if (tokens == null || tokens.isEmpty()) {
            return;
        }
        if (!Schema.sObjectType.Token__c.isUpdateable()) {
            throw new System.NoAccessException();
        }
        List<Token__c> toUpdate = new List<Token__c>();
        for (Token__c t : tokens) {
            toUpdate.add(new Token__c(Id = t.Id, Status__c = 'Expired'));
        }
        update toUpdate;
    }
}
