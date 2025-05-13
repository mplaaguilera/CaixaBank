/**********************************************************************************************************************
 Name:	  CBK_CyberIPRangesValidation
 Copyright © 2024  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Clase utilizada para la validación de IPs de LoginEvent y guardar un CBK_Log de los
que no estén en los rangos en el metadato CBK_RangoIPCyber
------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	        AUTHOR		   		DATE				Description
	1.0			US807680		    Jose M. Fernández	08/06/2024		    Init version
***********************************************************************************************************************/
/**
 * @description Método en el que se procesa un LoginEvent para evaluarse, solamente si es de ese tipo
 */
public with sharing class CBK_CyberIPRangesValidation implements TxnSecurity.EventCondition{
    /**
     * @description Método de evaluación que solamente procesará las entradas de LoginEvent
     */
    public Boolean evaluate(SObject oEvent){
        try {
            switch on oEvent{
                when LoginEvent oLoginEvent{
                    if(!hasBypassIPRangeCustomPermission(oLoginEvent.UserId)){
                        return evaluateLoginEvent(oLoginEvent);
                    }
                    return false;
                }
                when null{
                    return false;
                }
                when else{
                    return false;
                }
            }
        } catch(Exception e) {
            CBK_Log.DebugProcessConfigBuilder oBuilder = new CBK_Log.DebugProcessConfigBuilder()
                .setMessage('IPRangeError - Error al comprobar rango de IPs Cyber - ' + e.getMessage())
                .setValues(new List<Object>{ JSON.serialize(oEvent) })
                .setLevel(LoggingLevel.ERROR)
                .setForce(true)
                .setErr(e)
                .setCategory('Login IP Out Of Range');

            //Se inserta el Builder como CBK_Log
            oBuilder.addLog();
            CBK_Log.insertPlatformEvent();
            return false;
        }
    }

    /**
     * @description Método de evaluación del LoginEvent en el que se revisa la IP de entrada para comprobar si está en alguno de los rangos informados
     */
    private Boolean evaluateLoginEvent(LoginEvent oLoginEvent){
        //Se mira si viene informado la IP en el LoginEvent y si el estado fue 'Success'
        if(oLoginEvent.SourceIp != null && oLoginEvent.Status == 'Success'){
            //Se obtiene el rango de IPs permitidos desde el metadato CBK_RangoIPCyber
            List<CBK_CyberIPRange__mdt> listIPRanges = getCyberIPRanges();

            //En el caso de ser un test, se rellena la lista con un rango IP de ejemplo
            if(Test.isRunningTest()){
                CBK_CyberIPRange__mdt oTestIPRange = new CBK_CyberIPRange__mdt();
                oTestIPRange.CBK_IPStartAddress__c = '31.149.131.115';
                oTestIPRange.CBK_IPEndAddress__c = '31.149.131.115';
                listIPRanges = new List<CBK_CyberIPRange__mdt>{oTestIPRange};
            }  

            //Solamente se comprueba la IP en el caso que haya rangos configurados
            if(!listIPRanges.isEmpty()){
                //Se guarda el rango IP informado en el LoginEvent
                String sSourceIP = oLoginEvent.SourceIp;

                //Se revisa si la IP está en alguno de los rangos
                Boolean bIPEnRango = isIPInRangeList(sSourceIP, listIPRanges);

                //Si no está en el rango, se crea entrada de CBK_Log
                if(!bIPEnRango){
                    //Se genera la lista de Values a llenar en el Builder
                    List<Object> listValues = new List<Object>();
                    listValues.add(oLoginEvent.EventIdentifier);
                    listValues.add(oLoginEvent.EventDate);
                    listValues.add(JSON.serialize(oLoginEvent));

                    //Se genera el Builder
                    CBK_Log.DebugProcessConfigBuilder oBuilder = new CBK_Log.DebugProcessConfigBuilder()
                        .setContextId(oLoginEvent.Id)
                        .setMessage('IPRangeError - Acceso fuera del rango de IPs de Cyber')
                        .setValues(listValues)
                        .setLevel(LoggingLevel.INFO)
                        .setforce(true)
                        .seterr(new DmlException('IP Range Exception'))
                        .setemail(new Messaging.InboundEmail())
                        .setCategory('Login IP Out Of Range');

                    //Se inserta el Builder como CBK_Log
                    oBuilder.addLog();
                    CBK_Log.insertPlatformEvent();
                    return true;
                }
            }
        }

        //Retorno por defecto
        return false;
    }

    /**
     * @description Recuperar rangos de IP de Cyber guardados en el mdt CBK_CyberIPRanges
     */
    private List<CBK_CyberIPRange__mdt> getCyberIPRanges(){
        //Se recorren todos los rangos de IP para guardarlos en una forma procesable
        List<CBK_CyberIPRange__mdt> listIPRanges = new List<CBK_CyberIPRange__mdt>();
        for(CBK_CyberIPRange__mdt oCyberIPRange : [SELECT CBK_IPStartAddress__c, CBK_IPEndAddress__c
                                                   FROM CBK_CyberIPRange__mdt])
        {
            listIPRanges.add(oCyberIPRange);
        }

        //Retorno
        return listIPRanges;
    }

    /**
     * @description Recuperar rangos de IP de Cyber guardados en el mdt CBK_CyberIPRanges
     * @param sSourceIP		-> IP del intento de login
     * @param listIPRanges	-> Lista con los rangos de IP configurados
	 * @return		        -> Boolean que indica si ha entrado en el rango o no
     */
    private Boolean isIPInRangeList(String sSourceIP, List<CBK_CyberIPRange__mdt> listIPRanges){
        //Se utilizará este RegEx para comprobar que las IPs a comprobar tienen el formato correcto
        String sIPRegex = '^((25[0-5]|(2[0-4]|1\\d|[1-9]|)\\d)\\.?\\b){4}$';

        if(String.isBlank(sSourceIP) || !Pattern.matches(sIPRegex, sSourceIP)) {
            return false;
        }

        //Se recorren todos los rangos de IP para guardarlos en una forma procesable
        for(CBK_CyberIPRange__mdt oIPRange : listIPRanges){
            String sStartIP = oIPRange.CBK_IPStartAddress__c;
            String sEndIP = oIPRange.CBK_IPEndAddress__c;

            //Se revisa si las IPs de los rangos son válidas, y si es así, se revisa que la IP a validar esté en el rango
            if(Pattern.matches(sIPRegex, sStartIP) && Pattern.matches(sIPRegex, sEndIP) && (convertIPStringToDouble(sSourceIP) >= convertIPStringToDouble(sStartIP)) && (convertIPStringToDouble(sSourceIP) <= convertIPStringToDouble(sEndIP))){
                return true;
            }
        }
        return false;
    }

    /**
     * @description Convertir IP de String a Double
     * @param sIP   -> IP del intento de login
	 * @return		-> Double con la IP para ser utilizada en la validación de rangos
     */
    private Double convertIPStringToDouble(String sIP){
        List<String> listSegments = sIP.split('\\.');
        return Double.valueOf(listSegments[0]) * Math.pow(255, 3) + 
               Double.valueOf(listSegments[1]) * Math.pow(255, 2) +
               Double.valueOf(listSegments[2]) * Math.pow(255, 1) +
               Double.valueOf(listSegments[3]) * Math.pow(255, 0);
    }

    /**
     * @description Comprobar si el usuario posee el PermissionSet 'CBK_ByPass_IP_Range'
     * @param sUserId   -> ID del User del LoginEvent
	 * @return		    -> Boolean indicando si tiene el PermissionSet asignado o no
     */
    private Boolean hasBypassIPRangeCustomPermission(Id sUserId){
        List<PermissioNSetAssignment> listPermSetAssignments = [SELECT Id
                                                                FROM PermissionSetAssignment
                                                                WHERE Assignee.Id = :sUserId
                                                                AND PermissionSet.Name = 'CBK_ByPass_IP_Range'];
        if(listPermSetAssignments.isEmpty()){
            return false;
        }
        return true;
    }
}