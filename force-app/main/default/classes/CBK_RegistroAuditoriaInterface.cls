/**********************************************************************************************************************
 Name:	  CBK_RegistroAuditoriaInterface
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Interfaz para definir el contrato de las clases concretas del registro de auditoría y que permitirán a la clase
            principal del Framework interactuar con estas independientemente de la clase concreta que instancie la clase Factory.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	16/04/2021			Init version
***********************************************************************************************************************/
public interface CBK_RegistroAuditoriaInterface {
    /**
    * @description Definición del método de inserción de las entradas de los registros de auditoría
    * @author   fzaragoza | 16/04/2020
     **/
    void registroAuditoria();
}