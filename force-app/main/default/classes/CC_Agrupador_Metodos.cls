public class CC_Agrupador_Metodos {
    
    @InvocableMethod(label='CC_Agrupador_Metodos' description='Crear comunicaciones del agrupador')
    public static void crearComunicacionesAgrupador (List<Id> oAgrupadores){
        // TODO(SANTANA): Eliminar esta función de donde sea que se esté llamando
    }

    private class PlantillaRequerida {
        public String tipoCliente {get;set;}
        public String canal {get;set;}
        public String idioma {get;set;}
        public String cuerpo {get;set;}
        public String plantillaId {get;set;}
      
        public String carpeta {get;set;}
        public String nombrePlantilla {get;set;}
    }

    private static Integer indicePlantilla(CC_PlantillaAsociada__c plantillaAsociada, List<PlantillaRequerida> plantillasRequeridas) {
        for (Integer indice = 0; indice < plantillasRequeridas.size(); ++indice) {
            PlantillaRequerida plantillaRequerida = plantillasRequeridas[indice];
            if ((plantillaRequerida.tipoCliente == plantillaAsociada.CC_Tipo_Cliente__c)
             && (plantillaRequerida.canal == plantillaAsociada.CC_Canal__c)
             && (plantillaRequerida.idioma == plantillaAsociada.CC_Idioma__c))
             {
                 return indice;
             }
        }
        return -1;
    }

    public static void crearPlantillasNecesarias (Set<Id> idAgrupadores) {
        //Se prepara un mapa con las plantillas que cada agrupador necesita en función de sus casos
        Map<Id, List<PlantillaRequerida>> plantillasRequeridas = new Map<Id, List<PlantillaRequerida>>();
		
        //Solución Too many SOQL queries
        List<AggregateResult> oAggregateResult = [SELECT CC_Agrupador_Id__c, CC_CanalNotifCli__c, CC_Idioma__c, RecordTypeId
                                		   		  FROM Case WHERE CC_NotIncidencia__c = '1' AND CC_Agrupador_Id__c IN :idAgrupadores 
                                		   		  AND CC_Agrupador_Id__r.RecordType.DeveloperName = 'CC_Incidencia' WITH SECURITY_ENFORCED 
                                		   		  GROUP BY CC_Agrupador_Id__c, CC_CanalNotifCli__c, CC_Idioma__c, RecordTypeId ];
        for (AggregateResult aggregateResult : oAggregateResult) {
            PlantillaRequerida plantillaRequerida = new PlantillaRequerida();
            plantillaRequerida.tipoCliente = Schema.SObjectType.Case.getRecordTypeInfosById().get((Id)aggregateResult.get('RecordTypeId')).getName();
            plantillaRequerida.canal = String.valueOf(aggregateResult.get('CC_CanalNotifCli__c'));
            plantillaRequerida.idioma = String.valueOf(aggregateResult.get('CC_Idioma__c'));

            String idAgrupadorCaso = String.valueOf(AggregateResult.get('CC_Agrupador_Id__c'));
            if (!plantillasRequeridas.containsKey(idAgrupadorCaso)) {
                plantillasRequeridas.put(idAgrupadorCaso, new List<PlantillaRequerida>{plantillaRequerida});
            } else {
                plantillasRequeridas.get(idAgrupadorCaso).add(plantillaRequerida);
            }
        }

        //Se quitan del mapa las que ya existen y se guardan en una lista las que no necesitamos
        List<CC_PlantillaAsociada__c> plantillasInnecesarias = new List<CC_PlantillaAsociada__c>();
        
        //Solución Too many SOQL queries
        List<CC_PlantillaAsociada__c> oPlantillaAsociada = [SELECT CC_Agrupador__c, CC_Canal__c, CC_Idioma__c, CC_Tipo_Cliente__c, CC_Revisada__c 
                                                            FROM CC_PlantillaAsociada__c
                                                            WHERE CC_Agrupador__c IN :idAgrupadores WITH SECURITY_ENFORCED];
        for (CC_PlantillaAsociada__c plantillaAsociada : oPlantillaAsociada) {
            List<PlantillaRequerida> listaPlantillas = plantillasRequeridas.get(plantillaAsociada.CC_Agrupador__c);
            if (listaPlantillas == null){
                continue;
            }

            Integer indice = indicePlantilla(plantillaAsociada, listaPlantillas);
            if (indice != -1) {
                listaPlantillas.remove(indice);
            }
            else {
                plantillasInnecesarias.add(plantillaAsociada);
            }
        }

        // Eliminamos las plantillas innecesarias
        if (Schema.sObjectType.CC_PlantillaAsociada__c.isDeletable()) {
            delete plantillasInnecesarias;
        }

        // Recogemos los cuerpos de las plantillas de los metadatos
        Set<String> canalSet = new Set<String>();
        Set<String> idiomaSet = new Set<String>();
        Set<String> tipoClienteSet = new Set<String>();
        List<String> folderList = new List<String>();
        List<String> templateList = new List<String>();
        CC_ConfigNotifCliente__mdt configuracionEncontrada = new CC_ConfigNotifCliente__mdt();
        List<CC_ConfigNotifCliente__mdt> lstConfiguraciones = new List<CC_ConfigNotifCliente__mdt>();

        for (Id idAgrupador : plantillasRequeridas.keySet()) {
            for (PlantillaRequerida plantillaRequerida : plantillasRequeridas.get(idAgrupador)) {
                if (!canalSet.contains(plantillaRequerida.canal)) {
                    canalSet.add(plantillaRequerida.canal);
                }
                if (!canalSet.contains(plantillaRequerida.idioma)) {
                    idiomaSet.add(plantillaRequerida.idioma);
                }
                if (!canalSet.contains(plantillaRequerida.tipoCliente)) {
                    tipoClienteSet.add(plantillaRequerida.tipoCliente);
                }
            }
        }

        lstConfiguraciones = [SELECT CC_Canal__c, CC_Idioma__c, CC_Tipo_Cliente__c, CC_Cuerpo__c, CC_Plantilla__c, CC_Carpeta__c FROM CC_ConfigNotifCliente__mdt WHERE CC_Proceso__c = 'CC_NotIncidencia' AND CC_Canal__c IN :canalSet AND CC_Idioma__c IN :idiomaSet AND CC_Tipo_Cliente__c IN :tipoClienteSet AND CC_Activa__c = true WITH SECURITY_ENFORCED];

        for (Id idAgrupador : plantillasRequeridas.keySet()) {

            for (PlantillaRequerida plantillaRequerida : plantillasRequeridas.get(idAgrupador)) {
                // SOQL de metadatos. No cuenta para el límite de Apex
                configuracionEncontrada = null;
                for (CC_ConfigNotifCliente__mdt configuracion : lstConfiguraciones) {
                    if (configuracion.CC_Canal__c == plantillaRequerida.canal && configuracion.CC_Idioma__c == plantillaRequerida.idioma && configuracion.CC_Tipo_Cliente__c == plantillaRequerida.tipoCliente) {
                        configuracionEncontrada = configuracion;
                        break;
                    }
                }

                if (configuracionEncontrada != null) {
                    if (configuracionEncontrada.CC_Canal__c != 'Email') {
                        plantillaRequerida.cuerpo = configuracionEncontrada.CC_Cuerpo__c;
                    } else {
                        plantillaRequerida.carpeta = configuracionEncontrada.CC_Carpeta__c;
                        plantillaRequerida.nombrePlantilla = configuracionEncontrada.CC_Plantilla__c;
                        folderList.add(configuracionEncontrada.CC_Carpeta__c);
                        templateList.add(configuracionEncontrada.CC_Plantilla__c);
                    }
                }
            }
        }
        
        // Recogemos los cuerpos de los emails que nos faltan
        if (folderList.size() > 0 && templateList.size() > 0) {
            List<EmailTemplate> emailTemplateList = [SELECT HtmlValue, Folder.DeveloperName, Name, Id FROM EmailTemplate WHERE Folder.DeveloperName IN :folderList AND Name IN :templateList WITH SECURITY_ENFORCED];
            for (Id idAgrupador : plantillasRequeridas.keySet()) {
                for (PlantillaRequerida plantillaRequerida : plantillasRequeridas.get(idAgrupador)) {
                    if (plantillaRequerida.canal != 'Email'){
                        continue;
                    } 

                    for (EmailTemplate template : emailTemplateList) {
                        Folder carpeta = template.Folder;
                        if (carpeta.DeveloperName == plantillaRequerida.carpeta && template.Name == plantillaRequerida.nombrePlantilla) {
                            //Id template.Id
                            plantillaRequerida.plantillaId = template.Id;
                            plantillaRequerida.cuerpo = template.HtmlValue;
                            break;
                        }
                    }
                }
            }
        }

        // Crear las plantillas de verdad
        List<CC_PlantillaAsociada__c> listaPlantillas = new List<CC_PlantillaAsociada__c>();
        for (Id idAgrupador : plantillasRequeridas.keySet()) {
            for (PlantillaRequerida plantillaRequerida : plantillasRequeridas.get(idAgrupador)) {
                listaPlantillas.add(new CC_PlantillaAsociada__c(
                    CC_Agrupador__c = idAgrupador,
                    CC_Canal__c = plantillaRequerida.canal,
                    CC_Idioma__c = plantillaRequerida.idioma,
                    CC_Tipo_Cliente__c = plantillaRequerida.tipoCliente,
                    CC_Revisada__c = false,
                    CC_CuerpoNotificacion__c = plantillaRequerida.cuerpo,
                    CC_PlantillaId__c = plantillaRequerida.plantillaId
                ));
            }
        }

        if(Schema.sObjectType.CC_PlantillaAsociada__c.fields.CC_Agrupador__c.isCreateable()){
            insert listaPlantillas;
        }
    }
}