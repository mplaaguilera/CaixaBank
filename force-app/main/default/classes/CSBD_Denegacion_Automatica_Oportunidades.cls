public with sharing class CSBD_Denegacion_Automatica_Oportunidades {

    public static void denegacionAutomaticaOportunidades(List<Id> idOportunidades) {
        if (!idOportunidades.isEmpty()) {
            List<CSBD_Denegacion_Auto_Solicitud__c> configsDenegacionAutomatica = obtenerConfigsDenegacionAutomatica();
            List<Opportunity> oportunidades = obtenerOportunidades(idOportunidades);

            //Se evalúan los criterios para cada oportunidad
            for (Opportunity oportunidad : oportunidades) {
                for (CSBD_Denegacion_Auto_Solicitud__c configDenegacionAutomatica : configsDenegacionAutomatica) {
                    if (oportunidad.RecordType.DeveloperName == configDenegacionAutomatica.CSBD_Record_Type_Oportunidad__c
                    && oportunidad.CSBD_Circuito_Contratacion_Online__c == configDenegacionAutomatica.CSBD_Circuito_Contratacion_Online__c
                    && oportunidad.CSBD_Empresa_Proveedora__c == configDenegacionAutomatica.CSBD_Empresa_Proveedora__c
                    && oportunidad.Amount >= configDenegacionAutomatica.CSBD_Importe_Desde__c
                    && oportunidad.Amount <= configDenegacionAutomatica.CSBD_Importe_Hasta__c
                    && (!oportunidad.CSBD_Dispone_Importe_Preconcedido__c || !configDenegacionAutomatica.CSBD_Excluir_Clientes_Limite__c)
                    && (configDenegacionAutomatica.CSBD_Scoring_Riesgo__c!=null && oportunidad.CSBD_Scoring_Riesgo__c == configDenegacionAutomatica.CSBD_Scoring_Riesgo__c ) ) {
                        //La escala maestra es del contacto, si no es conocida la regla nunca se cumple (27/12: Excepción Denegada SIA)
                        if ((oportunidad?.CSBD_Contact__r?.CSBD_Escala_Maestra__c != null
                        && oportunidad.CSBD_Contact__r.CSBD_Escala_Maestra__c >= configDenegacionAutomatica.CSBD_Escala_Maestra_Desde__c
                        && oportunidad.CSBD_Contact__r.CSBD_Escala_Maestra__c <= configDenegacionAutomatica.CSBD_Escala_Maestra_Hasta__c)
                        //Si la escala maestra viene vacía y el scoring de riesgo es Denegada SIA --> Denegamos automáticamente
                        || (oportunidad?.CSBD_Contact__r?.CSBD_Escala_Maestra__c == null && oportunidad.CSBD_Scoring_Riesgo__c == 'Denegada SIA')){
                            //La oportunidad cumple la regla
                            CSBD_Opportunity.cerrarOportunidad(oportunidad.Id, 'Perdida', configDenegacionAutomatica.CSBD_Resolucion__c);
                            CSBD_Activity.crearActividad(oportunidad.Id, 'Denegación automática', 'Completed', 'Denegación automática', configDenegacionAutomatica.Name);
                            if (configDenegacionAutomatica.CSBD_Enviar_Correo_Auto__c) {
                                enviarCorreoDenegacionAutomatica(
                                    oportunidad.Id,
                                    oportunidad.CSBD_Empresa_Proveedora__c,
                                    oportunidad.CSBD_Contact__c,
                                    oportunidad.CSBD_Email_Solicitud__c,
                                    oportunidad.CSBD_Idioma_Solicitud__c == 'Catalán' ? configDenegacionAutomatica.CSBD_Plantilla_Correo_Catalan__c : configDenegacionAutomatica.CSBD_Plantilla_Correo_Castellano__c
                                );
                            }
                            break; //Siguiente oportunidad
                        }
                    }
                }
            }
            update oportunidades;
        }
    }

    private static List<CSBD_Denegacion_Auto_Solicitud__c> obtenerConfigsDenegacionAutomatica() {
        return [SELECT Name, CSBD_Record_Type_Oportunidad__c, CSBD_Empresa_Proveedora__c, CSBD_Excluir_Clientes_Limite__c,
                CSBD_Importe_Desde__c, CSBD_Importe_Hasta__c, CSBD_Escala_Maestra_Desde__c, CSBD_Escala_Maestra_Hasta__c,
                CSBD_Resolucion__c, CSBD_Enviar_Correo_Auto__c, CSBD_Scoring_Riesgo__c,
                CSBD_Plantilla_Correo_Castellano__c, CSBD_Plantilla_Correo_Catalan__c, CSBD_Circuito_Contratacion_Online__c
                FROM CSBD_Denegacion_Auto_Solicitud__c
                WHERE CSBD_Denegada__c = TRUE
                ORDER BY CSBD_Record_Type_Oportunidad__c, CSBD_Orden__c ASC];
    }

    private static List<Opportunity> obtenerOportunidades(List<Id> idOportunidades) {
        return [SELECT RecordType.DeveloperName, CSBD_Contact__c, CSBD_Empresa_Proveedora__c, CSBD_Idioma_Solicitud__c,
                Amount, CSBD_Contact__r.CSBD_Escala_Maestra__c, CSBD_Email_Solicitud__c,
                CSBD_Circuito_Contratacion_Online__c, CSBD_Dispone_Importe_Preconcedido__c, CSBD_Scoring_Riesgo__c
                FROM Opportunity WHERE Id IN :idOportunidades AND IsClosed = FALSE];
    }

    private static void enviarCorreoDenegacionAutomatica(Id idOportunidad, String empresaProveedora, String idContacto, String destinatario, String nombrePlantilla) {
        if (String.isNotBlank(destinatario) && String.isNotBlank(nombrePlantilla)) {
            Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
            if (!Test.isRunningTest()) {
                correo.setTemplateId([SELECT Id FROM EmailTemplate WHERE Folder.DeveloperName = 'CSBD_Denegacion_Auto' AND Name = :nombrePlantilla LIMIT 1].Id);
            } else {
                correo.setTemplateId([SELECT Id FROM EmailTemplate WHERE Name = :nombrePlantilla LIMIT 1].Id);
            }
            correo.setTargetObjectId(idContacto); //Se recibe como String porque puede venir vacío
            correo.setTreatTargetObjectAsRecipient(false);
            correo.setWhatId(idOportunidad);
            correo.setToAddresses(new List<String>{destinatario});
            correo.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = :(empresaProveedora == 'imaginBank' ? 'CSBD - ImaginBank' : 'CSBD - CaixaBank')].Id);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{correo});
        }
    }
}