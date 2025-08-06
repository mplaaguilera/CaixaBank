/*****************************************************************
 * Name: SAC_CaseDatosDeNotificacion 
 * Copyright © 2021  CaixaBank
 * ============================================================
 * Proposito: Rellenar los campos del email, telefono, dirección
 *             con los datos que se tiene en el objeto Account
 *             pero el usuario lo podrá editar con otro valor y
 *             se guardara el valor nuevo.
 * ============================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US213187       Marcela Neira   10/05/21       Creación
*****************************************************************/
public with sharing class SAC_CaseDatosDeNotificacion {
    public static void rellenarDatos(Map<Id,Case> mapNuevasReclamaciones, Map<Id,Case> mapViejasReclamaciones){

        Set<id> idesCuentas = new Set<Id>();
        
        for (Id ide : mapNuevasReclamaciones.keySet()) {
            if(!String.isBlank(mapNuevasReclamaciones.get(ide).AccountId)){
                idesCuentas.add(mapNuevasReclamaciones.get(ide).AccountId);
            }
        }

       
        if (!idesCuentas.isEmpty() && Schema.sObjectType.Account.isAccessible() ){
            Map<ID, Account> mapaCuentasDeCasos = new Map<ID, Account>([SELECT Id, CC_Email__c, BillingAddress, Phone FROM Account  WHERE id IN :idesCuentas]);
      
            for (Id ide : mapNuevasReclamaciones.keySet()) {
                //Solo es una inserción (Insert) de una Reclamación                                    //Se modificó la Cuenta
                if(mapViejasReclamaciones == null || mapNuevasReclamaciones.get(ide).AccountId != mapViejasReclamaciones.get(ide).AccountId){                   
                    mapNuevasReclamaciones.get(ide).CC_Telefono_Contacto__c = mapaCuentasDeCasos.get(mapNuevasReclamaciones.get(ide).AccountId).Phone;                        
                    mapNuevasReclamaciones.get(ide).OS_Email__c = mapaCuentasDeCasos.get(mapNuevasReclamaciones.get(ide).AccountId).CC_Email__c;             
                    mapNuevasReclamaciones.get(ide).SAC_DireccionPostalNotificacion__c = obtenerDireccion( mapaCuentasDeCasos.get(mapNuevasReclamaciones.get(ide).AccountId).BillingAddress);
                }              
            }        
        }       
    }

    /*****************************************************************
     * Proposito: Método para convertir la direccion (Address) en
     *              un String 
     * ============================================================
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US213187       Marcela Neira   10/05/21     Creación
    *****************************************************************/

    private static String  obtenerDireccion(Address direccion){
        String direccionText = '';
        String calle = '';
        String cp = '';
        String ciudad = '';
        String estado = '';
        String pais = '';
        if(direccion != null){
            calle = direccion.getStreet();
            cp = direccion.getPostalCode();
            ciudad = direccion.getCity();
            estado = direccion.getState();
            pais = direccion.getCountry();
        }

        if(calle <> null ){
            direccionText +=  Calle + ' ' ;
        }
        if(cp <> null){
            direccionText += cp + ' ';
        }
        if(ciudad <> null ){
            direccionText +=  ciudad + ' ' ;
        }
        if(estado <> null){
            direccionText += estado + ' ';
        }
        if(pais <> null){
            direccionText += pais + ' ';
        }  
        
        return direccionText;
    }
    
}