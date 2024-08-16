param(
  [Parameter(Mandatory = $true)]
  [string]$fold,

  [Parameter(Mandatory = $true)]
  [string]$opt
)

$StartTime = (Get-Date)
# $dataatual = Get-Date -Uformat “%d/%m/%Y”
$datafile = Get-Date -Uformat “%d%m%y_%H%M”

# Set-Location v:\
#Set-Location S:

#Local aonde será salvo os arquivos HTMLs
#$Destfiles = "V:\Belizze\"
# $Destfiles = "V:\Metta Mobili_41\" + "\"
#$Destfiles = [Environment]::GetFolderPath("Desktop")+"\"


# Pasta aonde se encontram as categorias / imagens
# $Fold = "V:\Metta Mobili_41\HTML" + "\"
#$Fold = "V:\Belizze\Imagens\"

$Destfiles = Split-Path $fold -Parent

$Destfiles = $Destfiles + "\"

#Arquivo de categoria se for via arquivo
# $ca = "C:\template\categoria.txt"

# Informe qual separador utilizar, valide fisicamente as imagens
$sep = " "

# Opção de pasta
# $opt = "2"

# 1 - pasta contendo imagens na raiz
# 2 - Pasta contendo Referencias organizadas em pastas
# 3 - pasta contendo estrutura categorias e dentro Referencias organizadas em pastas
# 4 - pasta contendo estrutura categorias e dentro imagens na raiz


switch ($opt) {
  1 { $lifi = Get-ChildItem -Path $fold -Recurse -Exclude Thumbs.db, "*.html" | ? { $_.Attributes -match "archive" } | select @{Label = 'categoria'; Expression = { Split-Path $fold -leaf } }, @{Label = 'cod'; Expression = { ($_.basename).split($sep)[0] } }, name, basename, fullname }
  2 { $lifi = Get-ChildItem -Path $fold -Recurse -Exclude Thumbs.db, "*.html" | ? { $_.Attributes -match "archive" -and $_.Attributes -notmatch "Directory" } | select @{Label = 'categoria'; Expression = { Split-Path $fold -leaf } }, @{Label = 'cod'; Expression = { ($_.basename).split($sep)[0] } }, name, basename, fullname }
  3 { $lifi = Get-ChildItem -Path $fold -Recurse -Exclude Thumbs.db, "*.html" | ? { $_.Attributes -match "archive" } | select @{Label = 'categoria'; Expression = { ($_.DirectoryName).Split("\")[-2] } }, @{Label = 'cod'; Expression = { ($_.basename).split($sep)[0] } }, name, basename, fullname }
  4 { $lifi = Get-ChildItem -Path $fold -Recurse -Exclude Thumbs.db, "*.html" | ? { $_.Attributes -match "archive" } | select @{Label = 'categoria'; Expression = { ($_.DirectoryName).Split("\")[-1] } }, @{Label = 'cod'; Expression = { ($_.basename).split($sep)[0] } }, name, basename, fullname }
  default { Write-host "Opção Invalida, processo abortado" -BackgroundColor Red; break }
}

# De-para - S ou N
$Depara = "N"
If ($Depara -eq "S") {
  $dep = $Destfiles + "De-para.txt"
  If (Test-Path -Path $Dep) {}else { Write-Host "De-para inexistente, abortado." -BackgroundColor Red; Break }
  $tabDp = Import-Csv -Path $dep -Header ref, SKU -Delimiter "`t" | Group-Object -AsHashTable -AsString ref
}

$law = ($lifi)."categoria" | sort -Unique
foreach ($sam in $law) {
  $hos = $lifi | ? { $_.categoria -eq $sam } | Group-Object -AsHashTable -AsString cod

  Write-Host "Processando $sam" -BackgroundColor Blue

  $Html = $Destfiles + $sam + '_' + $datafile + '.html'

  <# cabeçalho #>
  $Cab = @"
<!doctype html>
<html lang="pt-br">
<head>
  <meta charset="utf-8">
  <title>Lista de Produtos</title>
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <link href="https://fonts.googleapis.com/css?family=Roboto:100,300,400,500,700" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"
  integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN"
  crossorigin="anonymous">
<style>
  .box {
          border: black 1px solid;
          padding: 5px;
          margin-top: 10px;
  }

  .box img {
          max-width: 150px;
          max-height: 150px;
          width: auto;
          height: auto;
  }
</style>
</head>
    <body>
      <div class="container">
"@
  $Cab > $Html

  foreach ($h in ($hos.keys | sort)) {
    $he = $hos.$h | Group-Object -AsHashTable -AsString name
    $reference = $h

    $order = ""
    $order = (($hos.$h | select name, basename | Where-Object { !$_.PSIsContainer } |
        Sort-Object -Property @{Expression = { $_.basename -eq $h }; ascending = $false },
        @{Expression = { $_.name -like "*zoom*" }; ascending = $false },
        @{Expression = { $_.name -like "*diferencia*" }; ascending = $false },
        @{Expression = { $_.name -like "*cotas*" }; ascending = $false },
        @{Expression = { $_.name -like "*abert*" }; ascending = $false },
        @{Expression = { $_.name -like "escala*" }; ascending = $false },
        @{Expression = { $_.name -like "flex*" }; ascending = $false },
        @{Expression = { $_.name -like "*conte*" }; ascending = $false },
        @{Expression = { $_.name -like "*medidas*" }; ascending = $false },
        @{Expression = { $_.name -like "*fechad*" }; ascending = $false },
        @{Expression = { $_.name -like "*ambient*" }; ascending = $false },
        @{Expression = { $_.name -like "*minicama*" }; ascending = $false }, 
        @{Expression = { $_.name -like "*sof*" }; ascending = $false }) | select -ExpandProperty name) -join "|"
    '        <div class="box rounded">' >> $Html
    If ($Depara -eq "S") { $refitem = $reference + " - " + ($tabDp.$h)."SKU" }else { $refitem = $reference }
    # $h + "`t" + $order >> "C:\Users\Alex.Castel\Desktop\testeimg.csv"
    '            <p><strong>' + $refitem + '</strong></p>' >> $Html

    $ing = 1
    $la = (($order).split("|")).count
    $sum = 0

    foreach ($Imagens in 1..$la) {
      $li = ($he.(($order).split("|")[$sum]))."fullname"
      $Maior = If ($ing -ge 11) { " background-color: red;" }else {} # (ge) Maior ou igual
      '            <a href="' + $li + '" target="_blank"><img class="img-thumbnail" title="Imagem' + $ing + '" ' + $Maior + '" src="' + $li + '"></a>' >> $Html            
      $ing ++
      $sum ++
    }
    '        </div>' >> $Html
  }

  $Rod = @"
      </div>
      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"
      integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL"
      crossorigin="anonymous"></script>
    </body>
</html>
"@
  $Rod >> $Html
}


ii $Destfiles

#Tempo de execução da tarefa
$EndTime = (Get-Date)
$ElapsedTime = $EndTime - $StartTime
'Duração da tarefa: {0:mm} min {0:ss} seg' -f $ElapsedTime