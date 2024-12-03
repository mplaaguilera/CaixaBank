System.debug('Oportunidades ANTES del borrado: ' + [SELECT Id FROM Opportunity WHERE OwnerId = :UserInfo.getUserId()].size() + '.');
Database.delete([SELECT Id FROM Opportunity WHERE OwnerId = :UserInfo.getUserId()], false);
System.debug('Oportunidades DESPUÉS del borrado: ' + [SELECT Id FROM Opportunity WHERE OwnerId = :UserInfo.getUserId()].size() + '.');