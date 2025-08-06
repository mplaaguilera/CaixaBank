public with sharing class CC_Calculo_KPI_Tareas {

    private static Map<Case, Task> recuperarDatosCalculoKPI(List<Task> tareas, Set<String> tipoTareas) {

        // Extraer los IDs de casos de las tareas
        Set<Id> casoIds = new Set<Id>();
        for(Task tarea : tareas) {
            if(tarea.WhatId != null && tarea.WhatId.getSObjectType().getDescribe().getName() == 'Case' && tipoTareas.contains(tarea.Type)) {
                casoIds.add(tarea.WhatId);
            }
        }
        if(!casoIds.isEmpty()){
        // Recuperamos solo los casos
            Map<Id, Case> casosMap = new Map<Id, Case>([SELECT 
                            Id,
                            Subject, 
                            OwnerId, 
                            Account.AV_IndicadoresClientes__c, 
                            CC_Motivo_Derivacion__c, 
                            ContactId, 
                            CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c, 
                            CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c, 
                            SAC_EnvioParcial__c
                            FROM Case 
                        WHERE Id IN :casoIds]);

            // Crear mapa final
            Map<Case, Task> casos = new Map<Case, Task>();
            for(Id casoId : casosMap.keySet()) {
                for (Task tarea : tareas){
                    if(tarea.WhatId == casoId) {
                        casos.put(casosMap.get(casoId), tarea); //Se calculará el KPI a traves de la primera tarea que se procese para el caso (Bulk)
                        break;
                    }
                }
            }
            return casos;
        } else {
            return null;
        }
    }

    public static void rellenarKPI(List<Task> tareas){
        //Recogemos los tipos de tareas que se van a rellenar
        Set<String> tipoTareas = new Set<String>();

        List<CC_Lista_Valores__c> valoresOtrasOperativas = new List<CC_Lista_Valores__c>();
        List<CC_Lista_Valores__c> valoresDerivar = new List<CC_Lista_Valores__c>();
        
        List<CC_Lista_Valores__c> valores = [SELECT Id, Name, CC_Tipo_Tarea__c, CC_Valor__c, CC_Valor2__c, CC_AmbitoNull__c, CC_Lista__c, CC_Lista__r.Name FROM CC_Lista_Valores__c 
                WHERE CC_Lista__r.Name = 'Ámbitos cálculo KPI Derivar' 
                OR CC_Lista__r.Name = 'Ámbitos cálculo KPI Otras Operativas'
        ];

        for(CC_Lista_Valores__c valor : valores){
            tipoTareas.add(valor.CC_Tipo_Tarea__c);
            if(valor.CC_Lista__r.Name == 'Ámbitos cálculo KPI Derivar'){
                valoresDerivar.add(valor);
            } else if(valor.CC_Lista__r.Name == 'Ámbitos cálculo KPI Otras Operativas'){
                valoresOtrasOperativas.add(valor);
            }
        }

        System.debug('valores: ' + valores);

        //ESTRUCURA DE KPI - OPCION 1 - LOV
        //lISTA PRINCIPAL CON 2 LISTAS DE VALORES (VALORES DERIVAR Y VALORES OTRAS OPERATIVAS)
        //lISTA VALORES DERIVAR: CONTIENE LOS VALORES DE KPI RELACIONADOS CON EL AMBITO DE DERIVAR - ES NECESARIO QUE SE FIJE EN EL AMBITO TAREAS 
        //LISTA VALORES OTRAS OPERATIVAS: CONTIENE LOS VALORES DE KPI RELACIONADOS CON EL AMBITO DE OTRAS OPERATIVAS - NECESARIO QUE SE FIJE EN EL AMBITO TAREAS 
        //  SINO EN OTROS CAMPOS RELACIONADOS CON ESTE, POR EJEMPLO, CON EL CAMPO CC_ENTERCERNIVEL__C, O SIMPLEMENTE EN EL PROPIO CAMPO TIPO DE TAREA

        //Recuperamos los valores de los KPI
        Map<Case, Task> casos = recuperarDatosCalculoKPI(tareas, tipoTareas);
                
        //ESTRUCURA DE KPI - OPCION 2 - CUSTOM SETTINGS - CUSTOM METADATA
        //LOS VALORES DEL KPI SE ALMACENAN EN UN CUSTOM SETTING DE TIPO JERARQUICO O CUSTOM METADATA
        //3 CAMPOS:
        //1. Operativa del KPI
        //2. Valor del KPI (valor a asignar)
        //3. Tipo de KPI (tipo de la tarea)

        //List<CC_KPI_Tareas__mdt> kpiSettings = [SELECT Id, CC_Operativa__c, CC_Valor__c, CC_Tipo_Tarea__c, CC_AmbitoNull__c FROM CC_KPI_Tareas__mdt];

        //List<Task> tareasAMarcar = new List<Task>();

        if(casos != null && !casos.isEmpty()){
            for(Case caso : casos.keySet()){
                if(caso.SAC_EnvioParcial__c){
                    String ambitoActivo = caso.Account.AV_IndicadoresClientes__c != null && caso.Account.AV_IndicadoresClientes__c.contains('28') ? caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c : caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c;
                    String valorKPI = getLOV('Derivar', ambitoActivo, valoresDerivar, casos.get(caso).Type);
                    caso.CC_Motivo_Derivacion__c = valorKPI != null && valorKPI != '' ? valorKPI : caso.CC_Motivo_Derivacion__c;
                    caso.SAC_EnvioParcial__c = false;
                } else if (!caso.SAC_EnvioParcial__c){
                    String valorKPI = getLOV('Otras Operativas', null, valoresOtrasOperativas, casos.get(caso).Type);
                    caso.CC_Motivo_Derivacion__c = valorKPI != null && valorKPI != '' ? valorKPI : caso.CC_Motivo_Derivacion__c; 
                }
                //if(caso.CC_Motivo_Derivacion__c != null){
                //    tareasAMarcar.add(casos.get(caso));
                //}
            }

            /*if(!tareasAMarcar.isEmpty()){
                marcarTareaKPI(tareasAMarcar);
            }*/
            System.debug('caso motivo derivacion: ' + JSON.serializePretty(casos.keySet()));
            update new List<Case>(casos.keySet());
        }
    }

    private static String getLOV (String operativa, String ambitoActivo, List<CC_Lista_Valores__c> valores, String tipoTarea){

        //VAlOR DE EJEMPLO
        // 1. OPERATIVA = Derivar
        // 2. AMBITO ACTIVO = DOCUMENTACION
        // 3. VALORES POSIBLES DE CC_VALOR = Documentación, Solicitud Documentación, Gestionado con soporte
        // 4. TIPO DE TAREA (CC_TIPO_TAREA) = Solicitud Documentación
        // 5. VALOR DE RETORNO = Documentación

        if(operativa == null || valores == null || tipoTarea == null){
            return null;
        }

        for(CC_Lista_Valores__c valor : valores){
            if(valor.CC_Tipo_Tarea__c != tipoTarea) continue;

            if(operativa == 'Derivar'){
                if(valor.CC_Lista__r.Name == 'Ámbitos cálculo KPI Derivar' && (valor.CC_Valor__c == ambitoActivo || valor.CC_AmbitoNull__c == true) && valor.CC_Tipo_Tarea__c == tipoTarea){
                    return valor.CC_Valor2__c;
                }
            } else if (operativa == 'Otras Operativas'){
                if(valor.CC_Lista__r.Name == 'Ámbitos cálculo KPI Otras Operativas' && valor.CC_Tipo_Tarea__c == tipoTarea){
                    return valor.CC_Valor2__c;
                }
            }
        }

        return null;
    }

    //Creo que ya no es necesario marcar la tarea, ya que la tarea se rellena al crearse directamente y siempre será la ultima aunque no se complete la operativa
    /*private static void marcarTareaKPI(List<Task> tareas){
        // Recuperar extensiones existentes para todas las tareas
        Map<Id, CBK_Activity_Extension__c> extensiones = new Map<Id, CBK_Activity_Extension__c>();
        for(CBK_Activity_Extension__c ext : [SELECT Id, AV_ActivityId__c, CC_Tarea_Derivar__c 
                                            FROM CBK_Activity_Extension__c 
                                            WHERE AV_ActivityId__c IN :tareas]){
            extensiones.put(ext.AV_ActivityId__c, ext);
        }
        
        // Lista para almacenar extensiones a crear/actualizar
        List<CBK_Activity_Extension__c> paraUpsert = new List<CBK_Activity_Extension__c>();
        
        // Procesar cada tarea
        for(Task tarea : tareas){
            // Si la tarea ya tiene extensión
            if(extensiones.containsKey(tarea.Id)){
                CBK_Activity_Extension__c ext = extensiones.get(tarea.Id);
                // Solo actualizar si no tiene fecha asignada
                if(ext.CC_Tarea_Derivar__c == null){
                    ext.CC_Tarea_Derivar__c = CBK_UtilsDate.todaySYS();
                    paraUpsert.add(ext);
                }
            } else {
                // Crear nueva extensión si no existe
                paraUpsert.add(new CBK_Activity_Extension__c(
                    AV_ActivityId__c = tarea.Id,
                    CC_Tarea_Derivar__c = CBK_UtilsDate.todaySYS()
                ));
            }
        }
        
        // Ejecutar upsert si hay registros para procesar
        if(!paraUpsert.isEmpty()) upsert paraUpsert;
    }*/
}