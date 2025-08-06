@IsTest
public class CC_SocialPostReclBatch_Test {
   @testSetup
    static void test(){
       Case esCaso = new Case(
            Subject = 'Caso Test envío mensaje legal castellano',
            Status = 'Activo',
            CC_Idioma__c = 'es'
        );
        insert esCaso;
        
         SocialPost mensajeDirectoCliente = new SocialPost();
            mensajeDirectoCliente.Name = 'Mensaje del cliente';
            mensajeDirectoCliente.IsOutbound = false;
            mensajeDirectoCliente.MessageType = 'Direct';
            mensajeDirectoCliente.ParentId = esCaso.Id;
            mensajeDirectoCliente.Content = 'Mensaje del cliente';
        	mensajeDirectoCliente.Posted = DateTime.now().addDays(-30);
       		mensajeDirectoCliente.CC_ReclamacionActiva__c = false;
            mensajeDirectoCliente.CC_Respuesta_Reclamada__c = false;
            mensajeDirectoCliente.Provider = 'Twitter';
            mensajeDirectoCliente.CC_ReclamacionActiva__c = true;
            mensajeDirectoCliente.IsOutbound = true;
        	mensajeDirectoCliente.CC_Solicitud_Informacion__c = true;
        insert mensajeDirectoCliente;

    }
    	
 
     @isTest
    static void test1(){
        //test();
        CC_SocialPostReclBatch batch = new CC_SocialPostReclBatch (); //creas el batch = que la clase el nomrbe
        DataBase.executeBatch(batch); //y ahora se ejecuta esa clase   
    }
}