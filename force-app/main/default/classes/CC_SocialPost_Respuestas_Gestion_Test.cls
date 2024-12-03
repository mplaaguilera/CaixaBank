@isTest
public class CC_SocialPost_Respuestas_Gestion_Test {
    
    @isTest 
    static void CC_SocialPost_Reclamacion_Gestion() {
        
        Case esCaso = new Case(
            Subject = 'Caso Test envío mensaje legal castellano',
            Status = 'Activo',
            CC_Idioma__c = 'es'
        );
        insert esCaso;
      
        
         SocialPost mensajeDirectoCliente = new SocialPost(
            Name = 'Mensaje del cliente',
            IsOutbound = true,
            MessageType = 'Direct',
            ParentId = esCaso.Id,
            Content = 'Mensaje del cliente',
            Provider = 'Twitter',
            CC_ReclamacionActiva__c = true,
            CC_Solicitud_Informacion__c = true
        );
        insert mensajeDirectoCliente;
        
        SocialPost mensajeDirectoCliente1 = new SocialPost(
            Name = 'Mensaje del cliente',
            IsOutbound = true,
            MessageType = 'Direct',
            ParentId = esCaso.Id,
            Content = 'Mensaje del cliente',
            Provider = 'Twitter',
            CC_ReclamacionActiva__c = true,
            CC_Solicitud_Informacion__c = true
        );
        insert mensajeDirectoCliente1;
           
        List<Id> ListTwitt = new  List<Id>();
        ListTwitt.add(mensajeDirectoCliente.Id);
       
        
          // AND ParentId IN :oListaCasos AND  
                    
        
		CC_SocialPost_Respuestas_Gestion.CC_SocialPost_Reclamacion_Gestion(ListTwitt);
        System.assertEquals(false, [SELECT CC_ReclamacionActiva__c FROM SocialPost WHERE Id = :mensajeDirectoCliente1.Id ].CC_ReclamacionActiva__c); 
	} 
}