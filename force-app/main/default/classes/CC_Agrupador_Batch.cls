public class CC_Agrupador_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{
    List<Id> idAgrupadores;
    List<Id> tareasNotif;
    Boolean enviarNotificaciones = false;
    Boolean isCliente = false; // Variable para controlar si hay casos de cliente

    List<CC_Agrupador__c> listaAgrupadoresFallidos; // Lista de agrupadores fallidos para notificar por el platform event
    Map<Id, List<Case>> casosCierreFallidoTotal; // Mapa de casos fallidos agrupados por agrupador para notificar por el platform event
    

    //public CC_Agrupador_Batch (List<Id> idAgrupadores) { this.idAgrupadores = idAgrupadores; }

    public CC_Agrupador_Batch (List<Id> idAgrupadores, List<Id> tareasNotif, Boolean enviarNotificaciones) 
    { 
        this.idAgrupadores = idAgrupadores; 
        this.tareasNotif = tareasNotif; 
        this.enviarNotificaciones = enviarNotificaciones; 
        this.casosCierreFallidoTotal = new Map<Id, List<Case>>();
        this.listaAgrupadoresFallidos = new List<CC_Agrupador__c>();
    }
    
    public CC_Agrupador_Batch () 
    {
        this.casosCierreFallidoTotal = new Map<Id, List<Case>>();
        this.listaAgrupadoresFallidos = new List<CC_Agrupador__c>();
        CBK_log.debug('Comienzo batch Agrupador CC');
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, CC_Agrupador_Id__r.CC_Detalle_solucion__c,CC_Agrupador_Id__r.CC_Publica__c,CC_Detalles_Solucion__c,Status, CC_Agrupador_Id__c, CC_Idioma__c, RecordType.DeveloperName, RecordType.Name, CC_NotIncidencia__c FROM Case WHERE CC_Agrupador_Id__c IN :idAgrupadores AND Status != 'Cerrado' AND Status != 'Pendiente Revisión']); 
    }

    public void execute(Database.BatchableContext bc, List<Case> records) {
        // Inicializar variables si son null (por seguridad)
        if (this.casosCierreFallidoTotal == null) {
            this.casosCierreFallidoTotal = new Map<Id, List<Case>>();
        }
        if (this.listaAgrupadoresFallidos == null) {
            this.listaAgrupadoresFallidos = new List<CC_Agrupador__c>();
        }
        
        // Obtenemos todas las plantillas de los agrupadores
        List<Id> idsCasos = new List<Id>();
        List<Id> idsAgrupadores = new List<Id>();
        List<Id> tareasNotificarFinal = new List<Id>();
        List<Case> casosCierreFallido = new List<Case>(); // Lista de casos fallidos para actualizar en DML

        for (Case caso : records) {
            if (caso.RecordType.DeveloperName == 'CC_Cliente' && (this.isCliente == false || this.isCliente == null)){
                this.isCliente = true;
            }
            idsCasos.add(caso.Id);
            idsAgrupadores.add(caso.CC_Agrupador_Id__c);
        }
               
        //EMAIL
        Map<Id, Map<String, String>> mapaAgrupadorPlantillas = new Map<Id, Map<String, String>>(); //<idAgrupador, <idioma##tipoCliente, idPlantilla>>
        List<CC_PlantillaAsociada__c> listAgrupadorPlantilla = [SELECT CC_Agrupador__c, CC_Idioma__c, CC_CuerpoNotificacion__c, CC_Tipo_Cliente__c FROM CC_PlantillaAsociada__c WHERE CC_Agrupador__c IN :idsAgrupadores AND CC_Canal__c = 'Email'];
        for (CC_PlantillaAsociada__c junctionAgrupadorPlantilla : listAgrupadorPlantilla) {
            Map<String, String> mapaIdiomaCuerpo = mapaAgrupadorPlantillas.get(junctionAgrupadorPlantilla.CC_Agrupador__c);
            if (mapaIdiomaCuerpo == null) mapaIdiomaCuerpo = new Map<String, String>();
            mapaIdiomaCuerpo.put(junctionAgrupadorPlantilla.CC_Idioma__c + '##' + junctionAgrupadorPlantilla.CC_Tipo_Cliente__c, junctionAgrupadorPlantilla.CC_CuerpoNotificacion__c);
            mapaAgrupadorPlantillas.put(junctionAgrupadorPlantilla.CC_Agrupador__c, mapaIdiomaCuerpo);
            this.enviarNotificaciones = true;
        }
        
        //Se acumulan los registros a cerrar en las siguientes listas
        List<Case> casosCerrar = new List<Case>();
        String auxDetalleSolucionCase = '';
        for (Case caso : records) {
            caso.Status = 'Cerrado';
            if (caso.CC_NotIncidencia__c == '1' && mapaAgrupadorPlantillas.get(caso.CC_Agrupador_Id__c) != null) {
                caso.CC_NotIncidenciaCuerpo__c = mapaAgrupadorPlantillas.get(caso.CC_Agrupador_Id__c).get(caso.CC_Idioma__c + '##' + caso.RecordType.Name);
            }

            // Añadido por Moisés Cano - 16/01/24
            //Modificación para añadir el Detalles Solución del Agrupador en el Caso
            // US791370 : IOP Febrero
            if (caso.RecordType.DeveloperName == 'HDT_Empleado' && caso.CC_Agrupador_Id__r.CC_Publica__c == true) {  
                if (caso.CC_Detalles_Solucion__c != null) {
                    auxDetalleSolucionCase = caso.CC_Detalles_Solucion__c;
                    caso.CC_Detalles_Solucion__c = auxDetalleSolucionCase + '\n' + caso.CC_Agrupador_Id__r.CC_Detalle_solucion__c;
                }else{
                    caso.CC_Detalles_Solucion__c = caso.CC_Agrupador_Id__r.CC_Detalle_solucion__c;
                }
                
                
            }    

            casosCerrar.add(caso);
        }
        List<Task> tareasCerrar = new List<Task>();
        List<Id> tareasNotificar = new List<Id>();
        for (Task tarea : [SELECT Id FROM Task
                            WHERE Agrupador__c IN :this.idAgrupadores AND Status != 'Completed' AND WhatId IN :idsCasos]) {

            tarea.CC_Fecha_Fin__c = System.today();
            tarea.Status = 'Completed';
            tareasCerrar.add(tarea);

            tareasNotificar.add(tarea.Id);
        }
		        
        // Envío de notificación de cierre para cada caso. 2 razones porque el código está aquí especificamente:
        // 1. Tenemos que enviar las notificaciones incluso si el caso no se cierra bien
        // 2. El envío de los SMS tiene que ocurrir antes de hacer cualquier llamada DML
        tareasNotificar = CC_NotifSegInc.gestionarNotificacionesSMS(tareasNotificar);
        //if (this.tareasNotif == null)
        //{
        //    //this.tareasNotif = new List<Id>();
        //}
        //this.tareasNotif.addAll(tareasNotificar);
        tareasNotificarFinal.addAll(tareasNotificar);
        
        //Cierre de tareas y casos
        Database.update(tareasCerrar, false);
        List<Database.SaveResult> resultadosCierreCaso = Database.update(casosCerrar, false);

        //Gestión del resultado del cierre de los casos
        List<Task> tareasCrear = new List<Task>();
        Set<Id> idAgrupadoresFallidos = new Set<Id>();

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
                
                // Agregar al mapa agrupado por agrupador
                Id agrupadorId = casosCerrar[i].CC_Agrupador_Id__c;
                if (!this.casosCierreFallidoTotal.containsKey(agrupadorId)) {
                    this.casosCierreFallidoTotal.put(agrupadorId, new List<Case>());
                }
                this.casosCierreFallidoTotal.get(agrupadorId).add(casosCerrar[i]);
                
                casosCierreFallido.add(casosCerrar[i]);
                idAgrupadoresFallidos.add(casosCerrar[i].CC_Agrupador_Id__c);
            }
            tareasCrear.add(tareaCierreAuto);
        }
        CC_Activity.crearActividades(tareasCrear);

        //Si ha habido casos con cierre fallido se actualiza su estado y se muestra Toast
        List<CC_Agrupador__c> fallidosEnEsteBatch = new List<CC_Agrupador__c>();
        if (!idAgrupadoresFallidos.isEmpty()) {
            fallidosEnEsteBatch = [SELECT Name FROM CC_Agrupador__c WHERE Id = :idAgrupadoresFallidos];
            this.listaAgrupadoresFallidos.addAll(fallidosEnEsteBatch);
        }

        
        if (!casosCierreFallido.isEmpty()) {
            update casosCierreFallido;
        }

        // La razón por la que los emails ocurren al final es porque la clase NotifSegCaso está pensada
        // para ejecutarse después de los inserts. God knows why
       /*if (listAgrupadorPlantilla.size() == 1){
            CC_NotifSegCaso.gestionarBatchNotificacionCliente(tareasNotificar, 'CC_NotIncidencia');
        }*/


        if (this.enviarNotificaciones && !tareasNotificarFinal.isEmpty()){
            
            CC_NotifSegCaso.gestionarBatchNotificacionCliente(tareasNotificarFinal, 'CC_NotIncidencia');
        }

    }

    public void finish(Database.BatchableContext bc) 
    {
        if (this.casosCierreFallidoTotal != null && this.listaAgrupadoresFallidos != null) {
        
            if (!this.casosCierreFallidoTotal.isEmpty() && !this.listaAgrupadoresFallidos.isEmpty()) {
                // Calcular el total de casos fallidos
                Integer totalCasosFallidos = 0;
                for (List<Case> casosAgrupador : this.casosCierreFallidoTotal.values()) {
                    totalCasosFallidos += casosAgrupador.size();
                }
                // Eliminar duplicados de la lista de agrupadores fallidos para evitar que se repitan los mismos agrupadores en el mensaje de error
                Set<CC_Agrupador__c> setAgrupadoresFallidos = new Set<CC_Agrupador__c>(this.listaAgrupadoresFallidos);
                this.listaAgrupadoresFallidos = new List<CC_Agrupador__c>(setAgrupadoresFallidos);
                
                String mensajeError;
                if (this.listaAgrupadoresFallidos.size() == 1) {
                    mensajeError = 'Cierre del agrupador ' + this.listaAgrupadoresFallidos.iterator().next().Name + ' finalizado. Hay ' + totalCasosFallidos;
                } else if (this.listaAgrupadoresFallidos.size() > 1) {
                    String nombresAgrupadores = this.listaAgrupadoresFallidos[0].Name;
                    // Construir la lista de nombres de agrupadores
                    for (Integer i = 1; i < this.listaAgrupadoresFallidos.size(); ++i) {
                        if (i == this.listaAgrupadoresFallidos.size() - 1) {
                            // Último elemento
                            nombresAgrupadores += ' y ' + this.listaAgrupadoresFallidos[i].Name;
                        } else {
                            // Elementos intermedios
                            nombresAgrupadores += ', ' + this.listaAgrupadoresFallidos[i].Name;
                        }
                    }

                    mensajeError = 'Cierre de los agrupadores ' + nombresAgrupadores + ' finalizado. En total hay ' + totalCasosFallidos;
                } else {
                    mensajeError = 'Cierre de agrupadores finalizado. En total hay ' + totalCasosFallidos;
                }

                if (totalCasosFallidos == 1) { 
                    mensajeError += ' caso que no se ha podido cerrar y se debe revisar.';
                } else {
                    mensajeError += ' casos que no se han podido cerrar y se deben revisar.';
                }

                if (this.isCliente != null && this.isCliente)
                {
                    CC_Aviso_Agrupador__e avisoMensaje = new CC_Aviso_Agrupador__e (Message__c = mensajeError, Type__c = 'warning');
                    Eventbus.publish(avisoMensaje);
                    //CC_Notificacion.publicarToastAviso(mensajeError);
                }
            }
        }
        CBK_log.debug('Fin batch Agrupador CC');        
    }
}