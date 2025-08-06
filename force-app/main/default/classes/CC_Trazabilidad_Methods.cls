public with sharing class CC_Trazabilidad_Methods {
    /*
     * Metodo principal de Trazabilidad que distribuirá hacía los distintos metodos en función del paso en el que se encuentre el proceso de Trazabilidad
     */
    /*@InvocableMethod(label='CC_CircuitoTRZ' description='Circuito Trazabilidad')
	public static void CircuitoTrazabilidad(String metro, List<Id> IdCasos){
        Switch on metro {
            when 'Reapertura' {
                
            }
            when 'Alta' {
                
            }
            when 'Recepcion', 'Asignacion', 'Resolucion', 'Cierre' {
                
            }
            when 'Aviso' {
                
            }
            when 'Baja' {
                
            }
            when 'BajaAviso' {
                
            }
        }
    }*/
    
    /*
     * Trazabilidad: Función encargada de crear un registro de Alta de petición en TRZ
     */
    @InvocableMethod(label='CC_altaPeticionTRZ' description='Alta Peticion Trazabilidad')
    public static void altaPeticion(List<Id> CaseId) {
        
        //Recuperamos los datos del caso
        List<Case> oListCaso = getCaseData(CaseId);
        
        //Recuperamos las trazabilidades
        List<CC_Trazabilidad__c> TRZ = [SELECT Id, CC_Control_Envio__c, CC_Numperso__c, CC_Oficina__c, CC_Fecha_Inicio_Peticion__c, CC_Fecha_Fin_Peticion__c, CC_Orden__c,
                                        CC_Estado__c, CC_Tipo_de_Registro__c, CC_Id_Peticion__c, CC_Nueva_Instancia__c 
                                        FROM CC_Trazabilidad__c 
                                        WHERE CC_Id_Peticion__c = :CaseId AND CC_Estado__c = 'Activo'
                                        ORDER BY CreatedDate ASC, CC_Orden__c ASC];
        //Recuperamos el ID del proceso que es un parmaetro
        String sIdproceso = CC_MetodosUtiles.getParamValue('CC_IDPROCES');
        List<CC_Trazabilidad__c> trazabilidadInsertAlta =  new List<CC_Trazabilidad__c>();
        List<CC_Trazabilidad__c> trazabilidadInsertBaja =  new List<CC_Trazabilidad__c>();
        for (Case oCaso : oListCaso) {
            if (oCaso.CC_Fecha_Limite_Resolucion__c != null){
                List<CC_Trazabilidad__c> ListTRZUpd = new List<CC_Trazabilidad__c>();    
                
                String sDatfipeticio;
                String sDatpeticio; 
                Integer sNum = 3;
                Id sRechazId= null;
                String year = null;
                String month = null;
                String day = null;
                
                //Tratamos las fechas para dejarlas en formato AAAAMMDD
                if (oCaso.CC_Fecha_Reapertura__c != null){
                    year = String.valueOf(oCaso.CC_Fecha_Reapertura__c.year());
                    month = String.valueOf(oCaso.CC_Fecha_Reapertura__c.month());
                    day = String.valueOf(oCaso.CC_Fecha_Reapertura__c.day());
                    // Control de 0s en los dias y meses menores de 10
                    if (month.length()==1){
                        month = '0'+month;
                    }
                    if (day.length()==1){
                        day = '0'+day;
                    }
                    sDatpeticio = year + month + day;
                } else {
                    year = String.valueOf(oCaso.CreatedDate.year());
                    month = String.valueOf(oCaso.CreatedDate.month());
                    day = String.valueOf(oCaso.CreatedDate.day());
                    if (month.length()==1){
                        month = '0'+month;
                    }
                    if (day.length()==1){
                        day = '0'+day;
                    }
                    sDatpeticio = year + month + day;
                }
                if (oCaso.CC_Fecha_Limite_Resolucion__c != null){
                    year = String.valueOf(oCaso.CC_Fecha_Limite_Resolucion__c.year());
                    month = String.valueOf(oCaso.CC_Fecha_Limite_Resolucion__c.month());
                    day = String.valueOf(oCaso.CC_Fecha_Limite_Resolucion__c.day());
                    // Control de 0s en los dias y meses menores de 10
                    if (month.length()==1){
                        month = '0'+month;
                    }
                    if (day.length()==1){
                        day = '0'+day;
                    }
                    sDatfipeticio = year + month + day;
                }
                
                //Buscamos si existe algun registro de Trazabilidad
                Boolean trazabilidadEncontrada = false;
                for (CC_Trazabilidad__c trAlta : TRZ) {
                    if (trAlta.CC_Id_Peticion__c == oCaso.Id && trAlta.CC_Tipo_de_Registro__c == 'Alta') {
                        // Si existe registro pdte de envio lo actualizamos
                        if (trAlta.CC_Control_Envio__c == 'Pdte. Envio'){
                            if (oCaso.Account.CC_NumPerso__c == null){
                                trAlta.CC_Numperso__c = '0';
                            } else{
                                trAlta.CC_Numperso__c = oCaso.Account.CC_NumPerso__c;
                            }
                            trAlta.CC_Oficina__c = oCaso.Account.CC_OficinaGestoraId__r.CC_Numero_Oficina__c;
                            trAlta.CC_Fecha_Inicio_Peticion__c = sDatpeticio;
                            trAlta.CC_Fecha_Fin_Peticion__c = sDatfipeticio;
                            update trAlta;
                        } else {
                            // Si existe un registro y ya esta enviado deberemos:
                            // 1. Actualizar el registro de Alta incorporandole estado "Rechazado"
                            trAlta.CC_Estado__c = 'Rechazado';
                            update trAlta;
                            sRechazId = trAlta.Id;
                            // 2. Rechazar una baja previa si existiera
                            if (sRechazId != null) {
                                for (CC_Trazabilidad__c trBaja : TRZ) {
                                    if (trBaja.CC_Id_Peticion__c == oCaso.Id && trBaja.CC_Tipo_de_Registro__c == 'Baja') {
                                        trBaja.CC_Estado__c = 'Rechazado';
                                        update trBaja;
                                        break;
                                    }
                                }
                            }
                            // 3. Crear un registro de Baja copia del registro de Alta que acabamos de rechazar
                            CC_Trazabilidad__c newBajaTRZ = trAlta.clone();
                            newBajaTRZ.CC_Orden__c = 1;
                            newBajaTRZ.CC_Control_Envio__c = 'Pdte. Envio';
                            newBajaTRZ.CC_Estado__c = 'Activo';
                            newBajaTRZ.CC_Nueva_Instancia__c = 'B';
                            newBajaTRZ.CC_Tipo_de_Registro__c = 'Baja';
                            trazabilidadInsertBaja.add(newBajaTRZ);
                            //insert newBajaTRZ;
                            // 4. Crear un registro de Alta con los nuevos parametros
                            CC_Trazabilidad__c newAltaTRZ = trAlta.clone();
                            newAltaTRZ.CC_Orden__c = 2;
                            newAltaTRZ.CC_Control_Envio__c = 'Pdte. Envio';
                            newAltaTRZ.CC_Estado__c = 'Activo';
                            newAltaTRZ.CC_Nueva_Instancia__c = 'A';
                            newAltaTRZ.CC_Tipo_de_Registro__c = 'Alta';
                            if (oCaso.Account.CC_NumPerso__c == null){
                                newAltaTRZ.CC_Numperso__c = '0';
                            } else{
                                newAltaTRZ.CC_Numperso__c = oCaso.Account.CC_NumPerso__c;
                            }
                            newAltaTRZ.CC_Oficina__c = oCaso.Account.CC_OficinaGestoraId__r.CC_Numero_Oficina__c;
                            newAltaTRZ.CC_Fecha_Inicio_Peticion__c = sDatpeticio;
                            newAltaTRZ.CC_Fecha_Fin_Peticion__c = sDatfipeticio;
                            trazabilidadInsertBaja.add(newAltaTRZ);
                            //insert newAltaTRZ;
                            // 5. Creamos el paso de Recepcion
                            if(oCaso.CC_Fecha_Reapertura__c == null) {
                                List<Id> ListCaseId = new List<Id>();
                                ListCaseId.add(oCaso.Id);
                                altaPaso('Recepcion', sDatpeticio, ListCaseId);
                            }
                            // 6. Actualizar todos los registros Activos incorporandoles el estado pendiente de envio
                            for (CC_Trazabilidad__c actTraz : TRZ) {
                                if (actTraz.CC_Id_Peticion__c == oCaso.Id && actTraz.CC_Tipo_de_Registro__c != 'Baja' && actTraz.CC_Tipo_de_Registro__c != 'Alta') {
                                    actTraz.Id = actTraz.Id;
                                    actTraz.CC_Estado__c = 'Activo';
                                    actTraz.CC_Orden__c = sNum;
                                    actTraz.CC_Control_Envio__c = 'Pdte. Envio';
                                    ListTRZUpd.add(actTraz);
                                    sNum = sNum +1;
                                }
                            }
                            // Actualizar registros Activos para volver a enviar
                            if (ListTRZUpd.size() > 0){
                                Database.SaveResult[] oResUp = Database.update(ListTRZUpd, false);
                            }
                        }
                        trazabilidadEncontrada = true;
                        break;
                    }
                }
                
                if (!trazabilidadEncontrada) {
                    // Si no existe un registro activo lo creamos.
                    CC_Trazabilidad__c newTRZ = new CC_Trazabilidad__c();
                    newTRZ.CC_Id_Peticion__c = oCaso.Id;
                    newTRZ.CC_Nombre_Parametro__c = oCaso.Id;
                    newTRZ.CC_Orden__c = 2;
                    newTRZ.CC_Id_Proceso__c = sIdproceso;
                    if (oCaso.Account.CC_NumPerso__c == null){
                        newTRZ.CC_Numperso__c = '0';
                    } else{
                        newTRZ.CC_Numperso__c = oCaso.Account.CC_NumPerso__c;
                    }
                    newTRZ.CC_Oficina__c = oCaso.Account.CC_OficinaGestoraId__r.CC_Numero_Oficina__c;
                    newTRZ.CC_Fecha_Inicio_Peticion__c = sDatpeticio;
                    newTRZ.CC_Fecha_Fin_Peticion__c = sDatfipeticio;
                    newTRZ.CC_Nueva_Instancia__c = 'A';
                    newTRZ.CC_Tipo_de_Registro__c = 'Alta';
                    newTRZ.CC_Control_Envio__c = 'Pdte. Envio';
                    newTRZ.CC_Estado__c = 'Activo';
                    insert newTRZ;
                    if(oCaso.CC_Fecha_Reapertura__c == null) {
                        List<Id> ListCaseId = new List<Id>();
                        ListCaseId.add(oCaso.Id);
                        altaPaso('Recepcion', sDatpeticio, ListCaseId);
                    }
                }
            }
        }
        if (!trazabilidadInsertBaja.isEmpty()){
            Database.SaveResult[] resultado = Database.insert(trazabilidadInsertBaja);
        }
        if (!trazabilidadInsertAlta.isEmpty()){
            Database.SaveResult[] resultado = Database.update(trazabilidadInsertAlta);
        }
    }
	
    /*
     * Trazabilidad: Función encargada de crear un registro de paso de una petición en TRZ
     */
    //public static void altaPaso(String tipoPaso, String fechainicio, Id CaseId){
    public static void altaPaso(String tipoPaso, String fechainicio, List<Id> ListCaseId){
        
        //Recuperamos los datos del caso
        List<Case> oListCaso = getCaseData(ListCaseId);

        List<CC_Trazabilidad__c> TRZ = [SELECT Id, CC_Control_Envio__c, CC_Numperso__c, CC_Oficina__c, CC_Fecha_Inicio_Peticion__c, CC_Fecha_Fin_Peticion__c, 
                                            CC_Orden__c, CC_Estado__c, CC_Tipo_de_Registro__c, CC_Id_Peticion__c, CC_Nueva_Instancia__c 
                                            FROM CC_Trazabilidad__c 
                                            WHERE CC_Id_Peticion__c = :ListCaseId AND CC_Tipo_de_Registro__c = :tipoPaso AND CC_Estado__c = 'Activo'];
        
        List<Id> idsCase =  new List<Id>();
        
        //Recuperamos el ID del proceso que es un parmaetro
        String Idproceso = CC_MetodosUtiles.getParamValue('CC_IDPROCES');
        String idPaso = null;
        Switch on tipoPaso {
            when 'Recepcion' {
                idPaso = CC_MetodosUtiles.getParamValue('CC_CODRECIBIDA');
            }
            when 'Asignacion' {
                idPaso = CC_MetodosUtiles.getParamValue('CC_CODASIGNADA');
            }
            when 'Resolucion' {
                idPaso = CC_MetodosUtiles.getParamValue('CC_CODRESUELTA');
            }
            when 'Cierre' {
                idPaso = CC_MetodosUtiles.getParamValue('CC_CODCERRADA');
            }
        }
        
        if (fechainicio == ''){
            String year = String.valueOf(Datetime.valueOf(System.now()).year());
            String month = String.valueOf(Datetime.valueOf(System.now()).month());
            String day = String.valueOf(Datetime.valueOf(System.now()).day());
            if (month.length()==1){
                month = '0'+month;
            }
            if (day.length()==1){
                day = '0'+day;
            }
            fechainicio = year + month + day;
        }
        
        List<CC_Trazabilidad__c> trazabilidadInsert =  new List<CC_Trazabilidad__c>();
        List<CC_Trazabilidad__c> trazabilidadUpdate =  new List<CC_Trazabilidad__c>();     
        for (Case oCaso : oListCaso) {
            //String Idproceso = null;
            //String idPaso = null;
            //Integer sNum = 3;
            
            for (CC_Trazabilidad__c trazabilidad : TRZ) {
                if (trazabilidad.CC_Id_Peticion__c == oCaso.Id) {
                    trazabilidad.CC_Estado__c = 'Rechazado';
                    trazabilidadUpdate.add(trazabilidad);
                    //update tr;
                    //break;
                }
            }

            CC_Trazabilidad__c newTRZ = new CC_Trazabilidad__c();
            newTRZ.CC_Id_Peticion__c = oCaso.Id;
            newTRZ.CC_Nombre_Parametro__c = oCaso.Id;
            newTRZ.CC_Id_Proceso__c = Idproceso;
            newTRZ.CC_Orden__c = 3;
            newTRZ.CC_Actualizacion_Paso__c = 'S';
            newTRZ.CC_Resetear_Paso__c = 'S';
            newTRZ.CC_Tipo_de_Registro__c = tipoPaso;
            newTRZ.CC_Id_Paso__c = idPaso;
            newTRZ.CC_Fecha_Inicio_Paso__c = fechainicio;
            newTRZ.CC_Control_Envio__c = 'Pdte. Envio';
            newTRZ.CC_Estado__c = 'Activo';
            //insert newTRZ;
            trazabilidadInsert.add(newTRZ);
            
            if (tipoPaso == 'Cierre'){
                // Si el paso es de cierre debemos verificar que no existan avisos y en caso de que los hayan los daremos de baja.
                idsCase.add(oCaso.Id);
                //bajaAviso('I', 'CC_AVISREAPERTURA', oCaso.Id);
                
                //bajaAviso('I', 'CC_AVISREAPCLI', oCaso.Id);
            }            
        }
        if (!trazabilidadInsert.isEmpty()){
            Database.SaveResult[] resultado = Database.insert(trazabilidadInsert);
        }
        if (!trazabilidadUpdate.isEmpty()){
            Database.SaveResult[] resultado = Database.update(trazabilidadUpdate);
        }
        
        if(!idsCase.isEmpty()){
        	bajaAvisoList('I', 'CC_AVISREAPERTURA', idsCase);
            bajaAvisoList('I', 'CC_AVISREAPCLI', idsCase);
        }
    }
    
    /*
     * Trazabilidad: Función encargada de crear un registro de aviso de una petición en TRZ
     */
    public static void altaAviso(String valorAviso, String tipoAviso, String codigoAviso, Id caseID){
        
        Case oCaso = null;
        String Idproceso = null;
        String CodAviso = null;
        
        //Recuperamos los datos del caso
        oCaso = getCaseData(CaseId);
        
        if (oCaso != null){
        	//Recuperamos el ID del proceso que es un parmaetro
            Idproceso = CC_MetodosUtiles.getParamValue('CC_IDPROCES');
            Switch on codigoAviso {
                when 'AVISPDTEOFI' {
                    CodAviso = CC_MetodosUtiles.getParamValue('CC_AVISPDTEOFI');
                }
                when 'AVISPDTECLI' {
                    CodAviso = CC_MetodosUtiles.getParamValue('CC_AVISPDTECLI');
                }
                when 'AVISREAPCLI' {
                    CodAviso = CC_MetodosUtiles.getParamValue('CC_AVISREAPCLI');
                }
                when 'AVISREAPERTURA' {
                    CodAviso = CC_MetodosUtiles.getParamValue('CC_AVISREAPERTURA');
                }
            }
            
            CC_Trazabilidad__c altaAvisoTRZ = new CC_Trazabilidad__c();
            altaAvisoTRZ.CC_Gestion_Aviso__c = 'S';
            altaAvisoTRZ.CC_Accion_Aviso__c = 'A'; //Alta
            altaAvisoTRZ.CC_Vision_Aviso__c = 'O'; //O - Oficina / C - Cliente / T - Todos
            altaAvisoTRZ.CC_Orden__c = 3;
            altaAvisoTRZ.CC_Id_Peticion__c = oCaso.Id;
            altaAvisoTRZ.CC_Nombre_Parametro__c = oCaso.Id;
            altaAvisoTRZ.CC_Id_Proceso__c = Idproceso;
            altaAvisoTRZ.CC_Tipo_Aviso__c = tipoAviso; //A – Alerta /I - Informativo
            altaAvisoTRZ.CC_Codigo_Aviso__c = CodAviso;
            altaAvisoTRZ.CC_Variable_Aviso__c = valorAviso; //fecha del aviso formato AAAAMMDD
            altaAvisoTRZ.CC_Tipo_de_Registro__c = 'Aviso';
            altaAvisoTRZ.CC_Control_Envio__c = 'Pdte. Envio';
            altaAvisoTRZ.CC_Estado__c = 'Activo';
            insert altaAvisoTRZ;
        }
    }
    
    /*
     * Trazabilidad: Función encargada de crear un registro de BAJA de un aviso de una petición en TRZ
     */
    public static void bajaAviso(String tipoAviso, String codigoAviso, Id caseID){
		
        Case oCaso = null;
        String Idproceso = null;
        String CodAviso = null;
        
        //Recuperamos los datos del caso
        oCaso = getCaseData(CaseId);
        List<CC_Trazabilidad__c> trazabilidadInsert =  new List<CC_Trazabilidad__c>();
        if (oCaso != null){
        	//Recuperamos el ID del proceso que es un parmaetro
            Idproceso = CC_MetodosUtiles.getParamValue('CC_IDPROCES');
            Switch on codigoAviso {
                when 'AVISPDTEOFI' {
                    CodAviso = CC_MetodosUtiles.getParamValue('CC_AVISPDTEOFI');
                }
                when 'AVISPDTECLI' {
                    CodAviso = CC_MetodosUtiles.getParamValue('CC_AVISPDTECLI');
                }
                when 'AVISREAPCLI' {
                    CodAviso = CC_MetodosUtiles.getParamValue('CC_AVISREAPCLI');
                }
                when 'AVISREAPERTURA' {
                    CodAviso = CC_MetodosUtiles.getParamValue('CC_AVISREAPERTURA');
                }
            }
                        
            List<CC_Trazabilidad__c> altaAvisoTRZActiva = [SELECT Id FROM CC_Trazabilidad__c 
                                                     WHERE CC_Accion_Aviso__c = 'A' AND CC_Codigo_Aviso__c = :CodAviso 
                                                     AND CC_Id_Proceso__c = :Idproceso AND CC_Id_Peticion__c = :oCaso.Id LIMIT 1];
            if (!altaAvisoTRZActiva.isEmpty()){
                CC_Trazabilidad__c bajaAvisoTRZ = new CC_Trazabilidad__c();
                bajaAvisoTRZ.CC_Gestion_Aviso__c = 'S';
                bajaAvisoTRZ.CC_Accion_Aviso__c = 'B'; //Alta
                bajaAvisoTRZ.CC_Vision_Aviso__c = 'O'; //O - Oficina / C - Cliente / T - Todos
                bajaAvisoTRZ.CC_Orden__c = 3;
                bajaAvisoTRZ.CC_Id_Peticion__c = oCaso.Id;
                bajaAvisoTRZ.CC_Nombre_Parametro__c = oCaso.Id;
                bajaAvisoTRZ.CC_Id_Proceso__c = Idproceso;
                bajaAvisoTRZ.CC_Tipo_Aviso__c = tipoAviso; //A – Alerta /I - Informativo
                bajaAvisoTRZ.CC_Codigo_Aviso__c = CodAviso;
                bajaAvisoTRZ.CC_Tipo_de_Registro__c = 'Aviso';
                bajaAvisoTRZ.CC_Control_Envio__c = 'Pdte. Envio';
                bajaAvisoTRZ.CC_Estado__c = 'Activo';
                trazabilidadInsert.add(bajaAvisoTRZ);
                //insert bajaAvisoTRZ;
            }
        }
        if (!trazabilidadInsert.isEmpty()){
            Database.SaveResult[] resultado = Database.insert(trazabilidadInsert);
        }
    }
    
    public static void bajaAvisoList(String tipoAviso, String codigoAviso, List<Id> idsCase){
		
        //Case oCaso = null;
        String idProceso = null;
        String codAviso = null;
        
        //Recuperamos los datos del caso
        //oCaso = getCaseData(idsCase);
        List<CC_Trazabilidad__c> trazabilidadInsert =  new List<CC_Trazabilidad__c>();
        if (!idsCase.isEmpty()){
        	//Recuperamos el ID del proceso que es un parmaetro
            idProceso = CC_MetodosUtiles.getParamValue('CC_IDPROCES');
            Switch on codigoAviso {
                when 'AVISPDTEOFI' {
                    codAviso = CC_MetodosUtiles.getParamValue('CC_AVISPDTEOFI');
                }
                when 'AVISPDTECLI' {
                    codAviso = CC_MetodosUtiles.getParamValue('CC_AVISPDTECLI');
                }
                when 'AVISREAPCLI' {
                    codAviso = CC_MetodosUtiles.getParamValue('CC_AVISREAPCLI');
                }
                when 'AVISREAPERTURA' {
                    codAviso = CC_MetodosUtiles.getParamValue('CC_AVISREAPERTURA');
                }
            }
                        
            List<CC_Trazabilidad__c> altasAvisoTRZActiva = [SELECT Id, CC_Id_Peticion__c FROM CC_Trazabilidad__c 
                                                     WHERE CC_Accion_Aviso__c = 'A' AND CC_Codigo_Aviso__c = :codAviso 
                                                     AND CC_Id_Proceso__c = :idProceso AND CC_Id_Peticion__c IN :idsCase];
            if (!altasAvisoTRZActiva.isEmpty()){
                
                    for(CC_Trazabilidad__c altaAvisoTRZActiva :altasAvisoTRZActiva){
                        CC_Trazabilidad__c bajaAvisoTRZ = new CC_Trazabilidad__c();
                        bajaAvisoTRZ.CC_Gestion_Aviso__c = 'S';
                        bajaAvisoTRZ.CC_Accion_Aviso__c = 'B'; //Alta
                        bajaAvisoTRZ.CC_Vision_Aviso__c = 'O'; //O - Oficina / C - Cliente / T - Todos
                        bajaAvisoTRZ.CC_Orden__c = 3;
                        bajaAvisoTRZ.CC_Id_Peticion__c = altaAvisoTRZActiva.CC_Id_Peticion__c;
                        bajaAvisoTRZ.CC_Nombre_Parametro__c = altaAvisoTRZActiva.CC_Id_Peticion__c;
                        bajaAvisoTRZ.CC_Id_Proceso__c = Idproceso;
                        bajaAvisoTRZ.CC_Tipo_Aviso__c = tipoAviso; //A – Alerta /I - Informativo
                        bajaAvisoTRZ.CC_Codigo_Aviso__c = CodAviso;
                        bajaAvisoTRZ.CC_Tipo_de_Registro__c = 'Aviso';
                        bajaAvisoTRZ.CC_Control_Envio__c = 'Pdte. Envio';
                        bajaAvisoTRZ.CC_Estado__c = 'Activo';
                        trazabilidadInsert.add(bajaAvisoTRZ);
                        //insert bajaAvisoTRZ;                        
                    }
            }
        }
        if (!trazabilidadInsert.isEmpty()){
            Database.SaveResult[] resultado = Database.insert(trazabilidadInsert);
        }
    }
    
    
    
    
    /*
     * Trazabilidad: Función encargada de crear un registro de BAJA de una petición en TRZ
     */
    public static void bajaPeticion(Id caseID){
        
        Case oCaso = null;        
        //Recuperamos los datos del caso
        oCaso = getCaseData(CaseId);
        List<CC_Trazabilidad__c> trazabilidadInsert =  new List<CC_Trazabilidad__c>();
        List<CC_Trazabilidad__c> TRZ = [SELECT Id, CC_Control_Envio__c, CC_Numperso__c, CC_Oficina__c, CC_Fecha_Inicio_Peticion__c, CC_Fecha_Fin_Peticion__c, CC_Orden__c,
                   CC_Estado__c, CC_Tipo_de_Registro__c, CC_Id_Peticion__c, CC_Nueva_Instancia__c 
                   FROM CC_Trazabilidad__c 
                   WHERE CC_Id_Peticion__c = :oCaso.Id AND CC_Tipo_de_Registro__c = 'Alta' AND CC_Estado__c = 'Activo' LIMIT 1];
        if (!TRZ.isEmpty()){
            CC_Trazabilidad__c newBajaTRZ = TRZ[0].clone();
            newBajaTRZ.CC_Orden__c = 1;
            newBajaTRZ.CC_Control_Envio__c = 'Pdte. Envio';
            newBajaTRZ.CC_Estado__c = 'Activo';
            newBajaTRZ.CC_Nueva_Instancia__c = 'B';
            newBajaTRZ.CC_Tipo_de_Registro__c = 'Baja';
            trazabilidadInsert.add(newBajaTRZ);
            //insert newBajaTRZ;
        }
        if (!trazabilidadInsert.isEmpty()){
            Database.SaveResult[] resultado = Database.insert(trazabilidadInsert);
        }
    }
    
    /*
     * Trazabilidad: Función encargada de crear un registro de Alta de petición en TRZ
	 */
    public static void reapretura(String tipoPaso, Id CaseId){
        
        List<CC_Trazabilidad__c> ListTRZUpd = new List<CC_Trazabilidad__c>();
        Case oCaso = null;
        String Idproceso = null;
        String idPaso = null;
        String sDatpeticio = null;
        String sDatfipeticio = null;
        Decimal sNumOrden = 10;
        String year = null;
        String month = null;
        String day = null;
		String sRechazId= '@';
        
        //Recuperamos los datos del caso
        oCaso = getCaseData(CaseId);
        List<CC_Trazabilidad__c> trazabilidadInsertBaja =  new List<CC_Trazabilidad__c>();
        List<CC_Trazabilidad__c> trazabilidadInsertAlta =  new List<CC_Trazabilidad__c>();
        List<CC_Trazabilidad__c> trazabilidadInsertNewPaso =  new List<CC_Trazabilidad__c>();
        
        if (oCaso != null){
        	//Recuperamos el ID del proceso que es un parmaetro
            Idproceso = CC_MetodosUtiles.getParamValue('CC_IDPROCES');
            //Damos formato a la fecha de reapertura
            year = String.valueOf(oCaso.CC_Fecha_Reapertura__c.year());
            month = String.valueOf(oCaso.CC_Fecha_Reapertura__c.month());
            day = String.valueOf(oCaso.CC_Fecha_Reapertura__c.day());
            // Control de 0s en los dias y meses menores de 10
            if (month.length()==1){
                month = '0'+month;
            }
            if (day.length()==1){
                day = '0'+day;
            }
            sDatpeticio = year + month + day;
            //Damos formato a la fecha de limite resolucion
            if (oCaso.CC_Fecha_Limite_Resolucion__c != null){
                year = String.valueOf(oCaso.CC_Fecha_Limite_Resolucion__c.year());
                month = String.valueOf(oCaso.CC_Fecha_Limite_Resolucion__c.month());
                day = String.valueOf(oCaso.CC_Fecha_Limite_Resolucion__c.day());
                // Control de 0s en los dias y meses menores de 10
                if (month.length()==1){
                    month = '0'+month;
                }
                if (day.length()==1){
                    day = '0'+day;
                }
                sDatfipeticio = year + month + day;
            }
            
            Switch on tipoPaso {
                when 'Recepcion' {
                    idPaso = CC_MetodosUtiles.getParamValue('CC_CODRECIBIDA');
                }
                when 'Asignacion' {
                    idPaso = CC_MetodosUtiles.getParamValue('CC_CODASIGNADA');
                }
                when 'Resolucion' {
                    idPaso = CC_MetodosUtiles.getParamValue('CC_CODRESUELTA');
                }
                when 'Cierre' {
                    idPaso = CC_MetodosUtiles.getParamValue('CC_CODCERRADA');
                }
            }
            
            List<CC_Trazabilidad__c> TRZ = [SELECT Id, CC_Control_Envio__c, CC_Numperso__c, CC_Oficina__c, CC_Fecha_Inicio_Peticion__c, CC_Fecha_Fin_Peticion__c, CC_Orden__c,
                   CC_Estado__c, CC_Tipo_de_Registro__c, CC_Id_Peticion__c, CC_Nueva_Instancia__c 
                   FROM CC_Trazabilidad__c 
                   WHERE CC_Id_Peticion__c = :oCaso.Id AND CC_Tipo_de_Registro__c = 'Alta' AND CC_Estado__c = 'Activo' LIMIT 1];
            
            if (!TRZ.isEmpty()){
                // 1. Actualizar el registro de Alta incorporandole estado "Rechazado"
				TRZ[0].CC_Estado__c = 'Rechazado';
				update TRZ;
                sRechazId = TRZ[0].Id;
				// 2. Crear un registro de Baja copia del registro de Alta que acabamos de rechazar
				CC_Trazabilidad__c bajaTRZ = TRZ[0].clone();
                bajaTRZ.CC_Orden__c = 0;
                bajaTRZ.CC_Control_Envio__c = 'Pdte. Envio';
                bajaTRZ.CC_Estado__c = 'Activo';
                bajaTRZ.CC_Nueva_Instancia__c = 'B';
                bajaTRZ.CC_Tipo_de_Registro__c = 'Baja';
                trazabilidadInsertBaja.add(bajaTRZ);
                //insert bajaTRZ;
				// 3. Crear un registro de Alta con los nuevos parametros
				CC_Trazabilidad__c altaTRZ = TRZ[0].clone();
                altaTRZ.CC_Orden__c = 1;
                altaTRZ.CC_Control_Envio__c = 'Pdte. Envio';
                altaTRZ.CC_Estado__c = 'Activo';
                altaTRZ.CC_Nueva_Instancia__c = 'A';
                altaTRZ.CC_Tipo_de_Registro__c = 'Alta';
                altaTRZ.CC_Fecha_Inicio_Peticion__c = sDatpeticio;
				altaTRZ.CC_Fecha_Fin_Peticion__c = sDatfipeticio;
                trazabilidadInsertAlta.add(altaTRZ);
				//insert altaTRZ;
				// 4. Actualizar todos los registros Activos incorporandoles el estado pendiente de envio
				List<CC_Trazabilidad__c> ListTRZ = [SELECT Id, CC_Control_Envio__c, CC_Numperso__c, CC_Oficina__c, CC_Fecha_Inicio_Peticion__c, 
                									CC_Fecha_Fin_Peticion__c, CC_Orden__c, CC_Estado__c, CC_Tipo_de_Registro__c, CC_Id_Peticion__c, CC_Nueva_Instancia__c 
                    								FROM CC_Trazabilidad__c WHERE CC_Id_Peticion__c = :oCaso.Id AND CC_Estado__c = 'Activo' 
                        							AND (CC_Tipo_de_Registro__c != 'Alta' AND CC_Tipo_de_Registro__c != 'Baja')
                        							ORDER BY CreatedDate asc, CC_Orden__c asc];
                for (CC_Trazabilidad__c actTraz : ListTRZ){
                    actTraz.Id = actTraz.Id;
                    actTraz.CC_Estado__c = 'Activo';
                    actTraz.CC_Orden__c = sNumOrden;
                    actTraz.CC_Control_Envio__c = 'Pdte. Envio';
                    ListTRZUpd.add(actTraz);
                    sNumOrden = sNumOrden +1;
                }
                // Actualizar registros Activos para volver a enviar
                if (ListTRZUpd.size() > 0){
                    Database.SaveResult[] oResUp = Database.update(ListTRZUpd, false);
                }
                // 5. Rechazar una baja previa si existiera
                List<CC_Trazabilidad__c> TRZRechazo = [SELECT Id, CC_Control_Envio__c, CC_Numperso__c, CC_Oficina__c, CC_Fecha_Inicio_Peticion__c, 
                									CC_Fecha_Fin_Peticion__c, CC_Orden__c, CC_Estado__c, CC_Tipo_de_Registro__c, CC_Id_Peticion__c, CC_Nueva_Instancia__c 
                    								FROM CC_Trazabilidad__c WHERE CC_Id_Peticion__c = :oCaso.Id AND CC_Estado__c = 'Activo' 
                        							AND CC_Tipo_de_Registro__c = 'Baja' AND Id != :sRechazId];
                if (!TRZRechazo.isEmpty()){
                    TRZRechazo[0].CC_Estado__c = 'Rechazado';
                    update TRZRechazo;
                }
                // Crear el paso indicado
                CC_Trazabilidad__c newPasoTRZ = new CC_Trazabilidad__c();
                newPasoTRZ.CC_Id_Peticion__c = oCaso.Id;
                newPasoTRZ.CC_Nombre_Parametro__c = oCaso.Id;
                newPasoTRZ.CC_Id_Proceso__c = Idproceso;
                newPasoTRZ.CC_Actualizacion_Paso__c = 'S';
                newPasoTRZ.CC_Resetear_Paso__c = 'S';
                newPasoTRZ.CC_Orden__c = 2;
                newPasoTRZ.CC_Tipo_de_Registro__c = tipoPaso;
                newPasoTRZ.CC_Id_Paso__c = idPaso;
                newPasoTRZ.CC_Fecha_Inicio_Peticion__c = sDatpeticio;
                newPasoTRZ.CC_Control_Envio__c = 'Pdte. Envio';
            	newPasoTRZ.CC_Estado__c = 'Activo';
                //insert newPasoTRZ;
                trazabilidadInsertNewPaso.add(newPasoTRZ);
				//Creamos el aviso
				altaAviso(sDatpeticio, 'I', 'AVISREAPERTURA', oCaso.Id);
            }
        }
        if (!trazabilidadInsertBaja.isEmpty()){
            Database.SaveResult[] resultado = Database.insert(trazabilidadInsertBaja);
        }
        if (!trazabilidadInsertAlta.isEmpty()){
            Database.SaveResult[] resultado = Database.insert(trazabilidadInsertAlta);
        }
        if (!trazabilidadInsertNewPaso.isEmpty()){
            Database.SaveResult[] resultado = Database.insert(trazabilidadInsertNewPaso);
        }
    }
    
    /*
     * Trazabilidad: Función encargada de recuperar datos del Caso
     */
    public static Case getCaseData(Id CaseId){
        List<Id> ListCaseId = new List<Id>();
        ListCaseId.add(CaseId);
        List<Case> oListCaso = getCaseData(ListCaseId);

        Case oCaso = null;
        if (!oListCaso.isEmpty()) {
            oCaso = oListCaso[0];
        }
        return oCaso;
    }

    public static List<Case> getCaseData(List<Id> ListCaseId){
        
        Case oCaso = null;
        List<Case> oListCaso = [SELECT Id, Account.CC_NumPerso__c, Account.CC_OficinaGestoraId__r.CC_Numero_Oficina__c, ContactId, CreatedDate, 
                      			CaseNumber, CC_Fecha_Reapertura__c, CC_Fecha_Limite_Resolucion__c 
                      			FROM Case WHERE ID IN :ListCaseId];
        
        return oListCaso;
    }
}