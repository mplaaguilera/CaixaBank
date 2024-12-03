/*****************************************************************
 Name:  SIR_WrapperCabecera
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase wrapper para clase controladora SIR_LCMP_GetProfileClient                                                                                                                    
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US US244035      Atmira      24/06/2021     	      Clase Wrapper    

*****************************************************************/
public with sharing class SIR_WrapperCabecera {
    //Campos para la Ficha Cliente IMPA
	@AuraEnabled
    Public String persona;
    @AuraEnabled
	Public String segmento;
    @AuraEnabled
    Public String saldoPasivo;
    @AuraEnabled
    Public String ingresosTotal;
    @AuraEnabled
    Public String ingresosNomina;
    @AuraEnabled
    Public String ingresosPension;
    @AuraEnabled
    Public String ingresosParo;
    @AuraEnabled
    Public String deudaTotal;
    @AuraEnabled
    Public String deudaVencida;
    @AuraEnabled
    Public String deudaPendienteVencer;
    @AuraEnabled
    Public Double diasImpagoPeor;
    @AuraEnabled
    Public Double numeroCliclos;
    @AuraEnabled
    Public Double numeroCiclosTotal;
    @AuraEnabled
    Public String prioridad;
    @AuraEnabled
    Public String arquetipo;
    @AuraEnabled
    Public String capacidadDePago;
    @AuraEnabled
    Public String motorSolucion;
    @AuraEnabled
    public String importePP;
    @AuraEnabled
    public String deudaRefinanciada;
    @AuraEnabled
    public String indicadorPP;
    @AuraEnabled
    public String tipo { get; set; }


    //Campos para las Fichas de Cliente de PRESOL
    @AuraEnabled
    public String estrategiaPRESOL;
    @AuraEnabled
    public String personaPRESOL;
    @AuraEnabled
    public String segmentoPRESOL;
    @AuraEnabled
    public String prioridadPRESOL;
    @AuraEnabled
    public String motivoInclusion;
    @AuraEnabled
    public String indEnvio;
    @AuraEnabled
    public String resGestion;
    @AuraEnabled
    public String rating;
    @AuraEnabled
    public String saldoPasivoPRESOL;
    @AuraEnabled
    public String saldoDispuestoPRESOL;
    @AuraEnabled
    public String circulante;
    @AuraEnabled
    Public String deudaTotalPRESOL;
    @AuraEnabled
    Public String deudaVencidaPRESOL;
    @AuraEnabled
    Public String deudaPendienteVencerPRESOL;
    @AuraEnabled
    Public Double diasImpagoPeorPRESOL;
    @AuraEnabled
    Public Double numeroCiclosPRESOL;
    @AuraEnabled
    Public Double numeroCiclosTotalPRESOL;
    @AuraEnabled
    public Date vtoCBP;
    @AuraEnabled
    public Date vtoICO;
    @AuraEnabled
    public Date vtoCarencia;
    @AuraEnabled
    public Date vtoCCR;
    @AuraEnabled
    public String aviso;
    @AuraEnabled
    public String tenenciaICO;
    @AuraEnabled
    public String alertaPRESOL;
    @AuraEnabled
    public String saldoActivo;
    @AuraEnabled
    public Date fechaProximaCura;
    @AuraEnabled
    public Date fechaEstimadaSalidaPP;    
}