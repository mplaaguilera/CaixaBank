public with sharing class CBK_DKIM_Notification {
    // public Boolean testResult = false;
    @future(callout=true)
    public static void execute() {
        map<string,string> email = new map<string,string>();
        map<String,boolean> mapDomain = New map<String,boolean>();
        List<String> addresses = new List<String>();
        List<String> addresses2 = new List<String>();

        for (EmailDomainKey dkey : [SELECT Domain,isActive from  EmailDomainKey]){
            mapDomain.put(dkey.Domain,dkey.isActive);
        }

        for (OrgWideEmailAddress dir : [select Address from OrgWideEmailAddress])
        {
            if (mapDomain.containsKey (dir.Address.split('@').get(1))==false)
            {
                addresses.add(dir.Address);
            }
            else{
                if (mapDomain.get(dir.Address.split('@').get(1))==false){
                    addresses2.add(dir.Address);
                }
            }
        }
        if (addresses.size() > 0 || addresses2.size() > 0) {
            generateEmail(addresses, addresses2);
        }
    }

    
    // Send email to specific addresses 
    private static void generateEmail(List<String> addresses, List<String> addresses2){
        // Get addresses from custom setting
        CBK_DKIM_Notification_CSetting__c dncs = CBK_DKIM_Notification_CSetting__c.getValues('toAddress');
        CBK_DKIM_Notification_CSetting__c dncs2 = CBK_DKIM_Notification_CSetting__c.getValues('fromAddress');

        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> addss = dncs.Addresses__c.split(';');
        mail.setToAddresses(addss);
        mail.setSenderDisplayName(dncs2.Addresses__c);
        mail.setSubject('Oficina Técnica - Notificación DKIM');

        // Options
        if(addresses.size() > 0 && addresses2.size() > 0){
            mail.setPlainTextBody('Falta la clave DKIM en las siguientes direcciones: '+ addresses.toString()
                                + '\n La clave DKIM está inactiva en las siguientes direcciones: '+ addresses2.toString());
            sendEmail(mail);
        }
        if(addresses.size() > 0 && addresses2.size() == 0){
            mail.setPlainTextBody('Falta la clave DKIM en las siguientes direcciones: '+ addresses.toString());
            sendEmail(mail);
        }
        if(addresses.size() == 0 && addresses2.size() > 0){
            mail.setPlainTextBody('La clave DKIM está inactiva en las siguientes direcciones: '+ addresses2.toString());
            sendEmail(mail);
        }
        if(addresses.size() == 0 && addresses2.size() == 0){
            // Not need send email
        }
    }

    private static void sendEmail(Messaging.SingleEmailMessage mail){
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}