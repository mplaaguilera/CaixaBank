public without sharing class SAC_LCMP_HomeOficina {

    private static Set<String> objetos = new Set<String>{'Case','CC_Grupo_Colaborador__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEPRECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();  

    @AuraEnabled
    public static List <Case> getCases(String accountId, String oficina, String tipoBusquedaOficina, String tipoBusqueda, String valorBuscado, Date valorBuscadoDesde, Date valorBuscadoHasta) {

        String selectQuery = 'SELECT Id, LastModifiedDate, Status, SAC_EstadoRed__c, Account.Name, Account.CC_Numero_Documento__c, SAC_FechaRecepcion__c, ClosedDate, ' + 
            'SEG_Grupo__r.Name, CC_MCC_Tematica__r.Name, CC_MCC_Motivo__r.Name, CC_MCC_ProdServ__r.Name, SEG_Detalle__r.Name, SAC_SentidoResolucion__c,' +  
            'CC_Importe_Reclamado__c, CC_Importe_Abonado__c, Owner.Name, OS_Fecha_Resolucion__c, Subject, CaseNumber, SAC_FechaVencimientoSLA__c FROM Case WHERE RecordTypeId = :RECTYPEPRECLAMACION ';
        
        String whereQuery = 'AND SAC_OcultarOficina__c = false';

        if(String.isNotBlank(accountId) && String.isBlank(tipoBusquedaOficina) ){
            whereQuery = whereQuery + ' AND AccountId = :accountId';

        }else if (String.isNotBlank(tipoBusquedaOficina) && String.isNotBlank(oficina)){
            whereQuery = whereQuery + ' AND IsClosed = false ';

            if(tipoBusquedaOficina == 'ambas'){
                whereQuery = whereQuery + ' AND (Account.CC_OficinaGestoraId__c =:oficina OR CC_Oficina_Afectada_Lookup__c =:oficina)';
            }
            else if(tipoBusquedaOficina == 'gestora'){
                whereQuery = whereQuery + ' AND Account.CC_OficinaGestoraId__c =:oficina';
            }
            else{
                whereQuery = whereQuery + ' AND CC_Oficina_Afectada_Lookup__c =:oficina';
            }
     
        }else if(String.isNotBlank(tipoBusqueda) && String.isNotBlank(valorBuscado)){ 
            
            if(tipoBusqueda == 'idCaso'){
                whereQuery = whereQuery + ' AND CaseNumber = :valorBuscado';
            }
            if(tipoBusqueda == 'nif'){
                whereQuery = whereQuery + ' AND CC_SuppliedNIF__c = :valorBuscado';
            }
            if(tipoBusqueda == 'nombreCliente'){
                valorBuscado = '%' + valorBuscado + '%';
                whereQuery = whereQuery + ' AND SAC_NombreContacto__c   like :valorBuscado';
            }

        }else if(String.isNotBlank(tipoBusqueda) && valorBuscadoDesde != null && valorBuscadoHasta != null){

            if(tipoBusqueda == 'fechaRecep'){
                Integer diaAgregar = 1;
                valorBuscadoHasta = valorBuscadoHasta.addDays(diaAgregar);  // Hacemos esto porque el día hasta lo recoge como las 00:00h, entonces sumamos un día para incluir el "día hasta" en la query
                whereQuery = whereQuery + ' AND SAC_FechaRecepcion__c >= :valorBuscadoDesde AND SAC_FechaRecepcion__c <= :valorBuscadoHasta ORDER BY SAC_FechaRecepcion__c asc';
            }
        }

        if(String.isnotBlank(whereQuery)){
            return Database.query(String.escapeSingleQuotes(selectQuery + whereQuery));
        }
        else{
            return new List<Case>();
        }
    }
    @AuraEnabled
    public static List <SAC_WS_Antecedentes_RP.ClaimWrapper> getExternalCases(String accountId) {
        List<SAC_Antecedentes__c> antecedentes = new List<SAC_Antecedentes__c>();
        List <Account> clientes = [SELECT CC_Numero_Documento__c FROM Account WHERE Id =: accountId];

        Id profileId=userinfo.getProfileId();
        String profileName = [SELECT Id,Name FROM Profile WHERE Id=:profileId].Name;
    
        List <String> lstClientes = new List <String>();
        if (!clientes.isEmpty())
        {
            for(Account acc : clientes){
                lstClientes.add(acc.CC_Numero_Documento__c);
            }
            
            SAC_WS_Antecedentes_RQ.RequestWrapper reqWrapper = new SAC_WS_Antecedentes_RQ.RequestWrapper(lstClientes);
            SAC_WS_Antecedentes.AntecedentesResponse atrResponses = SAC_WS_Antecedentes.sendRequest(reqWrapper, profileName);
            List<SAC_WS_Antecedentes_RP.ClaimWrapper> antecedentesRP = atrResponses.antecedentes;
            
            return antecedentesRP;
        }
        return null;
    }

    @AuraEnabled
    public static List < Account > getOffices(String officeName) {
        String officeSearch = '*' + officeName + '*';
        String searchQuery = 'FIND \'' + officeSearch + '\' IN NAME FIELDS RETURNING Account(Id, Name WHERE RecordType.DeveloperName = \'CC_CentroCaixaBank\')';
        List<List <sObject>> searchList = search.query(searchQuery);
        return (List<Account>)searchList[0];
    }
    @AuraEnabled
    public static List <SAC_Accion__c> getActionOffice (String tipoBusqueda, String valorBuscado, Date valorBuscadoDesde, Date valorBuscadoHasta)
    {

        try {
            id accountid = [select AccountId from contact where AV_UsuarioAsociado__c =: userInfo.getUserId()].AccountId;         
            
            String selectQuery = 'SELECT Id, SAC_Oficina__r.Name, SAC_Reclamacion__r.Account.Name, SAC_Reclamacion__r.Account.CC_Numero_Documento__c, ' + 
            'SAC_FechaVencimientoProrroga__c, SAC_FechaVencimientoInicial__c, owner.Name, toLabel(SAC_Estado__c), SAC_Descripcion__c FROM SAC_Accion__c WHERE (SAC_Oficina__c = : accountid OR SAC_Oficina__r.parentId = : accountid OR SAC_Oficina__r.parent.parentId = : accountid ' + 
            'OR SAC_Oficina__r.parent.parent.parentId = : accountid OR SAC_Oficina__r.parent.parent.parent.parentId = : accountid OR SAC_Oficina__r.parent.parent.parent.parent.parentId = : accountid)';
        
            String whereQuery = '';

            if(String.isNotBlank(tipoBUsqueda) && tipoBusqueda == 'porDefecto'){
                List<String> listaEstados = new List<String>{'SAC_PendienteAsignar', 'SAC_EnGestion', 'SAC_StandBy'};
                whereQuery = ' AND SAC_Estado__c  IN :listaEstados';

            }else if(String.isNotBlank(tipoBusqueda) && String.isNotBlank(valorBuscado)){  

                if(tipoBusqueda == 'idTarea'){
                    valorBuscado = '%' + valorBuscado.toLowerCase() + '%';
                    whereQuery = ' AND Name like :valorBuscado';
                }
                if(tipoBusqueda == 'asunto'){
                    valorBuscado = '%' + valorBuscado.toLowerCase() + '%';
                    whereQuery = ' AND SAC_Descripcion__c like :valorBuscado';
                }
                if(tipoBusqueda == 'estado'){
                    // valorBuscado = '%' + valorBuscado.toLowerCase() + '%';
                    whereQuery = ' AND SAC_Estado__c  = :valorBuscado';
                }
            }else if(String.isNotBlank(tipoBusqueda) && valorBuscadoDesde != null && valorBuscadoHasta != null){

                if(tipoBusqueda == 'fechaCreacion'){

                    Integer diaAgregar = 1;
                    valorBuscadoHasta = valorBuscadoHasta.addDays(diaAgregar);  // Hacemos esto porque el día hasta lo recoge como las 00:00h, entonces sumamos un día para incluir el "día hasta" en la query
                    whereQuery = ' AND CreatedDate >= :valorBuscadoDesde AND CreatedDate <= :valorBuscadoHasta ORDER BY CreatedDate asc';
                }
            }
            
            if(String.isnotBlank(whereQuery)){
                return Database.query(String.escapeSingleQuotes(selectQuery + whereQuery));
            }
            else{
                return new List<SAC_Accion__c>();
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List <SAC_Interaccion__c> getConsultaOffice (String tipoBusqueda, String valorBuscado, Date valorBuscadoDesde, Date valorBuscadoHasta)
    {
        try {

            
            id accountid = [select AccountId from contact where AV_UsuarioAsociado__c =: userInfo.getUserId()].AccountId;
            
            String selectQuery = 'SELECT Id, SAC_Oficina__r.Name, SAC_Titulo__c, SAC_Reclamacion__r.Account.Name, SAC_Reclamacion__r.Account.CC_Numero_Documento__c, ' + 
            'SAC_Fecha_Vencimiento__c, toLabel(SAC_Estado__c) FROM SAC_Interaccion__c WHERE (SAC_Oficina__c = : accountid OR SAC_Oficina__r.parentId = : accountid OR SAC_Oficina__r.parent.parentId = : accountid ' + 
            'OR SAC_Oficina__r.parent.parent.parentId = : accountid OR SAC_Oficina__r.parent.parent.parent.parentId = : accountid OR SAC_Oficina__r.parent.parent.parent.parent.parentId = : accountid)';
        
            String whereQuery = '';

            if(String.isNotBlank(tipoBusqueda) && tipoBusqueda == 'porDefecto'){

                if(String.isBlank(valorBuscado)){
                    List<String> listaEstados = new List<String>{'SAC_PendienteRespuesta', 'SAC_PendienteRespuestaDefinitiva'};
                    whereQuery = ' AND SAC_Estado__c IN :listaEstados';

                }else if(String.isNotBlank(valorBuscado)){
                    whereQuery = ' AND SAC_Reclamacion__c = :valorBuscado';
                }
                    
            }else if(String.isNotBlank(tipoBusqueda) && (String.isNotBlank(valorBuscado) || (String.isBlank(valorBuscado) && valorBuscadoDesde == null))){ 

                if(tipoBusqueda == 'idConsulta'){
                    whereQuery = ' AND Name = :valorBuscado';
                }
                if(tipoBusqueda == 'asunto'){
                    valorBuscado = '%' + valorBuscado.toLowerCase() + '%';
                    whereQuery = ' AND SAC_Titulo__c like :valorBuscado';
                }
                if(tipoBusqueda == 'estado'){
                    whereQuery = ' AND SAC_Estado__c = :valorBuscado';
                }

            }
            else if(String.isNotBlank(tipoBusqueda) && valorBuscadoDesde != null && valorBuscadoHasta != null){

                if(tipoBusqueda == 'fechaCreacion'){

                    Integer diaAgregar = 1;
                    valorBuscadoHasta = valorBuscadoHasta.addDays(diaAgregar);  // Hacemos esto porque el día hasta lo recoge como las 00:00h, entonces sumamos un día para incluir el "día hasta" en la query
                    whereQuery = ' AND CreatedDate >= :valorBuscadoDesde AND CreatedDate <= :valorBuscadoHasta ORDER BY CreatedDate asc';
                }
            }
    
            if(String.isnotBlank(whereQuery)){
                return Database.query(String.escapeSingleQuotes(selectQuery + whereQuery));
            }
            else{
                return new List<SAC_Interaccion__c>();
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void shareAccion(Id accionId)
    {
        List<SAC_Accion__Share> accionesShare = new List<SAC_Accion__Share>();
        accionesShare.add(new SAC_Accion__Share(
                            ParentId = accionId,
                            UserOrGroupId = userInfo.getUserId(),
                            AccessLevel = 'Edit'
                        ));
        SAC_DatabaseDML.insertListDML(accionesShare, false);
        //Database.insert(accionesShare, false);
    }

    @AuraEnabled
    public static void shareInteraccion (Id interaccionId)
    {
        List<SAC_Interaccion__Share> interaccionesShare = new List<SAC_Interaccion__Share>();
        interaccionesShare.add(new SAC_Interaccion__Share(
                            ParentId = interaccionId,
                            UserOrGroupId = userInfo.getUserId(),
                            AccessLevel = 'Edit'
                        ));
        SAC_DatabaseDML.insertListDML(interaccionesShare, false);
        //Database.insert(interaccionesShare, false);
    }

    @AuraEnabled
    public static Id getCaseRecordTypeId ()
    {
        Id recTypeReclamacionId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        
        return recTypeReclamacionId;
    }

    @AuraEnabled
    public static void modificarPermisosAccount(Id cuenta){
        Id idUsuario = UserInfo.getUserId();
        List <AccountShare> listaAccountShare = new List <AccountShare>();

        listaAccountShare = [SELECT Id, AccountId, UserOrGroupId, CaseAccessLevel FROM AccountShare WHERE AccountId = :cuenta AND UserOrGroupId = :idUsuario];

        if (!listaAccountShare.isEmpty()) {
            for (AccountShare accShare : listaAccountShare) {
                accShare.CaseAccessLevel = 'Edit'; //Necesario para la creación del caso. Una vez creado, se devuelve a none.
            }

            SAC_DatabaseDML.updateListDML(listaAccountShare, true);
            //Database.update(listaAccountShare);
        }
    }

    @AuraEnabled
    public static void modificarPermisosReadAccount(Id cuenta){
        Id idUsuario = UserInfo.getUserId();
        List <AccountShare> listaAccountShare = new List <AccountShare>();

        listaAccountShare = [SELECT Id, AccountId, UserOrGroupId, CaseAccessLevel FROM AccountShare WHERE AccountId = :cuenta AND UserOrGroupId = :idUsuario];

        if (!listaAccountShare.isEmpty()) {
            for (AccountShare accShare : listaAccountShare) {
                accShare.CaseAccessLevel = 'None'; //Se quita el permiso Edit dado anteriormente para poder crear el caso
            }

            SAC_DatabaseDML.updateListDML(listaAccountShare, true);
            //Database.update(listaAccountShare);
        }
    }

    @AuraEnabled
    public static List<PicklistValue> getEstados(String objectName) {

        List<PicklistValue> picklistOptions = new List<PicklistValue>();
        PicklistValue optionDefecto = new PicklistValue();
        if(objectName == 'consulta'){
            optionDefecto.label = ' ';
            optionDefecto.value = '';
            picklistOptions.add(optionDefecto);
        }
        
        String fieldPath = 'SAC_Estado__c';
        Schema.DescribeFieldResult fieldResult;
        
        if(objectName == 'consulta'){
            fieldResult = Schema.SObjectType.SAC_Interaccion__c.fields.getMap().get(fieldPath).getDescribe();
        }else if(objectName == 'tarea'){
            fieldResult = Schema.SObjectType.SAC_Accion__c.fields.getMap().get(fieldPath).getDescribe();
        }
        
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntries) {          
            PicklistValue option = new PicklistValue();
            option.label = entry.getLabel();
            option.value = entry.getValue();
            picklistOptions.add(option);
        }
        return picklistOptions;
    }

    public class PicklistValue {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }
}