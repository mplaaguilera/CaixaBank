public with sharing class CC_Agrupador {

    //Cierre de agrupadores (se invoca desde process builder)
    @InvocableMethod(label='CC_Agrupador Cierre' description='Automatizaciones al cerrar un Agrupador')
    public static void cierreAgrupador (List<Id> idAgrupadores) {
        //Marc Pla, 29/12/19, se rehace el método para corregir varias incidencias y simplificar la lógica

        // Si utilizamos este if necesitaremos volver a poner @future en los métodos de envio de notificaciones
        
            //Comportamiento anterior
            //CC_Agrupador_OLD.cierreAgrupador(idAgrupadores);

            //Se acumulan los registros a cerrar en las siguientes listas
            /*List<Task> tareasCerrar = new List<Task>();
            List<Id> tareasNotificar = new List<Id>();
            for (Task tarea : [SELECT Id FROM Task
                                WHERE Agrupador__c IN :idAgrupadores AND Status != 'Completed']) {

                tarea.CC_Fecha_Fin__c = System.today();
                tarea.Status = 'Completed';
                tareasCerrar.add(tarea);

                tareasNotificar.add(tarea.Id);
            }

            List<Case> casosCerrar = new List<Case>();
            for (Case caso : [SELECT Status FROM Case
                                WHERE CC_Agrupador_Id__c IN :idAgrupadores AND Status != 'Cerrado' AND Status != 'Pendiente Revisión']) {
                                    
                caso.Status = 'Cerrado';
                casosCerrar.add(caso);
            }

            //Cierre de tareas y casos
            Database.update(tareasCerrar, false);
            List<Database.SaveResult> resultadosCierreCaso = Database.update(casosCerrar, false);
            
            //Gestión del resultado del cierre de los casos
            List<Task> tareasCrear = new List<Task>();
            List<Case> casosCierreFallido = new List<Case>();

            for (Integer i = 0; i < resultadosCierreCaso.size(); i++) {
                Task tareaCierreAuto = new Task();
                tareaCierreAuto.Status = 'Completed';                
                if (resultadosCierreCaso[i].isSuccess()) {
                    //Cierre OK
                    tareaCierreAuto.Type = 'Cierre Automático';
                    tareaCierreAuto.Subject = 'Cierre automático';
                    tareaCierreAuto.WhatId = resultadosCierreCaso[i].getId();
                    tareaCierreAuto.Description = 'Cierre automático por cierre de agrupador';
                } else {
                    //Cierre KO
                    tareaCierreAuto.Type = 'Cierre automático fallido';
                    tareaCierreAuto.Subject = 'Cierre automático fallido';
                    tareaCierreAuto.WhatId = casosCerrar[i].Id; //Los SaveResult están en el mismo orden que los casos

                    //Los motivos de errores de cierre se registran en la descripción de la actividad
                    List<String> mensajesError = new List<String>();
                    for (Database.Error errorCierre : resultadosCierreCaso[i].getErrors()) {
                        mensajesError.add(errorCierre.getMessage());
                    }
                    tareaCierreAuto.Description = String.join(mensajesError, ', ');

                    //Se actualizan los casos con estado Pendiente Revisión
                    casosCerrar[i].Status = 'Pendiente Revisión';
                    casosCierreFallido.add(casosCerrar[i]);
                }
                tareasCrear.add(tareaCierreAuto);
            }
            //insert tareasCrear;
            CC_Activity.crearActividades(tareasCrear);

            //Si ha habido casos con cierre fallido se actualiza su estado y se muestra Toast
            if (!casosCierreFallido.isEmpty()) {
                update casosCierreFallido;
                CC_Notificacion.publicarToastError('Hay ' + casosCierreFallido.size() + ' casos vinculados a agrupadores que no se han podido cerrar y se deben revisar.');
            }

            //Envío de notificación de cierre para cada caso
            CC_NotifSegInc.gestionarCierreIncidencia(tareasNotificar);*/
        if (!CC_MetodosUtiles.modificadorApex('Cierre agrupador OLD')) {
            //Database.executeBatch(new CC_Agrupador_Batch(idAgrupadores));
           
            //Si el metadato está activo o no hay registro se planifica con el framework	
        	List<CBK_Framework_Batch_Apex__mdt> oConf = [Select Id from CBK_Framework_Batch_Apex__mdt where developername ='CC_Agrupador_Batch' and Activo__c=false LIMIT 1];
            CC_Agrupacion_Casos__c customSettingCasos = CC_Agrupacion_Casos__c.getValues('Agrupador Casos');
            Integer umbralCarga = Integer.valueOf(customSettingCasos.CC_Grupos_Casos__c);
            map<String,Object> params = New map<String,Object>();
            params.put('idAgrupadores',idAgrupadores);
            params.put('tareasNotif',null);
            params.put('enviarNotificaciones',false);   
                     
            /*if (oConf.isEmpty()&&(!Test.isRunningTest())){ 
                CBK_BatchJob.executeBatch('CC_Agrupador_Batch', null, params,1);                
            } else {
                Database.executeBatch(new CC_Agrupador_Batch(idAgrupadores, null, false));
            }*/
            if (oConf.isEmpty()&&(!Test.isRunningTest())){ 
                CBK_BatchJob.executeBatch('CC_Agrupador_Batch', umbralCarga, params,1);
            } else {
                Database.executeBatch(new CC_Agrupador_Batch(idAgrupadores, null, false), 10);
            }
        }
    }
    
    @future
    public static void actualizarNumeroCasos(List<Id> idsAgrupador) {
        
        Map<Id, List<Case>> mapaCasosAgrupados = new Map<Id, List<Case>>();
        List<CC_Agrupador__c> agrupadores = new List<CC_Agrupador__c>();
        List<Case> lstCasos = [SELECT Id, CC_Agrupador_Id__c FROM Case WHERE CC_Agrupador_Id__c IN :idsAgrupador  ORDER BY CC_Agrupador_Id__c ];
        if (!lstCasos.isEmpty()) {
            for (Case casoAgrupado : lstCasos) {
                if(mapaCasosAgrupados.containsKey(casoAgrupado.CC_Agrupador_Id__c)) {
                    List<Case> lstCasosAgrupados = mapaCasosAgrupados.get(casoAgrupado.CC_Agrupador_Id__c);
                    lstCasosAgrupados.add(casoAgrupado);
                    mapaCasosAgrupados.put(casoAgrupado.CC_Agrupador_Id__c,lstCasosAgrupados);
                } else {
                    mapaCasosAgrupados.put(casoAgrupado.CC_Agrupador_Id__c, new List<Case> {casoAgrupado});
                }
            }

            for (Id idAgrupador : idsAgrupador) {
                if(mapaCasosAgrupados.containsKey(idAgrupador)){
                    CC_Agrupador__c agrupador = new CC_Agrupador__c(Id = idAgrupador);
                    agrupador.CC_Numero_Casos__c = mapaCasosAgrupados.get(idAgrupador).size();
                    agrupadores.add(agrupador);
                }
            }
        }

        if (!agrupadores.isEmpty() && Schema.sObjectType.CC_Agrupador__c.fields.CC_Numero_Casos__c.isUpdateable()) {
            Database.update(agrupadores);
        }
    }
}