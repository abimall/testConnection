#объявляем переменные
$hostName = "ya.ru"#доступность какой наружи проверяем
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path #куда кладём логи
$logFile = Join-Path $scriptDirectory "connect.txt" #как назыотличноваем файл логов
$counter = 1 #номер первой записи лога
$lastStatus = $null #номер последней записи лога

Write-Host "I'm work! $(Get-Date -Format "dd-MM-yyyy HH:mm:ss") $(Write-Output $env:logonserver)" #говорит что работает(по английски потому что тупой силаАда не умеет в кирилицу из коробки будтоо там не достаточно Русских программистов

#цикл который гоняет тестконекшн $hostName'a по кругу с дилэем на сколько то секунд - в самом низу цикла - устанавливается эмпирически
while ($true) {
    #тэстконнектим $hostName один раз и получаем только булевой вывод
    $pingResult = Test-Connection -ComputerName $hostName -Count 1 -Quiet
    if ($pingResult) {
        # есть связь
        $status = "YES"
    } else {
        # нет связь
        $status = "NO "
        # куда будем слать реквэст если связь нет
        $url = "https://portal.abimall.ru/"
        # создаём объекта запроса - так надо
        $request = [System.Net.HttpWebRequest]::Create($url)
        # авторизуем текущего юзера через реквэст
        $request.UseDefaultCredentials = $true
        # шлём реквэст
        $response = $request.GetResponse()
        # получаем что то в ответ - без этого валятся ошибки, скрипт функцию выполняет но  вывод консоли  становится не красиво
        $stream = $response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $responseContent = $reader.ReadToEnd()
        $reader.Close()
        $response.Close()
        #пишем что реквэст имел место быть - без проверки потому что мы уже всё проверили отдельно
        Write-Host "oh vey! send request $(Get-Date -Format "dd-MM-yyyy HH:mm:ss") $(Write-Output $env:logonserver)"
    }

    # создаём файл лога, если он еще не существует
    if (-not (Test-Path $logFile)) {
        $header = "Number`tTimestamp"
        $header | Out-File -FilePath $logFile -Encoding utf8
    }

    # пишем в лог только при изменении состояния связи с наружей
    if ($status -ne $lastStatus) {
        $logEntry = "$counter`t$(Get-Date -Format "dd-MM-yyyy HH:mm:ss")`t$status $(Write-Output $env:logonserver)"
        $logEntry | Out-File -FilePath $logFile -Append -Encoding utf8
        $counter++
        $lastStatus = $status
    }

    # тот самый дилэй
    Start-Sleep -Seconds 3
}
