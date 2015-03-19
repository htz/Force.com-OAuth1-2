public with sharing class OAuthUtil {
    public static ID getOAuthServiceRecordTypeId(String developerName) {
        ID recordTypeId = null;
        Schema.DescribeSObjectResult d = Schema.SObjectType.OAuthService__c;
        List<RecordType> rts = [Select DeveloperName From RecordType Where sObjectType = :d.getName() And DeveloperName = :developerName];
        if (rts.size() == 1) recordTypeId = rts[0].Id;
        return recordTypeId;
    }
}