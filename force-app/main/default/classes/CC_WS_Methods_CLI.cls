public with sharing class CC_WS_Methods_CLI {
    /*
        Clase para identificación de clientes / contactos vía CLI.
    */

    /*
        Método para recuperar los datos asociados a la lista de NumPerso de entrada.
        Devuelve solo los objetos que se han de actualizar vía CLI.

        NOTA: oData. Se puede pasar la referencia del objeto existente para realizar comprobaciones sin tener que volver a buscar el registro.
    */
    static public Map<String,SObject> getDataCLIWSbyNumPerso (String sNumPerso, String sTipoReg, String sIdOrig, SObject oData, Map<String, Object> oParamAux, Map<String,Object> oObjALF, CC_InterfaceSettings__mdt configCLI)
    {
        Map<String,SObject> oObj = new Map<String,SObject>();
        Map<String,SObject> oRes2 = new Map<String,SObject>();
		CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';
        
        if (sNumPerso != '')
        {
            //CC_InterfaceSettings__mdt configCLI = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_CLI');
            
            // LLAMADA AL WS DE CLI.
            if (configCLI != null) {               
                if (Test.isRunningTest())
                {
                    if (sTipoReg.length() > 4)
                    {
                        if (sTipoReg == 'Cliente' || sTipoReg.substring(0,6) == 'INTALF')
                        {
                            // Forzamos salida para no dar error entre ALF y CLI.
                            return oObj;
                        }
                    }else{
                        // Probando resto de llamadas RRSS, DOC, TEL.
                        return oObj;
                    }

                    //RESTO DE LLAMADAS.
                }

                CC_CLI_WS_Constructor.toinsoap oIn = new CC_CLI_WS_Constructor.toinsoap();

                if (sNumPerso.isNumeric())
                    oIn.numper = Decimal.valueOf(sNumPerso);
                
                // Gestión trazas.
                if (configCLI.CC_TrazaActiva__c || Test.isRunningTest())
                {
                    oTraza = new CC_TrazaInt__c();
                    oTraza.Name = 'CLI_WSDL';
                    oTraza.CC_Identificador__c = sNumPerso;
                    oTraza.CC_FechaInicio__c = datetime.now();
                    oTraza.CC_IdOrigen__c = sIdOrig;
                    
                    if (configCLI.CC_TrazaEntrada__c)
                        oTraza.CC_MensajeEntrada__c = String.valueOf(oIn);
                }
                
                try {
                    // Forzar error conversión.
                    oIn.numper = Decimal.valueOf(sNumPerso);

                    CC_CLI_WS_Constructor.LlamadaDatosPortTypePort oTest = new CC_CLI_WS_Constructor.LlamadaDatosPortTypePort();
                    if (!Test.isRunningTest())
                        oTest.clientCertName_x = configCLI.CC_Certificado__c;
    
                    oTest.timeout_x = Integer.valueOF(configCLI.CC_TimeOut__c);
                    oTest.endpoint_x = configCLI.CC_EndPoint__c;
                    CC_CLI_WS_Constructor.tooutsoap oRes = oTest.RecuperarDatos(oIn);
                    
                    // Convertir respuesta a Objects.
                    //    Formato clave MAP. Objeto##Accion##Clave
                    //    Objeto: Account, Contact, CanalCom
                    //    Accion: UP -> Upsert directo, QU -> Consulta
                    //    Clave: Numper para UP, Numper + Valor Búsqueda para QU
                    //
                    
                    oRes2 =  getContactAccountRespCLINP (sNumPerso, sTipoReg, oRes, oParamAux, oObjALF);
                    
                    // Recorrer los resultados.            
                    if (oRes2.size() > 0)
                    {
                        oObj.putAll(oRes2);
                    }
                }catch (Exception e) {
                        // Error comunicaciones.
                        sDescError = 'Error comunicaciones.';
                        sDetalleError = e.getMessage();
				}

                // Finalizar traza.
                if ( (configCLI.CC_TrazaActiva__c || Test.isRunningTest()) && oTraza != null)
                {
                    oTraza.CC_FechaFin__c = datetime.now();
        
                    if ((configCLI.CC_TrazaSalida__c || Test.isRunningTest()) && oRes2 != null)
                        oTraza.CC_MensajeSalida__c = String.valueOf(oRes2);
        
                    if (sDescError != '')
                    {
                        oTraza.CC_FinOK__c = false;
                        oTraza.CC_TipoError__c = sDescError;
                        oTraza.CC_DetalleError__c = sDetalleError;
                    }else{
                        oTraza.CC_FinOK__c = true;
                    }
                }
        
                // Preparar retorno.
                if (oTraza != null){
                    //oObj.put('TRAZA', oTraza);
                	String sClave = 'TRAZA##UP##' + sNumPerso;
                    oObj.put(sClave, oTraza);
            	}
			}
		}
        return oObj;
    }
    
    // Convertir respuesta CLI a objetos Contact y Account.
    static private Map<String,SObject> getContactAccountRespCLINP (String sNumPer, String sTipoReg, CC_CLI_WS_Constructor.tooutsoap oRes, Map<String, Object> oParamAux, Map<String,Object> oObjALF)
    {
        Map<String,SObject> oNewRes = new Map<String,SObject>();
        String Segmento = '';
        String SubSegmento = '';
        //Dejamos preparados el resto de campos que se recuperan de CLI por si se encesitan en un futuro.
        /*String NivelServicio = '';
        String Activo = '';
        String Pasivo = '';        
        String Indpub = '';
        String Consucap = '';
        String Pctrar = '';
        String Resul12M = '';
        String Tpcre12M = '';
   		*/
        String ImaginBank = '';
        String InTouch = '';
		
        if (oRes != null) {
            Segmento = oRes.segmento;
            SubSegmento = oRes.subSegmento;
            //Dejamos preparados el resto de campos que se recuperan de CLI por si se encesitan en un futuro.
            /*NivelServicio = oRes.nivServ;
            Activo = String.valueOf(oRes.DActivo);
            Pasivo = String.valueOf(oRes.DPasivo);            
            Indpub = oRes.indpub;
            Consucap = String.valueOf(oRes.consucap);
            Pctrar = String.valueOf(oRes.pctrar);
            Resul12M = String.valueOf(oRes.resul12m);
            Tpcre12M = String.valueOf(oRes.tpcre12m);
            */ // es un U01 porque es el gestor InTouch y hay que recuperar a partir de esto el numero de centro.
            ImaginBank = oRes.imaginBank;
            InTouch = oRes.inTouch;
            
			Id RecordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            List<Contact> contEmpleado = [Select Id, AccountId from Contact where CC_Matricula__c = :InTouch and RecordTypeId =: RecordTypeEmpleado LIMIT 1];
                        
            // Tratar respuesta.
            Account oAccount;
            
            // Integrarlo con la llamada de ALF.
            if (oObjALF != null) {
                String sClave = 'Account##0##'+sNumPer;
                if (oObjALF.get(sClave) != null)
                    oAccount = (Account)oObjALF.get(sClave);
                else
                    oAccount = new Account();
            }
            else {
            	oAccount = new Account();    
            }
            
            //Comprobar si ImaginBank contiene Y o N
            oAccount.CC_Senal_Comercial_Imaginbank__c = (ImaginBank == 'Y' || ImaginBank == 'y' || ImaginBank == 'S' || ImaginBank == 's');
                          
			//Guardar el gestor intouch
			oAccount.CC_Gestor_InTouch__c = InTouch;
            
			//Guardar el centro gestor intouch
            if (!contEmpleado.isEmpty()) {
                for (Contact cont: contEmpleado) {
                    oAccount.CC_Centro_Gestor_InTouch__c = cont.AccountId;
                }
            }
            
            oAccount.CC_NumPerso__c = sNumPer;
            oAccount.AV_Segmento__c = Segmento;
            oAccount.AV_Subsegmento__c = SubSegmento;

            // Recuperar segmento y subsegmento de la lista de valores.
            if (oParamAux != null && oParamAux.size() > 0) {
                if (oParamAux.get('CC_Segmento_CLI') != null) {
                    Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_Segmento_CLI');
                    if (oMap.get(Segmento) != null) {
                        oAccount.CC_Segmento_Descripcion__c = oMap.get(Segmento);
                    }
                }

                if (oParamAux.get('CC_Subsegmento_CLI') != null) {
                    Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_Subsegmento_CLI');
                    if (oMap.get(SubSegmento) != null) {
                        oAccount.CC_Subsegmento_Descripcion__c = oMap.get(SubSegmento);
                    }
                }
            }

            /*// Comprobar si se encuentra en la lista de valores de oficinas
            if(oAccount.CC_Telefono_Unico__c != true)
            {
                List<CC_Lista_Valores__c> listaValores = [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.name = 'Oficinas'];
                for(CC_Lista_Valores__c oficina: listaValores)
                {
                    if(oAccount.CC_Nombre_Oficina__c == listaValores.CC_Valor__c)
                    {
                        oAccount.CC_Telefono_Unico__c = true;
                    }
                }
            }*/

            //if (sTipoReg == 'Cliente')
            //    oAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			
            oNewRes.put('Account##0##'+sNumPer,oAccount);
			
            /*Contact oContact = new Contact();
            oContact.Account = new Account(CC_NumPerso__c = sNumPer);
            if (Segmento != null){
                oContact.CC_Segmento__c = Segmento;
            }
            oContact.CC_NumPerso__c = sNumPer;
            if (SubSegmento != null){
                oContact.CC_SubSegmento__c = SubSegmento;
            }
            
            if (sTipoReg == 'Cliente')
                oContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			
            oNewRes.put('Contact##0##'+sNumPer,oContact);*/

        }	
        return oNewRes;
    }
}