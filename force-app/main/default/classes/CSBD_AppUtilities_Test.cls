/**********************************************************************************************************************
Name:     CSBD_AppUtilities_Test
Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Clase test de la clase util de la aplicación.
=======================================================================================================================
Historial
---------------------
VERSION     USER_STORY      AUTHOR              DATE                Description
1.0         App CSBD        Esperanza Conde	    11/02/2022          Init version
***********************************************************************************************************************/
@isTest
public with sharing class CSBD_AppUtilities_Test {
    
    @TestSetup
    public static void crearDatosPrueba() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

    }
    /** 
     * Probamos la conversión de hexadecimal para el numperso
	*/
    @isTest static void testHexadecimal(){
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        String hexadecimal = 'A120E2';
        System.runAs(usuarioGestor) {
            Test.startTest();
            String numper = CSBD_AppUtilities.formatearNumperso(hexadecimal);
            Test.stopTest();
            
            system.assertEquals('10559714',numper, 'Comprobamos que los numper coinciden.');
        }
    }
    
    /** 
     * Probamos los minutos restantes en la resta de dos fechas
	*/
    @isTest static void testRestaFechas(){
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        DateTime hoy = Datetime.now();
        DateTime ayer = Datetime.now()-1;
        System.runAs (usuarioGestor) {
            Test.startTest();
            Long numper = CSBD_AppUtilities.calculateTimeDifferences(ayer,hoy);
            Test.stopTest();
            
            system.assert(numper>30, 'Comprobamos que la fecha es superior a los 30 min.');
        }
    }

}