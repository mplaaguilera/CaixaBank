/**********************************************************************************************************************
 Name:    EV_ChangeStatus_Trigger
 Copyright © 2024  CaixaBank
=======================================================================================================================
Proposito: Trigger de objeto EV_ChangeStatus__e
            Al tratarse de un evento de plataforma, solo se ejecuta trigger en el evento "after insert"
=======================================================================================================================
Historial
---------------------
    VERSION     USER_STORY          AUTHOR              DATE                Description
    1.0         DE86361             Carolina Lopez      06/02/2024          Init version
***********************************************************************************************************************/
trigger EV_ChangeStatus_Trigger on EV_ChangeStatus__e (after insert) {
    EV_LogDebug.printLogDebug('@@EV_ChangeStatus_Trigger ', 'Entra');
    EV_ChangeStatus_AI_TRHan.changeStatusCamp(Trigger.New);
}