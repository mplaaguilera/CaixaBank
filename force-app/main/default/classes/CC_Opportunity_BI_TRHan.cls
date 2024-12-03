public with sharing class CC_Opportunity_BI_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Opportunity>)tp.newList);
	}

    private void process(List<Opportunity> listNewObj) {
        listNewObj = descartarOportunidadesNoCsbd(listNewObj);
        if(!listNewObj.isEmpty()) {
            inicializarOportunidad(listNewObj);
            descartarOportunidadesNoCsbd(listNewObj);
            horarioComercialSiNo(listNewObj);
            CSBD_Hipoteca.informarCampoPrioridad(listNewObj, null);
            if(FeatureManagement.checkPermission('CSBD_UsuarioPromptsIA')){
                CSBD_EinsteinUtils.marcarCheckPromptSiCumple(listNewObj);
            }
        }
	}

    private void inicializarOportunidad(List<Opportunity> listNewObj) {
        Id hipotecaRT = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_Hipoteca');
        String chequearCanal = 'Plataformas Hipotecarias Digitales';
        Set<String> productosCSBD = new Set<String>();
        List<Opportunity> actualizarOportunidades = new List<Opportunity>();
        String centroOrigen = [SELECT MasterLabel FROM CSBD_Centro_Origen__mdt WHERE CSBD_Activo__c = TRUE LIMIT 1].MasterLabel;
        Set<Id> ownerIds = new Set<Id>();
        Map<Id, String> ownerDepartments = new Map<Id, String>();

        for (Opportunity oportunidad : listNewObj) {
            ownerIds.add(oportunidad.OwnerId);
        }

        for (User owner : [SELECT Department FROM User WHERE Id IN :ownerIds AND Department != null]) {
            ownerDepartments.put(owner.Id, owner.Department);
        }

        for (Opportunity oportunidad : listNewObj) {
			oportunidad.CloseDate = System.today().addDays(CSBD_Opportunity.diasFechaCierre(oportunidad.RecordTypeId));
			oportunidad.AV_FechaModificacion__c = System.today().addDays(CSBD_Opportunity.diasFechaCierre(oportunidad.RecordTypeId));
			oportunidad.AV_CentroOrigen__c = centroOrigen;
			oportunidad.AV_Center__c = centroOrigen;
            oportunidad.CSBD_Fecha_vencimiento_alta__c = (oportunidad.RecordTypeId == hipotecaRT && oportunidad.CSBD_Canal__c == chequearCanal) ?
                System.today().addMonths(3) : 
                System.today().addMonths(1);
			//Comprobar si se ha informado el campo CSBD_Producto al dar de alta la oportunidad manualmente
			if (!String.isBlank(oportunidad.CSBD_Producto__c)) {
				productosCSBD.add(oportunidad.CSBD_Producto__c);
				actualizarOportunidades.add(oportunidad);
			}

            if (ownerDepartments.containsKey(oportunidad.OwnerId)) {
                oportunidad.CSBD_Equipo__c = ownerDepartments.get(oportunidad.OwnerId);
            }
        }
        //Se establece la relación entre el valor guardado en CSBD_Producto__c y Product2 para guardarlo en AV_PF__c
        if (!productosCSBD.isEmpty()) {
            List<CC_Lista_Valores__c> lov = [SELECT CC_Valor2__c, CSBD_Product2__c FROM CC_Lista_Valores__c WHERE CSBD_Product2__c != null AND RecordType.DeveloperName = 'CC_Valor'
												AND CC_Lista__r.Name = 'CSBD: Relación de valores Now - Salesforce: Empresa, familia y producto'
												AND CC_Valor2__c IN :productosCSBD AND CC_Activa__c = TRUE];
            if (!lov.isEmpty()) {
                Map<String, String> product2Valor2 = new Map<String, String>();
                for (CC_Lista_Valores__c valor : lov) {
                    product2Valor2.put(valor.CC_Valor2__c, valor.CSBD_Product2__c);
                }
                for (Opportunity opportunity : actualizarOportunidades) {
                    if (product2Valor2.containsKey(opportunity.CSBD_Producto__c)) {
                        opportunity.AV_PF__c = product2Valor2.get(opportunity.CSBD_Producto__c);
                    }
                }
            }
        }
    }

    private static List<Opportunity> descartarOportunidadesNoCsbd(List<Opportunity> oportunidades) {
        List<Opportunity> oportunidadesCsbd = new List<Opportunity>();
        Map<Id, Schema.RecordTypeInfo> recordTypeInfos = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
        for (Opportunity oportunidad : oportunidades) {
        	//if (Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oportunidad.RecordTypeId).getDeveloperName().startsWith('CSBD_')) {
			if (recordTypeInfos.get(oportunidad.RecordTypeId).getDeveloperName().startsWith('CSBD_')) {
                oportunidadesCsbd.add(oportunidad);
            }
        }
        return oportunidadesCsbd;
    }

    private void horarioComercialSiNo(List<Opportunity> oportunidades) {
        Map<Id, Schema.RecordTypeInfo> recordTypeInfos = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
        // Recopilar los nombres de RecordType de las oportunidades
        Set<String> recordTypeNames = new Set<String>();
        for (Opportunity oportunidad : oportunidades) {
            recordTypeNames.add(recordTypeInfos.get(oportunidad.RecordTypeId).getName());
        }

        // Realizar una consulta SOQL para obtener los CC_Lista_Valores__c correspondientes
        Map<String, String> recordTypeNameToValueMap = new Map<String, String>();
        List<CC_Lista_Valores__c> lovList = [SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c
                                                WHERE RecordType.DeveloperName = 'CC_Valor'
                                                AND CC_Lista__r.Name = 'CSBD: Horarios comerciales por tipología'
                                                AND Name IN :recordTypeNames
                                                AND CC_Activa__c = TRUE];
        if(!lovList.isEmpty()){
            for (CC_Lista_Valores__c lov : lovList) {
                recordTypeNameToValueMap.put(lov.Name, lov.CC_Valor__c);
            }

            // Realizar una consulta SOQL para obtener los BusinessHours correspondientes
            Set<String> businessHourNames = new Set<String>(recordTypeNameToValueMap.values());
            Map<String, Id> businessHoursMap = new Map<String, Id>();
            List<BusinessHours> businessHoursList = [SELECT Id, Name FROM BusinessHours WHERE Name IN :businessHourNames];

            if(!businessHoursList.isEmpty()){
                for (BusinessHours bh : businessHoursList) {
                    businessHoursMap.put(bh.Name, bh.id);
                }

                // Recorrer las oportunidades y usar los mapas para establecer CSBD_HorarioComercial__c
                for (Opportunity oportunidad : oportunidades) {
                    String businessHourName = recordTypeNameToValueMap.get(recordTypeInfos.get(oportunidad.RecordTypeId).getName());
                        Id horarioComercial = businessHoursMap.get(businessHourName);
                            if (BusinessHours.isWithin(horarioComercial, CBK_UtilsDate.nowSYS())) {
                                oportunidad.CSBD_HorarioComercial__c = 'SI';
                            } else {
                                oportunidad.CSBD_HorarioComercial__c = 'NO';
                            }
                }
            }
        }
    }

}