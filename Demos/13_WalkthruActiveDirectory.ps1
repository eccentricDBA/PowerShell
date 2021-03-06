Import-Module ActiveDirectory

$UserName = "eccentricDBA"
#Get User Information
Get-ADUser -Identity $UserName 

#Get User Membership
Get-ADPrincipalGroupMembership -Identity $UserName | Select name, SamAccountName

#List Users of Sensitive Groups
Get-ADGroupMember -Identity "Domain Users" -Recursive | Select name, objectClass, SamAccountName
Get-ADGroupMember -Identity "SQLAdmins" -Recursive | Select name, objectClass, SamAccountName


#http://www.techrepublic.com/blog/networking/two-powershell-scripts-for-retrieving-user-info-from-active-directory/3028
#List accounts where the Password Never Expires
Search-ADAccount -PasswordNeverExpires | FT Name,  ObjectClass, UserPrincipalName
#List Office Phone for users
Get-AdUser -Filter * -Properties OfficePhone | Where-Object { ($_.OfficePhone)}| FT OfficePhone,UserPrincipalName
