@isTest
public with sharing class SIR_cls_WS_WrapperTest {
    @isTest
    public static void formatNumberTest(){
        String str;
        Test.startTest();
        str = SIR_cls_WS_Wrapper.formatNumber(13);
        Test.stopTest();
        System.assertEquals('13', str, 'SIR_cls_WS_WrapperTest.formatNumberTest - No se ha formateado el numero correctamente');
    }

    @isTest
    public static void formatDateTest(){
        Datetime today = Datetime.now();
        String hora = SIR_cls_WS_Wrapper.formatNumber(today.hour());
        String minuto = SIR_cls_WS_Wrapper.formatNumber(today.minute());
        String segundo = SIR_cls_WS_Wrapper.formatNumber(today.second());
        String resultado;
        String esperado = today.day() + '/' + today.month() + '/' + today.year(); //+ ' ' + hora + ':' + minuto + ':' + segundo;
        Test.startTest();
        resultado = SIR_cls_WS_Wrapper.formatDate(today.date());
        Test.stopTest();
        System.assertEquals(esperado, resultado, 'Las fechas son ' + today.date());
    }

    @isTest
    public static void formatDateGMTTest(){
        Datetime today = Datetime.newInstance(1900, 1, 1);        
        String resultado;
        String esperado = '01/01/1900';
        Test.startTest();
        resultado = SIR_cls_WS_Wrapper.formatDateGMT(today.date());
        Test.stopTest();
        System.assertEquals(esperado, resultado, 'Las fechas son ' + today.date());
    }
    @isTest
    public static void responseErrorOKTest(){
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

    @isTest 
    public static void formatDateSFTest(){
        String fecha = '19/10/2000';
        Date fechavieja = date.newInstance(2000, 10, 19);
        Test.startTest();
        Date fechanueva = SIR_cls_WS_Wrapper.formatDateSF(fecha);
        Test.stopTest();
        System.assertEquals(fechavieja, fechanueva, 'SIR_cls_WS_WrapperTest.formatDateSFTest Las fechas no coinciden');

    }
}