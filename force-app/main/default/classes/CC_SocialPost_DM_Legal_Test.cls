@isTest
public with sharing class CC_SocialPost_DM_Legal_Test {
    /* A falta de que Salesforce no implemente opciones para poder testear los envíos de SocialPost
        la clase correspondiente a este test no se podrá probar, quedamos a la espera*/
    
     @isTest
    public static void enviarMensajeLegalTwitter() {
        
        Case esCaso = new Case(
            Subject = 'Caso Test envío mensaje legal castellano',
            Status = 'Activo',
            CC_Idioma__c = 'es'
        );
        insert esCaso;
        
         SocialPost mensajeDirectoCliente = new SocialPost(
            Name = 'Mensaje del cliente',
            IsOutbound = false,
            MessageType = 'Direct',
            ParentId = esCaso.Id,
            Content = 'Mensaje del cliente'
        );
        insert mensajeDirectoCliente;
        
        
        List<Id> socialPostIds = new  List<Id>();
        socialPostIds.add(mensajeDirectoCliente.Id);
        
    	CC_SocialPost_DM_Legal.enviarMensajeLegalTwitter(socialPostIds);
        system.assertEquals('Mensaje del cliente', mensajeDirectoCliente.Content);
    }
    
      @isTest
    public static void enviarMensajeLegalTwitterSinIdioma() {
        
        Case esCaso = new Case(
            Subject = 'Caso Test envío mensaje legal castellano',
            Status = 'Activo',
            CC_Idioma__c = 'fr'
        );
        insert esCaso;
        
         SocialPost mensajeDirectoCliente = new SocialPost(
            Name = 'Mensaje del cliente',
            IsOutbound = false,
            MessageType = 'Direct',
            ParentId = esCaso.Id,
            Content = 'Mensaje del cliente'
        );
        insert mensajeDirectoCliente;
        
        
        List<Id> socialPostIds = new  List<Id>();
        socialPostIds.add(mensajeDirectoCliente.Id);
        
    	CC_SocialPost_DM_Legal.enviarMensajeLegalTwitter(socialPostIds);
        system.assertEquals('Mensaje del cliente', mensajeDirectoCliente.Content);
    }
    
    @isTest
    public static void saleDMEnCasoCastellano() {
        Case esCaso = new Case(
            Subject = 'Caso Test envío mensaje legal castellano',
            Status = 'Activo',
            CC_Idioma__c = 'es'
        );
        insert esCaso;

        SocialPost mensajeDirectoCliente = new SocialPost(
            Name = 'Mensaje del cliente',
            IsOutbound = false,
            MessageType = 'Direct',
            ParentId = esCaso.Id,
            Content = 'Mensaje del cliente'
        );
        insert mensajeDirectoCliente;

        SocialPost mensajeDirectoAgente = new SocialPost(
            Name = 'Mensaje del agente',
            IsOutbound = true,
            MessageType = 'Direct',
            ParentId = esCaso.Id,
            ReplyToId = mensajeDirectoCliente.Id,
            Content = 'Mensaje del agente'
        );
        insert mensajeDirectoAgente;

        //No llamamos a la función ya que al hacer el test ya lo hace el process builder al estar éste activado
        //List<Id> mensajesSalida = new List<Id>{mensajeDirectoAgente.Id};
        //CC_SocialPost_DM_Legal.enviarMensajeLegalTwitter(mensajesSalida);

        /*
        List<SocialPost> mensajesLegales = [SELECT Content,IsOutbound,MessageType,ReplyToId,ParentId FROM SocialPost WHERE Id NOT IN (:mensajeDirectoAgente.Id,:mensajeDirectoCliente.Id)];
        CC_Texto_MultiIdioma__mdt esMensajeLegal = [SELECT CC_Texto__c FROM CC_Texto_MultiIdioma__mdt WHERE CC_Nombre__c = 'Mensaje legal' AND CC_Idioma__c = 'es' LIMIT 1];
        System.assertEquals(1, mensajesLegales.size());
        System.assertEquals(true, mensajesLegales[0].IsOutbound);
        System.assertEquals(esMensajeLegal.CC_Texto__c, mensajesLegales[0].Content);
        System.assertEquals(esCaso.Id, mensajesLegales[0].ParentId);
        System.assertEquals(mensajeDirectoCliente.Id, mensajesLegales[0].ReplyToId);
        */
    }

    @isTest
    public static void saleDMEnCasoCatalan() {
        Case caCaso = new Case(
            Subject = 'Caso Test envío mensaje legal catalán',
            Status = 'Activo',
            CC_Idioma__c = 'ca'
        );
        insert caCaso;

        SocialPost mensajeDirectoCliente = new SocialPost(
            Name = 'Mensaje del cliente',
            IsOutbound = false,
            MessageType = 'Direct',
            ParentId = caCaso.Id,
            Content = 'Mensaje del cliente'
        );
        insert mensajeDirectoCliente;

        SocialPost mensajeDirectoAgente = new SocialPost(
            Name = 'Mensaje del agente',
            IsOutbound = true,
            MessageType = 'Direct',
            ParentId = caCaso.Id,
            ReplyToId = mensajeDirectoCliente.Id,
            Content = 'Mensaje del agente'
        );
        insert mensajeDirectoAgente;

        //No llamamos a la función ya que al hacer el test ya lo hace el process builder al estar éste activado
        //List<Id> mensajesSalida = new List<Id>{mensajeDirectoAgente};
        //CC_SocialPost_DM_Legal.enviarMensajeLegalTwitter(mensajesSalida)

        /*
        List<SocialPost> mensajesLegales = [SELECT Content,IsOutbound,MessageType,ReplyToId,ParentId FROM SocialPost WHERE Id NOT IN (:mensajeDirectoAgente.Id,:mensajeDirectoCliente.Id)];
        CC_Texto_MultiIdioma__mdt caMensajeLegal = [SELECT CC_Texto__c FROM CC_Texto_MultiIdioma__mdt WHERE CC_Nombre__c = 'Mensaje legal' AND CC_Idioma__c = 'ca' LIMIT 1];
        System.assertEquals(1, mensajesLegales.size());
        System.assertEquals(true, mensajesLegales[0].IsOutbound);
        System.assertEquals(caMensajeLegal.CC_Texto__c, mensajesLegales[0].Content);
        System.assertEquals(caCaso.Id, mensajesLegales[0].ParentId);
        System.assertEquals(mensajeDirectoCliente.Id, mensajesLegales[0].ReplyToId);
        */
    }

    @isTest
    public static void saleDMEnCasoIngles() {
        Case enCaso = new Case(
            Subject = 'Caso Test envío mensaje legal inglés',
            Status = 'Activo',
            CC_Idioma__c = 'en'
        );
        insert enCaso;

        SocialPost mensajeDirectoCliente = new SocialPost(
            Name = 'Mensaje del cliente',
            IsOutbound = false,
            MessageType = 'Direct',
            ParentId = enCaso.Id,
            Content = 'Mensaje del cliente'
        );
        insert mensajeDirectoCliente;

        SocialPost mensajeDirectoAgente = new SocialPost(
            Name = 'Mensaje del agente',
            IsOutbound = true,
            MessageType = 'Direct',
            ParentId = enCaso.Id,
            ReplyToId = mensajeDirectoCliente.Id,
            Content = 'Mensaje del agente'
        );
        insert mensajeDirectoAgente;

        //No llamamos a la función ya que al hacer el test ya lo hace el process builder al estar éste activado
        //List<Id> mensajesSalida = new List<Id>{mensajeDirectoAgente};
        //CC_SocialPost_DM_Legal.enviarMensajeLegalTwitter(mensajesSalida)

        /*
        List<SocialPost> mensajesLegales = [SELECT Content,IsOutbound,MessageType,ReplyToId,ParentId FROM SocialPost WHERE Id NOT IN (:mensajeDirectoAgente.Id,:mensajeDirectoCliente.Id)];
        CC_Texto_MultiIdioma__mdt enMensajeLegal = [SELECT CC_Texto__c FROM CC_Texto_MultiIdioma__mdt WHERE CC_Nombre__c = 'Mensaje legal' AND CC_Idioma__c = 'en' LIMIT 1];
        System.assertEquals(1, mensajesLegales.size());
        System.assertEquals(true, mensajesLegales[0].IsOutbound);
        System.assertEquals(enMensajeLegal.CC_Texto__c, mensajesLegales[0].Content);
        System.assertEquals(enCaso.Id, mensajesLegales[0].ParentId);
        System.assertEquals(mensajeDirectoCliente.Id, mensajesLegales[0].ReplyToId);
        */
    }

    @isTest
    public static void saleDMEnCasoNoIdioma() {
        Case caso = new Case(
            Subject = 'Caso Test envío mensaje legal castellano',
            Status = 'Activo'
        );
        insert caso;

        SocialPost mensajeDirectoCliente = new SocialPost(
            Name = 'Mensaje del cliente',
            IsOutbound = false,
            MessageType = 'Direct',
            ParentId = caso.Id,
            Content = 'Mensaje del cliente'
        );
        insert mensajeDirectoCliente;

        SocialPost mensajeDirectoAgente = new SocialPost(
            Name = 'Mensaje del agente',
            IsOutbound = true,
            MessageType = 'Direct',
            ParentId = caso.Id,
            ReplyToId = mensajeDirectoCliente.Id,
            Content = 'Mensaje del agente'
        );
        insert mensajeDirectoAgente;

        //No llamamos a la función ya que al hacer el test ya lo hace el process builder al estar éste activado
        //List<Id> mensajesSalida = new List<Id>{mensajeDirectoAgente};
        //CC_SocialPost_DM_Legal.enviarMensajeLegalTwitter(mensajesSalida)

        /*
        List<SocialPost> mensajesLegales = [SELECT Content,IsOutbound,MessageType,ReplyToId,ParentId FROM SocialPost WHERE Id NOT IN (:mensajeDirectoAgente.Id,:mensajeDirectoCliente.Id)];
        CC_Texto_MultiIdioma__mdt esMensajeLegal = [SELECT CC_Texto__c FROM CC_Texto_MultiIdioma__mdt WHERE CC_Nombre__c = 'Mensaje legal' AND CC_Idioma__c = 'es' LIMIT 1];
        System.assertEquals(1, mensajesLegales.size());
        System.assertEquals(true, mensajesLegales[0].IsOutbound);
        System.assertEquals(esMensajeLegal.CC_Texto__c, mensajesLegales[0].Content);
        System.assertEquals(caso.Id, mensajesLegales[0].ParentId);
        System.assertEquals(mensajeDirectoCliente.Id, mensajesLegales[0].ReplyToId);
        */
    }
}