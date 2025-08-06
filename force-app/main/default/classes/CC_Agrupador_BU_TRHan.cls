public class CC_Agrupador_BU_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((Map<Id, CC_Agrupador__c>)tp.oldMap, (Map<Id, CC_Agrupador__c>)tp.newMap, (List<CC_Agrupador__c>)tp.newList);
    }

    private void process(Map<Id, CC_Agrupador__c> mapOldObj, Map<Id, CC_Agrupador__c> mapNewObj, List<CC_Agrupador__c> listNewObj) {
        cierreAgrupadores(mapOldObj, mapNewObj);
        actualizarFechaAsociacion(mapOldObj, listNewObj);
    }

    private void cierreAgrupadores(Map<Id, CC_Agrupador__c> mapOldObj, Map<Id, CC_Agrupador__c> mapNewObj) {
        //Comprobar si se está cerrando alguno de los agrupadores modificados (no aplican
        //agrupadores de tipo Comunicación Informativa ni agrupadores sin notificación de cierre)
        Map<Id, CC_Agrupador__c> agrupadoresCerrados = recuperarAgrupadoresCerrados(mapOldObj, mapNewObj);

        if (!agrupadoresCerrados.isEmpty()) { //Hay agrupadores cerrados

            //Se prepara un mapa con las plantillas que cada agrupador necesita en función de sus casos
            Map<Id, List<CC_Agrupador_BU_TRHan.PlantillaRequerida>> plantillasRequeridas = new Map<Id, List<CC_Agrupador_BU_TRHan.PlantillaRequerida>>();

            for (AggregateResult aggregateResult : [SELECT CC_Agrupador_Id__c, CC_CanalNotifCli__c, CC_Idioma__c, RecordTypeId
                                                    FROM Case WHERE CC_NotIncidencia__c = '1' AND CC_Agrupador_Id__c IN :agrupadoresCerrados.keySet()
                                                    GROUP BY CC_Agrupador_Id__c, CC_CanalNotifCli__c, CC_Idioma__c, RecordTypeId]) {
                
                CC_Agrupador_BU_TRHan.PlantillaRequerida plantillaRequerida = new CC_Agrupador_BU_TRHan.PlantillaRequerida();
                plantillaRequerida.tipoCliente = Schema.SObjectType.Case.getRecordTypeInfosById().get((Id)aggregateResult.get('RecordTypeId')).getName();
                plantillaRequerida.canal = String.valueOf(aggregateResult.get('CC_CanalNotifCli__c'));
                plantillaRequerida.idioma = String.valueOf(aggregateResult.get('CC_Idioma__c'));
                plantillaRequerida.estado = EstadoPlantilla.SIN_ASOCIAR;

                String idAgrupadorCaso = String.valueOf(AggregateResult.get('CC_Agrupador_Id__c'));
                if (!plantillasRequeridas.containsKey(idAgrupadorCaso)) {
                    plantillasRequeridas.put(idAgrupadorCaso, new List<CC_Agrupador_BU_TRHan.PlantillaRequerida>{plantillaRequerida});
                } else {
                    plantillasRequeridas.get(idAgrupadorCaso).add(plantillaRequerida);
                }
            }

            //Se quitan del mapa las plantillas que SÍ tiene cada agrupador y se marcan las que no están revisadas
            for (CC_PlantillaAsociada__c plantillaAsociada : [SELECT CC_Agrupador__c, CC_Canal__c, CC_Idioma__c, CC_Tipo_Cliente__c, CC_Revisada__c FROM CC_PlantillaAsociada__c
                                                                WHERE CC_Agrupador__c IN :agrupadoresCerrados.keySet()]) {
                
                if (plantillasRequeridas.get(plantillaAsociada.CC_Agrupador__c) == null) continue;

                Integer indice = indicePlantilla(plantillaAsociada, plantillasRequeridas.get(plantillaAsociada.CC_Agrupador__c));
                
                if (indice != -1) {
                    List<PlantillaRequerida> listaPlantillas = plantillasRequeridas.get(plantillaAsociada.CC_Agrupador__c);
                    if (plantillaAsociada.CC_Revisada__c) {
                        listaPlantillas.remove(indice);
                    }
                    else {
                        listaPlantillas.get(indice).estado = EstadoPlantilla.SIN_REVISAR;
                    }
                }
            }

            //Los agrupadores que aún quedan en el mapa son aquellos que NO tienen alguna plantilla requerida por sus casos
            for (Id idAgrupador : plantillasRequeridas.keySet()) {
                List<PlantillaRequerida> plantillasRequeridasAgrupador = plantillasRequeridas.get(idAgrupador);
                if (plantillasRequeridasAgrupador.size() != 0) {
                    List<PlantillaRequerida> listaPlantillasSinRevisar = new List<PlantillaRequerida>();
                    List<PlantillaRequerida> listaPlantillasSinDefinir = new List<PlantillaRequerida>();
                    for (PlantillaRequerida pr : plantillasRequeridasAgrupador) {
                        if (pr.estado == EstadoPlantilla.SIN_REVISAR)
                            listaPlantillasSinRevisar.add(pr);
                        else
                            listaPlantillasSinDefinir.add(pr);
                    }

                    String textoError;
                    if (listaPlantillasSinDefinir.size() == 0) {
                        textoError = 'El agrupador no se puede cerrar porque no están revisadas todas las plantillas necesarias.';
                    }
                    else {
                        // Esto no debería saltar nunca, pero por si acaso. Quien sabe, quizás les da por borrar una plantilla a mano o algo
                        textoError = 'El agrupador no se puede cerrar porque no están definidas todas las plantillas necesarias.';
                        for (PlantillaRequerida pr : listaPlantillasSinDefinir) {
                            textoError += ' (' + pr.getNombreIdioma() + '/' + pr.canal + '/' + pr.tipoCliente + ')';
                        }
                    }

                    mapNewObj.get(idAgrupador).addError(textoError);
                }
            }
        }
    }
    private void actualizarFechaAsociacion(Map<Id, CC_Agrupador__c> mapOldObj, List<CC_Agrupador__c> listNewObj) {

        for (CC_Agrupador__c agrupador : listNewObj) {
            if (agrupador.recordTypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia') 
            && agrupador.CC_Numero_Casos__c != mapOldObj.get(agrupador.Id).CC_Numero_Casos__c && (agrupador.CC_Numero_Casos__c == 2 || agrupador.CC_Numero_Casos__c == 3) && agrupador.CC_Fecha_creacion_MAXIMO__c == null) {
                Datetime fechaAsociacion = System.now();
                agrupador.CC_Fecha_Asociacion_Caso__c = fechaAsociacion;
            }
        }

    }
    
    private enum EstadoPlantilla {SIN_ASOCIAR, SIN_REVISAR}
    private class PlantillaRequerida {
        public String tipoCliente {get;set;}
        public String canal {get;set;}
        public String idioma {get;set;}
        public EstadoPlantilla estado {get; set;}

        public String getNombreIdioma() {
            String result = '';
            for (Schema.PicklistEntry f : CC_PlantillaAsociada__c.CC_Idioma__c.getDescribe().getPicklistValues()) {
                if (f.getValue() == idioma) {
                    result = f.getLabel();
                    break;
                }
            }
            return result;
        }
    }

    private static Map<Id, CC_Agrupador__c> recuperarAgrupadoresCerrados(Map<Id, CC_Agrupador__c> mapOldObj, Map<Id, CC_Agrupador__c> mapNewObj) {
        //Comprobar si se está cerrando alguno de los agrupadores modificados (no aplican
        //comunicaciones informativas ni agrupadores sin notificación de cierre
        Map<Id, CC_Agrupador__c> agrupadoresCerrados = new Map<Id, CC_Agrupador__c>();
        
        for (Id idAgrupador : mapOldObj.keySet()) {
            if (mapNewObj.get(idAgrupador).RecordTypeId != CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Comunicacion_Informativa')
                && mapNewObj.get(idAgrupador).RecordTypeId != CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Comunicacion_Informativa_de_Campana')
                && mapNewObj.get(idAgrupador).RecordTypeId != CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Comunicacion_Informativa_de_Marca')
                && mapOldObj.get(idAgrupador).CC_Estado__c == 'Activo'
                && mapNewObj.get(idAgrupador).CC_Estado__c == 'Cerrado'
                && mapNewObj.get(idAgrupador).CC_Notificar_Clientes__c) {
                    agrupadoresCerrados.put(mapNewObj.get(idAgrupador).Id, mapNewObj.get(idAgrupador));
            }
        }
        return agrupadoresCerrados;
    }

    private static Integer indicePlantilla(CC_PlantillaAsociada__c plantillaAsociada, List<CC_Agrupador_BU_TRHan.PlantillaRequerida> plantillasRequeridas) {
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
}