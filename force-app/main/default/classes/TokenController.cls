/**
 * @description Apex controller exposing Token__c operations to Lightning Web Components.
 *              Delegates queries to TokenSelector and mutations to TokenService.
 */
public with sharing class TokenController {

    private static final TokenSelector selector = new TokenSelector();
    private static final TokenService service = new TokenService();

    /**
     * @description Returns all active Token__c records. Cacheable for LWC wire.
     * @return List of active Token__c records
     */
    @AuraEnabled(cacheable=true)
    public static List<Token__c> getActiveTokens() {
        try {
            return selector.getActiveTokens();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Creates a new Token__c record.
     * @param value The token value string
     * @param expiryDate The ISO-8601 expiry date string (yyyy-MM-dd HH:mm:ss)
     * @return The Id of the created Token__c record
     */
    @AuraEnabled
    public static Id createToken(String value, String expiryDate) {
        try {
            Datetime expiryDt = null;
            if (String.isNotBlank(expiryDate)) {
                expiryDt = Datetime.valueOfGmt(expiryDate);
            }
            Token__c token = service.createToken(value, expiryDt);
            return token.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Revokes an existing Token__c record.
     * @param tokenId The Id of the Token__c to revoke
     */
    @AuraEnabled
    public static void revokeToken(Id tokenId) {
        try {
            service.revokeToken(tokenId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
