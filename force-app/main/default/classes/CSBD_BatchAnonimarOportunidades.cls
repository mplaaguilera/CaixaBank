public with sharing class CSBD_BatchAnonimarOportunidades implements Database.Batchable<sObject>, Database.Stateful{

    Map<String, List<CSBD_ParametrosAnonimizar__c>> parametrosMapa;
    List<CSBD_ParametrosAnonimizar__c> parametros;
    String camposContact = '';

    public CSBD_BatchAnonimarOportunidades() {}

    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Consulta para obtener los registros que deseas procesar
        List<CSBD_ParametrosBatch__c> cd = [SELECT CSBD_HorasParaBatch__c FROM CSBD_ParametrosBatch__c LIMIT 1];

        Map<String, Schema.RecordTypeInfo> mapa = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
        Set<String> recordTypeIds = new Set<String>();

        for (String rt : mapa.keySet()) {
            if (rt.startsWith('CSBD_')) {
                recordTypeIds.add('\'' + mapa.get(rt).getRecordTypeId() + '\'');
            }
        }

        String recordTypeIdsStr = String.join(recordTypeIds, ',');

        Integer horas = 0;
        if(!cd.isEmpty()){ 
            horas = Integer.valueOf(cd[0].CSBD_HorasParaBatch__c); 
        }
        DateTime myDate = null;
        myDate = System.now().addHours(-horas);
        String startTimeFormat = myDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String estado = 'Rechazada';

        parametros = [SELECT CSBD_Campo__c, CSBD_Objeto__c FROM CSBD_ParametrosAnonimizar__c];
        parametrosMapa = new Map<String, List<CSBD_ParametrosAnonimizar__c>>{
            'Opportunity' => new List<CSBD_ParametrosAnonimizar__c>(),
            'Contact' => new List<CSBD_ParametrosAnonimizar__c>()
        };

        String camposQuery = '';
        if(!parametros.isEmpty()){
            List<String> camposAnonimizar = new List<String>();
            List<String> camposAnonimizarContact = new List<String>();
            for(CSBD_ParametrosAnonimizar__c pa : parametros){
                if (pa.CSBD_Objeto__c == 'Opportunity') {
                    camposAnonimizar.add(pa.CSBD_Campo__c);
                    parametrosMapa.get('Opportunity').add(pa);
                }else if(pa.CSBD_Objeto__c == 'Contact'){
                    camposAnonimizarContact.add(pa.CSBD_Campo__c);
                    parametrosMapa.get('Contact').add(pa);
                }
            }
            camposAnonimizar.add('CSBD_ContactoTitular1__c');
            camposAnonimizar.add('CSBD_ContactoTitular2__c');
            camposAnonimizar.add('CSBD_MenorEdad__c');

            camposQuery = camposAnonimizar.isEmpty() ? '' : ', ' + String.join(camposAnonimizar, ', ');
            camposContact = camposAnonimizarContact.isEmpty() ? '' : ', ' + String.join(camposAnonimizarContact, ', ');
        }

        String query = 'SELECT Id ' + camposQuery + ' FROM Opportunity WHERE CSBD_Fecha_vencimiento_alta__c <= ' + startTimeFormat + 
        ' AND CSBD_Contact__r.AV_NumPerso__c = null AND CSBD_Anonimizada__c = false AND CSBD_Estado__c = ' + '\''+ estado + '\'' +
        ' AND RecordTypeId IN (' + recordTypeIdsStr + ')';

        /*  QUERY DINAMICA POR CUSTOM SETTING ELIMINADA POR SEGURIDAD A QUE NO SE INTRODUZCAN CORRECTAMENTE LOS VALORES
        List<CSBD_QueryDinamica__c> wheres = [SELECT CSBD_WhereCondition__c, CSBD_FieldCondition__c, CSBD_Operador__c, CSBD_TipoBatch__c FROM CSBD_QueryDinamica__c WHERE CSBD_TipoBatch__c = 'Anonimizar'];
        if(!wheres.isEmpty()){
            for (CSBD_QueryDinamica__c variable : wheres) {
                query += ' AND ' + variable.CSBD_FieldCondition__c + variable.CSBD_Operador__c + variable.CSBD_WhereCondition__c;
            }
        }*/

        return Database.getQueryLocator(query);
                
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        // Lógica de procesamiento para cada lote de registros
        if(!parametros.isEmpty()){
            List<Opportunity> opplist =new List<Opportunity>();
            Boolean camposValidos = false; // Controla si algún campo tiene valor

            Set<Id> ids = new Set<Id>();
            for(Opportunity oportunidad: scope){
                ids.add(oportunidad.CSBD_ContactoTitular1__c);
                ids.add(oportunidad.CSBD_ContactoTitular2__c);
                ids.add(oportunidad.CSBD_MenorEdad__c);
            }

            if(ids.contains(null)){
                ids.remove(null);
            }

          /*  List<String> contactosList = new List<String>();
            for (Id rtId : ids) {
                contactosList.add('\'' + rtId + '\'');
            }
            String contactosIds = String.join(contactosList, ',');*/

            List<Contact> contactos;
            Map<Id, Contact> titulares;
            if(!ids.isEmpty()){
                Map<String, Object> bindParams = new Map<String, Object>{
                    'ids' => ids
                };
                contactos = Database.queryWithBinds('SELECT Id ' + camposContact + ' FROM Contact WHERE Id IN: ids', bindParams, AccessLevel.USER_MODE);
                titulares = new Map<Id, Contact>(contactos);
                contactos = new List<Contact>();
            }

            for (Opportunity opp : scope) {
                // Realiza la lógica de actualización o procesamiento aquí
                for(CSBD_ParametrosAnonimizar__c campo : parametrosMapa.get('Opportunity')){
                    if (opp.get(campo.CSBD_Campo__c) != null) { 
                        opp.put(campo.CSBD_Campo__c, getValorAnonimizado(campo.CSBD_Campo__c));
                    }
                }

                if(titulares != null && (titulares?.containsKey(opp.CSBD_ContactoTitular1__c) || titulares?.containsKey(opp.CSBD_ContactoTitular2__c) || titulares?.containsKey(opp.CSBD_MenorEdad__c))){
                    for(CSBD_ParametrosAnonimizar__c campo : parametrosMapa.get('Contact')){
                        Contact titular1 = titulares.get(opp.CSBD_ContactoTitular1__c);
                        if(titular1?.get(campo.CSBD_Campo__c) != null){
                            titular1.put(campo.CSBD_Campo__c, getValorAnonimizado(campo.CSBD_Campo__c));
                            if(!contactos.contains(titular1)){
                                contactos.add(titular1);
                            }
                        }

                        Contact titular2 = titulares.get(opp.CSBD_ContactoTitular2__c);
                        if(titular2?.get(campo.CSBD_Campo__c) != null){
                            titular2.put(campo.CSBD_Campo__c, getValorAnonimizado(campo.CSBD_Campo__c));
                            if(!contactos.contains(titular2)){
                                contactos.add(titular2);
                            }
                        }

                        Contact menorEdad = titulares.get(opp.CSBD_MenorEdad__c);
                        if(menorEdad?.get(campo.CSBD_Campo__c) != null){
                            menorEdad.put(campo.CSBD_Campo__c, getValorAnonimizado(campo.CSBD_Campo__c));
                            if(!contactos.contains(menorEdad)){
                                contactos.add(menorEdad);
                            }
                        }
                    }
                }

                opp.CSBD_Anonimizada__c = true;
            }

            // Actualiza los registros en la base de datos
            update scope;
            

            if(contactos != null && !contactos.isEmpty()){
                update contactos;
            }
        }
    }

    public String getValorAnonimizado(String nombreCampo){
        String anonimizarPatron = '******';
        //Campos tipo EMAIL
        Set<String> nombreCamposEmail = new Set<String>();
        nombreCamposEmail.add('Email');
        nombreCamposEmail.add('CSBD_Email_Solicitud__c');

        //CAMPOS tipo REDUDICO
        Set<String> nombreCamposReducido = new Set<String>();
        nombreCamposReducido.add('CBSD_Nacionalidad__c');
        
        if(nombreCamposEmail.contains(nombreCampo)){
            anonimizarPatron = 'xxxxxx@xxxxx.xxx';
        }else if(nombreCamposReducido.contains(nombreCampo)){
            anonimizarPatron = '***';
        }

        return anonimizarPatron;         
    }
    
    public void finish(Database.BatchableContext BC) {
        // Método opcional que se ejecuta después de que el proceso de lotes ha terminado
        CBK_Log.debug('Fin batch anonimizar oportunidades CSBD',logginglevel.INFO);
    }
}