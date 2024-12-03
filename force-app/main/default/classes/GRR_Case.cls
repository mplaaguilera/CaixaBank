public with sharing class GRR_Case {

    public static Case crearCaso(String recordTypeDeveloperName) {
        return crearCaso(recordTypeDeveloperName, new Map<String, Object>());
    }

    public static Case crearCaso(String recordTypeDeveloperName, Map<String, Object> campos) {
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', recordTypeDeveloperName);
        for (String campo : campos.keySet()) {
            caso.put(campo, campos.get(campo));
        }
        insert caso;
        return caso;
    }

    public static Case reapertura(Id idCaso, String descripcionTarea, Boolean cambiarPropietario, Boolean sinUpdate) {
        //Reapertura caso por respuesta (el estado pasa a Activo y se registra el motivo de reapertura en una nueva actividad)
        Case caso = [SELECT Status, ContactId FROM Case WHERE Id = :idCaso WITH SECURITY_ENFORCED];
        if (caso.Status != 'Activo') {
            Task tareaReactivacion = new Task();
            tareaReactivacion.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            tareaReactivacion.WhatId = idCaso;
            tareaReactivacion.Status = 'Completed';
            tareaReactivacion.Type = 'Reactivación';
            tareaReactivacion.Subject = 'Reactivación';
            tareaReactivacion.Description = descripcionTarea;
            tareaReactivacion.ActivityDate = System.today();
            tareaReactivacion.CC_Fecha_Inicio__c = System.now();
            insert tareaReactivacion;

            caso.Status = 'Activo';
            caso.CC_Fecha_Reapertura__c = Datetime.valueOf(System.now());
            if (cambiarPropietario) {
                caso.OwnerId = UserInfo.getUserId();
            }

            if (!sinUpdate) {
                update caso;
            }
        }
        return caso;
    }

    public static Case reapertura(Id idCaso, String descripcionTarea) {
        return reapertura(idCaso, descripcionTarea, true, false);
    }

    //NEW
    public static Case responderCerrar(Case caso){
        if (caso.Status == 'Activo') {
            caso.Status = 'Cerrado';
            caso.OS_Cerrado_Operativa__c = false;  
        }
        return caso;
    }
    
    public static String historicoCorreosSinCliente(Id idCaso) {
		String resultado = '';
		List<EmailMessage> correos = new List<EmailMessage>();
		//if (incluirInternos) {
			correos = [SELECT MessageDate, FromAddress, ToAddress, CcAddress, Subject, HtmlBody, TextBody FROM EmailMessage
						WHERE ParentId = :idCaso AND CC_Interno__c = true ORDER BY CreatedDate DESC LIMIT 1];
		//} 
        // else {
		// 	correos = [SELECT MessageDate, FromAddress, ToAddress, CcAddress, Subject, HtmlBody, TextBody FROM EmailMessage
		// 				WHERE ParentId = :idCaso AND CC_Interno__c = false ORDER BY CreatedDate DESC LIMIT 1];
		// }

		for (Integer i = 0; i < correos.size(); i++) {
			EmailMessage correo = correos[i];
			if (correo.HtmlBody != '' && correo.HtmlBody != null) {
				resultado += '<font color="gray">De: ' + correo.FromAddress + '<br/>';
				resultado += 'Enviado el: ' + formatearFecha(correo.MessageDate) + '<br/>';
				resultado += 'Para: ' + correo.ToAddress + '<br/>';
				if (correo.CcAddress != null) {
					resultado += 'Con copia a:' + correo.CcAddress + '<br/>';
				}
				resultado += 'Asunto: ' + correo.Subject + '</font><br/><br/>' + correo.HtmlBody;
				if (i < correos.size() - 1) {
					//Si no es el último correo incluye un separador
					resultado += '<br/>__________<br/><br/>';
				}
			} else if (correo.TextBody != '' && correo.TextBody != null) {
				String nuevoTextoPlano = '';
				for (String s : correo.TextBody.split('\\n')) {
					nuevoTextoPlano += s + '<br/>';
				}
				resultado += '<font color="gray">De: ' + correo.FromAddress + '<br/>';
				resultado += 'Enviado el: ' + formatearFecha(correo.MessageDate) + '<br/>';
				resultado += 'Para: ' + correo.ToAddress + '<br/>';
				if (correo.CcAddress != null) {
					resultado += 'Con copia a:' + correo.CcAddress + '<br/>';
				}
				resultado += 'Asunto: ' + correo.Subject + '</font><br/><br/>' + nuevoTextoPlano;
				if (i < correos.size() - 1) {
					//Si no es el último correo incluye un separador
					resultado += '<br/>__________<br/><br/>';
				}
			}
		}

        return resultado;
    }

    private static String formatearFecha(Datetime fecha) {
		List<String> diasEN = new List<String>{'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
		List<String> diasES = new List<String>{'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'};

		List<String> mesesEN = new List<String>{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
		List<String> mesesES = new List<String>{'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'};

		String retorno = diasES.get(diasEN.indexOf(fecha.format('EEE'))) + ', ' + fecha.day() + ' de ';
		retorno += mesesES.get(mesesEN.indexOf(fecha.format('MMM'))) + ' de ' + fecha.year() + ' ' + fecha.format('HH:mm');

		return retorno;
	}
}