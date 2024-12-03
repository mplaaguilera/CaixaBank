public with sharing class CSBD_Control_Duplicados {

    public static void controlDuplicados(List<Id> idOportunidades) {
        //Recuperar criterios del control de duplicados
        List<CSBD_Control_Duplicados__mdt> configsControlDuplicados = [SELECT DeveloperName, CSBD_Empresa_Proveedora__c, CSBD_Solo_Circuito_No_Online__c,
                                                                        CSBD_Campo1__c, CSBD_Campo2__c, CSBD_Campo3__c, CSBD_Minutos__c
                                                                        FROM CSBD_Control_Duplicados__mdt WHERE CSBD_Activo__c = true];

        Map<String, CSBD_Control_Duplicados__mdt> configsControlDuplicadosMapa = new Map<String, CSBD_Control_Duplicados__mdt>();
        for (CSBD_Control_Duplicados__mdt configControlDuplicados : configsControlDuplicados) {
            configsControlDuplicadosMapa.put(configControlDuplicados.DeveloperName + '|' + configControlDuplicados.CSBD_Empresa_Proveedora__c, configControlDuplicados);
        }

        //Identificar las oportunidades duplicadas (cumplen los criterios definidos en el mdt)
        List<Opportunity> oportunidadesConDuplicados = new List<Opportunity>();
        List<Opportunity> oportunidadesDuplicadas = new List<Opportunity>();

        DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('Opportunity').getDescribe();
        String describeResultName = describeResult.getName();
        List<String> fieldNames = new List<String>(describeResult.fields.getMap().keySet());
        String fieldNamesJoined = String.join(fieldNames, ', ');
        String queryFinal = 'SELECT ' + fieldNamesJoined + ' FROM ' +  describeResultName + ' WHERE Id IN :idOportunidades';
        List<Opportunity> oportunidades = Database.query(String.escapeSingleQuotes(queryFinal));

        for (Opportunity oportunidad : oportunidades) {
            CSBD_Control_Duplicados__mdt configControlDuplicadosOportunidad = null;
            String recordTypeOportunidad = CC_MetodosUtiles.getRecordTypeDeveloperNameFromId('Opportunity', oportunidad.RecordTypeId);
            if (configsControlDuplicadosMapa.containsKey(recordTypeOportunidad + '|' + oportunidad.CSBD_Empresa_Proveedora__c)) {
                configControlDuplicadosOportunidad = configsControlDuplicadosMapa.get(recordTypeOportunidad + '|' + oportunidad.CSBD_Empresa_Proveedora__c);
            } else if (configsControlDuplicadosMapa.containsKey(recordTypeOportunidad + '|Todas')) {
                configControlDuplicadosOportunidad = configsControlDuplicadosMapa.get(recordTypeOportunidad + '|Todas');
            }

            if (configControlDuplicadosOportunidad != null) {
                if (!configControlDuplicadosOportunidad.CSBD_Solo_Circuito_No_Online__c || !oportunidad.CSBD_Circuito_Contratacion_Online__c) {
                    @SuppressWarnings('PMD.OperationWithLimitsInLoop') //La consulta es distinta para cada oportunidad
                    List<Opportunity> oportunidadesAnteriores = Database.query(controlDuplicadosSoql(oportunidad, configControlDuplicadosOportunidad));
                    if (!oportunidadesAnteriores.isEmpty()) {
                        //Solicitud cumple los criterios para considerarse duplicada
                        oportunidadesConDuplicados.add(oportunidad);
                        oportunidadesDuplicadas.addAll(oportunidadesAnteriores);
                    }
                }
            }
        }

        Set<Id> idOportunidadesDuplicadas = new Set<Id>();

        //Rechazo de las oportunidades duplicadas
        for (Opportunity oportunidadDuplicada : oportunidadesDuplicadas) {
            Map<String, Object> campos = new Map<String, Object>{'CSBD_Con_Duplicados__c' => false};
            CSBD_Opportunity.cerrarOportunidad(oportunidadDuplicada.Id, 'Rechazada', 'Duplicada', campos);
            //Se guardan los Ids de las oportunidades duplicadas
            if(oportunidadDuplicada.CSBD_Alta_omnichannel__c){
                idOportunidadesDuplicadas.add(oportunidadDuplicada.Id);
            }
        }
        //Se solicita la baja a omnichannel de las oportunidades duplicadas
        if(!idOportunidadesDuplicadas.isEmpty()) {
            CSBD_GestorOportunidad.desactivarGestorOportunidad(idOportunidadesDuplicadas); 
        }
        //Se marca el campo "Con duplicados" de las nuevas oportunidad con duplicados
        for (Opportunity oportunidadConDuplicados : oportunidadesConDuplicados) {
            oportunidadConDuplicados.CSBD_Con_Duplicados__c = true;
        }
        update oportunidadesConDuplicados;
    }

    private static String controlDuplicadosSoql(Opportunity oportunidad, CSBD_Control_Duplicados__mdt configControlDuplicados) {
        String querySoql = 'SELECT Id, CSBD_Alta_omnichannel__c FROM Opportunity WHERE Id != \'' + oportunidad.Id + '\' AND RecordTypeId = \'' + oportunidad.RecordTypeId + '\'';
        if (String.isNotBlank(configControlDuplicados.CSBD_Empresa_Proveedora__c)) {
            querySoql += ' AND CSBD_Empresa_Proveedora__c = \'' + oportunidad.CSBD_Empresa_Proveedora__c + '\' AND IsClosed = FALSE';
        }

        //Valor campos
        querySoql += soqlComparacionCampos(configControlDuplicados, 'CSBD_Campo1__c', oportunidad);
        querySoql += soqlComparacionCampos(configControlDuplicados, 'CSBD_Campo2__c', oportunidad);
        querySoql += soqlComparacionCampos(configControlDuplicados, 'CSBD_Campo3__c', oportunidad);

        //Fecha
        Datetime fecha = oportunidad.CreatedDate;
        fecha = fecha.addMinutes(-(Integer)configControlDuplicados.CSBD_Minutos__c);
        querySoql += ' AND CreatedDate > ' + fecha.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        
        return querySoql;
    }

    private static String soqlComparacionCampos(CSBD_Control_Duplicados__mdt configControlDuplicados, String configControlDuplicadosCampo, Opportunity oportunidad) {
        String retorno = '';
        String nombreCampoOportunidad = (String)configControlDuplicados.get(configControlDuplicadosCampo);
        if (String.isNotBlank(nombreCampoOportunidad)) {
            Object valorCampoOportunidad = oportunidad.get(nombreCampoOportunidad);
            String valorCampoOportunidadString;

            Boolean esCheckbox = valorCampoOportunidad instanceof Boolean;
            if (esCheckbox) {

                if ((Boolean)valorCampoOportunidad) {
                    valorCampoOportunidadString = 'TRUE';
                } else {
                    valorCampoOportunidadString = 'FALSE';
                }
            } else {
                valorCampoOportunidadString = '\'' + (String)valorCampoOportunidad + '\'';
            }
            retorno += ' AND ' + nombreCampoOportunidad + ' = ' + valorCampoOportunidadString;

            if (!esCheckbox) {
                retorno += ' AND ' + nombreCampoOportunidad + ' != NULL';
            } 
        }

        return retorno;
    }
}