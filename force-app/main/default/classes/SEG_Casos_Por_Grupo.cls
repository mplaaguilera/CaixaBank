public with sharing class SEG_Casos_Por_Grupo {

    public class GruposListviews {
        @AuraEnabled
        public List<CC_Grupo_Colaborador__c> gruposOperativos;
        @AuraEnabled
        public List<ListView> listViews;
    }

    @AuraEnabled(cacheable=true)
    public static GruposListviews getGruposListviews() {
        GruposListviews retorno = new GruposListviews();
        retorno.gruposOperativos = [SELECT Name, SEG_Organizacion__c, SEG_Zona__c FROM CC_Grupo_Colaborador__c
                                        WHERE SEG_Inactivo__c = FALSE
                                        AND Id IN (SELECT CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c
                                                        WHERE CC_Usuario__c = :UserInfo.getUserId())];
        retorno.listViews = [SELECT Name FROM ListView WHERE SObjectType = 'Case' LIMIT 200];
        return retorno;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getZonas() {
        List<Map<String, String>> retorno = new List<Map<String, String>>();
        List<PicklistEntry> valoresPicklistZona = SObjectType.Case.fields.SEG_Zona__c.getSObjectField().getDescribe().getPicklistValues();
        for (PicklistEntry valorPicklistZona : valoresPicklistZona) {
            if (valorPicklistZona.isActive()) {
                retorno.add(new Map<String, String>{
                    'name' => valorPicklistZona.getValue(),
                    'label' => valorPicklistZona.getLabel()
                });
            }
        }
        return retorno;
    }

    public class Filtro {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String nombre;
        @AuraEnabled
        public String campo;
        @AuraEnabled
        public String operador;
        @AuraEnabled
        public String operadorApi;
        @AuraEnabled
        public String valor;
        @AuraEnabled
        public String title;
    }

    public class ResultadoCasos {
        @AuraEnabled
        public List<Case> casos;
        @AuraEnabled
        public Integer totalCount;
    }

    @AuraEnabled
    public static ResultadoCasos getCasosGruposOperativos(String tipoBusqueda, List<Id> idGruposOperativos, List<String> fieldNames, List<String> zonas, Integer pagina, Boolean incluirCount, String filtrosJSON, String logicaFiltro) {
        //try {
            ResultadoCasos retorno = new ResultadoCasos();
            if (!fieldNames.isEmpty()) {
                //Añadir toLabel() a los campos picklist para recuperar el label y no el api name
                Map<String, Schema.SObjectField> mapaFields = Schema.describeSObjects(new List<String>{'Case'})[0].fields.getMap();
                List<String> fieldNamesAux = new List<String>();
                for (String fieldName : fieldNames) {
                    if (!fieldName.contains('.') && mapaFields.get(fieldName).getDescribe().getType() == DisplayType.PICKLIST) {
                        fieldName = 'toLabel(' + fieldName + ')';
                    }
                    fieldNamesAux.add(fieldName);
                }

                List<String> listDevNames = new List<String>();
                listDevNames.add('SEG_Cliente');
                listDevNames.add('SEG_Seguimiento');
                String consultaSelectCasos = 'SELECT ' + String.join(fieldNamesAux, ', ') + ' FROM Case ';
                String consultaWhere = 'WHERE RecordType.DeveloperName IN :listDevNames ';
                Id userId = UserInfo.getUserId();
                String ownerSEGBO = 'SEG_BO';
                List<String> valoresStatus = new List<String>();
                switch on tipoBusqueda {
                    when 'Mis casos'{
                        valoresStatus.add('Activo');
                        valoresStatus.add('Abierto');
                        valoresStatus.add('Pendiente');
                        valoresStatus.add('Planificado');
                        consultaWhere += 'AND OwnerId = :userId AND Status IN :valoresStatus';
                    }
                    when 'Mis casos activos'{
                        valoresStatus.add('Activo');
                        valoresStatus.add('Abierto');
                        consultaWhere += 'AND OwnerId = :userId AND Status IN :valoresStatus';
                    }
                    when 'Mis casos pendientes'{
                        valoresStatus.add('Pendiente');
                        consultaWhere += 'AND OwnerId = :userId AND Status IN :valoresStatus';
                    }
                    when 'Mis casos planificados'{
                        valoresStatus.add('Planificado');
                        consultaWhere += 'AND OwnerId = :userId AND Status IN :valoresStatus';
                    }
                    when 'Mis casos cerrados'{
                        valoresStatus.add('Cerrado');
                        consultaWhere += 'AND OwnerId = :userId AND Status IN :valoresStatus';
                    }
                    when 'Casos activos de mis grupos'{
                        valoresStatus.add('Activo');
                        valoresStatus.add('Abierto');
                        List<Id> idMisGruposOperativos = new List<Id>();
                        for (CC_Grupo_Colaborador_Contact__c grupo : [SELECT CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c
                                                                WHERE CC_Usuario__c = :UserInfo.getUserId()]) {
                            idMisGruposOperativos.add(grupo.CC_Grupo_Colaborador__c);
                        }
                        consultaWhere += 'AND SEG_Grupo__c IN :idMisGruposOperativos AND Owner.Name = :ownerSEGBO AND Status IN :valoresStatus';
                    }
                    when 'Casos de los grupos seleccionados'{
                        if(!idGruposOperativos.isEmpty()){
                            valoresStatus.add('Activo');
                            valoresStatus.add('Abierto');
                            consultaWhere += 'AND SEG_Grupo__c IN :idGruposOperativos AND Owner.Name = :ownerSEGBO AND Status IN :valoresStatus';
                        }
                    }
                }

                consultaWhere = anyadirfiltroZonas(consultaWhere, zonas);

                //Transformación de filtros manuales introducidos en el JS
                List<Filtro> filtros = new List<Filtro>();

                if(filtrosJSON != null){
                    filtros = (List<Filtro>) JSON.deserialize(filtrosJSON, List<Filtro>.class);
                }

                if(filtros != null && !filtros.isEmpty()){
                    String retornoFiltro = '';
                    if (logicaFiltro != null && logicaFiltro != '') {
                        retornoFiltro = logicaFiltro;
                    } else {
                        for (Integer i = 0; i < filtros.size(); i++) {
                            retornoFiltro += String.valueOf(i+1) + ' AND ';
                        }
                        retornoFiltro = retornoFiltro.substring(0, retornoFiltro.lastIndexOf(' AND '));
                    }

                    for (Integer i = 0; i < filtros.size(); i++) {
                        retornoFiltro=retornoFiltro.replace(String.valueOf(i+1), '#@#' + String.valueOf(i + 1) + '#@#');
                    }

                    if (retornoFiltro != ''){
						retornoFiltro = '('+retornoFiltro+')';
                    }

                    String conjuntoFiltro;
                    for (Integer i = 0; i < filtros.size(); i++) {
                        conjuntoFiltro = '';
                        if (filtros[i].operador == 'contiene') {
                            String filtroEscapado = '%' + String.escapeSingleQuotes(filtros[i].valor) + '%';
                            conjuntoFiltro = filtros[i].campo + ' LIKE "' + filtroEscapado + '"';
                        } else if (filtros[i].operador == 'no contiene') {
                            String filtroEscapado2 = '%' + String.escapeSingleQuotes(filtros[i].valor) + '%';
                            conjuntoFiltro = '(NOT ' + filtros[i].campo + ' LIKE "' + filtroEscapado2 + '")';
                        } else if (filtros[i].operador == 'comienza por') {
                            String filtroEscapado3 = String.escapeSingleQuotes(filtros[i].valor) + '%';
                            conjuntoFiltro = filtros[i].campo + ' LIKE "' + filtroEscapado3 + '%"';
                        } else {
                            String filtroEscapado4 = String.escapeSingleQuotes(filtros[i].valor);
                            conjuntoFiltro = filtros[i].campo + ' ' + filtros[i].operadorApi + ' "' + filtroEscapado4 + '"';
                        }
                        //retornoFiltro = retornoFiltro.replace(String.valueOf(i + 1), conjuntoFiltro);
                        retornoFiltro = retornoFiltro.replace('#@#' + String.valueOf(i + 1) + '#@#', conjuntoFiltro);
                    }
                    consultaWhere += ' AND ' + retornoFiltro;
                }

                String consultaEscaped = '';
                //Si es la primera carga de datos recoge 300 registros
                if (pagina == 0){
                    consultaEscaped = consultaSelectCasos + consultaWhere + ' ORDER BY SEG_Priority_Orden__c ASC, CreatedDate ASC LIMIT 300';
                }
                else{
                    //En las siguientes carga de datos recoge los 100 registros siguientes
                    consultaEscaped = consultaSelectCasos + consultaWhere + ' ORDER BY SEG_Priority_Orden__c ASC, CreatedDate ASC LIMIT 100 OFFSET '+ (300 + (pagina - 1) * 100);
                }

                //String consultaEscaped = consultaSelectCasos + consultaWhere + ' ORDER BY SEG_Priority_Orden__c ASC, CreatedDate ASC LIMIT 100 OFFSET ' + (pagina * 100);
                retorno.casos = (List<Case>)Database.query(String.escapeSingleQuotes(consultaEscaped).replaceAll('"','\''));
                if (incluirCount) {
                    retorno.totalCount = Database.countQuery('SELECT Count() FROM Case ' + String.escapeSingleQuotes(consultaWhere).replaceAll('"','\''));
                }
            }
            return retorno;
        //} catch(Exception e) {
            //throw new AuraHandledException(e.getMessage());
        //}
    }

    @AuraEnabled(cacheable=true)
    public static List<Campo> definicionCamposCase() {
        List<Campo> campos = new List<Campo>();
        Map<String, Schema.SObjectField> mapaFields = Schema.describeSObjects(new List<String>{'Case'})[0].fields.getMap();
        for (String developerName : mapaFields.keySet()) {
            Schema.DescribeFieldResult fieldDesc = mapaFields.get(developerName).getDescribe();
			if (fieldDesc.isAccessible()) {
				Campo campo = new Campo();
				campo.name = developerName;
				campo.displayType = displayTypeString(fieldDesc.getType());

                //Para lookups estándar usamos el label del objeto al que apuntan en lugar del label del campo
                if (fieldDesc.getType() == DisplayType.REFERENCE && !fieldDesc.isCustom() && !fieldDesc.isNamePointing()
                && fieldDesc.getReferenceTo()[0].getDescribe().getName() != 'User'
                && fieldDesc.getReferenceTo()[0].getDescribe().getName() != 'Case') {
                    campo.label = fieldDesc.getReferenceTo()[0].getDescribe().getLabel();
                } else {
                    campo.label = fieldDesc.getLabel();

                }

                if (fieldDesc.getType() == DisplayType.REFERENCE) {
					campo.relationshipName = fieldDesc.getRelationshipName();
				}
				campos.add(campo);
			}
        }
        return campos;
    }

    @TestVisible
    public class Campo {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String displayType;
        @AuraEnabled
        public String relationshipName;
    }

    private static String displayTypeString(Schema.DisplayType displayType) {
        switch on displayType {
            when REFERENCE {
                return 'REFERENCE';
            }
            when STRING {
                return 'STRING';
            }
            when BOOLEAN {
                return 'CHECKBOX';
            }
            when PICKLIST {
                return 'PICKLIST';
            }
            when INTEGER {
                return 'INTEGER';
            }
            when DOUBLE {
                return 'DOUBLE';
            }
            when PERCENT {
                return 'PERCENT';
            }
            when ID {
                return 'ID';
            }
            when DATE {
                return 'DATE';
            }
            when DATETIME {
                return 'DATETIME';
            }
            when TIME {
                return 'TIME';
            }
            when URL {
                return 'URL';
            }
            when EMAIL {
                return 'EMAIL';
            }
            when PHONE {
                return 'PHONE';
            }
            when LONG {
                return 'LONG';
            }
            when CURRENCY {
                return 'CURRENCY';
            }
            when MULTIPICKLIST {
                return 'MULTIPICKLIST';
            }
            when ENCRYPTEDSTRING {
                return 'ENCRYPTEDSTRING';
            }
            when else {
                return '';
            }
        }
    }

    private static String anyadirfiltroZonas(String consultaWhere, List<String> zonas) {
        if (zonas.isEmpty()) {
            return consultaWhere;
        } else {
            for (Integer i = 0; i < zonas.size(); i++) {
                zonas[i] = '"' + zonas[i] + '"';
            }
            return consultaWhere + ' AND SEG_Zona__c IN (' + String.join(zonas, ', ') + ')';
        }
    }

    @AuraEnabled
    public static void tomarPropiedad(List<Id> idCasos) {
		try {
			SEG_Case.tomarPropiedad(idCasos);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
    }

    @AuraEnabled
    public static void rechazar(List<Id> idCasos) {
        Set<Id> setCasos = new Set<Id>();

        for(Id idCaso : idCasos){
            setCasos.add(idCaso);
        }

        SEG_Casos_Por_Grupo_Queueable cPGQ = new SEG_Casos_Por_Grupo_Queueable(setCasos);
		System.enqueueJob(cPGQ);
    }

    @AuraEnabled(cacheable=true)
    public static Boolean esSupervisor(Id idUsuario) {
        return FeatureManagement.checkPermission('SEG_Administrador_Negocio');
    }

    @AuraEnabled
    public static void cambiarPropietarioMasivo(List<Id> idCasos, String userId) {
        try {
            SEG_Case.cambiarOwner(idCasos, userId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getSegmentosRecordType(){
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
    }

    @AuraEnabled
    public static SEG_Case.RespuestaCompleja cambiarGrupoMasivoLWC(List<Id> idCasos, String grupoId) {
        SEG_Case.RespuestaCompleja resultado = new SEG_Case.RespuestaCompleja();
        try {
            resultado = SEG_Case.cambiarGrupoMasivo(idCasos, grupoId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return resultado;
    }

    @AuraEnabled
    public static void cerrarCasoMasivoLWC(List<Id> idCasos) {
        try {
            SEG_Case.cerrarCasoMasivo(idCasos);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> validarNif(String nif) {
        Map<String, Object> retorno = new Map<String, Object>();
        if (String.isNotBlank(nif) && nif.length() < 8) {
            //Falta validar REGEX
            retorno.put('validación', 'NIF no válido.');
        } else {
            List<Account> cuentas = [SELECT Name, SEG_Prioridad_Carterizacion_Segmentos__c, AV_OficinaPrincipal__r.SEG_Organizacion__c,
                                    AV_OficinaPrincipal__r.SEG_Zona__c, SEG_Oficina_Gestora_Segmentos__r.SEG_Organizacion__c,
                                    SEG_Oficina_Gestora_Segmentos__r.SEG_Zona__c FROM Account WHERE CC_Numero_Documento__c = :nif LIMIT 1];
            if (cuentas.isEmpty()) {
                retorno.put('validación', 'NIF no existente.');
            } else {
                Account cuenta = cuentas[0];
                retorno.put('cuenta', cuenta);
                if (cuenta.SEG_Prioridad_Carterizacion_Segmentos__c
                && cuenta.SEG_Oficina_Gestora_Segmentos__r.SEG_Organizacion__c != null
                && cuenta.SEG_Oficina_Gestora_Segmentos__r.SEG_Zona__c != null) {
                    retorno.put('validación', 'OK');
                    retorno.put('org', cuenta.SEG_Oficina_Gestora_Segmentos__r.SEG_Organizacion__c);
                    retorno.put('zona', cuenta.SEG_Oficina_Gestora_Segmentos__r.SEG_Zona__c);
                } else if (cuenta.AV_OficinaPrincipal__r.SEG_Organizacion__c != null && cuenta.AV_OficinaPrincipal__r.SEG_Zona__c != null) {
                    retorno.put('validación', 'OK');
                    retorno.put('org', cuenta.AV_OficinaPrincipal__r.SEG_Organizacion__c);
                    retorno.put('zona', cuenta.AV_OficinaPrincipal__r.SEG_Zona__c);
                } else {
                    retorno.put('validación', 'La cuenta carece de Org/Zona.');
                }
            }
        }
        return retorno;
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getUsuariosSEG(String cadenaBusqueda) {
        return [SELECT Name FROM User WHERE Name LIKE : ('%' + cadenaBusqueda + '%') AND Profile.Name = 'SEG_Usuario_CaixaBank' LIMIT 20];
    }
}