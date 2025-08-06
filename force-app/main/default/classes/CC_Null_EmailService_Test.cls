@isTEST
public class CC_Null_EmailService_Test {
    static testMethod void testEmail1() {
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        
        email.subject = 'Mail accionistas' ;
        email.plainTextBody = 'xxxxxxxxxxxxx';
        email.fromAddress = 'test@test.com';
        env.fromAddress = 'test@test.com';
      
        CC_Null_EmailService creatC = new CC_Null_EmailService();
        creatC.handleInboundEmail(email, env );
    
    }
}