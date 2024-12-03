/**********************************************************************************************************************
 Name:	  CBK_PermissionIterator
 Copyright © 2021  CaixaBank
***********************************************************************************************************************
Proposito: Clase Apex correspondiente iterable permisos. Clase base para el iterador de reciclado de permisos.
***********************************************************************************************************************
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	19/04/2022			Init version
***********************************************************************************************************************/
public class CBK_PermissionIterator implements Iterator<CBK_Permission>{ 
 
   private List<CBK_Permission> permissions;
   private Integer currentIndex;
 
   public CBK_PermissionIterator(List<CBK_Permission> permissionsList){
       this.permissions = permissionsList;
       this.currentIndex = 0;
   }
 
   public boolean hasNext(){ 
       return currentIndex < permissions.size() - 1;
   }    
 
   public CBK_Permission next(){
       if(hasNext()) {
           currentIndex++;
           return permissions[currentIndex];
       } else {
           throw new NoSuchElementException();
       }
   } 
}