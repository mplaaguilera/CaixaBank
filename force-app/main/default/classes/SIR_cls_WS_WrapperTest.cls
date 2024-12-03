/*****************************************************************
    Name: SIR_cls_WS_WrapperTest
    Copyright © 2023 CaixaBank

    Propósito: Clase test de SIR_cls_WS_Wrapper.                                                                               

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira

*****************************************************************/
@isTest
public with sharing class SIR_cls_WS_WrapperTest {

    /*****************************************************************                                                  
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira       
        
	*****************************************************************/  
    @isTest
    public static void formatNumberTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){
            String str;
            Test.startTest();
            str = SIR_cls_WS_Wrapper.formatNumber(13);
            Test.stopTest();
            System.assertEquals('13', str, 'SIR_cls_WS_WrapperTest.formatNumberTest - No se ha formateado el numero correctamente');
        }
    }

    /*****************************************************************                                                  
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira       
        
	*****************************************************************/  
    @isTest
    public static void formatDateTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){
            Datetime today = Datetime.now();
            String hora = SIR_cls_WS_Wrapper.formatNumber(today.hour());
            String minuto = SIR_cls_WS_Wrapper.formatNumber(today.minute());
            String segundo = SIR_cls_WS_Wrapper.formatNumber(today.second());
            String resultado;
            String esperado = today.day() + '/' + today.month() + '/' + today.year();
            Test.startTest();
            resultado = SIR_cls_WS_Wrapper.formatDate(today.date());
            Test.stopTest();
            System.assertNotEquals(esperado, resultado, 'Las fechas son ' + today.date());
        }
    }

    /*****************************************************************                                                  
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira       
        
	*****************************************************************/  
    @isTest
    public static void formatDateGMTTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){
            Datetime today = Datetime.newInstance(1900, 1, 1);        
            String resultado;
            String esperado = '01/01/1900';
            Test.startTest();
            resultado = SIR_cls_WS_Wrapper.formatDateGMT(today.date());
            Test.stopTest();
            System.assertEquals(esperado, resultado, 'Las fechas son ' + today.date());
        }  
    }

    /*****************************************************************                                                  
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira       
        
	*****************************************************************/  
    @isTest
    public static void responseErrorOKTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){
            List<String> resultado;
            Integer status = 202;
            SIR_cls_WS_Wrapper.ErrorResponseDto errorDto = new SIR_cls_WS_Wrapper.ErrorResponseDto();
            errorDto.descripcionError = 'Error al enviar';
            Test.startTest();
            resultado = SIR_cls_WS_Wrapper.responseError(status, errorDto);
            Test.stopTest();
            System.assertEquals('KO', resultado.get(0));
            System.assertEquals('Se ha producido un error en la sincronización, inténtelo más tarde.', resultado.get(1), 'No funciona el metodo responseErrorOKTest');
            System.assertNotEquals(null, resultado.get(2));
        }
    }

    /*****************************************************************                                                  
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira       
        
	*****************************************************************/   
    @isTest 
    public static void formatDateSFTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){
            String fecha = '19/10/2000';
            Date fechavieja = date.newInstance(2000, 10, 19);
            Test.startTest();
            Date fechanueva = SIR_cls_WS_Wrapper.formatDateSF(fecha);
            Test.stopTest();
            System.assertEquals(fechavieja, fechanueva, 'SIR_cls_WS_WrapperTest.formatDateSFTest Las fechas no coinciden');
        }
    }
}