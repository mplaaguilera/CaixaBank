System.debug('Casos ANTES del borrado: ' + [SELECT Id FROM Case WHERE OwnerId = :UserInfo.getUserId()].size() + '.');
Database.delete([SELECT Id FROM Case WHERE OwnerId = :UserInfo.getUserId()], false);
System.debug('Casos DESPUÉS del borrado: ' + [SELECT Id FROM Case WHERE OwnerId = :UserInfo.getUserId()].size() + '.');