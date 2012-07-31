trigger OAuthUniqToken on OAuth_Token__c (before insert) {
    List<OAuth_Token__c> delete_list = new List<OAuth_Token__c>();

    for (OAuth_Token__c t : Trigger.new) {
        delete_list.addAll([Select Id From OAuth_Token__c Where Owner__c = :t.Owner__c And OAuth_Service__c = :t.OAuth_Service__c]);
    }

    if (delete_list.size() > 0) {
        delete delete_list;
    }
}