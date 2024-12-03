public with sharing class OS_Informar_DAN_DG_DT_Caso {
    public static void informarCampos(Set<Id> caseID) {
        //DAN(GC) -> Delegacion general(DG) -> Direccion territorial DT -> TT -> TE  
        List<Case> listaCasosUpd = new List<Case>();
        
        List<Case > listaCase = [SELECT Id, Recordtype.DeveloperName,
                                 AccountId, Account.CC_Tipo_Centro__c,
                                 Account.ParentId, Account.Parent.CC_Tipo_Centro__c,
                                 Account.Parent.ParentId, Account.Parent.Parent.CC_Tipo_Centro__c,
                                 Account.Parent.Parent.ParentId, Account.Parent.Parent.Parent.CC_Tipo_Centro__c,

                                 Account.CC_OficinaGestoraId__c, Account.CC_OficinaGestoraId__r.CC_Tipo_Centro__c,
                                 Account.CC_OficinaGestoraId__r.ParentId, Account.CC_OficinaGestoraId__r.Parent.CC_Tipo_Centro__c,
                                 Account.CC_OficinaGestoraId__r.Parent.ParentId, Account.CC_OficinaGestoraId__r.Parent.Parent.CC_Tipo_Centro__c,
                                 Account.CC_OficinaGestoraId__r.Parent.Parent.ParentId, Account.CC_OficinaGestoraId__r.Parent.Parent.Parent.CC_Tipo_Centro__c
                                 
                                 FROM Case WHERE Id IN :caseID];

        if (!listaCase.isEmpty()) {  
            Set<Id> setCuentas = new Set<Id>();
            for (Case caso : listaCase) {
                setCuentas.add(caso.Account.Parent.Parent.ParentId);
                setCuentas.add(caso.Account.CC_OficinaGestoraId__r.Parent.Parent.ParentId);
            }
            List<Account> listaOficinas = [SELECT Id, CC_Tipo_Centro__c, 
                                ParentId, Parent.CC_Tipo_Centro__c,
                                Parent.ParentId, Parent.Parent.CC_Tipo_Centro__c, 
                                Parent.Parent.ParentId, Parent.Parent.Parent.CC_Tipo_Centro__c,
                                Parent.Parent.Parent.ParentId, Parent.Parent.Parent.Parent.CC_Tipo_Centro__c
                                FROM Account WHERE Id = :setCuentas];

            for (Case caso : listaCase) {
                if (caso.AccountId != null){
                    if(caso.RecordType.DeveloperName == 'OS_Empleado'){
                        if (caso.Account.CC_Tipo_Centro__c == 'DT'){
                            caso.CC_Direccion_Territorial__c = caso.AccountId;

                            listaCasosUpd.add(caso);
                        } else if (caso.Account.Parent.CC_Tipo_Centro__c == 'DT'){
                            caso.CC_Direccion_Territorial__c = caso.Account.ParentId;
                            if (caso.Account.CC_Tipo_Centro__c == 'DG'){
                                caso.CC_DG__c = caso.AccountId;
                            }
                            listaCasosUpd.add(caso);
                        } else if (caso.Account.Parent.Parent.CC_Tipo_Centro__c == 'DT'){
                            caso.CC_Direccion_Territorial__c = caso.Account.Parent.ParentId;
                            if (caso.Account.Parent.CC_Tipo_Centro__c == 'DG'){
                                caso.CC_DG__c = caso.Account.ParentId;
                            }
                            if (caso.Account.CC_Tipo_Centro__c == 'GC'){
                                caso.CC_DAN__c = caso.AccountId;
                            }
                            listaCasosUpd.add(caso);
                        } else if (caso.Account.Parent.Parent.Parent.CC_Tipo_Centro__c == 'DT'){
                            caso.CC_Direccion_Territorial__c = caso.Account.Parent.Parent.ParentId;
                            if (caso.Account.Parent.Parent.CC_Tipo_Centro__c == 'DG'){
                                caso.CC_DG__c = caso.Account.Parent.ParentId;
                            }
                            if (caso.Account.Parent.CC_Tipo_Centro__c == 'GC'){
                                caso.CC_DAN__c = caso.Account.ParentId;
                            }
                            listaCasosUpd.add(caso);
                        } 
                    }
                    if(caso.RecordType.DeveloperName == 'OS_Cliente'){
                        if (caso.Account.CC_OficinaGestoraId__r.CC_Tipo_Centro__c == 'DT'){
                            caso.CC_Direccion_Territorial__c = caso.Account.CC_OficinaGestoraId__c;

                            listaCasosUpd.add(caso);
                        } else if (caso.Account.CC_OficinaGestoraId__r.Parent.CC_Tipo_Centro__c == 'DT'){
                            caso.CC_Direccion_Territorial__c = caso.Account.CC_OficinaGestoraId__r.ParentId;
                            if (caso.Account.CC_OficinaGestoraId__r.CC_Tipo_Centro__c == 'DG'){
                                caso.CC_DG__c = caso.Account.CC_OficinaGestoraId__c;
                            }
                            listaCasosUpd.add(caso);
                        } else if (caso.Account.CC_OficinaGestoraId__r.Parent.Parent.CC_Tipo_Centro__c == 'DT'){
                            caso.CC_Direccion_Territorial__c = caso.Account.CC_OficinaGestoraId__r.Parent.ParentId;
                            if (caso.Account.CC_OficinaGestoraId__r.Parent.CC_Tipo_Centro__c == 'DG'){
                                caso.CC_DG__c = caso.Account.CC_OficinaGestoraId__r.ParentId;
                            }
                            if (caso.Account.CC_OficinaGestoraId__r.CC_Tipo_Centro__c == 'GC'){
                                caso.CC_DAN__c = caso.Account.CC_OficinaGestoraId__c;
                            }
                            listaCasosUpd.add(caso);
                        } else if (caso.Account.CC_OficinaGestoraId__r.Parent.Parent.Parent.CC_Tipo_Centro__c == 'DT'){
                            caso.CC_Direccion_Territorial__c = caso.Account.CC_OficinaGestoraId__r.Parent.Parent.ParentId;
                            if (caso.Account.CC_OficinaGestoraId__r.Parent.Parent.CC_Tipo_Centro__c == 'DG'){
                                caso.CC_DG__c = caso.Account.CC_OficinaGestoraId__r.Parent.ParentId;
                            }
                            if (caso.Account.CC_OficinaGestoraId__r.Parent.CC_Tipo_Centro__c == 'GC'){
                                caso.CC_DAN__c = caso.Account.CC_OficinaGestoraId__r.ParentId;
                            }
                            listaCasosUpd.add(caso);
                        } 
                    }                          
                    if(!listaOficinas.isEmpty()){
                        for (Account cuenta : listaOficinas){ 
                            if(cuenta.Parent.CC_Tipo_Centro__c == 'DT'){
                                caso.CC_Direccion_Territorial__c = cuenta.ParentId;
                                if (cuenta.CC_Tipo_Centro__c == 'DG'){
                                    caso.CC_DG__c = cuenta.Id;
                                }
                                if (caso.Account.Parent.Parent.CC_Tipo_Centro__c == 'GC'){
                                    caso.CC_DAN__c = caso.Account.Parent.ParentId;
                                }
                                listaCasosUpd.add(caso);
                            } else if(cuenta.Parent.Parent.CC_Tipo_Centro__c == 'DT'){
                                caso.CC_Direccion_Territorial__c = cuenta.Parent.ParentId;
                                if (cuenta.Parent.CC_Tipo_Centro__c == 'DG'){
                                    caso.CC_DG__c = cuenta.ParentId;
                                }
                                if (cuenta.CC_Tipo_Centro__c == 'GC'){
                                    caso.CC_DAN__c = cuenta.Id;
                                }
                                listaCasosUpd.add(caso);
                            } else if(cuenta.Parent.Parent.Parent.CC_Tipo_Centro__c == 'DT'){
                                caso.CC_Direccion_Territorial__c = cuenta.Parent.Parent.ParentId;
                                if (cuenta.Parent.Parent.CC_Tipo_Centro__c == 'DG'){
                                    caso.CC_DG__c = cuenta.Parent.ParentId;
                                }
                                if (cuenta.Parent.CC_Tipo_Centro__c == 'GC'){
                                    caso.CC_DAN__c = cuenta.ParentId;
                                }
                                listaCasosUpd.add(caso);
                            }
                        }
                    }
                }
            }
        }   
        update listaCasosUpd;
    }

    public static void desinformarCampos(List<Case> casosActualizarList){
        for(Case caso: casosActualizarList){
            caso.CC_DAN__c = null;
            caso.CC_DG__c = null;
            caso.CC_Direccion_Territorial__c = null;
        }
    }
}