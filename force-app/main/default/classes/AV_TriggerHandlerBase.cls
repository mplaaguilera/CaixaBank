/**********************************************************************************************************************
 Name:	  AV_TriggerHandlerBase
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase base para los Triggers de retail 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Sandra Gómez		23/08/2020			Init version
	1.1			PPM100538432	Sandra Gómez		17/09/2024			Add mapToByPassEvent

***********************************************************************************************************************/
public with sharing abstract class AV_TriggerHandlerBase extends CC_TriggerHandlerBase{
    /**
	 * Mapa para hacer un bypass con el propio registro
	 */
    public static Map<String, Opportunity> mapToByPassOld = new Map<String, Opportunity>();
	/**
	 * Mapa para hacer un bypass con el propio registro
	 */
    public static Map<String, Event> mapToByPassEvent = new Map<String, Event>();
}