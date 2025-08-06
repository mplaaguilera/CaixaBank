/*****************************************************************
 * Name: SPV_UserHelper
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Clase para los métodos de los triggers de User
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             US828257      Raúl Santos    29/04/24        Creación
****************************************************************/   

public with sharing class SPV_UserHelper {

    public class SPVException extends Exception {}

    private static final String PS_LECTURASAC = 'SPV_LecturaSAC';
    private static final String PS_GENERAL = 'SPV_General';
    private static final String PS_CLASESL = 'SPV_Clases';

    
    public static void asignarPermissionSetBasicos (List<User> listNew, String process){

        if(!listNew.isEmpty()){
            List<PermissionSetAssignment> listaInsert = new List<PermissionSetAssignment>();

            PermissionSet psLecturaSAC = getPermissionSet(PS_LECTURASAC);
            PermissionSet psGeneral = getPermissionSet(PS_GENERAL);
            PermissionSet psClases = getPermissionSet(PS_CLASESL);

            for(User usuario : listNew){
                PermissionSetAssignment assigmentLectura = new PermissionSetAssignment (PermissionSetId = psLecturaSAC.id, AssigneeId = usuario.Id); 
                listaInsert.add(assigmentLectura);   
                PermissionSetAssignment assigmentGeneral = new PermissionSetAssignment (PermissionSetId = psGeneral.id, AssigneeId = usuario.Id); 
                listaInsert.add(assigmentGeneral);
                PermissionSetAssignment assigmentClases = new PermissionSetAssignment (PermissionSetId = psClases.id, AssigneeId = usuario.Id); 
                listaInsert.add(assigmentClases);
            }

            try{
                if(!listaInsert.isEmpty() && Schema.sObjectType.PermissionSetAssignment.isCreateable()){
                    SPV_DatabaseDML.insertListDML(listaInsert, false);
                }
            } catch (Exception e){
                CBK_log.error(e);
            }      
        }
    }

    /*****************************************************************
     * Proposito: Método que devuelve el permissionset a añadir al usuario
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US828257      Raúl Santos    29/04/24        Creación
    *****************************************************************/
    public static PermissionSet getPermissionSet (String psName){ 
        if(!Schema.sObjectType.PermissionSet.isAccessible()){ throw new SPVException( 'No puede recuperar el permission set' ); }
        return [SELECT id FROM PermissionSet WHERE  PermissionSet.Name =: psName];
    }
}