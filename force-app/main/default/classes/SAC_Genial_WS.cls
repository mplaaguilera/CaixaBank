/*****************************************************************
 * Name: SAC_Genial_WS
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: servicio API REST de la respuesta de genIAl
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            genIAl           Alexandre Pérez   16/10/23     Creación
*****************************************************************/
@RestResource(urlMapping='/ActualizacionCasoPretensiones')
global with sharing class SAC_Genial_WS extends CBK_HttpServiceIntegration_Abstract{

    @httpPost
    global static void genialComunicacion(){
        String jsonEntrada = RestContext.request.requestBody.toString();
        RestResponse res = RestContext.response;
        genialRequest genialRequest = new genialRequest();

        try{
           
            try{
                genialRequest = (genialRequest)JSON.deserialize(jsonEntrada, genialRequest.class);
            } catch(Exception e) {
                res.statusCode = 400;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = blob.valueOf('{"descriptionError":"JSON erróneo"}');
                return;
            }
   
            if(genialRequest.reclamacion.Id == null){
                res.statusCode = 400;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = blob.valueOf('{"descriptionError":"Necesario informar el Id de la reclamación"}');
                return;
            }
            //en caso de que no venga marcado "usar datos del reclamante" escribimos los datos de contacto que vienen en la integración
            //SAC_GenialSettings__c  settings = SAC_GenialSettings__c.getInstance();
            case reclamacion = genialRequest.reclamacion;
            list<case> reclamaOriginal = new list<case>();
            if(Schema.SObjectType.Case.isAccessible() && 
            Schema.SObjectType.Case.fields.ownerId.isAccessible() &&
            Schema.SObjectType.Case.fields.AccountId.isAccessible() &&
            Schema.SObjectType.Case.fields.SAC_GenialEstado__c.isAccessible() &&
            Schema.SObjectType.Case.fields.CC_Oficina_Afectada_Lookup__c.isAccessible() &&
            Schema.SObjectType.Case.fields.isClosed.isAccessible()) {
                reclamaOriginal = [SELECT Id, ownerId, AccountId, SAC_GenialEstado__c, CC_Oficina_Afectada_Lookup__c, isClosed, CC_SuppliedNif__c, OS_Email__c,
                                    CC_Telefono_Contacto__c, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_PoblacionContacto__c,
                                    SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreContacto__c, origin
                                    FROM Case WHERE Id = : genialRequest.reclamacion.Id];
            }
            if(reclamaOriginal.isEmpty()){
                res.statusCode = 404;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = blob.valueOf('{"descriptionError":"El Id de reclamación proporcionado no se encuentra en BBDD"}');
                return;
            }
            if(reclamaOriginal.get(0).SAC_GenialEstado__c == 'SAC_002' || reclamaOriginal.get(0).SAC_GenialEstado__c == 'SAC_003' 
            || reclamaOriginal.get(0).SAC_GenialEstado__c == 'SAC_006'){
                //solo se pueden enviar datos a casos que esten en estado Enviado
                res.statusCode = 403;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = blob.valueOf('{"descriptionError":"La reclamación proporcionada ya ha sido tratada"}');
                return;
            }
            if(reclamacion.CC_Oficina_Afectada_Lookup__c != null && String.isNotBlank(Id.valueOf(reclamacion.CC_Oficina_Afectada_Lookup__c,true))){
                //comprobar si la oficina existe
                list<Account> oficinaReclama = new list<Account>();
                if(Schema.SObjectType.Account.isAccessible()) {
                    oficinaReclama = [SELECT Id FROM Account WHERE Id = : reclamacion.CC_Oficina_Afectada_Lookup__c];
                }
                
                if (oficinaReclama.size() == 0){
                    res.statusCode = 404;
                    res.addHeader('Content-Type', 'application/json');
                    res.responseBody = blob.valueOf('{"descriptionError":"La Oficina Afectada proporcionada no se encuentra en BBDD"}');
                    return;
                }
            }
            else{
                //el id es null o "" o whitespace
                genialRequest.reclamacion.CC_Oficina_Afectada_Lookup__c = null;
            }
            if(reclamaOriginal.get(0).isClosed){
                res.statusCode = 409;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = blob.valueOf('{"descriptionError":"La reclamación está cerrada"}');
                return;
            }
            group colaIA = new group();
            if(Schema.SObjectType.Group.isAccessible()) {
                colaIA = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = :'SAC_GenialPdteIA' LIMIT 1];
            }

            /*if(!reclamacion.SAC_UsarDatos__c){
                reclamacion.OS_Email__c = genialRequest.contactoReclamacion.email;
                reclamacion.CC_Telefono_Contacto__c = genialRequest.contactoReclamacion.telefono;
                reclamacion.SAC_DireccionContacto__c = genialRequest.contactoReclamacion.direccion;
                reclamacion.SAC_CodigoPostalContacto__c = genialRequest.contactoReclamacion.codPostal;
                reclamacion.SAC_PoblacionContacto__c = genialRequest.contactoReclamacion.poblacion;
                reclamacion.SAC_ProvinciaContacto__c = genialRequest.contactoReclamacion.provincia;
                reclamacion.SAC_PaisContacto__c = genialRequest.contactoReclamacion.pais;
                reclamacion.SAC_DireccionPostalNotificacion__c = genialRequest.contactoReclamacion.direccionNoti;
            }*/
            genialRequest.jsonRequest = jsonEntrada;
            genialRequest.reclamaOriginal = reclamaOriginal.get(0);
            genialRequest.pdteIA = (colaIA.Id == reclamaOriginal[0].ownerId);
            System.enqueueJob(new SAC_GenialQueueable(genialRequest, 0));

            res.statusCode = 200;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = blob.valueOf('{"description":"Reclamación recibida"}');

        } catch(Exception e) {
            CBK_Log.error(e);
            res.statusCode = 500;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = blob.valueOf('{"descriptionError":"Error de servidor"}');
        }
        
    }

    public class GenialRequest {
        public list<datosReclamante> reclamantes;
        public case reclamacion;
        public contactoReclamacion contactoReclamacion;
        public list<case> pretensiones;
        public case reclamantePrincipal;
        public case reclamaOriginal;
        public boolean pdteIA;
        public string jsonRequest;
        public Id idShadow;
        public DatosRecPrincipal datosRecPrincipal;
        public Umbrales umbrales;
    }

    public class DatosReclamante {
        public boolean reclamantePrincipal;
        public account reclamante;
    }

    public class DatosRecPrincipal {
        public string firstName;
        public string lastName;
        public string numPerso;
    }

    public class ContactoReclamacion {
        string email;
        string telefono;
        string direccion;
        string codPostal;
        string poblacion;
        string provincia;
        string pais;
        string direccionNoti;
    }
    
    public class Umbrales {
        public Decimal tematica;
        public Decimal producto;
        public Decimal motivo;
        public Decimal detalle;
    }

}