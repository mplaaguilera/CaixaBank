public with sharing class CSBD_ProductoOportunidadHija {


    @AuraEnabled
    public static List<String> crearOportunidadesHijas(List<String> productos, String etapa, String parentId, String nombreRecordType, String resolucion) {
        List<String> identificadores;
        List<CC_Lista_Valores__c> listasDeValores = [SELECT CC_Valor2__c, CC_Valor__c,Name FROM CC_Lista_Valores__c
                                                        WHERE CC_Lista__r.Name = 'CSBD: Acciones comerciales oportunidad' AND CC_Activa__c = true
                                                        AND CC_Valor_SFDC__c = :nombreRecordType AND CC_Valor2__c IN :productos];
        if (!listasDeValores.isEmpty()) {
            Opportunity oportunidadPadre = [SELECT Recordtype.Name, AV_Producto__c, AV_FechaModificacion__c, AccountId, RecordTypeId, Name, Description, StageName, Probability, CloseDate, OwnerId, CSBD_Circuito_Contratacion_Online__c,
            CSBD_Contact__c, CSBD_Diferencial_Limite__c, CSBD_Email_Solicitud__c, CSBD_Empresa_Proveedora_Logo__c, CSBD_Empresa_Proveedora__c, CSBD_Estado__c, CSBD_Estado_Tracking__c, CSBD_Idioma_Solicitud__c,
            CSBD_Importe_Producto_Principal__c, CSBD_Limite_Compra_Estrella__c, CSBD_Limite_Prestamos_Canales__c, CSBD_Limite_Prestamos_Oficinas__c, CSBD_Limite_Tarjetas_Canales__c, CSBD_Limite_Tarjetas_Oficinas__c,
            CSBD_Motivo_Pendiente_Interno__c, CSBD_Now_Boton__c, CSBD_Now_Codigo_Producto_Formato__c, CSBD_Now_Canal_Peticion__c, CSBD_Now_Id_Producto__c, CSBD_Skill__c, CSBD_Prioridad_Tracking__c,
            CSBD_Resolucion__c, CSBD_Scoring_Riesgo__c, CSBD_Subestado_Tracking__c, CSBD_Telefono_Solicitud__c, CSBD_Codigo_Estado_Tracking__c, CSBD_Now_Apellido1__c, CSBD_Now_Apellido2__c,
            CSBD_Now_Apellidos1_1Tit__c, CSBD_Now_Apellidos1_2Tit__c, CSBD_Now_Apellidos2_1Tit__c, CSBD_Now_Apellidos2_2Tit__c, CSBD_Now_Canal__c, CSBD_Now_CodProducto__c, CSBD_Now_DescripMotivo__c,
            CSBD_Now_Descripcion__c, CSBD_Now_DirVivienda__c, CSBD_Now_EmailGestor__c, CSBD_Now_EmailOficinaLO__c, CSBD_Now_EstatCivil2Tit__c, CSBD_Now_Finalidad__c, CSBD_Now_Hora__c, CSBD_Now_Horario2Tit__c,
            CSBD_Now_Id_Tarjeta__c, CSBD_Now_Importe__c, CSBD_Now_NIF1Tit__c, CSBD_Now_NIF2Tit__c, CSBD_Now_NIFSolicitante__c, CSBD_Now_NIF__c, CSBD_Now_NUMPERSO__c, CSBD_Now_Nacionalidad2Tit__c,
            CSBD_Now_Nombre1Tit__c, CSBD_Now_Nombre2Tit__c, CSBD_Now_NombreCompleto__c, CSBD_Now_NombreProducto__c, CSBD_Now_NombreSolicitante__c, CSBD_Now_Nombre__c, CSBD_Now_Nomina2Tit__c, CSBD_Now_Num_Oficina__c,
            CSBD_Now_Numsolicitud__c, CSBD_Now_Origen__c, CSBD_Now_Pais_Residencia2Tit__c, CSBD_Now_Plazo__c, CSBD_Now_Pobl2Tit__c, CSBD_Now_PoblVivienda__c, CSBD_Now_Presolicitud__c, CSBD_Now_Resultado__c,
            CSBD_Now_Subproducto_1__c, CSBD_Now_ValorVivienda__c, CSBD_Now_Vehiculo__c, CSBD_Ultima_Etapa_Ventas__c, CSBD_Asignacion_Auto_Pendiente__c, CSBD_Contact_Escala_Maestra__c, CSBD_Contact_Heavy_Digital__c,
            CSBD_Dif_Importe_Preconcedido__c, CSBD_PushTopic_Estado__c, CSBD_RecordType_DeveloperName__c, CSBD_Canal__c, CSBD_Con_Duplicados__c, CSBD_Dejar_Pendiente_Cliente__c, CSBD_Dispone_Importe_Preconcedido__c,
            CSBD_Familia_Producto__c, CSBD_Fecha_Cita__c, CSBD_Horario_Contacto__c, CSBD_Importe_Disponible_Contacto__c, CSBD_Now_Campanya__c, CSBD_Now_Codigo_Producto__c, CSBD_Now_Contrato__c,
            CSBD_Now_DiaPeticion__c, CSBD_Now_FechaContratacion__c, CSBD_Now_USUCLO__c, CSBD_OficinaLO__c, CSBD_Producto__c, CSBD_Programar_Propietario_Id__c, CSBD_Reactivada_Respuesta_Recibida__c,
            CSBD_Resolucion_QuickAction_Cerrar__c, CSBD_Resumen__c, CSBD_StageName_QuickAction_Cerrar__c, CSBD_Turno_Contacto__c, CSBD_Vehiculo_Renting__c, CSBD_Fecha_ultimacita__c, CSBD_Fecha_Firma__c,
            CSBD_Created_date_time__c, CSBD_Detalle_producto__c, CSBD_Comentarios_cliente__c, CSBD_Cliente_Internacional__c FROM Opportunity WHERE Id = :parentId];

            List<Task> tareasInsert = new List<Task>();
            List<Opportunity> oportunidadesCerradas = new List<Opportunity>();
            List<Opportunity> listaOportunidades = new List<Opportunity>();

            for (CC_Lista_Valores__c listaDeValores : listasDeValores) {
                Opportunity oportunidadHija = nuevaOportunidadHija(oportunidadPadre, etapa, listaDeValores, CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_Accion_Comercial'),resolucion);
                listaOportunidades.add(oportunidadHija);
                if (oportunidadHija.StageName == 'Formalizada' || oportunidadHija.StageName == 'Rechazada' || oportunidadHija.StageName == 'Perdida') {
                    oportunidadesCerradas.add(oportunidadHija);
                }
            }
            insert listaOportunidades;
            List<Id> idOportunidadesCreadas = CC_MetodosUtiles.listaCampo(listaOportunidades, 'Id');
            identificadores = CC_MetodosUtiles.listaCampo([SELECT CSBD_Identificador__c FROM Opportunity WHERE Id IN :idOportunidadesCreadas], 'CSBD_Identificador__c');

            if (!oportunidadesCerradas.isEmpty()) {
                for (Opportunity oportunidad : oportunidadesCerradas) {
                    Task tarea = new Task();
                    tarea = CSBD_Activity.crearActividadReturn(tarea, oportunidad.Id, oportunidad.CSBD_Estado__c, 'Completed', oportunidad.CSBD_Estado__c, null, null);
                    tareasInsert.add(tarea);
                }
                insert tareasInsert;
            }
        }
        return identificadores;
    }

    public static Opportunity nuevaOportunidadHija(Opportunity oportunidadPadre, String etapa, CC_Lista_Valores__c listaDeValores, Id idRecordType,String resolucion) {
        Opportunity oportunidadHija = new Opportunity();
        oportunidadHija = oportunidadPadre.clone(false, false, false, false);
        oportunidadHija.Name = 'temp';
        oportunidadHija.CSBD_Producto__c = listaDeValores.CC_Valor2__c;
        oportunidadHija.CSBD_Familia_Producto__c = listaDeValores.CC_Valor__c;
        oportunidadHija.CSBD_Now_Codigo_Producto__c = listaDeValores.Name;
        oportunidadHija.CSBD_Parent_Id__c = oportunidadPadre.Id;
        oportunidadHija.RecordTypeId = idRecordType;
        oportunidadHija.OwnerId = oportunidadPadre.OwnerId;
        oportunidadHija.CSBD_Resolucion__c = resolucion;
        oportunidadHija.CSBD_Canal__c = 'Venta cruzada ' + oportunidadPadre.RecordType.Name;
        oportunidadHija.StageName = etapa;
        oportunidadHija.CSBD_Estado__c = new Map<String, String>{
            'Rechazada' => 'Rechazada', 'Formalizada' => 'Cerrada', 'Perdida' => 'Cerrada'
        }.get(etapa) ?? 'Activa';

        /*
        if (oportunidadHija.StageName == 'Rechazada') {
            oportunidadHija.CSBD_Estado__c = oportunidadPadre.StageName;
        } else if (oportunidadHija.StageName == 'Formalizada' || oportunidadHija.StageName == 'Perdida') {
            oportunidadHija.CSBD_Estado__c = 'Cerrada';
        } else {
            oportunidadHija.CSBD_Estado__c = 'Activa';
        }
        */
        return oportunidadHija;
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_Lista_Valores__c> obtenerProductos(String nombreRecordType) {
        return [SELECT CC_Valor2__c, CC_Valor__c, Name FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'CSBD: Acciones comerciales oportunidad' and CC_Valor_SFDC__c = :nombreRecordType AND CC_Activa__c = true ORDER BY CC_Valor2__c  LIMIT 100 ];
    }

    @AuraEnabled
    public static List<Opportunity> obtenerOportunidadesHijas(id oportunidadId) {
        return [SELECT CSBD_Producto__c ,CSBD_Familia_Producto__c ,Name ,CSBD_Now_Codigo_Producto__c ,StageName FROM Opportunity WHERE CSBD_Parent_Id__c = :oportunidadId AND Recordtype.DeveloperName = 'CSBD_Accion_Comercial' ];
    }

    public static void actualizarPropietarioOportunidadesHijas(Map<Id, Opportunity> idOportunidad) {
        List<Opportunity> oportunidadesHijasAbiertas =  [SELECT OwnerId, CSBD_Parent_Id__c FROM Opportunity
                                                            WHERE CSBD_Parent_Id__c = :idOportunidad.keySet() AND Recordtype.DeveloperName = 'CSBD_Accion_Comercial' AND IsClosed = false];
        if(!oportunidadesHijasAbiertas.isEmpty()) {
            Set<Id> oportunidadesReasignadas = new Set<Id>();
            for(Opportunity oportunidad: oportunidadesHijasAbiertas) {
                if(idOportunidad.containsKey(oportunidad.CSBD_Parent_Id__c) && oportunidad.OwnerId != idOportunidad.get(oportunidad.CSBD_Parent_Id__c).OwnerId) {
                    oportunidad.OwnerId = idOportunidad.get(oportunidad.CSBD_Parent_Id__c).OwnerId;
                    oportunidadesReasignadas.add(oportunidad.Id);
                }
            }
            Update oportunidadesHijasAbiertas;
            if(!oportunidadesReasignadas.isEmpty()){
                CSBD_Activity.crearActividadReasignacion(oportunidadesReasignadas, 'Reasignación', 'Oportunidad reasignada jerárquicamente.');
            }
        }
    }

    public static void cerrarOportunidadesHijas(Map<Id, Opportunity> idOportunidad) {
        List<Opportunity> opp =  [SELECT RecordType.Name FROM Opportunity WHERE Id = :idOportunidad.keySet()];

        Map<Id, List<Opportunity>> oportunidadIdListaHijas = new Map<Id, List<Opportunity>>();
        for(Opportunity oportunidadHija: [SELECT StageName, CSBD_Estado__c, CSBD_Parent_Id__c, CSBD_Identificador__c,CSBD_Resolucion__c, RecordType.DeveloperName, CSBD_Alta_omnichannel__c, CSBD_Empresa_Proveedora__c, CSBD_Contact__c FROM Opportunity
                                            WHERE CSBD_Parent_Id__c = :idOportunidad.keySet() AND Recordtype.DeveloperName = 'CSBD_Accion_Comercial' AND IsClosed = false]) {

            if(!oportunidadIdListaHijas.containsKey(oportunidadHija.CSBD_Parent_Id__c)) {
                oportunidadIdListaHijas.put(oportunidadHija.CSBD_Parent_Id__c, new List<Opportunity>());
            }
            oportunidadIdListaHijas.get(oportunidadHija.CSBD_Parent_Id__c).add(oportunidadHija);
        }
        for(Opportunity oportunidadPadre: idOportunidad.values()) {
            if(oportunidadIdListaHijas.containsKey(oportunidadPadre.Id)){
                if (oportunidadPadre.StageName == 'Perdida') {
                    CSBD_Opportunity.cerrarOportunidad(oportunidadIdListaHijas.get(oportunidadPadre.Id), 'Rechazada', 'Oportunidad ' + opp[0].RecordType.Name +' asociada perdida');
                }else{
                    CSBD_Opportunity.cerrarOportunidad(oportunidadIdListaHijas.get(oportunidadPadre.Id), oportunidadPadre.StageName, oportunidadPadre.CSBD_Resolucion__c);
                }
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean obtenerOportunidadesHijasAbiertas(Id idOportunidad) {
        return ![SELECT Id FROM Opportunity WHERE CSBD_Parent_Id__c = :idOportunidad AND IsClosed = FALSE
                    AND RecordType.DeveloperName = 'CSBD_Accion_Comercial' LIMIT 1].isEmpty();
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccounts(String cadenaBusqueda) {
        if (Schema.SObjectType.Account.isAccessible()){
            return [FIND :cadenaBusqueda IN ALL FIELDS
                    RETURNING Account(Name, CC_Numero_Documento__c
                    WHERE RecordType.DeveloperName IN ('CC_Cliente', 'CC_ClientePA'))
                    LIMIT 15][0];
        } else {
            throw new AuraHandledException('Permisos insuficientes');
        }
    }

    @AuraEnabled
    public static Opportunity duplicarOpp (String oppId, String rt, String accId){

        Opportunity oppActual = [SELECT Recordtype.Name, AV_Producto__c, AV_FechaModificacion__c, AccountId, RecordTypeId, Name, Description, StageName, Probability, CloseDate, OwnerId, CSBD_Circuito_Contratacion_Online__c,
        CSBD_Contact__c, CSBD_Diferencial_Limite__c, CSBD_Email_Solicitud__c, CSBD_Empresa_Proveedora_Logo__c, CSBD_Empresa_Proveedora__c, CSBD_Estado__c, CSBD_Estado_Tracking__c, CSBD_Idioma_Solicitud__c,
        CSBD_Importe_Producto_Principal__c, CSBD_Identificador__c, CSBD_Limite_Compra_Estrella__c, CSBD_Limite_Prestamos_Canales__c, CSBD_Limite_Prestamos_Oficinas__c, CSBD_Limite_Tarjetas_Canales__c, CSBD_Limite_Tarjetas_Oficinas__c,
        CSBD_Motivo_Pendiente_Interno__c, CSBD_Now_Boton__c, CSBD_Now_Codigo_Producto_Formato__c, CSBD_Now_Canal_Peticion__c, CSBD_Now_Id_Producto__c, CSBD_Skill__c, CSBD_Prioridad_Tracking__c,
        CSBD_Resolucion__c, CSBD_Scoring_Riesgo__c, CSBD_Subestado_Tracking__c, CSBD_Telefono_Solicitud__c, CSBD_Codigo_Estado_Tracking__c, CSBD_Now_Apellido1__c, CSBD_Now_Apellido2__c,
        CSBD_Now_Apellidos1_1Tit__c, CSBD_Now_Apellidos1_2Tit__c, CSBD_Now_Apellidos2_1Tit__c, CSBD_Now_Apellidos2_2Tit__c, CSBD_Now_Canal__c, CSBD_Now_CodProducto__c, CSBD_Now_DescripMotivo__c,
        CSBD_Now_Descripcion__c, CSBD_Now_DirVivienda__c, CSBD_Now_EmailGestor__c, CSBD_Now_EmailOficinaLO__c, CSBD_Now_EstatCivil2Tit__c, CSBD_Now_Finalidad__c, CSBD_Now_Hora__c, CSBD_Now_Horario2Tit__c,
        CSBD_Now_Id_Tarjeta__c, CSBD_Now_Importe__c, CSBD_Now_NIF1Tit__c, CSBD_Now_NIF2Tit__c, CSBD_Now_NIFSolicitante__c, CSBD_Now_NIF__c, CSBD_Now_NUMPERSO__c, CSBD_Now_Nacionalidad2Tit__c,
        CSBD_Now_Nombre1Tit__c, CSBD_Now_Nombre2Tit__c, CSBD_Now_NombreCompleto__c, CSBD_Now_NombreProducto__c, CSBD_Now_NombreSolicitante__c, CSBD_Now_Nombre__c, CSBD_Now_Nomina2Tit__c, CSBD_Now_Num_Oficina__c,
        CSBD_Now_Numsolicitud__c, CSBD_Now_Origen__c, CSBD_Now_Pais_Residencia2Tit__c, CSBD_Now_Plazo__c, CSBD_Now_Pobl2Tit__c, CSBD_Now_PoblVivienda__c, CSBD_Now_Presolicitud__c, CSBD_Now_Resultado__c,
        CSBD_Now_Subproducto_1__c, CSBD_Now_ValorVivienda__c, CSBD_Now_Vehiculo__c, CSBD_Ultima_Etapa_Ventas__c, CSBD_Asignacion_Auto_Pendiente__c, CSBD_Contact_Escala_Maestra__c, CSBD_Contact_Heavy_Digital__c,
        CSBD_Dif_Importe_Preconcedido__c, CSBD_PushTopic_Estado__c, CSBD_RecordType_DeveloperName__c, CSBD_Canal__c, CSBD_Con_Duplicados__c, CSBD_Dejar_Pendiente_Cliente__c, CSBD_Dispone_Importe_Preconcedido__c,
        CSBD_Familia_Producto__c, CSBD_Fecha_Cita__c, CSBD_Horario_Contacto__c, CSBD_Importe_Disponible_Contacto__c, CSBD_Now_Campanya__c, CSBD_Now_Codigo_Producto__c, CSBD_Now_Contrato__c,
        CSBD_Now_DiaPeticion__c, CSBD_Now_FechaContratacion__c, CSBD_Now_USUCLO__c, CSBD_OficinaLO__c, CSBD_Producto__c, CSBD_Programar_Propietario_Id__c, CSBD_Reactivada_Respuesta_Recibida__c,
        CSBD_Resolucion_QuickAction_Cerrar__c, CSBD_Resumen__c, CSBD_StageName_QuickAction_Cerrar__c, CSBD_Turno_Contacto__c, CSBD_Vehiculo_Renting__c, CSBD_Fecha_ultimacita__c, CSBD_Fecha_Firma__c,
        CSBD_Created_date_time__c, CSBD_Detalle_producto__c, CSBD_Comentarios_cliente__c, CSBD_Cliente_Internacional__c FROM Opportunity WHERE Id = :oppId];

        Opportunity nuevaOpp = CSBD_Opportunity.duplicarOportunidad(oppActual, rt, null);
        nuevaOpp.AccountId = accId;
        update nuevaOpp;
        return nuevaOpp;
    }
}