public inherited sharing class CSBD_GestorOportunidad {
    public class DefaultException extends Exception {}

    //Llama Botón operativa reasignación automática de una en una - El estado se recalcula
    public static void activarGestorOportunidad(Id oportunidadId) {
        List<Opportunity> oportunidades = [SELECT Name, CSBD_Empresa_Proveedora__c, CSBD_Idioma_Solicitud__c,
                                            RecordTypeId, CSBD_Turno_Contacto__c, CSBD_Familia_Producto__c,
                                            CSBD_Skill__c, CSBD_Horario_Contacto__c, CSBD_Alta_omnichannel__c,
                                            CSBD_OC_Canal_Entrada__c, CSBD_OC_Prioridad__c, RecordType.Name, CSBD_Producto__c
                                            FROM Opportunity WHERE Id = :oportunidadId];
        activarGestorOportunidad(oportunidades, new Set<Id>{oportunidadId}, '');
    }

    //Llama CSBD_Oportunidad.finalizarCita()
    public static void activarGestorOportunidad(List<Opportunity> oportunidades, Set<Id> oportunidadesIds, String estadoDefinido) {
        List<Opportunity> oportunidadCrearGestorOportunidad = new List<Opportunity>();
        List<Opportunity> oportunidadActualizarGestorOportunidad = new List<Opportunity>();

        List<CSBD_Gestor_Oportunidad__c> gestorOportunidadActivar = [SELECT CSBD_Estado__c, CSBD_Oportunidad__c, CSBD_Oportunidad__r.CSBD_Turno_Contacto__c,
                                                                        CSBD_Hora_inicio_contacto__c, CSBD_Hora_fin_contacto__c
                                                                        FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c IN :oportunidadesIds];

        Map<Id, CSBD_Gestor_Oportunidad__c> idOportunidadGestorOportunidad = new Map<Id, CSBD_Gestor_Oportunidad__c>();
        if (!gestorOportunidadActivar.isEmpty()) {
            for (CSBD_Gestor_Oportunidad__c gestorOportunidad : gestorOportunidadActivar) {
                idOportunidadGestorOportunidad.put(gestorOportunidad.CSBD_Oportunidad__c, gestorOportunidad);
            }
            if (!oportunidades.isEmpty()) {
                for (Opportunity oportunidad : oportunidades) {
                    if (idOportunidadGestorOportunidad.containsKey(oportunidad.Id)) {
                        oportunidadActualizarGestorOportunidad.add(oportunidad);
                    } else {
                        oportunidadCrearGestorOportunidad.add(oportunidad);
                    }
                }
            }
        } else {
            oportunidadCrearGestorOportunidad.addAll(oportunidades);
        }
        //Crear Gestor Oportunidad
        insertarGestorOportunidad(oportunidadCrearGestorOportunidad, estadoDefinido);
        //Sincronizar Gestor Oportunidad -- si estadoDefinido está informado - este será el estado del Gestor Oportunidad actualizado
        sincronizarGestorOportunidad(oportunidadActualizarGestorOportunidad, gestorOportunidadActivar, estadoDefinido);
    }

    //Llamo desde WS alta oportunidad - no hay estado definido
    public static void insertarGestorOportunidad(List<Opportunity> oportunidadesList) {
        insertarGestorOportunidad(oportunidadesList, '');
    }

    //Llamo desde activarGestorOportunidad() si la oportunidad no tiene gestorOportunidad
    public static List<CSBD_Gestor_Oportunidad__c> insertarGestorOportunidad(List<Opportunity> oportunidadesList, String estadoDefinido) {
        Businesshours horarioComercial;
        List<CC_Lista_Valores__c> valoresAsignacionHorarioComercial = new List<CC_Lista_Valores__c>();
        //Solo usaremos estos datos si estadoDefinido == ''
        if (estadoDefinido == '') {
            //Horario en el que se enrutan las oportunidades cuando entran (si están dentro de horario de contacto)
            horarioComercial = [SELECT Id FROM BusinessHours WHERE Name = 'Now In Sales - Horario comercial' LIMIT 1];
            //Tipos de oportunidad que dependen del horario comercial
            valoresAsignacionHorarioComercial = [SELECT Name FROM CC_Lista_Valores__c
                                                    WHERE CC_Lista__r.Name = 'CSBD: Motor de asignación - Tipos de oportunidad con horario'
                                                    AND RecordType.DeveloperName = 'CC_Valor' AND CC_Activa__c = true];
        }

        //Insertamos los registros de Gestor Oportunidad para enrutar la oportunidad
        List<CSBD_Gestor_Oportunidad__c> gestorOportunidadInsert = new List<CSBD_Gestor_Oportunidad__c>();
        for (Opportunity oportunidad : oportunidadesList) {
            gestorOportunidadInsert.add(insertarUnidadGestorOportunidad(oportunidad, horarioComercial, valoresAsignacionHorarioComercial, estadoDefinido));
        }
        insert gestorOportunidadInsert;

        //Creamos registro de CBK_SCH_PendingProcess__c para que el FWK active el registro en estado 'Fuera horario contacto' y se enrute.
        List<CBK_SCH_PendingProcess__c> pendingProcessInsert = new List<CBK_SCH_PendingProcess__c>();
        for (CSBD_Gestor_Oportunidad__c gestorOportunidad : gestorOportunidadInsert) {
            if (gestorOportunidad.CSBD_Estado__c == 'Fuera horario contacto') {
                CBK_SCH_PendingProcess__c pendingProcess = crearRegistroPendingProcess(gestorOportunidad, System.now());
                pendingProcessInsert.add(pendingProcess);
            }
        }
        if (!pendingProcessInsert.isEmpty()) {
            insert pendingProcessInsert;
        }
        return gestorOportunidadInsert;
    }

    //Sirve para iterar y crear n gestores de Oportunidad con los datos indicados
    public static CSBD_Gestor_Oportunidad__c insertarUnidadGestorOportunidad(Opportunity oportunidad, BusinessHours horarioComercial, List<CC_Lista_Valores__c> valoresAsignacionHorarioComercial, String estadoDefinido) {
        CSBD_Gestor_Oportunidad__c gestorOportunidad = new CSBD_Gestor_Oportunidad__c();
        gestorOportunidad = mapearGestorOportunidadConOportunidad(oportunidad, gestorOportunidad);
        //INFORMAR ESTADO
        if (estadoDefinido != '') {
            gestorOportunidad.CSBD_Estado__c = estadoDefinido;
        } else {
            gestorOportunidad.CSBD_Estado__c = calcularEstadoGestorOportunidad(oportunidad, horarioComercial, valoresAsignacionHorarioComercial, System.now(), gestorOportunidad.CSBD_Hora_inicio_contacto__c, gestorOportunidad.CSBD_Hora_fin_contacto__c);
        }
        return gestorOportunidad;
    }

    //Llama desde activarGestorOportunidad()
    public static void sincronizarGestorOportunidad(List<Opportunity> oportunidadesList, List<CSBD_Gestor_Oportunidad__c> gestorOportunidadSincronizar, String estadoDefinido) {
        Map<Id, Opportunity> idOpportunityMap = new Map<Id, Opportunity>();
        for (Opportunity oportunidad : oportunidadesList) {
            idOpportunityMap.put(oportunidad.Id, oportunidad);
        }
        Boolean recalcularEstado = estadoDefinido == '' || estadoDefinido == null;
        sincronizarGestorOportunidad(idOpportunityMap, gestorOportunidadSincronizar, recalcularEstado, estadoDefinido);
    }

    //Actualizo los datos del registro de Gestor Oportunidad para que sean iguales a los de la oportunidad
    public static void sincronizarGestorOportunidad(Map<Id, Opportunity> idOpportunityMap, List<CSBD_Gestor_Oportunidad__c> gestorOportunidadSincronizar, Boolean recalcularEstado, String estadoDefinido) {
        Businesshours horarioComercial;
        List<CC_Lista_Valores__c> valoresAsignacionHorarioComercial = new List<CC_Lista_Valores__c>();
        List<CBK_SCH_PendingProcess__c> pendingProcessInsert = new List<CBK_SCH_PendingProcess__c>();

        //Solo hacen falta si se recalcula el estado (reasignación automática)
        if (recalcularEstado) {
            //Horario en el que se enrutan las oportunidades cuando entran (si están dentro de horario de contacto)
            horarioComercial = [SELECT Id FROM BusinessHours WHERE Name = 'Now In Sales - Horario comercial' LIMIT 1];
            //Tipos de oportunidad que dependen del horario comercial
            valoresAsignacionHorarioComercial = [SELECT Name FROM CC_Lista_Valores__c
                                                    WHERE CC_Lista__r.Name = 'CSBD: Motor de asignación - Tipos de oportunidad con horario'
                                                    AND RecordType.DeveloperName = 'CC_Valor' AND CC_Activa__c = true];
        }
        for (CSBD_Gestor_Oportunidad__c gestorOportunidad: gestorOportunidadSincronizar) {
            if (idOpportunityMap.containsKey(gestorOportunidad.CSBD_Oportunidad__c)) {
                Opportunity oportunidad = idOpportunityMap.get(gestorOportunidad.CSBD_Oportunidad__c);
                gestorOportunidad = mapearGestorOportunidadConOportunidad(oportunidad, gestorOportunidad);
                if (recalcularEstado) {
                    gestorOportunidad.CSBD_Estado__c = calcularEstadoGestorOportunidad(oportunidad, horarioComercial, valoresAsignacionHorarioComercial, System.now(), gestorOportunidad.CSBD_Hora_inicio_contacto__c, gestorOportunidad.CSBD_Hora_fin_contacto__c);
                    if (gestorOportunidad.CSBD_Estado__c == 'Fuera horario contacto') {
                        CBK_SCH_PendingProcess__c pendingProcess = crearRegistroPendingProcess(gestorOportunidad, System.now());
                        pendingProcessInsert.add(pendingProcess);
                    }
                } else if (estadoDefinido != '') {
                    gestorOportunidad.CSBD_Estado__c = estadoDefinido;
                }
            }
        }
        update gestorOportunidadSincronizar;
        insert pendingProcessInsert;
    }

    public static CSBD_Gestor_Oportunidad__c mapearGestorOportunidadConOportunidad(Opportunity oportunidad, CSBD_Gestor_Oportunidad__c gestorOportunidad) {
        Map<String, String> mapaTramoPrioridad = new Map<String, String>{
            '0' => '1', '1' => '1', '2' => '1', '3' => '1', '4' => '1',
            '5' => '2', '6' => '2', '7' => '2',
            '8' => '3', '9' => '3', '10' => '3', '11' => '3', '12' => '3', '13' => '3'
        };

        gestorOportunidad.Name = oportunidad.Name;
        if (oportunidad.CSBD_Producto__c != null) {
            gestorOportunidad.Name += ' - ' + oportunidad.CSBD_Producto__c;
        }
        gestorOportunidad.CSBD_Oportunidad__c = oportunidad.Id;        
        
        gestorOportunidad.CSBD_Tipo_de_oportunidad__c = CC_MetodosUtiles.obtenerRecordTypes('Opportunity').get(oportunidad.RecordtypeId);        

        if (oportunidad.RecordType.Name == 'Hipoteca' || ((oportunidad.RecordType.Name == 'CMN' || oportunidad.RecordType.Name == 'CMB') && oportunidad.CSBD_Familia_Producto__c == 'Hipotecas')) {
            gestorOportunidad.CSBD_OC_Canal_Entrada__c = oportunidad.CSBD_OC_Canal_Entrada__c;
            gestorOportunidad.CSBD_OC_Prioridad__c = mapaTramoPrioridad.get(oportunidad.CSBD_OC_Prioridad__c);
        }

        //Skill principal para enrutar.
        //INFORMAR PRODUCTO
        gestorOportunidad.CSBD_Familia_de_producto__c = calcularProductoGestorOportunidad(oportunidad.CSBD_Skill__c);
        //CALCULO HORARIO CONTACTO

        //Verificar si la skill de producto está marcada como skill única. Si es así, no se añaden skills adicionales.        
        CSBD_GestorOportunidadSkillHandler gestorOportunidadSkillHandler = CSBD_GestorOportunidadSkillHandler.getInstance();
        Boolean skillUnica = gestorOportunidadSkillHandler.contieneValor(gestorOportunidad.CSBD_Familia_de_producto__c);

        if (!skillUnica) {
            //Grupo de skills adicionales. 
            gestorOportunidad.CSBD_Empresa_proveedora__c = oportunidad.CSBD_Empresa_Proveedora__c;
            gestorOportunidad.CSBD_Idioma__c = oportunidad.CSBD_Idioma_Solicitud__c;
            gestorOportunidad.CSBD_Turno_de_contacto__c = oportunidad.CSBD_Turno_Contacto__c;
        }

        //Horario de Contacto en formato Time
        if (oportunidad.CSBD_Horario_Contacto__c != null && oportunidad.CSBD_Horario_Contacto__c != '') {
            List<Time> horaInicioFin = calcularHoraInicioFinContactoGestorOportunidad(oportunidad.CSBD_Horario_Contacto__c);
            if (!horaInicioFin.isEmpty()) {
                gestorOportunidad.CSBD_Hora_inicio_contacto__c = horaInicioFin[0];
                gestorOportunidad.CSBD_Hora_fin_contacto__c = horaInicioFin[1];
            }
        }
        return gestorOportunidad;
    }

    public static void desactivarGestorOportunidad(Id oportunidadId) {
        desactivarGestorOportunidad(new Set<Id>{oportunidadId});
    }

    public static void desactivarGestorOportunidad(Set<Id> oportunidadesIds) {
        //Antes de llamar a esta clase, cuando se esté iterando la oportunidad, marcar el checkbox "Baja omnichannel" para que no vuelva a entrar en el trigger
        List<CSBD_Gestor_Oportunidad__c> gestoresOportunidad = [SELECT Id FROM CSBD_Gestor_Oportunidad__c
                                                                WHERE CSBD_Oportunidad__c IN :oportunidadesIds AND CSBD_Estado__c != 'Inactivo'];

        for (CSBD_Gestor_Oportunidad__c gestorOportunidad : gestoresOportunidad) {
            gestorOportunidad.CSBD_Estado__c = 'Inactivo';
        }
        update gestoresOportunidad;
    }

    public static CBK_SCH_PendingProcess__c crearRegistroPendingProcess(CSBD_Gestor_Oportunidad__c gestorOportunidad, Datetime fechaCreacionOportunidad) {
        Datetime fechaProgramacion;
        Time inicioHorarioContacto = gestorOportunidad.CSBD_Hora_inicio_contacto__c;
        Time finHorarioContacto = gestorOportunidad.CSBD_Hora_fin_contacto__c;
        //Se crea el mismo dia en hora inicioHorarioContacto
        if (inicioHorarioContacto > fechaCreacionOportunidad.time()) {
            fechaProgramacion = Datetime.newInstance(fechaCreacionOportunidad.date(), inicioHorarioContacto);
        }
        //se crea el dia siguiente a hora inicioHorarioContacto
        else if(finHorarioContacto < fechaCreacionOportunidad.time()) {
            fechaProgramacion = Datetime.newInstance(fechaCreacionOportunidad.date().addDays(1), inicioHorarioContacto);
        }
        //La oportunidad entra dentro del horario de contacto
        else if(inicioHorarioContacto <= fechaCreacionOportunidad.time() && finHorarioContacto >= fechaCreacionOportunidad.time()) {
            fechaProgramacion = Datetime.newInstance(fechaCreacionOportunidad.date(), fechaCreacionOportunidad.time());
        }

        CBK_SCH_PendingProcess__c pendingProcess = new CBK_SCH_PendingProcess__c();
        pendingProcess.RecordId__c = gestorOportunidad.Id;
        pendingProcess.Schedule_Time__c = fechaProgramacion;
        pendingProcess.ClassName__c = 'CBK_SCH_CSBD_ActivarGestorOportunidad';
        return pendingProcess;
    }

    public static String calcularProductoGestorOportunidad(String skillOportunidad) {
        String familiaProductoCalculada;
        List<OT_Picklist.Item> familiaProductosItem = OT_Picklist.picklistCampo('CSBD_Gestor_Oportunidad__c', 'CSBD_Familia_de_producto__c');
        Set<String> familiaProductosLabel = new Set<String>();
        for (OT_Picklist.Item valorFamiliaProducto: familiaProductosItem) {
            familiaProductosLabel.add(valorFamiliaProducto.label);
        }

        if (familiaProductosLabel.contains(skillOportunidad)) {
            familiaProductoCalculada = skillOportunidad;
        } else {
            //Si la familia de producto no está contenida en la picklist no habrá skill para enrutarla --- la categorizamos como "Otra"
            familiaProductoCalculada = 'Otra';
        }
        return familiaProductoCalculada;
    }

    public static List<Time> calcularHoraInicioFinContactoGestorOportunidad(String horarioContactoCampo) {
        List<Time> horaInicioFinCalculada = new List<Time>();
        Time inicioHorarioContacto;
        Time finHorarioContacto;
        List<String> horarioContacto = horarioContactoCampo.replaceAll( '\\s+', '').split('-');
        if (!horarioContacto.isEmpty() && horarioContacto.size() == 2) {
            List<String> inicioHorarioList = horarioContacto[0].split(':');
            if (!inicioHorarioList.isEmpty() && inicioHorarioList.size() == 2) {
                inicioHorarioContacto = Time.newInstance(Integer.valueOf(inicioHorarioList[0]), Integer.valueOf(inicioHorarioList[1]), 0, 0);
            }
            List<String> finHorarioList = horarioContacto[1].split(':');
            if (!finHorarioList.isEmpty() && finHorarioList.size() == 2) {
                finHorarioContacto = Time.newInstance(Integer.valueOf(finHorarioList[0]), Integer.valueOf(finHorarioList[1]), 0, 0);
            }
            horaInicioFinCalculada.add(inicioHorarioContacto);
            horaInicioFinCalculada.add(finHorarioContacto);
        }
        return horaInicioFinCalculada;
    }

    public static String calcularEstadoGestorOportunidad(Opportunity oportunidad, BusinessHours horarioComercial, List<CC_Lista_Valores__c> valoresAsignacionHorarioComercial, Datetime fechaCreacionOportunidad,Time inicioHorarioContacto, Time finHorarioContacto) {
        String estadoCalculado;

        Set<String> tiposOportunidadHorarioAsignacion = new Set<String>();
        for (CC_Lista_Valores__c valor : valoresAsignacionHorarioComercial) {
            tiposOportunidadHorarioAsignacion.add(valor.Name);
        }
        //Si está dentro de las BH para los tipos definidos en la lista de valores o para los tipos que no están --> evaluamos el horario de contacto
        if ((BusinessHours.isWithin(horarioComercial.Id, fechaCreacionOportunidad) && tiposOportunidadHorarioAsignacion.contains(CC_MetodosUtiles.obtenerRecordTypes('Opportunity').get(oportunidad.RecordtypeId)))
        || !tiposOportunidadHorarioAsignacion.contains(CC_MetodosUtiles.obtenerRecordTypes('Opportunity').get(oportunidad.RecordtypeId))) {
            //Evaluamos la fecha de creación de la oportunidad
            //Entra en la asignación
            if (fechaCreacionOportunidad.time() >= inicioHorarioContacto && fechaCreacionOportunidad.time() <= finHorarioContacto) {
                estadoCalculado = 'Pendiente de asignar';
            } else if (inicioHorarioContacto != null && finHorarioContacto != null) {
                //Tiene horario de contacto, lo activa el FWK
                estadoCalculado = 'Fuera horario contacto';
            } else {
                //no tiene horario de contacto --> como ha entrado en periodo de BH/para oportunidades que no se rigen por este horario --> se asigna en el momento que entra
                estadoCalculado = 'Pendiente de asignar';
            }
        } else if(inicioHorarioContacto != null && finHorarioContacto != null) {
            //Si no está dentro de las BH y tiene horario de contacto >> se activa en el próximo dia laboral en horario de contacto mediante FWK
            estadoCalculado = 'Fuera horario contacto';
        } else {
            //si no está dentro de las BH y no tiene horario de contacto --- lo activa el batch
            estadoCalculado = 'Fuera horario comercial';
        }
        return estadoCalculado;
    }

    public static void calcularColaGestorOportunidad(Set<Id> oportunidadIds, List<CSBD_Gestor_Oportunidad__c> gestorOportunidadCambiarOwner, Set<String> tiposOportunidad) {
        String tiposOportunidadString = '';
        Integer iteracion = 0;
        for (String tipo : tiposOportunidad) {
            tiposOportunidadString += 'CSBD_Tipo_de_oportunidad__c INCLUDES (\'' + String.escapeSingleQuotes(tipo) + '\') ';
            iteracion += 1;
            if (iteracion < tiposOportunidad.size()) {
                tiposOportunidadString += 'OR ';
            }
        }
        String querySOQL = 'SELECT ';
        querySOQL += 'Name, CC_Activa__c, CC_Orden__c, CSBD_Cola_Oportunidad__c, CSBD_Tipo_de_oportunidad__c ';
        querySOQL += 'FROM ' + String.escapeSingleQuotes('CC_Lista_Valores__c') + ' ';
        querySOQL += 'WHERE Recordtype.DeveloperName = \'' + String.escapeSingleQuotes('CSBD_Regla_asignacion_oportunidad') + '\' ';
        querySOQL += 'AND CC_Activa__c = true ';
        if (tiposOportunidadString != '') {
            querySOQL += 'AND (' + tiposOportunidadString + ') ';
        }
        querySOQL += 'ORDER BY CC_Orden__c ASC ';

        List<CC_Lista_Valores__c> reglasAsignacion = Database.query(String.valueOf(querySOQL));

        //Los filtros de las reglas de asignación los guardo en el metadato CSBD_Criterios_asignacion_oportunidad__mdt --> sustituye al campo CSBD_Criterios_asignacion__c de la lista de valores
        Map<String, CSBD_Criterios_asignacion_oportunidad__mdt> nombreColaCriterioAsignacion = new Map<String, CSBD_Criterios_asignacion_oportunidad__mdt>();
        for (CSBD_Criterios_asignacion_oportunidad__mdt criterioAsignacion: [SELECT CSBD_Cola_Asignada__c, CSBD_Criterio_1__c, CSBD_Criterio_2__c FROM CSBD_Criterios_asignacion_oportunidad__mdt]) {
            nombreColaCriterioAsignacion.put(criterioAsignacion.CSBD_Cola_Asignada__c, criterioAsignacion);
        }
        //Calculo qué oportunidades cumplen para cada regla
        Map<Id, CC_Lista_Valores__c> idReglaAsignacion = new Map<Id, CC_Lista_Valores__c>();
        Map<Id, Set<Id>> reglaIdOportunidades = new Map<Id, Set<Id>>();
        Set<String> nombreColas = new Set<String>();
        for(CC_Lista_Valores__c regla: reglasAsignacion) {
            idReglaAsignacion.put(regla.Id, regla);

            String criterioRegla = '';
            if (nombreColaCriterioAsignacion.containsKey(regla.CSBD_Cola_Oportunidad__c)) {
                 //Filtros de la oportunidad del metadato
                CSBD_Criterios_asignacion_oportunidad__mdt criterioAsignacion = nombreColaCriterioAsignacion.get(regla.CSBD_Cola_Oportunidad__c);
                if (criterioAsignacion.CSBD_Criterio_1__c != null) {
                    criterioRegla += criterioAsignacion.CSBD_Criterio_1__c + ' ';
                }
                if (criterioAsignacion.CSBD_Criterio_2__c != null) {
                    criterioRegla += criterioAsignacion.CSBD_Criterio_2__c;
                }
            }
            //Tipos de oportunidad admitidos en la regla
            List<String> tiposOportunidadRegla = new List<String>();
            if (regla.CSBD_Tipo_de_oportunidad__c != null) {
                tiposOportunidadRegla = regla.CSBD_Tipo_de_oportunidad__c.split(';');
            }
            Set<Id> oportunidadesRegla = buscarOportunidadesRegla(oportunidadIds, criterioRegla, tiposOportunidadRegla);
            if (!oportunidadesRegla.isEmpty()) {
                List<Id> oportunidadesReglaList = new List<Id>();
                oportunidadesReglaList.addAll(oportunidadesRegla);
                //Quito las oportunidades que ya se han asignado para que no se tengan en cuenta en la siguiente iteración
                oportunidadIds.removeAll(oportunidadesReglaList);
                //Guardo las oportunidades que aplican a cada regla
                reglaIdOportunidades.put(regla.Id, oportunidadesRegla);
                //Queues de las reglas asignadas
                nombreColas.add(regla.CSBD_Cola_Oportunidad__c);
            }
            //Cuando todas las oportunidades han encontrado su regla salgo del bucle para no seguir iterando las restantes
            if (oportunidadIds.isEmpty()) {
                break;
            }
        }

        if(!reglaIdOportunidades.isEmpty()) {
            List<Group> colasGestorOportunidad = [SELECT DeveloperName FROM Group WHERE DeveloperName = :nombreColas AND Type = 'Queue'];
            Map<String, Id> developerNameIdCola = new Map<String, Id>();
            for (Group cola : colasGestorOportunidad) {
                developerNameIdCola.put(cola.DeveloperName, cola.Id);
            }
            //Creo un mapa con el Id oportunidad y el Id del grupo owner del gestor oportunidad
            Map<Id, Id> oportunidadIdQueueId = new Map<Id, Id>();
            Map<Id, String> oportunidadIdQueueName = new Map<Id, String>();
            for (Id reglaId : reglaIdOportunidades.keySet()) {
                for (Id oportunidadId : reglaIdOportunidades.get(reglaId)) {
                    if (!oportunidadIdQueueId.keySet().contains(oportunidadId) && idReglaAsignacion.containsKey(reglaId)) {
                        if (developerNameIdCola.containsKey(idReglaAsignacion.get(reglaId).CSBD_Cola_Oportunidad__c)) {
                            oportunidadIdQueueId.put(oportunidadId, developerNameIdCola.get(idReglaAsignacion.get(reglaId).CSBD_Cola_Oportunidad__c));
                            oportunidadIdQueueName.put(oportunidadId, idReglaAsignacion.get(reglaId).CSBD_Cola_Oportunidad__c);
                        }
                    }
                }
            }
            //Actualizo el owner del gestor oportunidad
            for (CSBD_Gestor_Oportunidad__c gestorOportunidadOwner : gestorOportunidadCambiarOwner) {
                if (oportunidadIdQueueId.containsKey(gestorOportunidadOwner.CSBD_Oportunidad__c)) {
                    //Actualizo owner a queue
                    gestorOportunidadOwner.OwnerId = oportunidadIdQueueId.get(gestorOportunidadOwner.CSBD_Oportunidad__c);
                    gestorOportunidadOwner.CSBD_Estado__c = 'Activo';
                }
                if (oportunidadIdQueueName.containsKey(gestorOportunidadOwner.CSBD_Oportunidad__c)) {
                    gestorOportunidadOwner.CSBD_Cola_Asignada__c = oportunidadIdQueueName.get(gestorOportunidadOwner.CSBD_Oportunidad__c);
                }
            }
        }
    }

    private static Set<Id> buscarOportunidadesRegla(Set<Id> oportunidadIds, String criterioRegla, List<String> tiposOportunidadRegla) {
        String soql = 'SELECT Id FROM Opportunity WHERE Id IN :oportunidadIds AND RecordType.Name IN :tiposOportunidadRegla ' + criterioRegla;
        Set<Id> idsOportunidadRegla = new Set<Id>();
        for (Opportunity oportunidad : Database.query(String.escapeSingleQuotes(soql).replaceAll('"','\''))) {
            idsOportunidadRegla.add(oportunidad.Id);
        }
        return idsOportunidadRegla;
    }
}