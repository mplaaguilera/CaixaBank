/**********************************************************************************************************************
 Name:	  CBK_Permission
 Copyright © 2021  CaixaBank
***********************************************************************************************************************
Proposito: Clase Apex correspondiente a la estructura wrapper de los distintos tipos de permisos. Clase base para el iterador de reciclado de permisos.
***********************************************************************************************************************
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	19/04/2022			Init version
***********************************************************************************************************************/
public with sharing class CBK_Permission {
 
    public enum PERMISSIONTYPE {PERMISSIONSET, PERMISSIONSETGROUP, PERMISSIONSETLICENSE}

    public PermissionType type;
    public Id idPermiso;
    public String uniquePermissionName;
    public Id userId;
    public Datetime userLastLoginDate;
    public Datetime userCreatedDate;
    public integer currentLogoutDays;
       
    public CBK_Permission(PermissionType permissionTypeParam, Id idPermisoParam,
    String uniquePermissionNameParam, Id userIdParam, Datetime userCreatedDateParam, Datetime userLastLoginDateParam){
        type=permissionTypeParam;
        idPermiso = idPermisoParam;
        uniquePermissionName = uniquePermissionNameParam;
        userId = userIdParam;
        userCreatedDate = userCreatedDateParam;
        userLastLoginDate = userLastLoginDateParam;
        currentLogoutDays = math.abs(Date.today().daysBetween(Date.valueof(userLastLoginDate != null?userLastLoginDate:(userCreatedDate != null?userCreatedDate:System.Datetime.now()))));

    }
}