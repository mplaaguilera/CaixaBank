/*
* Name: SAC_GenialBalanceador
* Copyright © 2024  CaixaBank
* 
* Proposito: Definir el mejor sistema de integración en base a la carga de trabajo actual y del porcentaje definido en SAC_GenialSettingsCanal__c
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR            DATE         Description
* 1.0            US976182       Borja Lavesiera     22/07/24      Creación 
*/
public with sharing class SAC_GenialBalanceador implements Queueable {
    /*Proposito: Coordina las llamadas a los demás métodos auxiliares
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR            DATE         Description
    * 1.0            US976182       Borja Lavesiera     22/07/24      Creación 
    */
    private Id reclamacionId;
    private String canal;
    private String description;

    public SAC_GenialBalanceador(Id reclamacionId, String canal, String description) {
        this.reclamacionId = reclamacionId;
        this.canal = canal;
        this.description = description;
    }
    // Método para encolar el trabajo con una firma única
    public static void enqueueJob(Id reclamacionId, String canal, String description) {
        AsyncOptions options = new AsyncOptions();
        options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                                    .addId(reclamacionId)
                                    .addString('GenialBalanceador')
                                    .build();
        try {
            System.enqueueJob(new SAC_GenialBalanceador(reclamacionId, canal, description), options);
        } catch (Exception e) {
            CBK_Log.error(e, 'Intento de ejecutar un Queueable duplicado');
        }
    }
    public class IntegrationConfig implements Comparable {
        public String name;
        public Integer value;

        public IntegrationConfig(String name, Integer value) {
            this.name = name;
            this.value = value;
        }

        public Integer compareTo(Object other) {
            IntegrationConfig otherConfig = (IntegrationConfig) other;
            return this.value - otherConfig.value; // Orden ascendente
        }
    }
    public void execute(QueueableContext context) {
        try {
            // Obtener la configuración del balanceador
            Map<String, Integer> balanceadorMap = obtenerConfiguracionBalanceador(canal);
            SAC_GenialSettingsCanal__c settings = SAC_GenialSettingsCanal__c.getInstance(canal);

            if (balanceadorMap != null) {
                // Verificar si alguno de los adjuntos supera el límite introducido en el setting
                
                Decimal sizeLimit = (Decimal)settings.SAC_Tamano_Maximo_Attach__c;
                Boolean limiteAdjuntos = verificarSizeAdjuntos(reclamacionId, sizeLimit);
                String bestIntegration = null;
                if (limiteAdjuntos) {
                    bestIntegration = String.isNotBlank(settings.SAC_Integracion_Adjuntos_Pesados__c) ? 
                                      settings.SAC_Integracion_Adjuntos_Pesados__c : 'Azure';
                    //falta caso si el max de tamaño es superado y no hay integración para desviarlo, hay que volverlo a caso normal(resetear a null GenialEstado y owner pendiente de asignar)
                } else {

                    List<AggregateResult> casosAgrupadosPorTipo = ejecutarConsultaSOQL();

                    Map<String, Integer> casosPorTipo = procesarResultadosConsulta(casosAgrupadosPorTipo);

                    Map<String, Double> cargaActual = calcularCargaActual(casosPorTipo, balanceadorMap);

                    bestIntegration = determinarMejorIntegracion(cargaActual, balanceadorMap, casosPorTipo);
                }
                // Ejecutamos programarEnviar con la integración mas óptima
                if (!String.isBlank(bestIntegration)) {
                    SAC_GenialUtils.programarEnviar(reclamacionId, canal, description, bestIntegration);
                } else {
                    CBK_Log.error('El sistema de integracion IA no es reconocido' + bestIntegration);
                }
            }
        } catch (Exception e) {
            // Manejar la excepción general
            CBK_Log.error('The following exception has occurred: ' + e.getMessage());
        }
    }
    /*Proposito: Obtiene Spliteado las distintas opciones de integraciónes disponibles y sus porcentajes
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR            DATE         Description
    * 1.0            US976182       Borja Lavesiera     22/07/24      Creación 
    */
    @TestVisible
    private static Map<String, Integer> obtenerConfiguracionBalanceador(String canal) {
        SAC_GenialSettingsCanal__c settings = SAC_GenialSettingsCanal__c.getInstance(canal);
        if ((settings.SAC_IAactiva__c || settings.SAC_shadow__c) && settings.SAC_Balanceador_Integracion__c != null) {
            String balanceadorConfig = settings.SAC_Balanceador_Integracion__c;

            Map<String, Integer> balanceadorMap = new Map<String, Integer>();
            for (String config : balanceadorConfig.split(';')) {
                List<String> configParts = config.split(',');
                balanceadorMap.put(configParts[0], Integer.valueOf(configParts[1]));
            }
            return balanceadorMap;
        }
        return null;
    }
    /*Proposito: Control del tamaño de adjuntos en la fase previa a la integración, si supera límite va por Azure 
    o por el sistema definido en el campo SAC_Integracion_Adjuntos_Pesados
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR            DATE         Description
    * 1.0            US976182       Borja Lavesiera     24/07/24      Creación 
    */
    @TestVisible
    private static Boolean verificarSizeAdjuntos(Id casoId, Decimal sizeMaximoAdjuntoMB) {
        List<ContentDocumentLink> doculink = [SELECT Id, ContentDocumentId 
                                              FROM ContentDocumentLink 
                                              WHERE LinkedEntityId = :casoId];
        List<String> idsAttachments = new List<String>();
        for (ContentDocumentLink d : doculink) {
            idsAttachments.add(d.ContentDocumentId);
        }
        List<ContentVersion> docuversions = [SELECT Id, ContentDocumentId, ContentSize, IsLatest 
                                             FROM ContentVersion 
                                             WHERE ContentDocumentId IN :idsAttachments AND IsLatest = true];
        final Decimal bytesToMb = 1024 * 1024;
        for (ContentVersion d : docuversions) {
            Decimal sizeMB = d.ContentSize / bytesToMb; // Convertir bytes a MB
            if (sizeMB > sizeMaximoAdjuntoMB) {                
                return true;
            }
        }
        return false;
    }
    /*Proposito: Consulta SOQL para obtener volumetría de casos Gestionados por cada tipo de Sistema IA
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR            DATE         Description
    * 1.0            US976182       Borja Lavesiera     22/07/24      Creación 
    */
    private static List<AggregateResult> ejecutarConsultaSOQL() {

        return [SELECT SAC_Tipo_integracion_IA__c, COUNT(Id)
                FROM Case
                WHERE CreatedDate = TODAY AND SAC_Tipo_integracion_IA__c != null
                WITH SECURITY_ENFORCED
                GROUP BY SAC_Tipo_integracion_IA__c];
    }
    /*Proposito: Devuelve un mapa de los casos clasificados por Tipo IA
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR            DATE         Description
    * 1.0            US976182       Borja Lavesiera     22/07/24      Creación 
    */
    private static Map<String, Integer> procesarResultadosConsulta(List<AggregateResult> casosAgrupadosPorTipo) {
        Map<String, Integer> casosPorTipo = new Map<String, Integer>();
        for (AggregateResult ar : casosAgrupadosPorTipo) {
            String tipo = (String) ar.get('SAC_Tipo_integracion_IA__c');
            Integer count = Integer.valueOf(ar.get('expr0'));
            casosPorTipo.put(tipo, count);
        }
        return casosPorTipo;
    }
    /*Proposito: Cálcula la carga actual de casos de cada tipo para tenerlo en cuenta en balanceador
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR            DATE         Description
    * 1.0            US976182       Borja Lavesiera     22/07/24      Creación 
    */
    private static Map<String, Double> calcularCargaActual(Map<String, Integer> casosPorTipo, Map<String, Integer> balanceadorMap) {
        Map<String, Double> cargaActual = new Map<String, Double>();
        Integer totalCasos = 0;
        // Calculamos volumetría total
        for (String tipo : balanceadorMap.keySet()) {
            if (casosPorTipo.containsKey(tipo)) {
                totalCasos += casosPorTipo.get(tipo);
            }
        }
        // Calculamos volumetría por cada tipo de integración
        for (String tipo : balanceadorMap.keySet()) {
            if (casosPorTipo.containsKey(tipo)) {
                cargaActual.put(tipo, (casosPorTipo.get(tipo) / (Double) totalCasos) * 100);
            } else {
                cargaActual.put(tipo, 0.0);
            }
        }
        return cargaActual;
    }
    /*Proposito: Determina a que integración lo mandamos en función de la carga y el porcentaje definido
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR            DATE         Description
    * 1.0            US976182       Borja Lavesiera     22/07/24      Creación 
    */
    @TestVisible
    private static String determinarMejorIntegracion(Map<String, Double> cargaActual, Map<String, Integer> balanceadorMap, Map<String, Integer> casosPorTipo) {
        String bestIntegration = null;
        // Si solo hay un sistema de integración, manejarlo directamente
        if (balanceadorMap.size() == 1) {
            bestIntegration = balanceadorMap.keySet().iterator().next();
        }
        // Determinar el tipo de integración menos cargado
        for (String tipo : balanceadorMap.keySet()) {
            if (cargaActual.get(tipo) < balanceadorMap.get(tipo)) {
                bestIntegration = tipo;
                break;
            }
        }
        // Si todos los sistemas de integración están cargados por encima de su porcentaje, devolver el de menor carga
        if (bestIntegration == null) {
            Double minCarga = 100.0;
            for (String tipo : cargaActual.keySet()) {
                if (cargaActual.get(tipo) < minCarga) {
                    minCarga = cargaActual.get(tipo);
                    bestIntegration = tipo;
                }
            }
        }
        //Si no hay casos que comparar para volumtería nos quedamos con el de mayor porcentaje
        if (casosPorTipo.isEmpty()) {
            List<IntegrationConfig> sortedList = new List<IntegrationConfig>();
            for (String key : balanceadorMap.keySet()) {
                sortedList.add(new IntegrationConfig(key, balanceadorMap.get(key)));
            }
            sortedList.sort();
            if (!sortedList.isEmpty()) {
                bestIntegration = sortedList[sortedList.size() - 1].name;
            }
        }
        return bestIntegration;
    }
}