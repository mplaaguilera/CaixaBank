public with sharing class TMS_Case_Operativa {

    //Comprobar si la validacion es necesario tras obtener el MCC final
    @AuraEnabled
    public static List<String> validarCamposCaso(Id recordId) {
        List<String> camposNoValidos = new List<String>();
        Case caso = [SELECT SuppliedEmail
                        FROM Case WHERE Id = :recordId];
        if (caso.SuppliedEmail == null) { camposNoValidos.add('Email del heredero (Web Email)'); }

        return camposNoValidos;
    }

    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> getPlantillasTMS() {
        //Se buscan todas las plantillas
        return [SELECT Name FROM EmailTemplate WHERE Folder.DeveloperName LIKE 'TMS_%' order by name asc LIMIT 30 ];
    }

    @AuraEnabled
    public static void prepararCaso(Id idCaso, Id idPlantilla, Boolean informarReferenciaCorreo, String operativa) {
        Case caso = [SELECT CC_Canal_Procedencia__c, CC_Buzon_Salida__c, CC_MCC_Plantilla__c, TMS_Servicio_Premium__c FROM Case WHERE Id = :idCaso ];
        caso.CC_MCC_Plantilla__c = idPlantilla;
        caso.CC_Ultima_Operativa_Correo__c = operativa;
        List<TMS_Correo__mdt> configBuzones = new List<TMS_Correo__mdt>();
        if(caso.TMS_Servicio_Premium__c){
            configBuzones = [SELECT TMS_Correo__c FROM TMS_Correo__mdt WHERE TMS_Canal_Procedencia__c = :caso.CC_Canal_Procedencia__c AND DeveloperName = 'TMS_Buzon_Premium' LIMIT 1];
        } else {
            configBuzones = [SELECT TMS_Correo__c FROM TMS_Correo__mdt WHERE TMS_Canal_Procedencia__c = :caso.CC_Canal_Procedencia__c AND DeveloperName = 'TMS_Buzon_No_Reply' LIMIT 1];
        }
        if (configBuzones.isEmpty()) {
            throw new AuraHandledException('Problema recuperando los datos del buzón de correo');
        } else {
            caso.CC_Buzon_Salida__c = configBuzones[0].TMS_Correo__c;
        }
        
        if (informarReferenciaCorreo) {
            caso.CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente();
        }
        update(caso);
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> destinatarios(Id idCaso) {

        List<String> direccionesCorreoPara = new List<String>();
        List<String> direccionesCorreoCc = new List<String>();

        Map<String, List<String>> retorno = new Map<String, List<String>>();
        Case caso = [SELECT SuppliedEmail, CC_Buzon_Salida__c
                        FROM Case WHERE Id = :idCaso];
    
        if (!String.isEmpty(caso.SuppliedEmail)) {
            direccionesCorreoPara.add(caso.SuppliedEmail);
        }

        //Direcciones de los correos anteriores (respetando si estaban en el "Para" o en "Copia")
        for (EmailMessage correoAnterior : [SELECT ToAddress, CcAddress FROM EmailMessage
                                            WHERE ParentId = :idCaso AND CC_Interno__c = false
                                            ORDER BY CreatedDate ASC]) {
            
            if (String.isNotBlank(correoAnterior.ToAddress)) {
                for (String direccionPara : correoAnterior.ToAddress.split(';')) {
                    if (!direccionPara.trim().equals(caso.CC_Buzon_Salida__c)) {
                        direccionesCorreoPara.add(direccionPara.trim());
                    }
                }
            }
            if (String.isNotBlank(correoAnterior.CcAddress)) {
                for (String direccionCc : correoAnterior.CcAddress.split(';')) {
                    if (!direccionCc.trim().equals(caso.CC_Buzon_Salida__c)) {
                        direccionesCorreoCc.add(direccionCc.trim());
                    }
                }
            }
        }

        //Quitar duplicados + Si una dirección está en el "Para" se descarta del "CC"
        direccionesCorreoPara = CC_MetodosUtiles.descartarDuplicadosLista(direccionesCorreoPara);
        direccionesCorreoCc = CC_MetodosUtiles.descartarDuplicadosLista(direccionesCorreoCc);

        for (Integer i = direccionesCorreoCc.size() - 1; i >= 0; i--) {
            if (direccionesCorreoPara.contains(direccionesCorreoCc[i])) {
                direccionesCorreoCc.remove(direccionesCorreoCc.indexOf(direccionesCorreoCc[i]));
            }
        }

        //Quitar direcciones de los propios buzones de TMS 
        for (EmailServicesAddress emailServiceAddress : [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress
                                                        WHERE Function.FunctionName = 'TMS_EmailService']) {
            String direccionBuzonTMS = emailServiceAddress.LocalPart + '@' + emailServiceAddress.EmailDomainName;
            if (direccionesCorreoPara.contains(direccionBuzonTMS)) {
                direccionesCorreoPara.remove(direccionesCorreoPara.indexOf(direccionBuzonTMS));
            }
            if (direccionesCorreoCc.contains(direccionBuzonTMS)) {
                direccionesCorreoCc.remove(direccionesCorreoCc.indexOf(direccionBuzonTMS));                
            }
        }
        retorno.put('Para', direccionesCorreoPara);
        retorno.put('Cc', direccionesCorreoCc);

        return retorno;
    }
}