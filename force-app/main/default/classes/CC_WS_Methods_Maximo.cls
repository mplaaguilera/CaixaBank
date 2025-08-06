public with sharing class CC_WS_Methods_Maximo {

    static private String convertirFechaMaximo (Datetime dFecha) {

        String sNewFecha = '';

        if (dFecha != null) {
            String sAux = String.valueOf(dFecha.dateGmt());
            sAux = sAux.substringBefore(' ');

            String sAux2 = String.valueOf(dFecha.timeGmt());
            sAux2 = sAux2.substringBefore('.');

            sNewFecha = sAux + 'T' + sAux2 + '+00:00';
        }
        return sNewFecha;
    }

    /*
Recuperar los datos de los agrupadores a enviar a Máximo.
*/
    static private Map<String,Object> recuperarAgrupador (Set<Id> oID) {
        Id recordTypeEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id recordTypeEmpleadoCSIBankia = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        Id recordTypeEmpleadoHDT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        Map<String,Object> oRes = new Map<String,Object>();
        Map<String,String> oIncUsu = new Map<String,String>();
        Map<String,String> oUsuId = new Map<String,String>();

        if (oID == null || oID.isEmpty()) {
            return oRes;
        }

        // Buscar los datos de los Agrupadores.
        for (CC_Agrupador__c oIncidencia : [SELECT Name, CC_Id_Maximo__c, CC_Titulo__c, CC_Descripcion__c, CC_Clasificacion_Maximo__c, CC_Clasificacion_Maximo__r.CC_Nivel_1__c,
                                            CC_Clasificacion_Maximo__r.CC_Propietario__c, CC_Clasificacion_Maximo__r.CC_Path__c, CC_Persona_Afectada__c, CC_Opcion_Call_Center__c,
                                            CC_GrupoMaximo__c, CC_GrupoMaximo__r.Name, CreatedById,
                                            (SELECT CreatedDate, CaseNumber,HDT_Activo_Secundario__r.Account.CC_Numero_Empresa__c , HDT_Activo_Secundario__r.Account.CC_Numero_Oficina__c, HDT_Activo_Secundario__c, HDT_Activo_Secundario__r.CC_Numero_Maquina__c,  Asset.CC_Numero_Maquina__c, Asset.Account.CC_Numero_Empresa__c,
                                                Asset.Account.CC_Numero_Oficina__c, Contact.Name, RecordTypeId, Contact.CC_Matricula__c, Contact.Account.CC_Numero_Empresa__c
                                                FROM Casos__r ORDER BY CreatedDate ASC),
                                            CC_Tematica_Id__r.Name, CC_Producto_Servicio__r.Name, CC_Motivo__r.Name, CC_CanalEntrada__c, CC_CanalProcedencia__c
                                            FROM CC_Agrupador__c WHERE Id IN :oID]) {

            Map<String,String> oInc = new Map<String,String>();
            oInc.put('AFFECTEDDATE', '');
            oInc.put('AFFECTEDPERSONID', '');
            if (oIncidencia.CC_Titulo__c.length() <= 100) {
                oInc.put('DESCRIPTION', oIncidencia.CC_Titulo__c);
            } else {
                oInc.put('DESCRIPTION', oIncidencia.CC_Titulo__c.substring(100));
            }
            oInc.put('DESCRIPTION_LONG', oIncidencia.CC_Descripcion__c);

            if (oIncidencia.CC_Clasificacion_Maximo__c != null)
            {
                if (oIncidencia.CC_Clasificacion_Maximo__r.CC_Path__c != null)
                {
                    oInc.put('HIERARCHYPATH', oIncidencia.CC_Clasificacion_Maximo__r.CC_Path__c);
                }
            }

            oInc.put('ID_MAXIMO', oIncidencia.CC_Id_Maximo__c);
            oInc.put('ITD_BRIDGETICKETNUM', oIncidencia.Name);
            oInc.put('ITDCHCREATEDBYGROUP', oIncidencia.CC_GrupoMaximo__r.Name); //Nombre Grupo Maximo
            oInc.put('ITDCHCREATEDBYGROUPID', String.valueOf(oIncidencia.CC_GrupoMaximo__r.Id)); //id Grupo Maximo convertido en String
            oInc.put('ITNAMBITO', oIncidencia.CC_Clasificacion_Maximo__r.CC_Nivel_1__c);
            oInc.put('ITNINCCLIENTEAFEC', oIncidencia.CC_Persona_Afectada__c);
            oInc.put('ITNINCACCION', oIncidencia.CC_Motivo__r.Name);
            oInc.put('ITNINCCONTRATO', oIncidencia.CC_CanalEntrada__c);
            oInc.put('ITNINCDETALLE', oIncidencia.CC_CanalProcedencia__c);
            oInc.put('ITNINCFAMILIA', oIncidencia.CC_Tematica_Id__r.Name);
            oInc.put('ITNINCPRODUCTO', oIncidencia.CC_Producto_Servicio__r.Name);
            oInc.put('ITNOPCONCALLCENTER', oIncidencia.CC_Opcion_Call_Center__c);
            oInc.put('ITNPROPIETARIO', oIncidencia.CC_Clasificacion_Maximo__r.CC_Propietario__c);
            oInc.put('MAXIMO_CREATED_BY','');
            oInc.put('MAXIMO_CREATIONDATE','');
            oInc.put('REPORTDATE','');
            oInc.put('REPORTEDBYID','');
            //Nos quedamos con el primer caso que se devuelve
            String sFechaAux = '';
            for (Case oCaso : oIncidencia.Casos__r)
            {
                if(String.isNotBlank(oCaso.Contact.Account.CC_Numero_Empresa__c)){
                    //codigo empresa, ponemos dos 0 porque el campo ITNEXTRA4 tiene 5 caracteres y CC_Numero_Empresa__c solo 3, por lo tanto lo rellenamos con 0s
                    oInc.put('ITNEXTRA4', '00' + oCaso.Contact.Account.CC_Numero_Empresa__c);
                }
                // Manipulamos fecha para el formato Máximo.
                sFechaAux = convertirFechaMaximo(oCaso.CreatedDate);
                oInc.put('AFFECTEDDATE', sFechaAux);
                if (oCaso.RecordTypeId == recordTypeEmpleado || oCaso.RecordTypeId == recordTypeEmpleadoCSIBankia || oCaso.RecordTypeId == recordTypeEmpleadoHDT){
                    oInc.put('AFFECTEDPERSONID', oCaso.Contact.CC_Matricula__c);
                }
                break; //Solo queremos el primero
            }

            // Obtener la fecha actual en formato Máximo.
            Datetime oFechaActual = Datetime.now();
            sFechaAux = convertirFechaMaximo(oFechaActual);
            oInc.put('MAXIMO_CREATIONDATE', sFechaAux);
            oInc.put('REPORTDATE', sFechaAux);

            //Incluimos en un map el listado de casos.
            List<Case> oListCasos = new List<Case>();
            for (Case oCase : oIncidencia.Casos__r){
            	oListCasos.add(oCase);
            }

            oRes.put(oIncidencia.Id, oInc);
            oRes.put(oIncidencia.Id + '_Casos', oListCasos);

            oIncUsu.put(oIncidencia.Id, oIncidencia.CreatedById);
        }

        // Buscar los login de usuarios detectados.
        if (!oIncUsu.isEmpty())
        {
            Set<String> oUsuarios = new Set<String>();
            for (String sClave : oIncUsu.keySet())
            {
                if (oIncUsu.get(sClave) != null)
                {
                    oUsuarios.add(oIncUsu.get(sClave));
                }
            }

            if (!oUsuarios.isEmpty())
            {
                for (User oUser : [SELECT Id, EmployeeNumber FROM User WHERE Id IN :oUsuarios])
                {
                    if (oUser.EmployeeNumber != null)
                        if (oUser.EmployeeNumber != '')
                        oUsuId.put(oUser.Id, oUser.EmployeeNumber);
                }
            }
            oUsuarios = null;

            if (!oUsuId.isEmpty())
            {
                for (String sClave : oIncUsu.keySet())
                {
                    if (oIncUsu.get(sClave) != null && oRes.get(sClave) != null)
                    {
                        if (oUsuId.get(oIncUsu.get(sClave)) != null)
                        {
                            ((Map<String,String>)oRes.get(sClave)).put('MAXIMO_CREATED_BY', oUsuId.get(oIncUsu.get(sClave)));
                            ((Map<String,String>)oRes.get(sClave)).put('REPORTEDBYID', oUsuId.get(oIncUsu.get(sClave)));
                        }
                    }
                }
            }
            oUsuId = null;
        }
        oIncUsu =  null;


        return oRes;
    }

    /*
Validar los datos de los agrupadores a enviar a Máximo.
*/
    static private void validarAgrupadores (Map<String,Object> oAgrupadores, Map<String,String> oAmbito, Map<String,String> oRetorno, List<CC_TrazaInt__c> oListTraza, CC_InterfaceSettings__mdt oCfgInt)
    {

        // Recuperar el grupo por defecto.
        String sUserId = UserInfo.getUserId();
        Set<Id> listaIdsUsuariosGrupoMaximo = new Set<Id>();
        Boolean usuarioGrupoMaximo = false;


        if (oAgrupadores == null)
        {
            return;
        }

        if (oAgrupadores.isEmpty())
        {
            return;
        }

        for (String sClave : oAgrupadores.keySet())
        {
            String sDescError = '';
            String sDetalle = '';
            //No queremos que coja el listado de casos
            Boolean oListCases = sClave.contains('_Casos');
            if (oAgrupadores.get(sClave) != null && oListCases == false)
            {
                // No enviar si tiene Id de Máximo.
                Map<String,String> oDataInc = (Map<String,String>)oAgrupadores.get(sClave);

                //--------------------------------------
                // Sergio Castro -> "06-05-2020" -> Metodo que controla si el usuario pertenece al Grupo Colaborador
                //--------------------------------------
                for (CC_Grupo_Colaborador_Contact__c usuariosGrupoMaximo : [SELECT CC_Usuario__r.Id FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__r.id = :oDataInc.get('ITDCHCREATEDBYGROUPID')]){
                    listaIdsUsuariosGrupoMaximo.add(usuariosGrupoMaximo.CC_Usuario__r.Id);
                }

                if(!listaIdsUsuariosGrupoMaximo.isEmpty()){
                    for (String lista : listaIdsUsuariosGrupoMaximo) {
                        if(sUserId == lista){
                            usuarioGrupoMaximo = true;
                        }
                    }
                }

                if (oDataInc.get('ID_MAXIMO') != null)
                {
                    oAgrupadores.remove(sClave);
                    sDescError = 'Validaciones.';
                    sDetalle = 'El Agrupador ya está enviado a Máximo.';
                }else{
                    // Comprobar datos obligatorios.
                    if (oDataInc.get('DESCRIPTION') == null || oDataInc.get('DESCRIPTION_LONG') == null ||
                        oDataInc.get('HIERARCHYPATH') == null || oDataInc.get('ITD_BRIDGETICKETNUM') == null ||
                        oDataInc.get('ITDCHCREATEDBYGROUP') == null || oDataInc.get('ITNAMBITO') == null ||
                        oDataInc.get('ITNOPCONCALLCENTER') == null || oDataInc.get('AFFECTEDDATE') == null ||
                        oDataInc.get('DESCRIPTION') == '' || oDataInc.get('DESCRIPTION_LONG') == '' ||
                        oDataInc.get('HIERARCHYPATH') == '' || oDataInc.get('ITD_BRIDGETICKETNUM') == '' ||
                        oDataInc.get('ITDCHCREATEDBYGROUP') == '' || oDataInc.get('ITNAMBITO') == '' ||
                        oDataInc.get('ITNOPCONCALLCENTER') == '')
                    {
                        oAgrupadores.remove(sClave);
                        sDescError = 'Validaciones.';

                    }
                    //--------------------------------------
                    // Sergio Castro -> "06-05-2020" -> Controlamos que el usuario pertenezca al grupo de Maximos si no es asi salta el error "Maximo"
                    // Nerea Sanchez -> "27-01-2022" -> Corrección mensage de error usuario que si pertenece al grupo de Maximos.
                    //--------------------------------------
                    if (usuarioGrupoMaximo == false){
                        oAgrupadores.remove(sClave);
                        sDescError = sDescError +  ' Maximo.';
                    }

                    if (sDescError.contains('Maximo.')){
                        sDetalle = sDetalle+'Este usuario no pertenece al grupo de máximo y no es posible enviarlo. \n';
                    }

                    if (sDescError.contains('Validaciones.'))
                    {
                        sDetalle = sDetalle + 'El Agrupador no tiene todos los datos obligatorios informados.\n';
                        sDetalle = sDetalle + 'La siguiente información ha de estar informada:\n';
                        sDetalle = sDetalle + '- Título.\n';
                        sDetalle = sDetalle + '- Descripción.\n';
                        sDetalle = sDetalle + '- Clasificación Maximo.\n';
                        sDetalle = sDetalle + '- Grupo Maximo.\n';
                        sDetalle = sDetalle + '- Opción Call Center.\n';
                        sDetalle = sDetalle + '- Número de incidencia en Salesforce.\n';
                    }
                }

                // Convertir valor, si no hay errores.
                if (sDescError == '')
                {
                    String sValor = oDataInc.get('ITNAMBITO');
                    if (sValor != null)
                    {
                        ((Map<String,String>)oAgrupadores.get(sClave)).put('ITNAMBITO', oAmbito.get(sValor));
                    }
                }
            }

            if (sDescError != '')
            {
                oRetorno.put(sClave, sDescError + '\n ' + sDetalle);

                // Gestión trazas.
                if (oCfgInt != null)
                {
                    if (oCfgInt.CC_TrazaActiva__c || Test.isRunningTest())
                    {
                        CC_TrazaInt__c oTraza = new CC_TrazaInt__c();
                        oTraza.Name = 'MAXIMO_CREACION';
                        oTraza.CC_Identificador__c = sClave;
                        oTraza.CC_FechaInicio__c = datetime.now();
                        oTraza.CC_IdOrigen__c = sClave;
                        oTraza.CC_FechaFin__c = datetime.now();
                        oTraza.CC_FinOK__c = false;
                        oTraza.CC_TipoError__c = sDescError;
                        oTraza.CC_DetalleError__c = sDetalle;
                        oListTraza.add(oTraza);
                    }
                }
            }
        }
        return;
    }

    /*
    Recuperar configuración de la integración.
    */
    static private CC_InterfaceSettings__mdt getConfigMaximo(String sInterfaz) {
        if (String.isBlank(sInterfaz)) {
            return null;
        } else {
            List<CC_InterfaceSettings__mdt> oConfig = [SELECT CC_Certificado__c, CC_EndPoint__c, CC_TimeOut__c,
                                                        CC_TipoPeticion__c, CC_TrazaActiva__c, CC_TrazaEntrada__c, CC_TrazaSalida__c,
                                                        CC_AFFECTEDEMAIL__c, CC_AFFECTEDPHONE__c, CC_EXTERNALSYSTEM__c, CC_ITD_ITNINCIDENTINCI__c, CC_ITNESCENARIO__c,
                                                        CC_ITNEVENTO__c, CC_ITNINCTYPE__c, CC_ITNRELEVANTE__c, CC_ITNROL__c, CC_ORGID__c, CC_REPORTEDEMAIL__c,
                                                        CC_REPORTEDPHONE__c, CC_SITEID__c, CC_CLASS__c, CC_ConvAmbito__c, CC_WORKLOG_LOGTYPE__c, CC_WORKLOG_ACTION__c
                                                        FROM CC_InterfaceSettings__mdt WHERE DeveloperName = :sInterfaz AND CC_Activa__c = true];
            if (oConfig.size() == 1) {
                return oConfig[0];
            } else {
                return null;
            }
        }
    }

    /*
    Método para parsear los datos de conversión del ámbito.
    */
    static private Map<String,String> getConvAmbito(String sConversion) {
        if (String.isBlank(sConversion)) {
            return null;
        } else {
            Map<String, String> oRes = new Map<String, String>();
            for (String sValor : sConversion.split(';')) {
                if (sValor != '') {
                    List<String> oData2 = sValor.split('##');
                    if (oData2.size() == 2) {
                        // Preparar valores MAP.
                        oRes.put(oData2[0], oData2[1]);
                    }
                }
            }
            return oRes;
        }
    }

    /*
Método para generar una incidencia desde un LC.
*/
    @AuraEnabled
    static public String auraGestionMaximo (Id oID)
    {
        String sRetorno = '';
        Set<Id> oInput = new Set<Id>();
        String sObjName = '';


        if (oID != null)
        {
            Schema.SObjectType oTipoObj = oID.getSobjectType();
            if (oTipoObj != null)
            {
                try {
                    sObjName = oTipoObj.getDescribe().getName();
                } catch (Exception e) {
                    sObjName = '';
                }
            }
        }

        if (oID != null)
        {
            String sID = String.valueOf(oID);
            oInput.add(oID);
            Map<String,String> oRes;

            if (sObjName == 'CC_Agrupador__c')
            {
                oRes = crearIncidenciaMaximo (oInput);
            }

            if (sObjName == 'CC_Notificacion_Volumen__c')
            {
                oRes = crearActualizarEventoMaximo (oInput);
            }

            // Tratar retorno.
            if (oRes.get(sID) != null)
            {
                if (oRes.get(sID) != '')
                {
                    sRetorno = oRes.get(sID);
                }
            }else{
                // Error, no enviado.
                String sAux = '';
                if (sObjName == 'CC_Agrupador__c'){
                    sAux = 'agrupador';
                }else{
                    sAux = 'evento';
                }
                sRetorno = 'El ' + sAux + ' no se ha enviado correctamente. Vuelva a intentarlo, si el problema persiste contacte con el administrador de la aplicación.';
            }

        }else{
            // Sin Id informado.
            sRetorno = 'No hay un agrupador informado. Revise los datos visualizados en pantalla';
        }

        if(sRetorno == ''){
            notificacionEmpleado(oID);
        }

        return sRetorno;
    }

    @AuraEnabled
    static public void notificacionEmpleado(Id idAgrupador) {
        List<Case> casos = [SELECT Contact.Email, CC_Idioma__c, CC_Canal_Procedencia__c, Contact.Id, RecordType.DeveloperName FROM Case
                            WHERE CC_Agrupador_Id__c = :idAgrupador AND RecordType.DeveloperName = 'CC_Empleado' AND CC_Agrupador_Id__r.CC_Publica__c = FALSE LIMIT 1];
        
        List<Case> casosHDT = [SELECT Contact.Email, CC_Idioma__c, CC_Canal_Procedencia__c, Contact.Id, RecordType.DeveloperName FROM Case
                            WHERE CC_Agrupador_Id__c = :idAgrupador AND RecordType.DeveloperName = 'HDT_Empleado' AND CC_Agrupador_Id__r.CC_Publica__c = FALSE LIMIT 1];

        List<Case> casosCSIBankia = [SELECT Contact.Email, CC_Idioma__c, CC_Canal_Procedencia__c, Contact.Id FROM Case
                                        WHERE CC_Agrupador_Id__c = :idAgrupador AND RecordType.DeveloperName = 'CC_CSI_Bankia'
                                        AND CC_Agrupador_Id__r.CC_Publica__c = FALSE LIMIT 1];

        //Plantilla para enviar correo con Template
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();

        if (!casos.isEmpty()) {
            Case caso = casos[0];
            String idioma = caso.CC_Idioma__c;
            String recTypeCaso = caso.RecordType.DeveloperName;
            
            if (idioma == 'es') {
                idioma = 'Castellano';
            } else if (idioma == 'ca') {
                idioma = 'Català';
            } else if (idioma == 'en') {
                idioma = 'Inglés';
            }

            List<CC_Buzones_Por_Defecto__mdt> buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                                                            WHERE CC_Canal_Procedencia__c = :caso.CC_Canal_Procedencia__c AND CC_Idioma__c = :idioma LIMIT 1];
            if (buzones.isEmpty()) {
                buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                            WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = :idioma AND CC_Activo__c = true LIMIT 1];
            }
            if (buzones.isEmpty()) {
                buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                            WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = true LIMIT 1];
            }
            if (!buzones.isEmpty()) {
               Id plantillaId;
                
                if(recTypeCaso == 'CC_Empleado'){
                    if (idioma == 'Castellano') {
                        plantillaId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Notificacion_Agrupador_Empleado_es' LIMIT 1].Id;
                    } else if (idioma == 'Català') {
                        plantillaId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Notificacion_Agrupador_Empleado_ca' LIMIT 1].Id;
                    } else if (idioma == 'Inglés') {
                        plantillaId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Notificacion_Agrupador_Empleado_en' LIMIT 1].Id;
                    }
                }
                

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE Address = :buzones[0].CC_Direccion_Correo__c LIMIT 1].Id);
                mail.setTemplateId(plantillaId);
                mail.setSaveAsActivity(true);
                mail.setWhatId(caso.Id);
                mail.setTargetObjectId(caso.Contact.Id);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setToAddresses(new List<String>{caso.Contact.Email});
                allmsg.add(mail);
            }
        }
        
        //Generamos el email para empleados HDT
        if (!casosHDT.isEmpty()) {
            
            Case caso = casosHDT[0];
            String idioma = caso.CC_Idioma__c;
            String recTypeCaso = caso.RecordType.DeveloperName;

            List<HDT_Correos_Buzones_Entrada__mdt> buzonesHDT = [SELECT HDT_Email_Destino__c FROM HDT_Correos_Buzones_Entrada__mdt
                            WHERE HDT_Canal_Procedencia__c = :caso.CC_Canal_Procedencia__c LIMIT 1];
            
            if (buzonesHDT.isEmpty()) {
                buzonesHDT = [SELECT HDT_Email_Destino__c FROM HDT_Correos_Buzones_Entrada__mdt LIMIT 1];
            }

            if (!buzonesHDT.isEmpty()) {
                Id plantillaId;

                if(recTypeCaso == 'HDT_Empleado'){
                    if (idioma == 'es') {
                        idioma = 'Castellano';
                        plantillaId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Notificacion_Agrupador_Empleado_HDT_es' LIMIT 1].Id;
                    } else if (idioma == 'ca') {
                        idioma = 'Català';
                        plantillaId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Notificacion_Agrupador_Empleado_HDT_ca' LIMIT 1].Id;
                    } else if (idioma == 'en') {
                        idioma = 'Inglés';
                        plantillaId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Notificacion_Agrupador_Empleado_HDT_en' LIMIT 1].Id;
                    }
                } 
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE Address = :buzonesHDT[0].HDT_Email_Destino__c LIMIT 1].Id);
                mail.setTemplateId(plantillaId);
                mail.setSaveAsActivity(true);
                mail.setWhatId(caso.Id);
                mail.setTargetObjectId(caso.Contact.Id);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setToAddresses(new List<String>{caso.Contact.Email});
                allmsg.add(mail);   
            }
        }    
        
        
        //Generamos el email para empleados CSIBankia
        if (!casosCSIBankia.isEmpty()) {
            List<CC_Buzones_Por_Defecto__mdt> buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                                                            WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'CSI'];
            if (!buzones.isEmpty()) {
                Id plantillaId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Notificacion_Agrupador_Empleados_CSI_es' LIMIT 1].Id;
                Case caso = casosCSIBankia[0];

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(plantillaId);
                mail.setSaveAsActivity(true);
                mail.setWhatId(caso.Id);
                mail.setTargetObjectId(caso.Contact.Id);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setToAddresses(new List<String>{caso.Contact.Email});
                mail.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE Address = :buzones[0].CC_Direccion_Correo__c LIMIT 1].Id);
                allmsg.add(mail);
            }
        }

        if (!allmsg.isEmpty()) {
            Messaging.sendEmail(allmsg, false);
        }
    }



    //@future(callout=true)
    static public Map<String,String> crearIncidenciaMaximo(Set<Id> oID) {
        if (oID == null) {
            return null;
        }

        List<CC_TrazaInt__c> oListTrazas = new List<CC_TrazaInt__c>();
        List<CC_Agrupador__c> oListAgr = new List<CC_Agrupador__c>();
        Map<String,String> oRetorno = new Map<String,String>();

        // Recuperar datos origen para validar.
        Map<String,Object> oDataOrig = recuperarAgrupador (oID);

        // Recuperar configuración integración Máximo
		String nombreCmdtInterfaz = lightningAppName() == 'HDT_App' ? 'HDT_Int_Maximo' : 'CC_Int_Maximo';
		CC_InterfaceSettings__mdt oCfgInt = getConfigMaximo(nombreCmdtInterfaz);

        // Obtener conversiones para el Ámbito.
        Map<String,String> oAmbito;
        if (oCfgInt != null)
        {
            oAmbito = getConvAmbito (oCfgInt.CC_ConvAmbito__c);
        }

        // Validar agrupadores.
        validarAgrupadores (oDataOrig, oAmbito, oRetorno, oListTrazas, oCfgInt);

        // Realizar los envíos a Máximo.
        for (String sAgrupadorId : oDataOrig.keySet())
        {
            Boolean oListCases = sAgrupadorId.contains('_Casos');
            if (oDataOrig.get(sAgrupadorId) != null && oListCases == false)
            {
                // Crear traza.
                String sDetalle = '';

                // Realizar el envío de Máximo.
                Map<String,Object> oRet = sendMaximoWS (sAgrupadorId, (Map<String,String>)oDataOrig.get(sAgrupadorId), oCfgInt, (List<Case>)oDataOrig.get(sAgrupadorId+ '_Casos'));

                for (String sClave : oRet.keySet())
                {
                    if (sClave == 'TRAZA')
                    {
                        // Añadir traza.
                        if (oRet.get(sClave) != null)
                        {
                            oListTrazas.add((CC_TrazaInt__c)oRet.get(sClave));
                        }
                    }else if (sClave == 'NUMMAXIMO')
                    {
                        // Preparar actualización agrupador.
                        if (oRet.get(sClave) != null)
                        {
                            CC_Agrupador__c oActAgr = new CC_Agrupador__c();
                            oActAgr.Id = sAgrupadorId;
                            oActAgr.CC_Id_Maximo__c = (String)oRet.get(sClave);
                            // Fecha envio maximo
                            oActAgr.CC_Fecha_creacion_MAXIMO__c = Datetime.valueOf(System.now());
                            oListAgr.add(oActAgr);
                        }
                    }
                }

                if (oRet.get('DESCERROR') != null)
                    sDetalle = (String)oRet.get('DESCERROR');

                if (oRet.get('DETERROR') != null)
                {
                    if (sDetalle != '')
                        sDetalle = sDetalle + '. ';
                    sDetalle = sDetalle + (String)oRet.get('DETERROR');
                }

                oRetorno.put(sAgrupadorId, sDetalle);
            }
        }

        // Crear las trazas del proceso.
        if (!oListTrazas.isEmpty())
        {
            Database.SaveResult[] oResUp = Database.insert(oListTrazas, false);
        }

        if (!oListAgr.isEmpty())
        {
            Database.SaveResult[] oResUp = Database.update(oListAgr, false);
        }


        return oRetorno;
    }

    /*
Método para realizar el envío a Máximo.
*/
    //TODO: Nuevo input con el listado de casos
    static private Map<String,Object> sendMaximoWS(String sIncidenciaId, Map<String,String> oDatosInc, CC_InterfaceSettings__mdt oCfgInt, List<Case> oDatosIncCasos) {
        Id recordTypeEmpleado = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id recordTypeEmpleadoCSIBankia = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        Id recordTypeEmpleadoHDT = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();

        Map<String,Object> oRes = new Map<String,Object>();
        CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';
        CC_WS_Maximo.INCIDENTMboKeySetType oRetorno;
        String sNumMaximo = '';

        if (oCfgInt == null)
        {
            oRes.put('DESCERROR', 'Integración inactiva.');
            oRes.put('DETERROR', 'La integración de actualización de eventos no está activa.');
            return oRes;
        }

        // Gestión trazas.
        if (oCfgInt != null)
        {
            if (oCfgInt.CC_TrazaActiva__c || Test.isRunningTest())
            {
                oTraza = new CC_TrazaInt__c();
                oTraza.Name = 'MAXIMO_CREACION';
                oTraza.CC_Identificador__c = sIncidenciaId;
                oTraza.CC_FechaInicio__c = datetime.now();
                oTraza.CC_IdOrigen__c = sIncidenciaId;
            }
        }

            if (sIncidenciaId == null || oDatosInc == null)
            {
                // Marcar error.
                sDescError = 'Error entrada datos.';
                sDetalleError = 'No se han informados los datos de entrada de la incidencia';
            }

            if (sIncidenciaId == '')
            {
                // Marcar error.
                sDescError = 'Error entrada datos.';
                sDetalleError = 'No se han informados los datos de entrada de la incidencia';
            }

            if (sDescError == '')
            {
                // Preparar estructura de la petición del WebService.

                CC_WS_Maximo.ITNINCSIEBEL8V4_INCIDENTType oInc = new CC_WS_Maximo.ITNINCSIEBEL8V4_INCIDENTType();

                // Incorporar los datos de la incidencia.
                oInc.AFFECTEDDATE = oDatosInc.get('AFFECTEDDATE');
                oInc.AFFECTEDPERSONID = oDatosInc.get('AFFECTEDPERSONID');
                oInc.DESCRIPTION = oDatosInc.get('DESCRIPTION');
                oInc.DESCRIPTION_LONGDESCRIPTION = oDatosInc.get('DESCRIPTION_LONG');
                oInc.HIERARCHYPATH = oDatosInc.get('HIERARCHYPATH');
                oInc.ITDCHCREATEDBYGROUP = oDatosInc.get('ITDCHCREATEDBYGROUP');
                oInc.ITDS_OWNERGROUP = oDatosInc.get('ITDCHCREATEDBYGROUP'); // Obtenido del XML de ejemplo de Máximo.
                oInc.ITNAMBITO = oDatosInc.get('ITNAMBITO');
                oInc.ITNINCACCION = 'PTE_ACCION'; //oDatosInc.get('ITNINCACCION');
                oInc.ITNINCCLIENTEAFEC = oDatosInc.get('ITNINCCLIENTEAFEC');
                oInc.ITNINCCONTRATO = 'PTE_CONTRATO';//oDatosInc.get('ITNINCCONTRATO');
                oInc.ITNINCDETALLE = 'PTE_DETALLE';//oDatosInc.get('ITNINCDETALLE');
                oInc.ITNINCFAMILIA = 'PTE_FAMILIA';//oDatosInc.get('ITNINCFAMILIA');
                oInc.ITNINCPRODUCTO = 'PTE_PRODUCTO';//oDatosInc.get('ITNINCPRODUCTO');
                oInc.ITNOPCONCALLCENTER = oDatosInc.get('ITNOPCONCALLCENTER');
                oInc.ITNPROPIETARIO = oDatosInc.get('ITNPROPIETARIO');
                oInc.PLUSPCUSTOMER = oDatosInc.get('ITNPROPIETARIO'); // Obtenido del XML de ejemplo de Máximo.
                oInc.CREATEDBY = oDatosInc.get('MAXIMO_CREATED_BY'); //MAXIMO_CREATED_BY
                oInc.CREATIONDATE = oDatosInc.get('MAXIMO_CREATIONDATE'); // MAXIMO_CREATIONDATE
                oInc.REPORTDATE = oDatosInc.get('REPORTDATE');
                oInc.REPORTEDBYID = oDatosInc.get('REPORTEDBYID');
                oInc.ITNEXTRA4 = oDatosInc.get('ITNEXTRA4');

                // Uso futuro.
                //oInc.ASSETNUM

                // Incorporar los datos preconfigurados.
                if (oCfgInt != null)
                {
                    oInc.CLASS_x = oCfgInt.CC_CLASS__c;
                    oInc.AFFECTEDEMAIL = oCfgInt.CC_AFFECTEDEMAIL__c;
                    oInc.AFFECTEDPHONE = oCfgInt.CC_AFFECTEDPHONE__c;
                    oInc.EXTERNALSYSTEM = oCfgInt.CC_EXTERNALSYSTEM__c;
                    oInc.ITNESCENARIO = oCfgInt.CC_ITNESCENARIO__c;
                    oInc.ITNEVENTO = oCfgInt.CC_ITNEVENTO__c;
                    oInc.ITNINCTYPE = oCfgInt.CC_ITNINCTYPE__c;
                    oInc.ITNRELEVANTE = oCfgInt.CC_ITNRELEVANTE__c;
                    oInc.ITNROL = oCfgInt.CC_ITNROL__c;
                    oInc.ORGID = oCfgInt.CC_ORGID__c;
                    oInc.REPORTEDEMAIL = oCfgInt.CC_REPORTEDEMAIL__c;
                    oInc.REPORTEDPHONE = oCfgInt.CC_REPORTEDPHONE__c;
                    oInc.SITEID = oCfgInt.CC_SITEID__c;
                }

                // Valores por defecto a 0.
                oInc.ITNLLAMADASAB = '0';
                oInc.ITNLLAMADASABP = '0';
                oInc.ITNLLAMADASAT = '0';
                oInc.ITNLLAMADASATP = '0';
                oInc.ITNPUSERAFECTADOS = '0';
                oInc.ITNTIPOAFEC = '0';
                oInc.ITNTIPOBATCH = '0';
                oInc.ITNTIPOINDISP = '0';
                oInc.ITNTIPOTRANS = '0';
                oInc.ITNUSERAFECTADOS = '0';

                CC_WS_Maximo.ITNINCSIEBEL8V4_ITDTHIRDPARTYType oThirdPart = new CC_WS_Maximo.ITNINCSIEBEL8V4_ITDTHIRDPARTYType();
                oThirdPart.ITDBRIDGETICKETNUM = oDatosInc.get('ITD_BRIDGETICKETNUM'); // ITD_BRIDGETICKETNUM
                oThirdPart.ITNINCIDENTINCI = oCfgInt.CC_ITD_ITNINCIDENTINCI__c; // ITD_ITNINCIDENTINCI
                //oThirdPart.ITDTHIRDPARTYID = '0'; //ITD_THIRDPARTYID

                List<CC_WS_Maximo.ITNINCSIEBEL8V4_ITDTHIRDPARTYType> oListThirdPart = new List<CC_WS_Maximo.ITNINCSIEBEL8V4_ITDTHIRDPARTYType>();
                oListThirdPart.add(oThirdPart);

                oInc.ITDTHIRDPARTY = oListThirdPart;
				String asset;
                //ITNINCSIEBEL8V4_MULTIASSETLOCCIType
                List<CC_WS_Maximo.ITNINCSIEBEL8V4_MULTIASSETLOCCIType> oListAsset = new List<CC_WS_Maximo.ITNINCSIEBEL8V4_MULTIASSETLOCCIType>();
                for (Case oCaso : oDatosIncCasos){
                    if (oCaso.RecordTypeId == recordTypeEmpleado || oCaso.RecordTypeId == recordTypeEmpleadoCSIBankia || oCaso.RecordTypeId == recordTypeEmpleadoHDT){
                        if (oCaso.Asset.CC_Numero_Maquina__c != null){
                            CC_WS_Maximo.ITNINCSIEBEL8V4_MULTIASSETLOCCIType oIncAsset = new CC_WS_Maximo.ITNINCSIEBEL8V4_MULTIASSETLOCCIType();
                            oIncAsset.ITNINCEXTASSETNUM = oCaso.Asset.CC_Numero_Maquina__c; //codigo inventario
                            if((oCaso.Asset.Account.CC_Numero_Empresa__c == '001' && oCaso.Asset.Account.CC_Numero_Oficina__c == '27381') || (oCaso.Asset.Account.CC_Numero_Empresa__c == '001' && oCaso.Asset.Account.CC_Numero_Oficina__c == '27999')){
                            	oIncAsset.LOCATION = '0011017316'; //codigo centro
                            }else{
                                oIncAsset.LOCATION = '00'+oCaso.Asset.Account.CC_Numero_Empresa__c+oCaso.Asset.Account.CC_Numero_Oficina__c;
                            }
                            oIncAsset.ITNAFECPERSON  = oCaso.Contact.CC_Matricula__c; //matricula del empleado
                            oIncAsset.ITNTICKETCALL = oCaso.Id; //id del caso
                            oIncAsset.ITNDETALLAMADA = oCaso.CaseNumber; //Número SR
                            oIncAsset.COMMENTS = 'Usuario afectado: ' + oDatosInc.get('AFFECTEDPERSONID'); //Comentarios
                            oListAsset.add(oIncAsset);
                        }
                        if (oCaso.RecordTypeId == recordTypeEmpleadoHDT && oCaso.HDT_Activo_Secundario__c != null && oCaso.HDT_Activo_Secundario__r.CC_Numero_Maquina__c != null){
                        	CC_WS_Maximo.ITNINCSIEBEL8V4_MULTIASSETLOCCIType oIncAssetSec = new CC_WS_Maximo.ITNINCSIEBEL8V4_MULTIASSETLOCCIType();
                            oIncAssetSec.ITNINCEXTASSETNUM = oCaso.HDT_Activo_Secundario__r.CC_Numero_Maquina__c; //codigo inventario
                            if((oCaso.HDT_Activo_Secundario__r.Account.CC_Numero_Empresa__c == '001' && oCaso.HDT_Activo_Secundario__r.Account.CC_Numero_Oficina__c == '27381') || (oCaso.HDT_Activo_Secundario__r.Account.CC_Numero_Empresa__c == '001' && oCaso.HDT_Activo_Secundario__r.Account.CC_Numero_Oficina__c == '27999')){
                            	oIncAssetSec.LOCATION = '0011017316'; //codigo centro
                            }else{
                                oIncAssetSec.LOCATION = '00'+oCaso.HDT_Activo_Secundario__r.Account.CC_Numero_Empresa__c+oCaso.HDT_Activo_Secundario__r.Account.CC_Numero_Oficina__c;
                            }
                            oIncAssetSec.ITNAFECPERSON  = oCaso.Contact.CC_Matricula__c; //matricula del empleado
                            oIncAssetSec.ITNTICKETCALL = oCaso.Id; //id del caso
                            oIncAssetSec.ITNDETALLAMADA = oCaso.CaseNumber; //Número SR
                            oIncAssetSec.COMMENTS = 'Usuario afectado: ' + oDatosInc.get('AFFECTEDPERSONID'); //Comentarios
                            oListAsset.add(oIncAssetSec);    
                            
                        }
                        
                        
                    }
                     if(oCaso.RecordTypeId == recordTypeEmpleadoHDT && oCaso.Asset.CC_Numero_Maquina__c != null && asset == null){
                     	asset = oCaso.Asset.CC_Numero_Maquina__c;			
                     }
                }
                oInc.MULTIASSETLOCCI = oListAsset;
                
                 // Incidencia plataforma. Asignar inventario genérico.
                if (oDatosInc.get('ITNAMBITO') == 'Plataforma')
                {   
                    if (asset != null){
                        oInc.ITNINCEXTASSETNUM = asset;
                    }else{                    
                        oInc.ITNINCEXTASSETNUM = '00001-PC';
                    }
                }               
                

                // Preparar estructura final.
                List<CC_WS_Maximo.ITNINCSIEBEL8V4_INCIDENTType> oListInc = new List<CC_WS_Maximo.ITNINCSIEBEL8V4_INCIDENTType>();
                oListInc.add(oInc);

                CC_WS_Maximo.ITNINCSIEBEL8V4SetType oInCST = new CC_WS_Maximo.ITNINCSIEBEL8V4SetType();
                oInCST.INCIDENT = oListInc;

                // Gestión trazas.
                if (oCfgInt != null)
                {
                    if (oCfgInt.CC_TrazaActiva__c || Test.isRunningTest())
                    {
                        if (oCfgInt.CC_TrazaEntrada__c)
                            oTraza.CC_MensajeEntrada__c = String.valueOf(oInCST);
                    }
                }

                Boolean bReintento = false;

                CC_WS_Maximo.ITNINCSIEBEL8V4SOAP11Port oWebServ = new CC_WS_Maximo.ITNINCSIEBEL8V4SOAP11Port();

                oWebServ.clientCertName_x = oCfgInt.CC_Certificado__c;
                oWebServ.timeout_x = Integer.valueOf(oCfgInt.CC_TimeOut__c);
                oWebServ.endpoint_x = oCfgInt.CC_EndPoint__c;

                try
                {
                    oRetorno = oWebServ.CreateITNINCSIEBEL8V4(oInCST);

                    if (oRetorno != null)
                    {
                        if (oRetorno.INCIDENT != null)
                        {
                            if (!oRetorno.INCIDENT.isEmpty())
                            {
                                sNumMaximo = oRetorno.INCIDENT[0].TICKETID;
                            }
                        }
                    }
                }catch(Exception e) {
                    if (e.getMessage().containsIgnoreCase('is not valid for Escenario'))
                    {
                        // Reintentar con escenario Participades.
                        bReintento = true;
                    }else{
                        // Error comunicaciones.
                        sDescError = 'Error comunicaciones.';
                        sDetalleError = e.getMessage();
                    }
                }

                if (bReintento)
                {
                    oInCST.INCIDENT[0].ITNESCENARIO = 'Produccio Participades';
                    try{
                        oRetorno = oWebServ.CreateITNINCSIEBEL8V4(oInCST);

                        if (oRetorno != null)
                        {
                            if (oRetorno.INCIDENT != null)
                            {
                                if (!oRetorno.INCIDENT.isEmpty())
                                {
                                    sNumMaximo = oRetorno.INCIDENT[0].TICKETID;
                                }
                            }
                        }
                    }catch(Exception e) {
                        // Error comunicaciones.
                        sDescError = 'Error comunicaciones.';
                        sDetalleError = e.getMessage();
                    }
                }
            }


        // Finalizar traza.
        if (oCfgInt != null)
        {
            if ( (oCfgInt.CC_TrazaActiva__c || Test.isRunningTest()) && oTraza != null)
            {
                oTraza.CC_FechaFin__c = datetime.now();

                if (oCfgInt.CC_TrazaSalida__c || Test.isRunningTest())
                {
                    if (oRetorno != null)
                        oTraza.CC_MensajeSalida__c = String.valueOf(oRetorno);
                    else
                        oTraza.CC_MensajeSalida__c = sDetalleError;
                }

                if (sDescError != '')
                {
                    oTraza.CC_FinOK__c = false;
                    oTraza.CC_TipoError__c = sDescError;
                    oTraza.CC_DetalleError__c = sDetalleError;
                }else{
                    oTraza.CC_FinOK__c = true;
                }
            }
        }

        // Preparar retorno.
        oRes.put('TRAZA', oTraza);
        oRes.put('DESCERROR', sDescError);
        oRes.put('DETERROR', sDetalleError);
        oRes.put('NUMMAXIMO', sNumMaximo);


        return oRes;
    }

    /*
Método para crear la Reclamacion en Máximo
*/
    @future(callout=true)
    static public void crearReclamacionMaximo (Set<Id> oID)
    {
        String oRes = '';
        List<Task> oListTasks = new List<Task>();
        List<CC_Agrupador_Reclamacion__c> oListReclam = new List<CC_Agrupador_Reclamacion__c>();
        List<CC_TrazaInt__c> oListTrazas = new List<CC_TrazaInt__c>();

        // Recuperar datos origen para validar.
        Map<String,String> oUsuarios = new Map<String,String>();
        List<CC_Agrupador_Reclamacion__c> oDataOrig = recuperaReclAgrupador (oID, oUsuarios);

        // Recuperar configuración integración Máximo.
		String nombreCmdtInterfaz = lightningAppName() == 'HDT_App' ? 'HDT_Int_Recl_Maximo' : 'CC_Int_Recl_Maximo';
        CC_InterfaceSettings__mdt oCfgInt = getConfigMaximo(nombreCmdtInterfaz);

        // Realizar los envíos a Máximo.
        for (CC_Agrupador_Reclamacion__c sAgrupador : oDataOrig){
            if (sAgrupador.CC_Agrupador_Id__r.CC_Id_Maximo__c != null){

                // Realizar el envío de Máximo.
                oRes = sendReclamacionMaximoWS (sAgrupador, oUsuarios, oCfgInt, oListTrazas);
                if (oRes != 'KO') {
                    //Marcar como enviado
                    CC_Agrupador_Reclamacion__c reclamacion = new CC_Agrupador_Reclamacion__c();
                    reclamacion.Id = sAgrupador.Id;
                    reclamacion.CC_Enviado__c = true;
                    oListReclam.add(reclamacion);

                    // Crear Actividad Reclamación MAXIMO
                    Task tarea = new Task();
                    tarea.WhatId = sAgrupador.CC_Agrupador_Id__c;
                    // Modificación para HDT IOP MAYO 25
                    tarea.Type = sAgrupador.CC_Tipo_de_actividad__c;
                    //tarea.Type = 'Reclamación';
                    tarea.Subject = 'Reclamación MAXIMO';
                    tarea.Status = 'Completed';
                    tarea.ActivityDate = System.today();
                    tarea.Description = 'Se ha realizado una reclamación a MAXIMO sobre la Incidencia ' + sAgrupador.CC_Agrupador_Id__r.CC_Id_Maximo__c + ' correctamente.';

					if (lightningAppName() == 'HDT_App') {
						tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
					}
                    oListTasks.add(tarea);
                }
            }
        }
        if (!oListReclam.isEmpty()){
            Database.SaveResult[] oResReclamacion = Database.update(oListReclam, false);
        }

        if (!oListTrazas.isEmpty())
        {
            Database.SaveResult[] oResUp = Database.insert(oListTrazas, false);
        }

        if (!oListTasks.isEmpty()){
            //Database.SaveResult[] oResTask = Database.insert(oListTasks, false);
            Database.SaveResult[] oResTask =  CC_Activity.crearActividades(oListTasks, false);
        }
    }

    /*
Recuperar los datos de la reclamación del agrupador a enviar a Máximo.
*/
    static private List<CC_Agrupador_Reclamacion__c> recuperaReclAgrupador (Set<Id> oID, Map<String,String> oUsuarios)
    {
        List<CC_Agrupador_Reclamacion__c> oReclamacion = new List<CC_Agrupador_Reclamacion__c>();

        if (oID == null || oUsuarios == null){
            return oReclamacion;
        }

        if (oID.isEmpty()){
            return oReclamacion;
        }

        // Buscar los datos de la Reclamacion del Agrupador.
        oReclamacion = [SELECT Id, CC_Agrupador_Id__c, CC_Agrupador_Id__r.CC_Id_Maximo__c, CC_Descripcion__c, CC_Contenido__c, CC_Enviado__c,
                        CC_Fecha_Envio__c, CC_Tipo_de_actividad__c, CreatedDate, CreatedById
                        FROM CC_Agrupador_Reclamacion__c WHERE Id IN :oID];

        // Preparar los usuarios que han creado la reclamación.
        for (CC_Agrupador_Reclamacion__c oAux : oReclamacion)
        {
            if (oAux.CreatedById != null)
            {
                oUsuarios.put(oAux.CreatedById, '');
            }
        }

        if (!oUsuarios.isEmpty())
        {
            for (User oUser : [SELECT Id, EmployeeNumber FROM User WHERE Id IN :oUsuarios.keySet()])
            {
                if (oUser.EmployeeNumber != null)
                    if (oUser.EmployeeNumber != '')
                    oUsuarios.put(oUser.Id, oUser.EmployeeNumber);
            }
        }

        return oReclamacion;
    }

    /*
Método para realizar el envío de la Reclamación a Máximo.
*/
    static private String sendReclamacionMaximoWS (CC_Agrupador_Reclamacion__c sAgrupador, Map<String,String> oUsuarios, CC_InterfaceSettings__mdt oCfgInt, List<CC_TrazaInt__c> oListTrazas){
        String oResultado = '';
        CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';

        try{
            // Preparar estructura de la petición del WebService.
            CC_WS_Maximo.CC_ITNINCSIEBEL8V4_INCIDENTType oInc = new CC_WS_Maximo.CC_ITNINCSIEBEL8V4_INCIDENTType();

            // Control integración activa.
            if (oCfgInt == null)
            {
                return 'KO';
            }

            // Incorporar los datos preconfigurados.
            if (oCfgInt != null){
                if (oCfgInt.CC_TrazaActiva__c || Test.isRunningTest())
                {
                    oTraza = new CC_TrazaInt__c();
                    oTraza.Name = 'MAXIMO_RECLAMACION';
                    oTraza.CC_Identificador__c = sAgrupador.Id;
                    oTraza.CC_FechaInicio__c = datetime.now();
                    oTraza.CC_IdOrigen__c = sAgrupador.Id;
                }
                oInc.CLASS_x = oCfgInt.CC_CLASS__c;
            }

            // Valores de la reclamacion
            oInc.TICKETID = sAgrupador.CC_Agrupador_Id__r.CC_Id_Maximo__c;
            oInc.action = 'Change';

            CC_WS_Maximo.ITNINCSIEBEL8V4_WORKLOGType oWORKLOG = new CC_WS_Maximo.ITNINCSIEBEL8V4_WORKLOGType();
            oWORKLOG.DESCRIPTION = sAgrupador.CC_Descripcion__c;
            oWORKLOG.DESCRIPTION_LONGDESCRIPTION = sAgrupador.CC_Contenido__c;
            oWORKLOG.ITDCREATEDATE = convertirFechaMaximo(sAgrupador.CreatedDate);
            oWORKLOG.CREATEBY = oUsuarios.get(sAgrupador.CreatedById);
            //Modificado para HDT en la IOP MAYO 25
            oWORKLOG.LOGTYPE = sAgrupador.CC_Tipo_de_actividad__c;

            //oWORKLOG.LOGTYPE = oCfgInt.CC_WORKLOG_LOGTYPE__c;
            oWORKLOG.action = 'Add';

            List<CC_WS_Maximo.ITNINCSIEBEL8V4_WORKLOGType> oListWORKLOG = new List<CC_WS_Maximo.ITNINCSIEBEL8V4_WORKLOGType>();
            oListWORKLOG.add(oWORKLOG);
            oInc.WORKLOG = oListWORKLOG;

            // Preparar estructura final.
            List<CC_WS_Maximo.CC_ITNINCSIEBEL8V4_INCIDENTType> oListInc = new List<CC_WS_Maximo.CC_ITNINCSIEBEL8V4_INCIDENTType>();
            oListInc.add(oInc);

            CC_WS_Maximo.CC_ITNINCSIEBEL8V4SetType oInCST = new CC_WS_Maximo.CC_ITNINCSIEBEL8V4SetType();
            oInCST.INCIDENT = oListInc;
            if (oCfgInt != null){
                if (oCfgInt.CC_TrazaEntrada__c){
                    oTraza.CC_MensajeEntrada__c = String.valueOf(oInCST);
                }
            }

            CC_WS_Maximo.ITNINCSIEBEL8V4SOAP11Port oWebServ = new CC_WS_Maximo.ITNINCSIEBEL8V4SOAP11Port();

            oWebServ.clientCertName_x = oCfgInt.CC_Certificado__c;
            oWebServ.timeout_x = Integer.valueOf(oCfgInt.CC_TimeOut__c);
            oWebServ.endpoint_x = oCfgInt.CC_EndPoint__c;

            oWebServ.UpdateITNINCSIEBEL8V4(oInCST);
            oResultado = 'OK';

        }catch(Exception e) {
            oResultado = 'KO';
            // Error comunicaciones.
            sDescError = 'Error comunicaciones.';
            sDetalleError = e.getMessage();
        }

        // Finalizar traza.
        if (oCfgInt != null)
        {
            if ((oCfgInt.CC_TrazaActiva__c || Test.isRunningTest()) && oTraza != null)
            {
                oTraza.CC_FechaFin__c = datetime.now();

                // No hay mensaje de salida. Solo devuelve 200 - OK.

                if (sDescError != '')
                {
                    oTraza.CC_FinOK__c = false;
                    oTraza.CC_TipoError__c = sDescError;
                    oTraza.CC_DetalleError__c = sDetalleError;
                }else{
                    oTraza.CC_FinOK__c = true;
                }
            }
        }

        if (oTraza != null)
        {
            oListTrazas.add(oTraza);
        }

        return oResultado;
    }

    @InvocableMethod(label='Reclamacion MAXIMO' description='Reclamacion MAXIMO')
    public static void enviarReclamacionMAXIMO (List<Id> ListReclId) {
        Set<Id> oID = new Set<Id>(ListReclId);
        CC_WS_Methods_Maximo.crearReclamacionMaximo(oID);
    }

    /*
Método para generar una incidencia desde un LC.
*/
    /*    @AuraEnabled
static public String auraGenerarEvento (String sID)
{

String sRetorno = '';
Set<Id> oInput = new Set<Id>();

if (sID != '')
{
oInput.add(Id.valueOf(sID));

Map<String,String> oRes = crearActualizarEventoMaximo (oInput);

// Tratar retorno.
if (oRes.get(sID) != null)
{
if (oRes.get(sID) != '')
{
sRetorno = oRes.get(sID);
}
}else{
// Error, no enviado.
sRetorno = 'El evento no se ha enviado correctamente. Vuelva a intentarlo, si el problema persiste contacte con el administrador de la aplicación.';
}

}else{
// Sin Id informado.
sRetorno = 'No hay un evento informado. Revise los datos visualizados en pantalla';
}


return sRetorno;
}
*/
    /*
Creación / Actualización de evento.
*/
    static public Map<String,String> crearActualizarEventoMaximo (Set<Id> oID)
    {

        List<CC_TrazaInt__c> oListTrazas = new List<CC_TrazaInt__c>();
        List<CC_Notificacion_Volumen__c> oListAgr = new List<CC_Notificacion_Volumen__c>();
        Map<String,String> oRetorno = new Map<String,String>();

        if (oID == null)
        {
            return null;
        }

        // Recuperar datos origen para validar.
        Map<String,Object> oDataOrig = recuperarActVolumen (oID);

        // Recuperar configuración integración Máximo.
		String nombreCmdtInterfaz = lightningAppName() == 'HDT_App' ? 'HDT_Int_Maximo_Eve' : 'CC_Int_Maximo_Eve';
        CC_InterfaceSettings__mdt oCfgInt = getConfigMaximo(nombreCmdtInterfaz);

        // Validar agrupadores.
        validarEventos (oDataOrig, oRetorno, oListTrazas, oCfgInt);

        // Realizar los envíos a Máximo.
        for (String sEventoId : oDataOrig.keySet())
        {
            if (oDataOrig.get(sEventoId) != null)
            {
                // Crear traza.
                String sDetalle = '';

                // Realizar el envío de Máximo.
                Map<String,Object> oRet = sendEventoMaximoWS (sEventoId, (Map<String,String>)oDataOrig.get(sEventoId), oCfgInt);

                for (String sClave : oRet.keySet())
                {
                    if (sClave == 'TRAZA')
                    {
                        // Añadir traza.
                        if (oRet.get(sClave) != null)
                        {
                            oListTrazas.add((CC_TrazaInt__c)oRet.get(sClave));
                        }
                    }else if (sClave == 'MARCAR_ENV')
                    {
                        // Preparar actualización agrupador.
                        if (oRet.get(sClave) != null)
                        {
                            if ((Boolean)oRet.get(sClave))
                            {
                                CC_Notificacion_Volumen__c oEveUpd = new CC_Notificacion_Volumen__c();
                                oEveUpd.Id = sEventoId;
                                oEveUpd.CC_Estado__c = 'Enviada';

                                /* DESCARTAMOS ACTUALIZACIÓN TIPO VOLUMEN.
                                if (((Map<String,String>)oDataOrig.get(sEventoId)).get('LOGTYPE') == 'SEGEVENTO')
                                {
                                    oEveUpd.CC_Tipo__c = 'Notificación';
                                }else if (((Map<String,String>)oDataOrig.get(sEventoId)).get('LOGTYPE') == 'ACTEVENTO')
                                {
                                    oEveUpd.CC_Tipo__c = 'Actualizar evento';
                                }
                                FIN DESCARTADO. */

                                oListAgr.add(oEveUpd);
                            }
                        }
                    }
                }

                if (oRet.get('DESCERROR') != null)
                    sDetalle = (String)oRet.get('DESCERROR');

                if (oRet.get('DETERROR') != null)
                {
                    if (sDetalle != '')
                        sDetalle = sDetalle + '. ';
                    sDetalle = sDetalle + (String)oRet.get('DETERROR');
                }

                oRetorno.put(sEventoId, sDetalle);
            }
        }

        // Crear las trazas del proceso.
        if (!oListTrazas.isEmpty())
        {
            Database.SaveResult[] oResUp = Database.insert(oListTrazas, false);
        }

        if (!oListAgr.isEmpty())
        {
            Database.SaveResult[] oResUp = Database.update(oListAgr, false);
        }


        return oRetorno;
    }

    /*
Recuperar los datos de los volúmenes de agrupadores a enviar a Máximo.
*/
    static private Map<String,Object> recuperarActVolumen (Set<Id> oID)
    {

        Map<String,Object> oRes = new Map<String,Object>();
        Map<String,String> oIncUsu = new Map<String,String>();
        Map<String,String> oUsuId = new Map<String,String>();
        //Map<String,String> oEveInc = new Map<String,String>();
        //Map<String,String> oIncEve = new Map<String,String>();

        if (oID == null)
        {
            return oRes;
        }

        if (oID.isEmpty())
        {
            return oRes;
        }

        // Buscar los datos de los volúmenes de agrupadores.
        for (CC_Notificacion_Volumen__c oVol : [SELECT Id, CreatedDate, CreatedById, CC_Tipo__c, CC_Mensaje__c, CC_Contenido__c, CC_Estado__c, CC_Llamadas_Abandonadas__c, CC_Llamadas_Atendidas__c, CC_Llamadas_Abandonadas_Parcial__c, CC_Llamadas_Atendidas_Parcial__c, CC_Agrupador_Id__r.CC_Id_Maximo__c, CC_Agrupador_Id__c, CC_Agrupador_Id__r.CC_Evento__c FROM CC_Notificacion_Volumen__c WHERE Id IN :oID])
        {
            Map<String,String> oEve = new Map<String,String>();
            oEve.put('ITNRELEVANTE','');
            oEve.put('ITNEVENTO','');
            oEve.put('ITNLLAMADASAB', String.valueOf(oVol.CC_Llamadas_Abandonadas__c));
            oEve.put('ITNLLAMADASABP', String.valueOf(oVol.CC_Llamadas_Abandonadas_Parcial__c));
            oEve.put('ITNLLAMADASAT', String.valueOf(oVol.CC_Llamadas_Atendidas__c));
            oEve.put('ITNLLAMADASATP', String.valueOf(oVol.CC_Llamadas_Atendidas_Parcial__c));
            oEve.put('TICKETID', oVol.CC_Agrupador_Id__r.CC_Id_Maximo__c);
            oEve.put('action','Change');
            oEve.put('DESCRIPTION', oVol.CC_Mensaje__c);
            oEve.put('DESCRIPTION_LONGDESCRIPTION', oVol.CC_Contenido__c);
            oEve.put('ITDCREATEDATE', convertirFechaMaximo(oVol.CreatedDate));
            oEve.put('CREATEBY','');
            oEve.put('LOGTYPE','');
            oEve.put('actionWork','Add');
            oEve.put('ESTADO', oVol.CC_Estado__c);
            oEve.put('MARCA_EVENTO', String.valueOf(oVol.CC_Agrupador_Id__r.CC_Evento__c));

            // Cambio con la nueva información de Máximo. Calculamos el LOGTYPE.
            if (oVol.CC_Tipo__c == 'Notificación')
            {
                oEve.put('LOGTYPE','SEGEVENTO');
            }else if (oVol.CC_Tipo__c == 'Actualizar evento'){
                oEve.put('LOGTYPE','ACTEVENTO');
            }else if (oVol.CC_Tipo__c == 'Mensaje VRU'){
                oEve.put('LOGTYPE','MENSAJEVRU');
            }else{
                oEve.put('LOGTYPE','SEGEVENTO');
            }

            oRes.put(oVol.Id, oEve);
            oIncUsu.put(oVol.Id, oVol.CreatedById);
            //oEveInc.put(oVol.Id, oVol.CC_Agrupador_Id__c);
            //oIncEve.put(oVol.CC_Agrupador_Id__c, oVol.Id);
        }

        /* DESCARTADO. El LOGTYPE se calcula en base a lo seleccionado por el usuario.
        // Buscar número de eventos enviados para recalcular el type.
        if (!oIncEve.isEmpty())
        {
            AggregateResult[] groupedResults = [SELECT CC_Agrupador_Id__c, count(Id) FROM CC_Notificacion_Volumen__c WHERE CC_Agrupador_Id__c IN :oIncEve.keySet() AND CC_Estado__c = 'Enviada' AND (CC_Tipo__c = 'Notificación' OR CC_Tipo__c = 'Actualizar evento') GROUP BY CC_Agrupador_id__c];
            for (AggregateResult ar : groupedResults)
            {
                String sClave = String.valueOf(ar.get('CC_Agrupador_Id__c'));
                Integer iValor = Integer.valueOf(ar.get('expr0'));

                String sClaveEve = oIncEve.get(sClave);

                // Actualizar el tipo a enviar.
                if (iValor > 0)
                {
                    oEveInc.put(sClaveEve, 'ACTEVENTO');
                }
            }
        }
        oIncEve = null;

        // Actualizar el tipo de los eventos.
        if (!oRes.isEmpty())
        {
            for (String sClave : oRes.keySet())
            {
                if (oEveInc.get(sClave) == 'ACTEVENTO')
                {
                    ((Map<String,String>)oRes.get(sClave)).put('LOGTYPE','ACTEVENTO');
                }else{
                    ((Map<String,String>)oRes.get(sClave)).put('LOGTYPE','SEGEVENTO');
                }
            }
        }
        oEveInc = null;
        FIN DESCARTADO. */

        // Buscar los login de usuarios detectados.
        if (!oIncUsu.isEmpty())
        {
            Set<String> oUsuarios = new Set<String>();
            for (String sClave : oIncUsu.keySet())
            {
                if (oIncUsu.get(sClave) != null)
                {
                    oUsuarios.add(oIncUsu.get(sClave));
                }
            }

            if (!oUsuarios.isEmpty())
            {
                for (User oUser : [SELECT Id, EmployeeNumber FROM User WHERE Id IN :oUsuarios])
                {
                    if (oUser.EmployeeNumber != null)
                        if (oUser.EmployeeNumber != '')
                        oUsuId.put(oUser.Id, oUser.EmployeeNumber);
                }
            }
            oUsuarios = null;

            if (!oUsuId.isEmpty())
            {
                for (String sClave : oIncUsu.keySet())
                {
                    if (oIncUsu.get(sClave) != null && oRes.get(sClave) != null)
                    {
                        if (oUsuId.get(oIncUsu.get(sClave)) != null)
                        {
                            ((Map<String,String>)oRes.get(sClave)).put('CREATEBY', oUsuId.get(oIncUsu.get(sClave)));
                        }
                    }
                }
            }
            oUsuId = null;
        }
        oIncUsu =  null;


        return oRes;
    }

    /*
Validar los datos de los agrupadores a enviar a Máximo.
*/
    static private void validarEventos (Map<String,Object> oEventos, Map<String,String> oRetorno, List<CC_TrazaInt__c> oListTraza, CC_InterfaceSettings__mdt oCfgInt)
    {

        if (oEventos == null)
        {
            return;
        }

        if (oEventos.isEmpty())
        {
            return;
        }

        for (String sClave : oEventos.keySet())
        {
            String sDescError = '';
            String sDetalle = '';

            if (oEventos.get(sClave) != null)
            {
                // No enviar si tiene Id de Máximo.
                Map<String,String> oDataInc = (Map<String,String>)oEventos.get(sClave);

                if (oDataInc.get('ESTADO') != 'Envío pendiente')
                {
                    oEventos.remove(sClave);
                    sDescError = 'Validaciones.';
                    sDetalle = 'El evento ya está enviado a Máximo.';
                }else{
                    // Comprobar datos obligatorios.
                    if (oDataInc.get('DESCRIPTION') == null || oDataInc.get('DESCRIPTION_LONGDESCRIPTION') == null ||
                        oDataInc.get('TICKETID') == null || oDataInc.get('ITNLLAMADASATP') == null ||
                        oDataInc.get('ITNLLAMADASAT') == null || oDataInc.get('ITNLLAMADASAB') == null ||
                        oDataInc.get('ITNLLAMADASABP') == null || oDataInc.get('MARCA_EVENTO') == null)
                    {
                        oEventos.remove(sClave);
                        sDescError = 'Validaciones.';
                        sDetalle = 'El evento no tiene todos los datos obligatorios informados.';
                    }else if (oDataInc.get('DESCRIPTION') == '' || oDataInc.get('DESCRIPTION_LONGDESCRIPTION') == '' ||
                              oDataInc.get('TICKETID') == '' || oDataInc.get('ITNLLAMADASATP') == '' ||
                              oDataInc.get('ITNLLAMADASAT') == '' || oDataInc.get('ITNLLAMADASAB') == '' ||
                              oDataInc.get('ITNLLAMADASABP') == '')
                    {
                        oEventos.remove(sClave);
                        sDescError = 'Validaciones.';
                        sDetalle = 'El evento no tiene todos los datos obligatorios informados.';
                    }else if (oDataInc.get('MARCA_EVENTO') != 'true')
                    {
                        oEventos.remove(sClave);
                        sDescError = 'Validaciones.';
                        sDetalle = 'El agrupador asociado al evento no está marcado como "evento".';
                    }
                }
            }

            if (sDescError != '')
            {
                oRetorno.put(sClave, sDescError + ' ' + sDetalle);

                // Gestión trazas.
                if (oCfgInt != null)
                {
                    if (oCfgInt.CC_TrazaActiva__c || Test.isRunningTest())
                    {
                        CC_TrazaInt__c oTraza = new CC_TrazaInt__c();
                        oTraza.Name = 'MAXIMO_EVENTO';
                        oTraza.CC_Identificador__c = sClave;
                        oTraza.CC_FechaInicio__c = datetime.now();
                        oTraza.CC_IdOrigen__c = sClave;
                        oTraza.CC_FechaFin__c = datetime.now();
                        oTraza.CC_FinOK__c = false;
                        oTraza.CC_TipoError__c = sDescError;
                        oTraza.CC_DetalleError__c = sDetalle;
                        oListTraza.add(oTraza);
                    }
                }
            }
        }


        return;
    }

    /*
Método para realizar el envío a Máximo.
*/
    static private Map<String,Object> sendEventoMaximoWS (String sEventoId, Map<String,String> oDatosInc, CC_InterfaceSettings__mdt oCfgInt)
    {

        Map<String,Object> oRes = new Map<String,Object>();
        CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';
        Boolean bMarcaEnv = false;

        // Si no viene informada la configuración de la interfaz. No se trata como activa.
        if (oCfgInt == null)
        {
            oRes.put('DESCERROR', 'Integración inactiva.');
            oRes.put('DETERROR', 'La integración de actualización de eventos no está activa.');
            return oRes;
        }

        // Gestión trazas.
        if (oCfgInt != null)
        {
            if (oCfgInt.CC_TrazaActiva__c || Test.isRunningTest())
            {
                oTraza = new CC_TrazaInt__c();
                oTraza.Name = 'MAXIMO_EVENTO';
                oTraza.CC_Identificador__c = sEventoId;
                oTraza.CC_FechaInicio__c = datetime.now();
                oTraza.CC_IdOrigen__c = sEventoId;
            }
        }

        try
        {
            if (sEventoId == null || oDatosInc == null)
            {
                // Marcar error.
                sDescError = 'Error entrada datos.';
                sDetalleError = 'No se han informados los datos de entrada del evento';
            }

            if (sEventoId == '')
            {
                // Marcar error.
                sDescError = 'Error entrada datos.';
                sDetalleError = 'No se han informados los datos de entrada del evento';
            }

            if (sDescError == '')
            {
                // Preparar estructura de la petición del WebService.
                CC_WS_Maximo.CC_EventITNINCSIEBEL8V4_INCIDENTType oInc = new CC_WS_Maximo.CC_EventITNINCSIEBEL8V4_INCIDENTType();

                oInc.ITNLLAMADASAB = oDatosInc.get('ITNLLAMADASAB');
                oInc.ITNLLAMADASABP = oDatosInc.get('ITNLLAMADASABP');
                oInc.ITNLLAMADASAT = oDatosInc.get('ITNLLAMADASAT');
                oInc.ITNLLAMADASATP = oDatosInc.get('ITNLLAMADASATP');
                oInc.TICKETID = oDatosInc.get('TICKETID');
                oInc.action = oDatosInc.get('action');

                // Incorporar los datos preconfigurados.
                if (oCfgInt != null)
                {
                    oInc.CLASS_x = oCfgInt.CC_CLASS__c;
                    oInc.ITNEVENTO = oCfgInt.CC_ITNEVENTO__c;
                    oInc.ITNRELEVANTE = oCfgInt.CC_ITNRELEVANTE__c;
                }

                CC_WS_Maximo.ITNINCSIEBEL8V4_WORKLOGType oWORKLOG = new CC_WS_Maximo.ITNINCSIEBEL8V4_WORKLOGType();
                oWORKLOG.DESCRIPTION = oDatosInc.get('DESCRIPTION');
                oWORKLOG.DESCRIPTION_LONGDESCRIPTION = oDatosInc.get('DESCRIPTION_LONGDESCRIPTION');
                oWORKLOG.ITDCREATEDATE = oDatosInc.get('ITDCREATEDATE');
                oWORKLOG.CREATEBY = oDatosInc.get('CREATEBY');
                oWORKLOG.LOGTYPE = oDatosInc.get('LOGTYPE');
                oWORKLOG.action = 'Add';

                List<CC_WS_Maximo.ITNINCSIEBEL8V4_WORKLOGType> oListWORKLOG = new List<CC_WS_Maximo.ITNINCSIEBEL8V4_WORKLOGType>();
                oListWORKLOG.add(oWORKLOG);
                oInc.WORKLOG = oListWORKLOG;

                // Preparar estructura final.
                List<CC_WS_Maximo.CC_EventITNINCSIEBEL8V4_INCIDENTType> oListInc = new List<CC_WS_Maximo.CC_EventITNINCSIEBEL8V4_INCIDENTType>();
                oListInc.add(oInc);

                CC_WS_Maximo.CC_EventITNINCSIEBEL8V4SetType oInCST = new CC_WS_Maximo.CC_EventITNINCSIEBEL8V4SetType();
                oInCST.INCIDENT = oListInc;

                if (oCfgInt != null){
                    if (oCfgInt.CC_TrazaEntrada__c){
                        oTraza.CC_MensajeEntrada__c = String.valueOf(oInCST);
                    }
                }

                CC_WS_Maximo.ITNINCSIEBEL8V4SOAP11Port oWebServ = new CC_WS_Maximo.ITNINCSIEBEL8V4SOAP11Port();

                oWebServ.clientCertName_x = oCfgInt.CC_Certificado__c;
                oWebServ.timeout_x = Integer.valueOf(oCfgInt.CC_TimeOut__c);
                oWebServ.endpoint_x = oCfgInt.CC_EndPoint__c;

                oWebServ.UpdateEventITNINCSIEBEL8V4(oInCST);

                bMarcaEnv = true;
            }

        }catch(Exception e) {
            // Error comunicaciones.
            sDescError = 'Error comunicaciones.';
            sDetalleError = e.getMessage();
        }

        // Finalizar traza.
        if (oCfgInt != null)
        {
            if ( (oCfgInt.CC_TrazaActiva__c || Test.isRunningTest()) && oTraza != null)
            {
                oTraza.CC_FechaFin__c = datetime.now();

                // No hay mensaje de respuesta.

                if (sDescError != '')
                {
                    oTraza.CC_FinOK__c = false;
                    oTraza.CC_TipoError__c = sDescError;
                    oTraza.CC_DetalleError__c = sDetalleError;
                }else{
                    oTraza.CC_FinOK__c = true;
                }
            }
        }

        // Preparar retorno.
        oRes.put('TRAZA', oTraza);
        oRes.put('DESCERROR', sDescError);
        oRes.put('DETERROR', sDetalleError);
        oRes.put('MARCAR_ENV', bMarcaEnv);


        return oRes;
    }

    /*
Creación / Actualización de evento.
*/
    @future(callout=true)
    static public void crearActualizarEventoMaximoFuture (Set<Id> oID){

        List<CC_TrazaInt__c> oListTrazas = new List<CC_TrazaInt__c>();
        List<CC_Notificacion_Volumen__c> oListAgr = new List<CC_Notificacion_Volumen__c>();
        Map<String,String> oRetorno = new Map<String,String>();

        if (oID != null) {
            // Recuperar datos origen para validar.
            Map<String,Object> oDataOrig = recuperarActVolumen (oID);

            // Recuperar configuración integración Máximo.
			String nombreCmdtInterfaz = lightningAppName() == 'HDT_App' ? 'HDT_Int_Maximo_Eve' : 'CC_Int_Maximo_Eve';
			CC_InterfaceSettings__mdt oCfgInt = getConfigMaximo(nombreCmdtInterfaz);

            // Validar agrupadores.
            validarEventos (oDataOrig, oRetorno, oListTrazas, oCfgInt);

            // Realizar los envíos a Máximo.
            for (String sEventoId : oDataOrig.keySet()){
                if (oDataOrig.get(sEventoId) != null){
                    // Crear traza.
                    String sDetalle = '';

                    // Realizar el envío de Máximo.
                    Map<String,Object> oRet = sendEventoMaximoWS (sEventoId, (Map<String,String>)oDataOrig.get(sEventoId), oCfgInt);

                    for (String sClave : oRet.keySet()){
                        if (sClave == 'TRAZA'){
                            // Añadir traza.
                            if (oRet.get(sClave) != null){
                                oListTrazas.add((CC_TrazaInt__c)oRet.get(sClave));
                            }
                        }else if (sClave == 'MARCAR_ENV'){
                            // Preparar actualización agrupador.
                            if (oRet.get(sClave) != null){
                                if ((Boolean)oRet.get(sClave)){
                                    CC_Notificacion_Volumen__c oEveUpd = new CC_Notificacion_Volumen__c();
                                    oEveUpd.Id = sEventoId;
                                    oEveUpd.CC_Estado__c = 'Enviada';

                                    /* DESCARTAMOS ACTUALIZACIÓN TIPO VOLUMEN.
                                    if (((Map<String,String>)oDataOrig.get(sEventoId)).get('LOGTYPE') == 'SEGEVENTO'){
                                        oEveUpd.CC_Tipo__c = 'Notificación';
                                    }else if (((Map<String,String>)oDataOrig.get(sEventoId)).get('LOGTYPE') == 'ACTEVENTO'){
                                        oEveUpd.CC_Tipo__c = 'Actualizar evento';
                                    }
                                    FIN DESCARTADO. */

                                    oListAgr.add(oEveUpd);
                                }
                            }
                        }
                    }

                    if (oRet.get('DESCERROR') != null)
                        sDetalle = (String)oRet.get('DESCERROR');

                    if (oRet.get('DETERROR') != null){
                        if (sDetalle != '')
                            sDetalle = sDetalle + '. ';
                        sDetalle = sDetalle + (String)oRet.get('DETERROR');
                    }
                    oRetorno.put(sEventoId, sDetalle);
                }
            }

            // Crear las trazas del proceso.
            if (!oListTrazas.isEmpty()) {
                Database.insert(oListTrazas, false);
            }

            if (!oListAgr.isEmpty()) {
                Database.update(oListAgr, false);
            }
        }
    }

    private static String lightningAppName() {
        List<UserAppInfo> userAppInfos = [SELECT AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() LIMIT 1];
        if (userAppInfos.isEmpty()) {
            return null;
        } else {
            return [SELECT DeveloperName FROM AppDefinition WHERE DurableId = :userAppInfos[0].AppDefinitionId LIMIT 1].DeveloperName;
        }
    }
}