public without sharing class CSBD_Opp_AltaCMBIntouch_Controller {
    @AuraEnabled
    public static void altaCMBIntouch(String nombreCliente, String DNICliente, String fechaContacto, String tramoHorario, String codigoProducto, String operativa, String numeroContrato, String descripcion){
        try {
        
        //Informar horaInicio y horaFin según tramo elegido    
            Map<String, String> tramosHorariosMap = getHorasTramoHorario(tramoHorario);
            String horaInicio = tramosHorariosMap.get('horaInicio');
            String horaFin = tramosHorariosMap.get('horaFin');
        
        //Informar campos oportunidad    
            Map<String, Object> campos = new Map<String, Object>();
            campos.put('CSBD_Now_NombreCompleto__c', nombreCliente);
            campos.put('CSBD_Now_NIF__c', DNICliente);
            campos.put('CSBD_Estado__c', 'Pendiente Cita');
            campos.put('CSBD_Empresa_Proveedora__c', 'inTouch');
            
            String titulo = 'Petición Intouch ' + numeroContrato;
            titulo = titulo.left(255);
            campos.put('CSBD_Titulo__c', titulo);

            String descripcionOpportunidad = operativa + '\n' + descripcion;
            descripcionOpportunidad = descripcionOpportunidad.left(32000);
            campos.put('Description', descripcionOpportunidad);
            
            String horarioContacto = horaInicio.left(5) + ' - ' + horaFin.left(5);
            campos.put('CSBD_Horario_Contacto__c', horarioContacto);

            Id opportunityOwner = [SELECT Id FROM User WHERE UserName LIKE 'csbd_generico@cc-caixabank.com%'].Id;
            campos.put('OwnerId', opportunityOwner); 

        //Informar producto
            campos.put('CSBD_Now_Codigo_Producto__c', codigoProducto);
            List<CC_Lista_Valores__c> lov = [SELECT CC_Valor__c, CC_Valor2__c, CC_Valor_SFDC__c, CSBD_Valor4__c FROM CC_Lista_Valores__c WHERE RecordType.DeveloperName = 'CC_Valor'
                                            AND CC_Lista__r.Name = 'CSBD: Relación de valores Now - Salesforce: Empresa, familia y producto'
                                            AND Name = :codigoProducto AND CC_Activa__c = TRUE LIMIT 1];
            if (!lov.isEmpty()) {
                campos.put('CSBD_Empresa_Proveedora__c', String.isNotBlank(lov[0].CC_Valor_SFDC__c) ? lov[0].CC_Valor_SFDC__c : 'inTouch');
                campos.put('CSBD_Familia_Producto__c', lov[0].CC_Valor__c);
                campos.put('CSBD_Producto__c', lov[0].CC_Valor2__c);
                campos.put('CSBD_Skill__c', lov[0].CSBD_Valor4__c);
            }
        
        //Crear oportunidad
            Opportunity nuevaOportunidad = CSBD_Opportunity.crearOportunidad('CSBD_CMB', campos);

        //Programar cita
            Id idOportunidad = nuevaOportunidad.Id;
            Boolean asignacionAuto = true;
            Id idPropietario = null;
            Datetime startDateTime;

            //Fecha y hora contacto formulario
            Date fechaContactoDate = date.valueOf(fechaContacto);
            Time horaIniCita = stringToTime(horaInicio);
            Time horaFinCita = stringToTime(horaFin);
            
            //fecha y hora actual
            DateTime fechaHoraActual= system.now();
            Time horaActual = fechaHoraActual.time();
            Date fechaActual = fechaHoraActual.date();

            //Fecha <= hoy - lógica de siempre
            if(fechaContactoDate <= fechaActual){
                //horaIniCita > horaActual ---- reprogramada::: fechaHoy - horaIniCita
                if(horaIniCita > horaActual){
                    startDateTime = DateTime.newInstance(fechaActual, horaIniCita);
                }                       
                //horaIniCita <= horaActual <= horaFinCita --- reprogramada::: fechaHoy - horaActual
                if(horaIniCita <= horaActual && horaActual <= horaFinCita){
                    startDateTime = DateTime.newInstance(fechaActual, horaActual);
                }
                //horaActual > horaFinCita --- reprogramada:::: fechaMañana --- horaIniCita
                if(horaActual > horaFinCita){
                startDateTime = DateTime.newInstance(fechaActual.addDays(1), horaIniCita);
                }
            }
            //fecha > hoy - reprogramada fecha y hora indicada
            if(fechaContactoDate > fechaActual){
                startDateTime = DateTime.newInstance(fechaContactoDate, horaIniCita);
            }
            CSBD_Opportunity.programarCita(idOportunidad, asignacionAuto, idPropietario, startDateTime);
 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Time stringToTime(String strTimeChange){
        String[] strTimeSplit = strTimeChange.split(':');
        Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                     ,Integer.valueOf(strTimeSplit[1]) //min
                                     ,0                                //sec
                                     ,0);
        Return timeChange;

    }
    public static Map<String, String> getHorasTramoHorario(String tramoHorario){
        
        Map<String, String> tramosHorariosMap = new Map<String, String>();
        String horaInicio;
        String horaFin;

        if(tramoHorario == '8h-10h'){
            horaInicio = '08:00:00.000Z';
            horaFin = '10:00:00.000Z';
        }
        else if(tramoHorario == '10h-12h'){
            horaInicio = '10:00:00.000Z';
            horaFin = '12:00:00.000Z';
        }
        else if(tramoHorario == '12h-14h'){
            horaInicio = '12:00:00.000Z';
            horaFin = '14:00:00.000Z';
        }
        else if(tramoHorario == '14h-16h'){
            horaInicio = '14:00:00.000Z';
            horaFin = '16:00:00.000Z';
        }
        else if(tramoHorario == '16h-18h'){
            horaInicio = '16:00:00.000Z';
            horaFin = '18:00:00.000Z';
        }
        else if(tramoHorario == '18h-20h'){
            horaInicio = '18:00:00.000Z';
            horaFin = '20:00:00.000Z';
        }

        tramosHorariosMap.put('horaInicio', horaInicio);
        tramosHorariosMap.put('horaFin', horaFin);

        return tramosHorariosMap;
    }
}