public with sharing class GRR_Convertir_Registro_Caso_Controller {

    @AuraEnabled(cacheable=true)
    public static List<GRR_RegistroCarga__c> getListadoRegistros(String cargaId) {
        List<GRR_RegistroCarga__c> registros = [
            SELECT Id, GRR_Fichero__c, Name, GRR_Caso__c, GRR_GRR__c, RecordType.Name, RecordTypeId, GRR_UR__c, GRR_Vulnerabilidad__c, GRR_Departamento__c, 
            GRR_Motivos__c, GRR_Provincia__c, GRR_Direccion__c, GRR_Poblacion__c, GRR_Comunidad__c, GRR_CodigoOficina__c, GRR_CodigoDAN__c, GRR_CodigoDT__c,
            GRR_NIF__c, GRR_Intervinientes__c , GRR_NIFs_Con_RR__c, GRR_Intervinientes_Con_RR__c, GRR_Informacion_Cliente__c, GRR_ObservacionesCP__c, 
            GRR_ComentariosSancionBC__c
            FROM GRR_RegistroCarga__c
            WHERE GRR_Fichero__c = :cargaId
            AND GRR_Caso__c = null
            WITH SECURITY_ENFORCED
        ];
        return registros;
    }

    public static Map<String, SObject> getCuentasConNIFs(Set<String> nifs){
        Map<String, SObject> mapaDNIsClientes = new Map<String, SObject>();
        
        //Solo Clientes empresa y Clientes Particulares
        Id sClienteRecordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        Id sClientePARecordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
        Id sNoClienteRecordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'GRR_NoCliente_PA');

        for (Account cuenta : [SELECT CC_Numero_Documento__c, Id, RecordTypeId, PersonContactId  FROM Account WHERE CC_Numero_Documento__c  IN :nifs AND (RecordTypeId = :sClienteRecordType OR RecordTypeId = :sClientePARecordType OR RecordTypeId = :sNoClienteRecordType) WITH SECURITY_ENFORCED]) {
            if(String.isNotBlank(cuenta.CC_Numero_Documento__c)){
                mapaDNIsClientes.put(cuenta.CC_Numero_Documento__c, cuenta);
            }
        }

        //Solo Clientes, Representantes y Clientes Particulares
        Id sRTRep = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Representante'); 
        Id sRTCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        Id sRTClientePA = null; //Clientes particulares tiene RT null para Contactos 

        for (Contact contacto : [SELECT CC_Numero_Documento__c, Id, RecordTypeId, AccountId  FROM Contact WHERE CC_Numero_Documento__c  IN :nifs AND (RecordTypeId = :sRTCliente OR RecordTypeId = :sRTRep OR RecordTypeId = :sRTClientePA) WITH SECURITY_ENFORCED]){
            if(String.isNotBlank(contacto.CC_Numero_Documento__c)){
                mapaDNIsClientes.put(contacto.CC_Numero_Documento__c, contacto);
            }
        }

        return mapaDNIsClientes;
    }

    public static Map<String, List<CC_MCC__c>> getMCCs(Set<String> productos, Set<String> motivos){
        String rtProductoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        String rtMotivoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        String departamentoName;
        Set<Id> productoIds = new Set<Id>();
        Map<String, List<CC_MCC__c>> mapaProductoMotivos = new Map<String, List<CC_MCC__c>>();

        for (CC_MCC__c producto : [SELECT Id FROM CC_MCC__c WHERE RecordTypeId = :rtProductoId AND CC_Tipo_Cliente__c = 'Cliente (GRR)' AND CC_Activo__c = true AND CC_Tematica__r.Name = 'Comités' AND Name IN :productos WITH SECURITY_ENFORCED]){
            productoIds.add(producto.Id);
        }
		
        if (!productoIds.isEmpty()){
            for (CC_MCC__c motivo : [SELECT Id, Name, CC_Producto_Servicio__c, CC_Producto_Servicio__r.Name FROM CC_MCC__c WHERE RecordTypeId = :rtMotivoId AND CC_Tipo_Cliente__c = 'Cliente (GRR)' AND CC_Activo__c = true AND CC_Producto_Servicio__c IN :productoIds WITH SECURITY_ENFORCED]){
                departamentoName = motivo.CC_Producto_Servicio__r.Name;
                departamentoName = (departamentoName != null) ? departamentoName.toLowerCase() : null;

                if(String.isNotBlank(departamentoName)){
                    if (!mapaProductoMotivos.containsKey(departamentoName)){
                        mapaProductoMotivos.put(departamentoName, new List<CC_MCC__c>());
                    }
    
                    mapaProductoMotivos.get(departamentoName).add(motivo);
                }
            }
        }

        return mapaProductoMotivos;
    }


    public static String getTematicaGRR(String cadena){
        String rtTematicaId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        String tematicaId;

        List<CC_MCC__c> lstTematicas = [SELECT Id, Name FROM CC_MCC__c WHERE RecordTypeId = :rtTematicaId AND CC_Tipo_Cliente__c = 'Cliente (GRR)' AND CC_Activo__c = true AND Name LIKE :cadena WITH SECURITY_ENFORCED LIMIT 1];

        if(!lstTematicas.isEmpty()){
            tematicaId = lstTematicas[0].Id;
        }
        
        return tematicaId;
    } 

    public static String getProcedenciaUnica(){
        String resultado;
        List<GroupMember> gruposPertenecientes = [SELECT Id, Group.DeveloperName FROM GroupMember WHERE (UserOrGroupId = :UserInfo.getUserId() AND Group.type='Regular' AND Group.DeveloperName LIKE 'GRR_Buzon%') WITH SECURITY_ENFORCED LIMIT 1];
        
        if (!gruposPertenecientes.isEmpty()) {
            String grupo = gruposPertenecientes[0].Group.DeveloperName;
            List<GRR_Correos_Buzones_Entrada__mdt> relaciones = [SELECT GRR_Canal_Procedencia__c, GRR_Cola_Procedencia__c from GRR_Correos_Buzones_Entrada__mdt WHERE GRR_Cola_Procedencia__c = :grupo WITH SECURITY_ENFORCED LIMIT 1];
            
            if (!relaciones.isEmpty()) {
                //Siempre se asocia el primer grupo al que pertenece 
                resultado = relaciones[0].GRR_Canal_Procedencia__c;
            }
        }
        else {
            throw new AuraHandledException('Aviso - Usuario no pertenece a ningún public group');
        }

        return resultado;
    }

    @AuraEnabled
    public static List<pickListWrapper> getGruposUsuario(){
        Set<String> nombresGrupos = new Set<String>();
        List<pickListWrapper> opcionesProcedencia = new List<pickListWrapper>();
        String query;
       
        for (GroupMember grupo : [SELECT Id, Group.DeveloperName, Group.Name FROM GroupMember WHERE (UserOrGroupId = :UserInfo.getUserId() AND Group.type='Regular' AND Group.DeveloperName LIKE 'GRR_Buzon%') WITH SECURITY_ENFORCED]){
            nombresGrupos.add(grupo.Group.DeveloperName);
        }

        if(nombresGrupos.contains('GRR_Buzon_Servicios_Centrales')){
            query = 'SELECT GRR_Canal_Procedencia__c, GRR_Cola_Procedencia__c from GRR_Correos_Buzones_Entrada__mdt WITH SECURITY_ENFORCED ORDER BY GRR_Canal_Procedencia__c ASC';
        } else {
            query = 'SELECT GRR_Canal_Procedencia__c, GRR_Cola_Procedencia__c from GRR_Correos_Buzones_Entrada__mdt WHERE GRR_Cola_Procedencia__c IN :nombresGrupos WITH SECURITY_ENFORCED ORDER BY GRR_Canal_Procedencia__c ASC';
        }

        if (!nombresGrupos.isEmpty()) {
            for (GRR_Correos_Buzones_Entrada__mdt procedencia: Database.query(query)){
                PickListWrapper wrap = new PickListWrapper(procedencia.GRR_Canal_Procedencia__c, procedencia.GRR_Canal_Procedencia__c);
                opcionesProcedencia.add(wrap);
            }
        }

        if (!opcionesProcedencia.isEmpty()) {
            return opcionesProcedencia;
        } else {
            throw new AuraHandledException('Aviso - Usuario no pertenece a ningún public group');
        }
    }

    public class PickListWrapper {
        @AuraEnabled
        public String label {get; set;}

        @AuraEnabled
        public String value {get; set;}

        public PickListWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }


    @AuraEnabled
    public static String validarRegistroIndividual(List<Map<String, String>> registros) {
        List<Map<String, String>> registrosSinCaso = new List<Map<String, String>>();
        String tipo;
        String resultado;

        for (Map<String, String> registro : registros) {
            if (String.isBlank(registro.get('GRR_Caso__c'))) {
                registrosSinCaso.add(registro);
                tipo = registro.get('RecordTypeId');
            }
        }

        if (registrosSinCaso.isEmpty()) {
            throw new AuraHandledException('Aviso - No se puede generar porque el registro ya tiene asociado un caso.');
        } else {
            resultado = separarTipo(registrosSinCaso, tipo, null);
        }

        return resultado;
    }

    @AuraEnabled
    public static String validarMultiplesRegistros(GRR_Carga__c carga, List<Map<String, String>> registros, String procedenciaSeleccionada) {
        String resultado; 

        // Todos los registros son del mismo Record Type ?
        Map<String, String> recordTypeMap = new Map<String, String>(); //Mapa para relacionar el id y el nombre del record type
        String firstRecordTypeName = null;
        String firstRecordTypeId = null;
        
        if (registros.isEmpty()){
            throw new AuraHandledException('Aviso - No se puede generar porque todos los registros tienen un caso asociado.');
        } 

        for (Map<String, String> registro : registros) {
            String recordTypeId = registro.get('RecordTypeId');
            String recordTypeName = registro.get('RecordTypeName');
            
            if (firstRecordTypeName == null) {
                firstRecordTypeId = recordTypeId;
                firstRecordTypeName = recordTypeName;
            }

            if (!firstRecordTypeId.equals(recordTypeId)) {
                throw new AuraHandledException('Aviso - Todos los registros deben ser del mismo tipo. Por favor, revisa el registro: ' + registro.get('Name'));
            }

            recordTypeMap.put(recordTypeId, recordTypeName); 
        }

        //El Record Type coincide con el campo Tipo de Fichero de la Carga?
        if (!firstRecordTypeName.equals(carga.GRR_TipoDeFichero__c)) {
            throw new AuraHandledException('Aviso - El Tipo de Fichero de la Carga seleccionado (' + carga.GRR_TipoDeFichero__c + ') es diferente al tipo de registro (' + firstRecordTypeName + ').');
        }

        //Devuelve el Record Type que corresponde
        if (recordTypeMap.size() == 1) { 
            String recordTypeIdComite = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_RegistroCarga__c', 'GRR_Acta_comite');
            String recordTypeIdRecobro = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_RegistroCarga__c', 'GRR_Recobro');
            String recordTypeIdHistorico = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_RegistroCarga__c', 'GRR_Historico');
            List<Map<String, String>> registrosFiltrados = new List<Map<String, String>>();

            if (firstRecordTypeId != null && firstRecordTypeId.equals(recordTypeIdComite)){
                //Actas de Comités
                for (Map<String, String> registro : registros) {
                    if (String.isNotBlank(registro.get('GRR_GRR__c'))) {
                        registrosFiltrados.add(registro);
                    }
                }
            } else if (firstRecordTypeId != null && (firstRecordTypeId.equals(recordTypeIdRecobro) || firstRecordTypeId.equals(recordTypeIdHistorico))){
                // Recobros e Históricos
                registrosFiltrados = registros;
            }

            if (registrosFiltrados.isEmpty()){
                throw new AuraHandledException('Aviso - No se puede generar porque todos los registros tienen un caso asociado.');
            } 
            
            resultado = separarTipo(registrosFiltrados, firstRecordTypeId, procedenciaSeleccionada);
        } 

        return resultado;
    }

    public static String separarTipo( List<Map<String, String>> registros, String tipoRegistro, String procedenciaSeleccionada) {
        String methodName = 'separarTipo';
        try{
            Map<String,String> mapaResultado = new Map<String,String>(); 
            String resultadoFinal = ''; 

            if(tipoRegistro.equals(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_RegistroCarga__c', 'GRR_Recobro'))){ 
                
                Set<String> listadoCompletoDNIs = new Set<String>(); 
                Map<String, SObject> mapaDNIsClientes = new Map<String, SObject>();
                
                //Mapa que relaciona el Id de cada registro con otro mapa que contiene los NIFs asociados a cada registro y un booleno para marcar los nifs como cliente principal o participante
                Map<String, Map<String, Boolean>> mapaRegistrosDNIs = extraerDNIs(registros);

                if(!mapaRegistrosDNIs.isEmpty()){
                    for (Map<String, String> registro : registros) {
                        if (mapaRegistrosDNIs.containsKey(registro.get('Id'))){
                            Map<String, Boolean> mapaNIFs = mapaRegistrosDNIs.get(registro.get('Id'));
                            if (!mapaNIFs.isEmpty()) {
                                listadoCompletoDNIs.addAll(mapaNIFs.keySet()); //Agrega los NIFs a la lista completa
                            }
                        }
                    }
                    mapaDNIsClientes = getCuentasConNIFs(listadoCompletoDNIs);
                }

                mapaResultado = generarCasosRecobros(registros, mapaRegistrosDNIs, mapaDNIsClientes, procedenciaSeleccionada);

            } else{
                Set<String> provinciasRegistros = new Set<String>();
                Set<String> listaDepartamentos = new Set<String>(); 
                Set<String> listaMotivos = new Set<String>(); 
                String prov;
                String dep;
                String mot;

                for (Map<String, String> registro : registros) {
                    prov = registro.get('GRR_Provincia__c');
                    prov = (prov != null) ? prov.toUpperCase() : null;
                    if (String.isNotBlank(prov)) {
                        provinciasRegistros.add(prov);
                    }
                    
                    dep = registro.get('GRR_Departamento__c');
                    dep = (dep != null) ? dep.toLowerCase() : null;
                    if (String.isNotBlank(dep)) {
                        listaDepartamentos.add(dep);
                    }

                    mot = registro.get('GRR_Motivos__c');
                    mot = (mot != null) ? mot.toLowerCase() : null;
                    if (String.isNotBlank(mot)) {
                        listaMotivos.add(mot);
                    }
                }

                //Añadir siempre el valor SIN IDENTIFICAR por si no se encuentra la provincia, o está en blanco, vacía...
                provinciasRegistros.add('SIN IDENTIFICAR');

                //Consulta MCCs
                Map<String, List<CC_MCC__c>> mapaProductoMotivos = getMCCs(listaDepartamentos, listaMotivos);

                Map<String, Map<String, String>> provinciasMapa = obtenerEquivalenciasProvincias(provinciasRegistros);
                if (tipoRegistro.equals(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_RegistroCarga__c', 'GRR_Acta_comite'))){
                    mapaResultado = generarCasosComites(registros, provinciasMapa, mapaProductoMotivos); 
                } else if (tipoRegistro.equals(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_RegistroCarga__c', 'GRR_Historico'))){
                    mapaResultado = generarCasosHistoricos(registros, provinciasMapa);
                } else {
                    throw new AuraHandledException('Aviso - El Record Type del registro no es ninguno de los permitidos: recobros, actas de comités o históricos');
                }
            }

            if (mapaResultado.containsKey('Error')){
                resultadoFinal = mapaResultado.get('Error');
            } else{
                resultadoFinal = mapaResultado.get('Success');
            } 
            return resultadoFinal;

        } catch (Exception e) {
            CBK_Log.error(methodName, 'GRR - The following exception has occurred: ' + e.getMessage());
            throw new AuraHandledException('Error - ' + e.getMessage());
        } 
    }

    public static Map<String,String> generarCasosRecobros(List<Map<String, String>> registros, Map<String, Map<String, Boolean>> mapaRegistrosDNIs, Map<String, SObject> mapaDNIsClientes, String procedenciaSeleccionada){
        List<Case> casosInsert = new List<Case>();
        Map<String, Case> mapaIdRegistroCaso = new Map<String, Case>();
        String procedenciaPropietario = procedenciaSeleccionada;
        String tematicaRecobroId = getTematicaGRR('Recobro');
        List<String> lstErrores = new List<String>();
        List<Object> objs = new List<Object>();
        Set<Id> successIds = new Set<Id>();
        Map<String,String> resultadoRecobros = new Map<String,String>();

        if (procedenciaPropietario == null){
            procedenciaPropietario = getProcedenciaUnica();
        }

       
        //Obtiene las relaciones entre código oficina, DAN, DT
        Map<String, Map<String,String>> oficinasMapa = obtenerCamposOficina(registros);

        //Para cada registro, se crea un caso y se guarda en un mapa la correspondencia entre el objeto caso y el Id del registro
        for (Map<String, String> registro: registros) {
            Case caso = crearCaso(procedenciaPropietario, tematicaRecobroId, 'recobro');
            
            // Rellena oficina - DAN - DT
            String codOficina = completarIdentificador(registro.get('GRR_CodigoOficina__c'));
            rellenarOficina(caso, codOficina, oficinasMapa);  

            // Concatena los datos del cliente/participante en el campo "Información Cliente"
            String infoCliente = limpiarCadena(registro.get('GRR_NIFs_Con_RR__c'))  + '\n' + limpiarCadena(registro.get('GRR_Intervinientes_Con_RR__c')) 
            + '\n\n' + limpiarCadena(registro.get('GRR_NIF__c')) + '\n' + limpiarCadena(registro.get('GRR_Intervinientes__c'));
            caso.GRR_Informacion_Cliente__c = infoCliente.left(4000);
            
            //Asocia el cliente principal si lo encuentra
            if (!mapaRegistrosDNIs.isEmpty() && mapaRegistrosDNIs.containsKey(registro.get('Id'))){
                Map<String, Boolean> nifsMapAux = mapaRegistrosDNIs.get(registro.get('Id'));

                if (!nifsMapAux.isEmpty()){
                    for (String nif : nifsMapAux.keySet()) {
                        if (mapaDNIsClientes.containsKey(nif) && nifsMapAux.get(nif)){ //True -> Cliente principal
                            SObject clienteAux = mapaDNIsClientes.get(nif);

                            if (clienteAux != null && clienteAux instanceof Account){
                                Account clienteCuenta = (Account) clienteAux;

                                //Cuenta empresa (Account)
                                if (clienteCuenta.RecordtypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente')){
                                    caso.AccountId = clienteCuenta.Id; 
                                }

                                //Cuenta particular (Person Account)
                                else if (clienteCuenta.RecordtypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'GRR_NoCliente_PA') || clienteCuenta.RecordtypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA')){
                                    caso.AccountId = clienteCuenta.Id; 
                                    caso.ContactId = clienteCuenta.PersonContactId;
                                }
                            } else if (clienteAux != null && clienteAux instanceof Contact) {
                                Contact clienteContacto = (Contact) clienteAux;

                                //Contacto (Contact -> Cliente, Representante o Cliente Particular)
                                if (clienteContacto.RecordtypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente') 
                                || clienteContacto.RecordtypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Representante')
                                || clienteContacto.RecordtypeId == null){
                                    caso.AccountId  = clienteContacto.AccountId; 
                                    caso.ContactId = clienteContacto.Id;
                                }
                            }
                        }
                    }
                }
            }

            casosInsert.add(caso); 
            mapaIdRegistroCaso.put(registro.get('Id'), caso);
        }

        if (Schema.sObjectType.Case.isCreateable() && !casosInsert.isEmpty()){
            Database.SaveResult[] srcasos = Database.insert(casosInsert, false);
            for(Database.SaveResult sr : srcasos) {
                if (sr.isSuccess()) { 
                    successIds.add(sr.getId());  
                }else{
                    if(!sr.getErrors().isEmpty()) {
                        Database.Error err = sr.getErrors()[0];
                        objs.add(err.getStatusCode() + ': ' + err.getMessage());
                        lstErrores.add(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            } 
        }
        
        Integer numGenerados = actualizarRegistrosRecobros(registros, successIds, mapaRegistrosDNIs, mapaDNIsClientes, mapaIdRegistroCaso);  
        
        if(!lstErrores.isEmpty()){
            resultadoRecobros.put('Error', 'Error - Han sido generados correctamente (' + numGenerados + '), aunque se han encontrado los siguientes errores en el resto: ' + lstErrores);
            CBK_Log.error('Error en la generación de casos de Recobros ', objs);
        } else {
            resultadoRecobros.put('Success', 'Han sido generados correctamente todos los casos solicitados (' + String.valueOf(numGenerados) + ')');
        }
          
        return resultadoRecobros;
    }


    public static Integer actualizarRegistrosRecobros(List<Map<String, String>> registros, Set<Id> idcasosGenerados, Map<String, Map<String, Boolean>> mapaRegistrosDNIs, Map<String, SObject> mapaDNIsClientes, Map<String, Case> mapaIdRegistroCaso){
        List<GRR_RegistroCarga__c> registrosUpdate = new List<GRR_RegistroCarga__c>();
        List <GRR_Participante__c> participantesInsert = new List<GRR_Participante__c>();

        //Para cada registro, mediante el mapa entre el caso y el id del registro, asocia el caso al registro y lo actualiza
        for (Map<String, String> registroToUpdate : registros) {
            Case casoToUpdate = (Case) mapaIdRegistroCaso.get(registroToUpdate.get('Id')); 

            if (casoToUpdate != null && idcasosGenerados.contains(casoToUpdate.Id)) {
                GRR_RegistroCarga__c registroCargaToUpdate = new GRR_RegistroCarga__c(
                    Id = registroToUpdate.get('Id'),
                    GRR_Caso__c = ((Case) casoToUpdate).Id
                );

                registrosUpdate.add(registroCargaToUpdate);

                if (!mapaRegistrosDNIs.isEmpty() && mapaRegistrosDNIs.containsKey(registroToUpdate.get('Id'))){
                    Map<String, Boolean> nifsMapAux = mapaRegistrosDNIs.get(registroToUpdate.get('Id'));

                    if (!nifsMapAux.isEmpty()){
                        for (String nif : nifsMapAux.keySet()) {   
                            if (mapaDNIsClientes.containsKey(nif) && !nifsMapAux.get(nif)){ //False -> Participantes
                                SObject clienteAux = mapaDNIsClientes.get(nif);

                                // Se crea un participante y se relacioa con el caso y la cuenta (Junction Object)
                                GRR_Participante__c participante = new GRR_Participante__c();
                                participante.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_Participante__c', 'GRR_Participante');
                                participante.GRR_Case_Participante__c = casoToUpdate.Id;
                                participante.GRR_Rol__c = 'Sin identificar';

                                if (clienteAux != null && clienteAux instanceof Account){
                                    Account clienteCuenta = (Account) clienteAux;
                                
                                    if (clienteCuenta.RecordtypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente')){
                                        participante.GRR_Cliente_Participante__c = clienteCuenta.Id;
                                    } else if (clienteCuenta.RecordtypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA') || clienteCuenta.RecordtypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'GRR_NoCliente_PA')){
                                        participante.GRR_Cliente_Participante__c = clienteCuenta.Id;
                                        participante.GRR_Contacto_Participante__c = clienteCuenta.PersonContactId;
                                    }
                                } else if (clienteAux != null && clienteAux instanceof Contact){
                                    Contact clienteContacto = (Contact) clienteAux;

                                    if (clienteContacto.RecordtypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente') 
                                    || clienteContacto.RecordtypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Representante')
                                    || clienteContacto.RecordtypeId == null){
                                        participante.GRR_Cliente_Participante__c = clienteContacto.AccountId; 
                                        participante.GRR_Contacto_Participante__c = clienteContacto.Id;
                                    }
                                }
                                
                                participantesInsert.add(participante);
                            }
                        }
                    }
                }
            } 
        }

        if (Schema.sObjectType.GRR_Participante__c.isCreateable() && !registrosUpdate.isEmpty() && !participantesInsert.isEmpty()){
            Database.insert(participantesInsert, false);
        }
        if (Schema.sObjectType.GRR_RegistroCarga__c.isUpdateable() && !registrosUpdate.isEmpty()){
            Database.update(registrosUpdate, false);
        }
        return registrosUpdate.size();
    }

    public static Map<String,String> generarCasosComites(List<Map<String, String>> registros, Map<String, Map<String, String>> provinciasMapa, Map<String, List<CC_MCC__c>> mapaProductoMotivos){
        List<Case> casosInsert = new List<Case>();
        Map<String, Case> mapaIdRegistroCaso = new Map<String, Case>();
        Map<String, String> mapaIdRegistroPropietario = new Map<String, String>();
        String procedenciaPropietario = getProcedenciaUnica();
        String tematicaComiteId = getTematicaGRR('Comités');
        List<String> lstErrores = new List<String>();
        List<Object> objs = new List<Object>();
        Set<Id> successIds = new Set<Id>();
        Map<String,String> resultadoComites = new Map<String,String>();
        List<CC_MCC__c> listaMotivosPorProducto = new List<CC_MCC__c>();
        Map<String,String> excepcionesCodigoDTProvinciasMapa = obtenerExcepcionesCodigosDT();

        //Para cada registro, se crea un caso y se guarda en un mapa la correspondencia entre el objeto caso y el Id del registro
        for (Map<String, String> registro: registros) {
            Case caso = crearCaso(procedenciaPropietario, tematicaComiteId, 'acta de comité');

            caso.GRR_Vulnerabilidad__c = registro.get('GRR_Vulnerabilidad__c');
            caso.GRR_Departamento__c = registro.get('GRR_Departamento__c');
            caso.GRR_Motivos__c = registro.get('GRR_Motivos__c');
            caso.SAC_DireccionContacto__c = registro.get('GRR_Direccion__c'); 
            caso.SAC_PoblacionContacto__c = registro.get('GRR_Poblacion__c');
            caso.GRR_ObservacionesCP__c = registro.get('GRR_ObservacionesCP__c');
            caso.GRR_ComentariosSancion__c = registro.get('GRR_ComentariosSancionBC__c');
            caso.GRR_GRR__c = registro.get('GRR_GRR__c');
            
            //Asocia la UR
            String urLookup = registro.get('GRR_UR__c');
            caso.GRR_UR_Relacionada__c = (urLookup != null) ? urLookup : null;

            //Rellenar los MCCs
            String departamento = registro.get('GRR_Departamento__c');
            departamento = (departamento != null) ? departamento.toLowerCase() : null;
            String motivo = registro.get('GRR_Motivos__c');

            if (departamento != null && !mapaProductoMotivos.isEmpty() && mapaProductoMotivos.containsKey(departamento)){
                listaMotivosPorProducto = mapaProductoMotivos.get(departamento);

                if (!listaMotivosPorProducto.isEmpty()){
                    for (CC_MCC__c mot : listaMotivosPorProducto) {
                        if (!String.isBlank(mot.Name) && motivo != null && motivo.equalsIgnoreCase(mot.Name)){
                            caso.CC_MCC_Motivo__c = mot.Id;
                            caso.CC_MCC_ProdServ__c = mot.CC_Producto_Servicio__c;
                        }
                    }
                    
                    if(caso.CC_MCC_ProdServ__c == null){
                        caso.CC_MCC_ProdServ__c = listaMotivosPorProducto[0].CC_Producto_Servicio__c;
                    }
                }
            }

            //Mapeo Provincia
            String provincia = registro.get('GRR_Provincia__c');
            provincia = (provincia != null) ? provincia.toUpperCase() : null;

            String codigoDT = registro.get('GRR_CodigoDT__c');
            String canalProcedencia;
            String comunidad;
            String colaId;
            
            if (provincia != null && provinciasMapa.containsKey(provincia)){
                // Se encuentra equivalencia provincia
                Map<String, String> provinciaMapaAux = provinciasMapa.get(provincia);
                comunidad = provinciaMapaAux.get('GRR_Comunidad_Autonoma__c');

                if (String.isNotBlank(codigoDT) && excepcionesCodigoDTProvinciasMapa.containsKey(codigoDT) && provinciasMapa.containsKey(excepcionesCodigoDTProvinciasMapa.get(codigoDT))){
                    provinciaMapaAux = provinciasMapa.get(excepcionesCodigoDTProvinciasMapa.get(codigoDT));
                }

                canalProcedencia = provinciaMapaAux.get('GRR_Canal_Procedencia__c');
                colaId = provinciaMapaAux.get('GRR_Cola_Id__c');
            } else {
                 // No se encuentra equivalencia provincia
                Map<String, String> provinciaErroneaMapa = provinciasMapa.get('SIN IDENTIFICAR');
                provincia = null; 
                canalProcedencia = provinciaErroneaMapa.get('GRR_Canal_Procedencia__c');
                colaId = provinciaErroneaMapa.get('GRR_Cola_Id__c');
            }

            caso.GRR_Provincia__c = (provincia != null) ? provincia : null;
            caso.GRR_ComunidadAutonoma__c = (comunidad != null) ? comunidad : null;
            if (canalProcedencia != null){
                caso.CC_Canal_Procedencia__c = canalProcedencia;
            }

            casosInsert.add(caso);
            mapaIdRegistroCaso.put(registro.get('Id'), caso);
            mapaIdRegistroPropietario.put(registro.get('Id'), colaId);
        }

        if (Schema.sObjectType.Case.isCreateable() && !casosInsert.isEmpty()){
            Database.SaveResult[] srcasos = Database.insert(casosInsert, false);
            for(Database.SaveResult sr : srcasos) {
                if (sr.isSuccess()) { 
                    successIds.add(sr.getId());  
                }else{
                    if(!sr.getErrors().isEmpty()) {
                        Database.Error err = sr.getErrors()[0];
                        objs.add(err.getStatusCode() + ': ' + err.getMessage());
                        lstErrores.add(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            } 
        }
        
        Integer numGenerados = actualizarRegistrosComitesHistoricos(registros, successIds, mapaIdRegistroCaso, mapaIdRegistroPropietario, true);
        
        if(!lstErrores.isEmpty()){
            resultadoComites.put('Error', 'Error - Han sido generados correctamente (' + numGenerados + '), aunque se han encontrado los siguientes errores en el resto: ' + lstErrores);
            CBK_Log.error('Error en la generación de casos de Comités ', objs);
        } else {
            resultadoComites.put('Success', 'Han sido generados correctamente todos los casos solicitados (' + String.valueOf(numGenerados) + ')');
        }
          
        return resultadoComites;
    }

    public static Map<String,String> generarCasosHistoricos(List<Map<String, String>> registros, Map<String, Map<String, String>> provinciasMapa){
        List<Case> casosInsert = new List<Case>();
        Map<String, Case> mapaIdRegistroCaso = new Map<String, Case>();
        String procedenciaPropietario = getProcedenciaUnica();
        List<String> lstErrores = new List<String>();
        List<Object> objs = new List<Object>();
        Set<Id> successIds = new Set<Id>();
        Map<String,String> resultadoHistoricos = new Map<String,String>();

        //Obtener relaciones entre código oficina: Id, DAN, DT
        Map<String, Map<String,String>> oficinasMapa = obtenerCamposOficina(registros);
        
        //Para cada registro, se crea un caso y se guarda en un mapa la correspondencia entre el objeto caso y el Id del registro
        for (Map<String, String> registro: registros) {
            Case caso = crearCaso(procedenciaPropietario, null, 'histórico');
            
            caso.SAC_DireccionContacto__c = registro.get('GRR_Direccion__c'); 
            caso.SAC_PoblacionContacto__c = registro.get('GRR_Poblacion__c'); 

            //Asocia la UR
            String urLookup = registro.get('GRR_UR__c');
            caso.GRR_UR_Relacionada__c = (urLookup != null) ? urLookup : null;

            //Mapeo Provincia
            String provincia = registro.get('GRR_Provincia__c');
            provincia = (provincia != null) ? provincia.toUpperCase() : null;
            String comunidad;

            if (provincia != null && provinciasMapa.containsKey(provincia)){
                // Se encuentra equivalencia provincia
                Map<String, String> provinciaMapaAux = provinciasMapa.get(provincia);
                comunidad = provinciaMapaAux.get('GRR_Comunidad_Autonoma__c');
            } else {
                // No se encuentra equivalencia provincia
                provincia = null; 
            }

            caso.GRR_Provincia__c = (provincia != null) ? provincia : null;
            caso.GRR_ComunidadAutonoma__c = (comunidad != null) ? comunidad : null;
 
            // Rellena oficina - DAN - DT
            String codOficina = completarIdentificador(registro.get('GRR_CodigoOficina__c'));
            rellenarOficina(caso, codOficina, oficinasMapa);
                    
            // Concatenar los valores en el campo "Información Cliente"
            String infoCliente = limpiarCadena(registro.get('GRR_NIF__c')) + '\n'
            + limpiarCadena(registro.get('GRR_Informacion_Cliente__c'));
            caso.GRR_Informacion_Cliente__c = infoCliente.left(4000);

            casosInsert.add(caso); 
            
            mapaIdRegistroCaso.put(registro.get('Id'), caso);
        }

        if (Schema.sObjectType.Case.isCreateable() && !casosInsert.isEmpty()){
            Database.SaveResult[] srcasos = Database.insert(casosInsert, false);
            for(Database.SaveResult sr : srcasos) {
                if (sr.isSuccess()) { 
                    successIds.add(sr.getId());  
                }else{
                    if(!sr.getErrors().isEmpty()) {
                        Database.Error err = sr.getErrors()[0];
                        objs.add(err.getStatusCode() + ': ' + err.getMessage());
                        lstErrores.add(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            } 
        }
        
        Integer numGenerados = actualizarRegistrosComitesHistoricos(registros, successIds, mapaIdRegistroCaso, null, false);  
        
        if(!lstErrores.isEmpty()){
            resultadoHistoricos.put('Error', 'Error - Han sido generados correctamente (' + numGenerados + '), aunque se han encontrado los siguientes errores en el resto: ' + lstErrores);
            CBK_Log.error('Error en la generación de casos de Históricos ', objs);
        } else {
            resultadoHistoricos.put('Success', 'Han sido generados correctamente todos los casos solicitados (' + String.valueOf(numGenerados) + ')');
        }
          
        return resultadoHistoricos;
    }

    
    public static Integer actualizarRegistrosComitesHistoricos(List<Map<String, String>> registros, Set<Id> idcasosGenerados, Map<String, Case> mapaIdRegistroCaso, Map<String, String> mapaIdRegistroPropietario, Boolean esComites){
        List<GRR_RegistroCarga__c> registrosUpdate = new List<GRR_RegistroCarga__c>();
        List<Case> casosUpdate = new List<Case>();

        for ( Map<String, String> registroToUpdate : registros) {
            Case casoToUpdate = (Case) mapaIdRegistroCaso.get(registroToUpdate.get('Id')); 

            if (casoToUpdate != null  && idcasosGenerados.contains(casoToUpdate.Id)) {
                String idRegistro = registroToUpdate.get('Id');
                String idCaso = ((Case) casoToUpdate).Id;

                GRR_RegistroCarga__c registroCargaToUpdate = new GRR_RegistroCarga__c(
                    Id = idRegistro,
                    GRR_Caso__c = idCaso
                );
                
                registrosUpdate.add(registroCargaToUpdate);

                if(esComites && !mapaIdRegistroPropietario.isEmpty() && mapaIdRegistroCaso.containsKey(idRegistro)){
                    String propietarioNuevo = mapaIdRegistroPropietario.get(idRegistro);

                    if (String.isNotBlank(propietarioNuevo)){
                        casoToUpdate.OwnerId = (propietarioNuevo != null) ? propietarioNuevo : UserInfo.getUserId();
                        casosUpdate.add(casoToUpdate);  
                    }
                }
            } 
        }

        if (Schema.sObjectType.GRR_RegistroCarga__c.isUpdateable() && !registrosUpdate.isEmpty()){
            Database.update(registrosUpdate, false);
        }

        //Para actualizar el cambio de propietario 
        if (Schema.sObjectType.Case.isUpdateable() && !casosUpdate.isEmpty() && esComites){
            Database.update(casosUpdate, false);
        }

        return registrosUpdate.size();
    }

    public static Case crearCaso(String procedencia, String tematica, String tipo){
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente');
        caso.Status = '	Activo';
        caso.Origin = 'Automático';
        caso.Subject = 'Caso automático de ' + tipo;
        caso.Description = 'Caso automático de ' + tipo;
        caso.OwnerId = UserInfo.getUserId();
        caso.CC_Canal_Procedencia__c = procedencia; 
        caso.CC_MCC_Tematica__c = (tematica != null) ? tematica : null;
        return caso;
    }


    public static void rellenarOficina(Case caso, String codOficina, Map<String, Map<String,String>> oficinasMapa){
        if(String.isNotBlank(codOficina) && !oficinasMapa.isEmpty() && oficinasMapa.containsKey(codOficina)){
            Map<String,String> oficinaAux = oficinasMapa.get(codOficina);

            if(!oficinaAux.isEmpty() && oficinaAux != null){
                caso.CC_Oficina__c = oficinaAux.get('Id');
                caso.CC_Direccion_Territorial__c = oficinaAux.get('CC_Direccion_Territorial__c');
                caso.CC_DAN__c = oficinaAux.get('CC_Gerencia_Comercial__c');
            }
        }
    }
      

    public static Map<String, Map<String, Boolean>> extraerDNIs(List<Map<String, String>> registros) {
        Map<String, Map<String, Boolean>> mapaRegistrosDNIs = new  Map<String, Map<String, Boolean>>();
        
        for (Map<String, String> registro : registros) {
            Map<String, Boolean> mapaNIFs = new Map<String, Boolean>();
            String campoNIFsConRR = registro.get('GRR_NIFs_Con_RR__c');
            String campoNIFs = registro.get('GRR_NIF__c');

            // Concatena ambos campos
            String nifsConcatenados = concatenarDNIs(campoNIFsConRR, campoNIFs);

            if (String.isNotBlank(nifsConcatenados)) {
                String[] dnisArray = nifsConcatenados.split(';');
                Set<String> uniqueDNIs = new Set<String>(); // Para guardar los valores únicos
                Boolean isFirstNIF = false; // Para informar si ya se encontró el primer NIF

                for (String dni : dnisArray) {
                    if (String.isNotBlank(dni)){
                        String dniSinEspacios = dni.trim(); // Elimina espacios en blanco

                        if (String.isNotBlank(dniSinEspacios) && !uniqueDNIs.contains(dniSinEspacios)){
                            uniqueDNIs.add(dniSinEspacios);
                            
                            if (!isFirstNIF && String.isNotBlank(campoNIFsConRR)) {
                                mapaNIFs.put(dniSinEspacios, true);
                                isFirstNIF = true;
                            } else {
                                mapaNIFs.put(dniSinEspacios, false);
                            }
                        }
                    }
                }

                // Asociar el Id del registro con el mapa de NIFs - principal
                mapaRegistrosDNIs.put(registro.get('Id'), mapaNIFs);
            }
        }
        return mapaRegistrosDNIs;
    }


    public static String concatenarDNIs(String campo1, String campo2) {
        // Concatena ambos campos solo si son distintos de null o vacíos
        String textoConcatenado = '';

        if (campo1 != null && String.isNotBlank(campo1.trim())) {
            textoConcatenado += campo1.trim();
        }

        if (campo2 != null && String.isNotBlank(campo2.trim())) {
            if (String.isNotBlank(textoConcatenado)) {
                textoConcatenado += ';';
            }
            textoConcatenado += campo2.trim();
        }

        return textoConcatenado;
    }


    public static Map<String, Map<String, String>> obtenerEquivalenciasProvincias(Set<String> provincias){
        Map<String, Map<String, String>> provinciasMapa = new Map<String, Map<String, String>>();

        // Obtiene el mapeo de todas las provincias del custom metadata
        List<GRR_Equivalencia_Provincias__mdt> equivalenciasProvincias = [
            SELECT GRR_Provincia__c, GRR_Comunidad_Autonoma__c, GRR_Correos_Buzones_Relacionado__r.GRR_Canal_Procedencia__c, GRR_Correos_Buzones_Relacionado__r.GRR_Cola_Procedencia__c
            FROM GRR_Equivalencia_Provincias__mdt
            WITH SECURITY_ENFORCED
        ];

        if(!equivalenciasProvincias.isEmpty()){
            // Guarda los nombres de las colas asociadas a las provincias
            Set<String> nombresColas = new Set<String>();
            for (GRR_Equivalencia_Provincias__mdt equivalencia : equivalenciasProvincias) {
                nombresColas.add(equivalencia.GRR_Correos_Buzones_Relacionado__r.GRR_Cola_Procedencia__c);
            }

            // Obtiene los Ids de las colas asociadas y los guarda
            Map<String, Id> colaNameIdMap = new Map<String, Id>();
            for (Group cola : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN :nombresColas WITH SECURITY_ENFORCED]) {
                colaNameIdMap.put(cola.DeveloperName, cola.Id);
            }

            //Mapa completo
            for (GRR_Equivalencia_Provincias__mdt equivalencia : equivalenciasProvincias) {
                Map<String, String> provinciaMapaAux = new Map<String, String>();
                provinciaMapaAux.put('GRR_Comunidad_Autonoma__c', equivalencia.GRR_Comunidad_Autonoma__c);
                provinciaMapaAux.put('GRR_Canal_Procedencia__c', equivalencia.GRR_Correos_Buzones_Relacionado__r.GRR_Canal_Procedencia__c);
                provinciaMapaAux.put('GRR_Cola_Procedencia__c', equivalencia.GRR_Correos_Buzones_Relacionado__r.GRR_Cola_Procedencia__c);
                
                // Agregar el ID de la cola al mapa solo si está disponible
                if (colaNameIdMap.containsKey(equivalencia.GRR_Correos_Buzones_Relacionado__r.GRR_Cola_Procedencia__c)) {
                    provinciaMapaAux.put('GRR_Cola_Id__c', colaNameIdMap.get(equivalencia.GRR_Correos_Buzones_Relacionado__r.GRR_Cola_Procedencia__c));
                }

                provinciasMapa.put(equivalencia.GRR_Provincia__c, provinciaMapaAux);
            }
        }

        return provinciasMapa;
    }

    public static Map<String, String> obtenerExcepcionesCodigosDT(){
        Map<String, String> excepcionesMapa = new Map<String, String>(); // Código DT - Provincia
        Id valorRecordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CBK_Lista_Valores__c', 'CBK_Valor');
        String nombreLista = 'GRR_EXCEPCIONES_CODIGOS_DT';

        for(CBK_Lista_Valores__c valor : [SELECT Name, CBK_Valor__c FROM CBK_Lista_Valores__c WHERE RecordTypeId = :valorRecordType AND CBK_Lista__r.Name = :nombreLista AND CBK_Activa__c = true AND CBK_Lista__r.CBK_Activa__c = true AND CBK_Negocio__c  = 'GRR' WITH SECURITY_ENFORCED]){
            if (String.isNotBlank(valor.Name) && String.isNotBlank(valor.CBK_Valor__c)){
            	excepcionesMapa.put(valor.Name, valor.CBK_Valor__c.toUpperCase());
            }   
        }

        return excepcionesMapa;
    }

    public static Map<String, Map<String,String>> obtenerCamposOficina(List<Map<String, String>> registros) {
        Set<String> setCodigosOficina = new Set<String>();
        Map<String, Map<String,String>> resultado = new Map<String, Map<String,String>>();
        
        for (Map<String, String> registro : registros) {
            String codigoOficina = registro.get('GRR_CodigoOficina__c');
            
            if (String.isNotBlank(codigoOficina)) {
                codigoOficina = completarIdentificador(codigoOficina);
                setCodigosOficina.add(codigoOficina);
            }
        }

        if(!setCodigosOficina.isEmpty()){
            List<Account> lstOficinas = new List<Account>([
                SELECT Id, CC_Gerencia_Comercial__c, CC_Direccion_Territorial__c, CC_Numero_Oficina__c
                FROM Account 
                WHERE CC_Numero_Oficina__c IN :setCodigosOficina AND CC_Numero_Empresa__c = '001'
                AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank')
                ]);

            if(!lstOficinas.isEmpty()){
                for (Account oficina : lstOficinas) {
                    Map<String, String> resultadoAux = new Map<String, String>();

                    resultadoAux.put('Id', (oficina.Id != null) ? oficina.Id : null);
                    resultadoAux.put('CC_Gerencia_Comercial__c', (oficina.CC_Gerencia_Comercial__c != null) ? oficina.CC_Gerencia_Comercial__c : null);
                    resultadoAux.put('CC_Direccion_Territorial__c', (oficina.CC_Direccion_Territorial__c != null) ? oficina.CC_Direccion_Territorial__c : null);

                    resultado.put(oficina.CC_Numero_Oficina__c, resultadoAux);
                }
            }
        }

        return resultado;
    }

    public static String completarIdentificador(String identificador) {
        String identificadorCompletado = ''; 
        Integer longitud = 0;
        Integer cerosFaltantes = 0;

        if(String.isNotBlank(identificador)){
            longitud = identificador.length();
        
            if (longitud < 5) {
                cerosFaltantes = 5 - longitud;
                identificadorCompletado = '0'.repeat(cerosFaltantes) + identificador;
            }
        }
        
        return identificadorCompletado;
    }

    public static String limpiarCadena(String cadena){
        cadena = (cadena != null) ? cadena : '';
        return cadena;
    }

}