public without sharing class CSBD_EmailMessage_Vincular_Controller {
    
    @AuraEnabled
    public static List<EmailMessage> obtenerCorreosNoVinculados(String empresa) {
        if (String.isNotBlank(empresa)) {

           /* Map<String, String> buzonesCSBD = new Map<String, String>();
            for (OrgWideEmailAddress buzonCSBD : [SELECT DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName LIKE 'CSBD%' OR DisplayName LIKE 'Banca Digital - Caixabank']) {
                buzonesCSBD.put(buzonCSBD.DisplayName, buzonCSBD.Address);
            }*/

            List<String> buzonesMostrar = new List<String>();
            /*if (empresa == 'CaixaBank') {
                buzonesMostrar.add(buzonesCSBD.get('Banca Digital - Caixabank'));
            } else if (empresa == 'imaginBank') {
                buzonesMostrar.add(buzonesCSBD.get('CSBD - ImaginBank'));
            }*/
            Id idBuzonSalida = CSBD_MetodosComunes.obtenerIdBuzonSalida(empresa);
            if (idBuzonSalida != null) {
                buzonesMostrar.add([SELECT Address FROM OrgWideEmailAddress WHERE Id = :idBuzonSalida]?.Address);
            }
            return [SELECT CC_Id_Aux__c, MessageDate, FromAddress, ToAddress, Status, Subject, HtmlBody, HasAttachment FROM EmailMessage
                    WHERE CC_Aplicacion__c = 'CSBD' AND Incoming = True
                    AND CSBD_Oportunidad_Id__c = NULL AND CC_Rechazado__c = False AND ToAddress IN :buzonesMostrar
                    ORDER BY MessageDate ASC LIMIT 80];
        } else {
            return [SELECT CC_Id_Aux__c, MessageDate, FromAddress, ToAddress, Status, Subject, HtmlBody, HasAttachment FROM EmailMessage
                    WHERE CC_Aplicacion__c = 'CSBD' AND Incoming = True
                    AND CSBD_Oportunidad_Id__c = NULL AND CC_Rechazado__c = False
                    ORDER BY MessageDate ASC LIMIT 80];
        }
    }

    @AuraEnabled
    public static Id vincularCorreoAOportunidadNumero(Id idEmailMessage, String numeroOportunidad) {
        List<Opportunity> oportunidades = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName LIKE 'CSBD_%'
                                            AND CSBD_Identificador__c = :numeroOportunidad LIMIT 1];
        if (oportunidades.isEmpty()) {
            throw new AuraHandledException('El identificador indicado no se corresponde con ninguna oportunidad.');
        } else {
            return CSBD_EmailMessage.vincularCorreoAOportunidad(idEmailMessage, oportunidades[0].Id);
        }
    }

    @AuraEnabled
    public static Id vincularCorreoAOportunidad(Id idEmailMessage, Id idOpportunity) {
        return CSBD_EmailMessage.vincularCorreoAOportunidad(idEmailMessage, idOpportunity);
    }

    @AuraEnabled
    public static void rechazarCorreo(List<Id> idsEmailMessage) {
        List<EmailMessage> correos = new List<EmailMessage>();
        for (Id idCorreo : idsEmailMessage) {
            EmailMessage correo = new EmailMessage(Id = idCorreo);
            correo.CC_Rechazado__c = true;
            correos.add(correo);
        }
        update correos;
    }

    @AuraEnabled
    public static List<Opportunity> obtenerOportunidades(String empresa, String direccionCorreo) {
        return [SELECT CSBD_Id_Aux__c, CSBD_Identificador__c, Name, CreatedDate, CSBD_Estado__c FROM Opportunity
                WHERE RecordType.DeveloperName LIKE 'CSBD_%' AND SystemModStamp = LAST_N_DAYS:90
                AND (CSBD_Email_Solicitud__c = :direccionCorreo OR CSBD_Contact__r.Email = :direccionCorreo)
                AND CSBD_Empresa_Proveedora__c = :empresa ORDER BY CreatedDate DESC LIMIT 20];
    }
}