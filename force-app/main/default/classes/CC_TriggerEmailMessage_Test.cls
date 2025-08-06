@isTest
public with sharing class CC_TriggerEmailMessage_Test {
	@testSetup
    static void testSetup(){
        
    }
    static testMethod void respuestaSolicitudInfo() {
        Case caso = new Case();
        caso.Subject = 'Mail entrante';
        caso.Status = 'New';
        caso.Reason = 'Helpdesk';
        insert caso;
        
        // Testar el trigger del objeto EmailMessage
        EmailMessage emailmes = new EmailMessage();
        emailmes.TextBody ='Email Body';
        emailmes.Incoming = true;
        emailmes.RelatedToId = caso.Id;
        insert emailmes;
	}
}