#Импорт модуля Active Directory для запуска команд
Import-Module ActiveDirectory

#Сохраняем данные из файла NewUsersFinal.csv в переменной $ADUsers
$ADUsers = Import-Csv C:\temp\NewUsersFinal.csv -Delimiter ";"

#Выполните цикл по каждой строке, содержащей сведения о пользователе в файле CSV
foreach ($User in $ADUsers) {
    #Читаем пользовательские данные из каждого поля в каждой строке и назначаем данные в переменные как показано ниже
    $username = $User.username
    $password = $User.password
    $firstname = $User.firstname
    $lastname = $User.lastname
    $middlename = $User.middlename
    $Description = $User.Description
    $OU = $User.ou #Это поле относится к подразделению, в котором должна быть создана учетная запись пользователя
    $UPN = $User.UPN
    $email = $User.email
    $streetaddress = $User.streetaddress
    $city = $User.city
    $zipcode = $User.zipcode
    $state = $User.state
    $telephone = $User.telephone
    $jobtitle = $User.jobtitle
    $company = $User.company
    $department = $User.department

    #Проверяем наличие пользователя из списка на наличие в Active Directory
    if (Get-ADUser -F { SamAccountName -eq $username }) {  
        #Если пользователь существует, выдаём предупреждение
        Write-Warning "A user account with username $username already exists in Active Directory."
    }
    else {
        #Пользователь не существует, переходим к созданию новой учетной записи пользователя
        #Учетная запись будет создана в подразделении переменной $OU, считанной из CSV-файла
        New-ADUser `
            -SamAccountName $username `
            -UserPrincipalName "$username@$UPN" `
            -Name "$firstname $middlename $lastname" `
            -GivenName $firstname `
            -Surname $lastname `
            -Initials $middlename `
            -Description $Description `
            -Enabled $True `
            -DisplayName "$firstname $middlename $lastname" `
            -Path $OU `
            -City $city `
            -PostalCode $zipcode `
            -Company $company `
            -State $state `
            -StreetAddress $streetaddress `
            -OfficePhone $telephone `
            -EmailAddress $email `
            -Title $jobtitle `
            -Department $department `
            -CannotChangePassword $True `
            -PasswordNeverExpires $True `
            -ChangePasswordAtLogon $False `
            -AccountPassword (ConvertTo-secureString $password -AsPlainText -Force)
        #Если пользователь создан, показываем сообщение.
        Write-Host "The user account $username is created." -ForegroundColor Cyan
    }
}

Read-Host -Prompt "Press Enter to exit"