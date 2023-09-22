final Id userId = UserInfo.getUserId(); 
final String PERMISSION_SET_NAME = 'LogAccess'; 
List<PermissionSet> perms = [SELECT Id FROM PermissionSet WHERE Name = :PERMISSION_SET_NAME LIMIT 1];
PermissionSet perm = (perms?.isEmpty() == false) ? perms[0] : null; 
PermissionSetAssignment assignment = new PermissionSetAssignment(); 
assignment.AssigneeId = userId; 
assignment.PermissionSetId = perm?.Id; 
try {
    insert assignment; 
    System.debug('Inserted PermissionSetAssignment ' + assignment?.Id);
} catch (Exception error) {
    System.debug('Failed to insert PermissionSetAssignment: ' + error);
}