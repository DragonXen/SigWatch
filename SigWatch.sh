#!/bin/bash
PATH_SIG="data/signatures/SignatureMalware.json"

ScanSignatures() {
  echo "Executando escaneamento..."
  while read file;
  do
    HASH_SCAN "${file}" &
  done <<< $(find "$1" -type f)
}

RegisterSignatures() {
  # duas formas de registro: calculate hash, insert hash
  ## menu para selecionar o tipo
  printf ">>>Registro de assinatura maliciosa<<<\n"
  while true;
  do
    echo -e "\nDigite a assinatura sha256 do arquivo ou pressione \"Enter\" para escolher o arquivo."
    read sig
    if [[ -z "${sig}" ]] ;
    then
        echo "Digite onde está o arquivo:"
        read file
        sig=$(sha256sum "${file}" | cut -d " " -f1)
    fi

    len_sig=$(echo "${sig}" | wc -c)
    if [[ "${len_sig}" < "65" ]];
    then
      echo "Assinatura sha256 invalida"
      break
    fi
    ## registrar se é hash ou se é string
    ## no momento vai ser só hash
    type="sha256"
    
    timestamp=$(date +%s)
    reg=$(jo sig="${sig}" type_sig="${type}" timestamp="${timestamp}")
    echo "${reg}" >> "${PATH_SIG}"

    printf "Registro adicionado\n${reg}\n"

    echo "Deseja adicionar mais? Enter: sair, S: adicionar"
    read op
    if [[ -z $op ]];
    then
      break
    fi
  done
}

QuarantineMalware() {
  # utilize xz para isso
  xz $1
  mv $1.xz $1.xz.lock
}

HASH_SCAN() {
  file="$1"
  sig_file=$(sha256sum "${file}" | cut -d " " -f1)
  while read obj;
  do
    sig=$(jq -r .sig <<< "${obj}")
    if [[ "${sig_file}" == "${sig}" ]];
    then
      echo "Arquivo malicioso detectado:"
      echo "${file}"
      QuarantineMalware ${file}
      break
    fi
  done < "${PATH_SIG}"
}

clear
printf "\t[SigWatch - Hunter Malware]\n"
case $1 in
  --scan)
    ScanSignatures $2
  ;;
  --reg)
    RegisterSignatures
  ;;
esac