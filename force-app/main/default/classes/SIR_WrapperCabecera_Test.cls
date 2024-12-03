/*****************************************************************
 Name:  SIR_WrapperCabecera_Test
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase Test de la clase wrapper SIR_WrapperCabecera                                                                                                               
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US244035         Atmira         21/06/2021     	  Created    


*****************************************************************/
@isTest
public class SIR_WrapperCabecera_Test {
	/*****************************************************************
        Proposito:  test1 sirve para comprobar la cobertura del wrapper                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US244035         Atmira         21/06/2021     	  Created    
        
	*****************************************************************/
    @isTest 
        static void test1() {
        Test.startTest();
        
       	SIR_WrapperCabecera wrapper = new SIR_WrapperCabecera();
        wrapper.persona      		  = 'test';
        wrapper.segmento     		  = 'test';
        wrapper.saldoPasivo  		  = 'test';
		wrapper.ingresosNomina  	  = 'test';
		wrapper.ingresosPension       = 'test';
		wrapper.ingresosParo  		  = 'test';	
		wrapper.deudaTotal  		  = 'test';
		wrapper.deudaVencida  		  = 'test';
		wrapper.deudaPendienteVencer  = 'test';
		wrapper.diasImpagoPeor  	  = 1;
		wrapper.numeroCliclos  		  = 1;
		wrapper.numeroCiclosTotal     = 1;
		wrapper.prioridad  			  = 'test';
        wrapper.arquetipo  			  = 'test';
		wrapper.capacidadDePago  	  = 'test';
		wrapper.motorSolucion         = 'test';
        wrapper.tipo				  = 'test';

        wrapper.personaPRESOL      	  = 'test';
        wrapper.segmentoPRESOL        = 'test';
        wrapper.estrategiaPRESOL      = 'test';
        wrapper.prioridadPRESOL       = 'test';
        wrapper.motivoInclusion       = 'test';
        wrapper.indEnvio              = 'test';
        wrapper.resGestion            = 'test';
        wrapper.rating                = '3';
        wrapper.saldoPasivoPRESOL = 'test';
        wrapper.saldoDispuestoPRESOL = 'test';
        wrapper.circulante = 'test';
        wrapper.deudaTotalPRESOL = 'test';
        wrapper.deudaVencidaPRESOL = 'test'; 
        wrapper.deudaPendienteVencerPRESOL = 'test';
        wrapper.diasImpagoPeorPRESOL = 3;
        wrapper.numeroCiclosPRESOL = 3;
        wrapper.numeroCiclosTotalPRESOL = 3;
        wrapper.vtoCBP = date.today();
        wrapper.vtoICO = date.today();
        wrapper.vtoCarencia  = date.today();
        wrapper.vtoCCR = date.today();
        wrapper.aviso = 'test';
        wrapper.tenenciaICO = 'test';
        wrapper.alertaPRESOL = 'test';
   		Test.stopTest();
        system.assertNotEquals(null,wrapper,'test');
   }
}