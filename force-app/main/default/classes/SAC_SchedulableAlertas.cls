/***********************************************************************
 * Name: SAC_SchedulableAlertas
 * Copyright © 2022  CaixaBank
 * 
 * Proposito: Clase que mediante los pendingProcess (framework schedulable) comprueba si las consultas que se han creado siguen
 * estando en pendiente de respuesta pasadas 24 horas. Si siguen en pendiente de respuesta, crea una alerta y inserta un registro
 * nuevo de pending process para que vuelva a comprobar la consulta al cabo de otras 24 horas y volver a mandar alertas si hiciera falta.
 * Esta clase se lanza mediante el registro de pending process que se crea al insertar una consulta (se pone para que se lance al cabo de 24 horas).
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US418231         CS             05/09/2022   Creación
 * 1.1            US494885         Alex Perez     14/12/22     hacerlo configurable
*************************************************************************/
public without sharing class SAC_SchedulableAlertas extends CBK_SCH_Queueable_Abstract{
    public override void execute(QueueableContext ctx) {
        List<CBK_SCH_PendingProcess__c> lstInfoPp = this.lstInfoProcess;
        work(lstInfoPp);
 
    }
 
    @TestVisible
    private void work(List<CBK_SCH_PendingProcess__c> lstInfoPp) {

        //Comprobar si hace mas de 24 horas desde el createdDate hasta ahora y sigue sin contestarse
        try {
            Id recTypeConsulta = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
            Id recTypeConsultaSPV = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SPV_Consulta').getRecordTypeId();
            Id recTypeLetradosDT = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SAC_LetradosDT').getRecordTypeId();
            List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
            List<SAC_Interaccion__c> listaConsultas = new List<SAC_Interaccion__c>();
            Set<Id> setIdsConsulta = new Set<Id>();
            List<CBK_SCH_PendingProcess__c> nuevosPendingProcess = new List<CBK_SCH_PendingProcess__c>();
            Map<String, CBK_SCH_PendingProcess__c> mapaPendingProcess = new Map<String, CBK_SCH_PendingProcess__c>();
            List<SAC_MaestroTemas__c> listaLetradosDT = new List<SAC_MaestroTemas__c>();
            Map<Id, SAC_MaestroTemas__c> mapaLetradosDT = new Map<Id, SAC_MaestroTemas__c>();

            List<Group> listaColas = [SELECT Id, DeveloperName, Name FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];

            //Recorrer los pendingProcess para sacar las ids de las consultas y poder recuperarlas
            //Además, creamos nuevos pending process copiados de los originales para volver a comprobar si debe alertar al cabo de 24 horas
            for (CBK_SCH_PendingProcess__c pendingProcessConsulta : lstInfoPp) {
                setIdsConsulta.add(pendingProcessConsulta.RecordId__c);
                //Añadirlos a mapa con key de registro consulta
                mapaPendingProcess.put(pendingProcessConsulta.RecordId__c, pendingProcessConsulta);
            }

            //Recuperar las consultas
            if (!setIdsConsulta.isEmpty()) {
                listaConsultas = [SELECT Id, Name, SAC_Reclamacion__c, OwnerId, SAC_Estado__c, SAC_GrupoColaborador__c, SAC_GrupoColaborador__r.SAC_Email__c,
                                    SAC_GrupoColaborador__r.SAC_Email2__c, SAC_GrupoColaborador__r.SAC_Email3__c, SAC_Oficina__c, SAC_Oficina__r.CC_Email__c,
                                    SAC_GrupoColaborador__r.SAC_Externo__c, SAC_Titulo__c, SAC_Correos48h__c, SAC_Reclamacion__r.Subject, 
                                    SAC_Oficina__r.Parent.CC_Email__c, SAC_Oficina__r.Parent.Parent.CC_Email__c, SAC_Oficina__r.CC_Tipo_Centro__c,
                                    SAC_Oficina__r.Parent.CC_Tipo_Centro__c, SAC_Oficina__r.Parent.Parent.CC_Tipo_Centro__c, SAC_Oficina__r.Parent.Parent.Parent.CC_Tipo_Centro__c,
                                    SAC_Oficina__r.Parent.Parent.Parent.Parent.CC_Tipo_Centro__c, SAC_EmailOficina__c, RecordTypeId, SAC_GrupoColaborador__r.SAC_DeveloperName__c
                                    FROM SAC_Interaccion__c WHERE (RecordTypeId = :recTypeConsulta OR RecordTypeId = :recTypeConsultaSPV) AND Id IN :setIdsConsulta];
            }
            List<SAC_MaestroTipologiasAlertas__mdt> listaMaestros = [SELECT Id, SAC_Tipo__c, toLabel(SAC_Tipo__c) labelTipo, SAC_RequiereNotificacion__c, SAC_RequiereAlerta__c, SAC_RequiereEmail__c,
                                                                        SAC_OrgWideAddress__c, SAC_Plantilla__c, DeveloperName, SAC_SiguienteEjecucion__c, SAC_TiempoEjecucion__c, SAC_Condiciones__c,
                                                                        SAC_PararEjecucion__c, SAC_Destinatarios__c, SAC_Prioridad__c
                                                                    FROM SAC_MaestroTipologiasAlertas__mdt
                                                                    WHERE (SAC_Tipo__c = 'SAC_003' OR SAC_Tipo__c = 'SPV_004')
                                                                    ORDER BY SAC_Prioridad__c DESC, SAC_TiempoEjecucion__c DESC];

            //Recuperar letrados DT y almacenarlos en mapa
            listaLetradosDT = [SELECT Id, SAC_GrupoLetradoDT__c, SAC_Oficina__c, SAC_CorreoLetradoDT__c FROM SAC_MaestroTemas__c WHERE RecordTypeId = :recTypeLetradosDT AND SAC_GrupoLetradoDT__r.SAC_DeveloperName__c = 'LetradosDT'];

            if (!listaLetradosDT.isEmpty()) {
                for (SAC_MaestroTemas__c letDT : listaLetradosDT) {
                    mapaLetradosDT.put(letDT.SAC_Oficina__c, letDT);
                }
            }
                                                                    
            //Recorrer consultas y ver a cuales hay que mandarles alerta
            for (SAC_Interaccion__c consulta : listaConsultas) {
                //Si la consulta sigue en pendiente de respuesta (esto se ha lanzado 24 horas despues de crearse) hay que mandar alerta
                if (consulta.SAC_Estado__c == 'SAC_PendienteRespuesta' || consulta.SAC_Estado__c == 'SAC_PendienteRespuestaDefinitiva') {
                    SAC_WrapperAlerta wrapAlerta;

                    sObject sobjConsulta = (sObject)consulta;

                    for(SAC_MaestroTipologiasAlertas__mdt maestro : listaMaestros) {

                        //Validar que para cada consulta, se tome el maestro de alertas correspondiente a su proyecto SAC o SPV
                        if((consulta.RecordTypeId == recTypeConsulta && maestro.SAC_Tipo__c == 'SAC_003') || (consulta.RecordTypeId == recTypeConsultaSPV && maestro.SAC_Tipo__c == 'SPV_004')){

                            if(maestro.SAC_TiempoEjecucion__c > decimal.valueof(mapaPendingProcess.get(consulta.Id).Param1__c) ||
                            maestro.SAC_Condiciones__c == null) {
                                continue;
                            }
                            list<string> condiciones = (maestro.SAC_Condiciones__c).split(';');
                            boolean bPlantilla= true;
                            for(string condicion : condiciones) {
                                list<string> actores = condicion.split(' ');
                                string sActor;
                                decimal dActor;
                                //para diferenciar entre texto y number al realizar la comparación y así hacer la conversión correctamente
                                boolean bsActor = false;
                                boolean bdActor = false;
                        
                                //si se ha puesto en la conf que es null
                                if(actores[2] == 'null') {
                                    bsActor = true;
                                //si es texto
                                } else if (actores[2].startsWith('\'')) {
                                    sActor = actores[2].replace('\'','');
                                    bsActor = true;
                                //si es number
                                } else {
                                    dActor = decimal.valueOf(actores[2]);
                                    bdActor = true;
                                }
                                //logica para sacar campos relacionados de otros objetos
                                list<string> actor0spliteado = actores[0].split('\\.');
                                sObject sOrelacionado;
                                object oActor0;
                                if(actor0spliteado.size() > 1) {
                                    for(integer inte = 0; actor0spliteado.size() > inte+1; inte++) {
                                        sOrelacionado = sobjConsulta.getSObject(actor0spliteado[inte]);
                                    }
                                    oActor0 = sOrelacionado.get(actor0spliteado[actor0spliteado.size()-1]);
                                } else {
                                    oActor0 = sobjConsulta.get(actores[0]);
                                }
                                
                                if(actores[1] == '=') {if(bsActor && string.valueof(oActor0) != sActor || bdActor && decimal.valueof(string.valueof(oActor0)) != dActor) {bPlantilla = false;}
                                }else if(actores[1] == '>') {if(bsActor && string.valueof(oActor0) <= sActor || bdActor && decimal.valueof(string.valueof(oActor0)) <= dActor) {bPlantilla = false;}

                                } else if(actores[1] == '<') {if(bsActor && string.valueof(oActor0) >= sActor || bdActor && decimal.valueof(string.valueof(oActor0)) >= dActor) {bPlantilla = false;}

                                } else if(actores[1] == '>=') {if(bsActor && string.valueof(oActor0) < sActor || bdActor && decimal.valueof(string.valueof(oActor0)) < dActor) {bPlantilla = false;}

                                } else if(actores[1] == '<=') {if(bsActor && string.valueof(oActor0) > sActor || bdActor && decimal.valueof(string.valueof(oActor0)) > dActor) {bPlantilla = false;}

                                }else if(actores[1] == '!=') {
                                    if(bsActor && string.valueof(oActor0) == sActor || bdActor && decimal.valueof(string.valueof(oActor0)) == dActor) {bPlantilla = false;}

                                }
                            }

                            if(bPlantilla) {
                                wrapAlerta = new SAC_WrapperAlerta(consulta.SAC_Reclamacion__c, maestro.DeveloperName, '', '', '', '', consulta.Id);
                                
                                if((maestro.SAC_PararEjecucion__c > decimal.valueof(mapaPendingProcess.get(consulta.Id).Param1__c) ||
                                maestro.SAC_PararEjecucion__c == null) &&  maestro.SAC_SiguienteEjecucion__c != null){
                                    CBK_SCH_PendingProcess__c pendingProcessConsultaCopia = new CBK_SCH_PendingProcess__c();
                                    pendingProcessConsultaCopia.recordId__c = consulta.Id;
                                    pendingProcessConsultaCopia.Schedule_Time__c = system.now().addHours(integer.valueOf(maestro.SAC_SiguienteEjecucion__c));
                                    pendingProcessConsultaCopia.className__c = 'SAC_SchedulableAlertas';
                                    pendingProcessConsultaCopia.Param1__c = string.valueOf((decimal.valueof(mapaPendingProcess.get(consulta.Id).Param1__c) + maestro.SAC_SiguienteEjecucion__c));
                                    nuevosPendingProcess.add(pendingProcessConsultaCopia);
                                }
                                //incluimos los destinatarios que estan en los campos configurados en el metadata de maestros
                                for(string destinatario : maestro.SAC_Destinatarios__c.split(';')) {
                                    list<string> destinatarioEspliteado = destinatario.split('\\.');
                                    sObject sOrelacionado;
                                    object oDestinatario;
                                    if(destinatarioEspliteado.size() > 1) {
                                        sOrelacionado = sobjConsulta;
                                        for(integer inte = 0; destinatarioEspliteado.size() > inte+1; inte++) {
                                            sOrelacionado = sOrelacionado.getSObject(destinatarioEspliteado[inte]);
                                        }
                                        oDestinatario = sOrelacionado.get(destinatarioEspliteado[destinatarioEspliteado.size()-1]);
                                    } else {
                                        oDestinatario = sobjConsulta.get(destinatario);
                                    }
                                    if(oDestinatario != null) {
                                        //Modificación: Añadido spliteo por si viene en el campo más de un correo concatenado con ;
                                        if (String.valueOf(oDestinatario).contains(';')) {
                                            for (String destSplitFinal : String.valueOf(oDestinatario).split(';')) {
                                                wrapAlerta.listaEmailsGrupo.add(destSplitFinal);
                                            }
                                        } else {
                                            wrapAlerta.listaEmailsGrupo.add(string.valueOf(oDestinatario));
                                        }

                                        //Añadido para los DT de 72
                                        String correoLetradoDT = '';
                                        correoLetradoDT = buscarLetradoDT(consulta, maestro, mapaLetradosDT);
                                        if (String.isNotBlank(correoLetradoDT)) {
                                            wrapAlerta.listaEmailsGrupo.add(correoLetradoDT);
                                        }
                                    }
                                }
                                wrapAlerta.idGrupoColaborador = consulta.SAC_GrupoColaborador__c;
                                
                                //Si es una consulta de SPV
                                if(consulta.RecordTypeId == recTypeConsultaSPV){
                                    wrapAlerta.proyecto = 'SPV';

                                    //Si es una consulta interna NO oficina y no esta pendiente de asignar, le asignamos un idDestinatario para la alerta de campanita 
                                    if(consulta.SAC_GrupoColaborador__r.SAC_Externo__c == false && consulta.SAC_GrupoColaborador__r.SAC_DeveloperName__c != 'OFICINA' && consulta.OwnerId != listaColas[0].Id){
                                        wrapAlerta.idUsuarioDestinatario = consulta.OwnerId;
                                    }
                                }
                                
                                listaWrapperAlerta.add(wrapAlerta);
                                break;
                            }
                        }
                    }
                }
            }
            //Si tenemos alertas que enviar, se llama al método que las envía
            if (!listaWrapperAlerta.isEmpty()) {
                SAC_Alertas.generarAlertas(listaWrapperAlerta);
            }
            //Ya que hemos tenido que mandar alertas porque sigue pendiente de respuesta, volvemos a insertar los mismos pending process
            //para que vuelva a comprobar si tiene que volver a alertar al cabo de 24 horas más
            if (!nuevosPendingProcess.isEmpty()) {
                SAC_DatabaseDML.insertListDML(nuevosPendingProcess, true);
            }
        }catch(Exception e) {
            CBK_Log.error(e);
        }
    }

    private static String buscarLetradoDT(SAC_Interaccion__c consulta, SAC_MaestroTipologiasAlertas__mdt maestro, Map<Id, SAC_MaestroTemas__c> mapaLetradosDT) {
        String idOficinaDT = '';
        String correoLetradoDT = '';
        //Si el maestro de la alerta nos indica que es la de 72 horas, hay que buscar el letrado DT de la oficina
        if (maestro.DeveloperName == 'SAC_ConsultaPdteRespuesta72ofi' || maestro.DeveloperName == 'SPV_ConsultaPdteRespuesta72ofi') {
            if (String.isNotBlank(consulta.SAC_Oficina__r.CC_Tipo_Centro__c) && consulta.SAC_Oficina__r.CC_Tipo_Centro__c == 'DT') {
                idOficinaDT = consulta.SAC_Oficina__c;
            } else if (String.isNotBlank(consulta.SAC_Oficina__r.Parent.CC_Tipo_Centro__c) && consulta.SAC_Oficina__r.Parent.CC_Tipo_Centro__c == 'DT') {
                idOficinaDT = consulta.SAC_Oficina__r.ParentId;
            }
            else if (String.isNotBlank(consulta.SAC_Oficina__r.Parent.Parent.CC_Tipo_Centro__c) && consulta.SAC_Oficina__r.Parent.Parent.CC_Tipo_Centro__c == 'DT') {
                idOficinaDT = consulta.SAC_Oficina__r.Parent.ParentId;
            }
            else if (String.isNotBlank(consulta.SAC_Oficina__r.Parent.Parent.Parent.CC_Tipo_Centro__c) && consulta.SAC_Oficina__r.Parent.Parent.Parent.CC_Tipo_Centro__c == 'DT') {
                idOficinaDT = consulta.SAC_Oficina__r.Parent.Parent.ParentId;
            }
            else if (String.isNotBlank(consulta.SAC_Oficina__r.Parent.Parent.Parent.Parent.CC_Tipo_Centro__c) && consulta.SAC_Oficina__r.Parent.Parent.Parent.Parent.CC_Tipo_Centro__c == 'DT') {
                idOficinaDT = consulta.SAC_Oficina__r.Parent.Parent.Parent.ParentId;
            }
        }

        //Buscar el letrado de la oficina DT y almacenar el correo del letrado en la variable a retornar
        if (String.isNotBlank(idOficinaDT)) {
            if (mapaLetradosDT.containsKey(idOficinaDT)) {
                correoLetradoDT = mapaLetradosDT.get(idOficinaDT).SAC_CorreoLetradoDT__c;
            }   
        }

        return  correoLetradoDT;
    }
}