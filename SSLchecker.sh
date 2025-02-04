# set liocation path of your certications
NginxEnabledPath='/etc/nginx/sites-enabled'

ListOfDomains=$(ls $NginxEnabledPath)

DomainConfList=()

for x in $ListOfDomains
do
  DomainList+=($x)
done

for (( i = 0; $i < ${#DomainList[@]}; i++ ))
do
  GetCertPath=$(cat $NginxEnabledPath/${DomainList[$i]} | grep "ssl_certificate " | sed -e "s/;//" | sed -e 's/ssl_certificate//' | tr -d ' ')

  # Read ssl cert info about it dates
  test=$(openssl x509 -in $GetCertPath -noout -dates)
  test=$(echo "$test" | tr '\n' ';')

  # Sequence character for splitting a strings
  IFS=';'

  array=()

  PresentDate=$(date "+%h %d %H:%M:%S %Y")

  for x in $test
  do
    array+=($(echo $x | sed 's/^[^=]*=//'  | awk '{print $1, $2, $3, $4}'))
  done

  BeforeDate=$(date -d "${array[0]}" +%s)
  PresentDate=$(date -d $PresentDate +%s)
  AfterDate=$(date -d "${array[1]}" +%s)

  DayLeft=$(( ( $(date -d @"$AfterDate" +%s) - $(date -d @"$PresentDate" +%s) ) / 60 / 60 / 24 ))

  # See if ssl cert is fully expired or not
  if [[ DayLeft -eq 1 ]]; then
    Message="SSL cert are expired going to expire in 1 days for ${DomainList[$i]}"
    # setting up a messaging system that integrates functionalities similar to MQTT, ntfy, Slack, and Telegram notifications.
  elif [[ DayLeft -eq 87 ]]; then
    Message="SSL cert are expired going to expire in 7 days for ${DomainList[$i]}"
    # setting up a messaging system that integrates functionalities similar to MQTT, ntfy, Slack, and Telegram notifications.
  fi
done