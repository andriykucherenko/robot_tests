*** Settings ***
Resource        keywords.robot
Resource        resource.robot
Suite Setup     Test Suite Setup
Suite Teardown  Close all browsers

*** Variables ***
${mode}         openua

${role}         viewer
${broker}       Quinta


*** Test Cases ***
Можливість оголосити понадпороговий однопредметний тендер
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Можливість оголосити тендер
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      minimal
  [Documentation]   Створення закупівлі замовником, обовязково має повертати UAID закупівлі (номер тендера)
  ${tender_data}=  Підготовка початкових даних
  ${TENDER_UAID}=  Викликати для учасника  ${tender_owner}  Створити тендер  ${tender_data}
  ${LAST_MODIFICATION_DATE}=  Get Current TZdate
  Set To Dictionary  ${USERS.users['${tender_owner}']}  initial_data  ${tender_data}
  Set To Dictionary  ${TENDER}   TENDER_UAID             ${TENDER_UAID}
  Set To Dictionary  ${TENDER}   LAST_MODIFICATION_DATE  ${LAST_MODIFICATION_DATE}
  Log  ${TENDER}

Пошук позапорогового однопредметного тендера по ідентифікатору
  [Tags]   ${USERS.users['${viewer}'].broker}: Пошук тендера по ідентифікатору
  ...      viewer  tender_owner  provider  provider1
  ...      ${USERS.users['${viewer}'].broker}  ${USERS.users['${tender_owner}'].broker}
  ...      ${USERS.users['${provider}'].broker}  ${USERS.users['${provider1}'].broker}
  ...      minimal
  ${usernames}=  Create List  ${viewer}  ${tender_owner}  ${provider}  ${provider1}
  :FOR  ${username}  IN  @{usernames}
  \  Дочекатись синхронізації з майданчиком    ${username}
  \  Викликати для учасника  ${username}  Пошук тендера по ідентифікатору   ${TENDER['TENDER_UAID']}

Відображення типу закупівлі оголошеного тендер
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення основних даних оголошеного тендера
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  Звірити поле тендера  ${viewer}  ${USERS.users['${tender_owner}'].initial_data}  procurementMethodType

Відображення початку періоду прийому пропозицій оголошеного тендера
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення основних даних оголошеного тендера
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      minimal
  ${usernames}=  Create List  ${viewer}  ${provider}  ${provider1}
  :FOR  ${username}  IN  @{usernames}
  \  Звірити дату тендера  ${username}  ${USERS.users['${tender_owner}'].initial_data}  tenderPeriod.startDate

Відображення закінчення періоду прийому пропозицій оголошеного тендера
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення основних даних оголошеного тендера
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      minimal
  ${usernames}=  Create List  ${viewer}  ${provider}  ${provider1}
  :FOR  ${username}  IN  @{usernames}
  \  Звірити дату тендера  ${username}  ${USERS.users['${tender_owner}'].initial_data}  tenderPeriod.endDate

Можливість подати вимогу на умови більше ніж за 10 днів до завершення періоду подання пропозицій
  [Tags]   ${USERS.users['${provider}'].broker}: Можливість подати вимогу на умови
  ...      provider
  ...      ${USERS.users['${provider}'].broker}
  [Documentation]    Користувач  ${USERS.users['${provider}'].broker}  намагається подати скаргу на умови оголошеної  закупівлі
  ${claim}=  Get From List  ${COMPLAINTS}  0
  Set To Dictionary  ${claim.data}   status   claim
  Викликати для учасника   ${provider}   Подати скаргу    ${TENDER['TENDER_UAID']}   ${claim}
  ${complaints}=  Create Dictionary
  Set To Dictionary  ${complaints}   claim0   ${claim}
  Set To Dictionary  ${USERS.users['${provider}']}   complaints   ${complaints}

Можливість скасувати вимогу на умови
  [Tags]   ${USERS.users['${provider}'].broker}: Можливість скасувати скаргу на умови
  ...      provider
  ...      ${USERS.users['${provider}'].broker}
  ${claim}=  Get From Dictionary  ${USERS.users['${provider}'].complaints}  claim0
  Set To Dictionary  ${claim.data}   status   cancelled
  Set To Dictionary  ${claim.data}   cancellationReason   test_draft_cancellation
  Викликати для учасника   ${provider}     Обробити скаргу    ${TENDER['TENDER_UAID']}  0  ${claim}


Подати цінову пропозицію першим учасником після оголошення тендеру
  [Tags]   ${USERS.users['${provider}'].broker}: Можливість подати цінову пропозицію
  ...      provider
  ...      ${USERS.users['${provider}'].broker}
  ${bid}=  test bid data
  Log  ${bid}
  ${bidresponses}=  Create Dictionary
  Set To Dictionary  ${bidresponses}                 bid   ${bid}
  Set To Dictionary  ${USERS.users['${provider}']}   bidresponses  ${bidresponses}
  ${resp}=  Викликати для учасника   ${provider}   Подати цінову пропозицію   ${TENDER['TENDER_UAID']}   ${bid}
  Set To Dictionary  ${USERS.users['${provider}'].bidresponses}   resp  ${resp}
  log  ${resp}

Подати цінову пропозицію другим учасником
  [Tags]   ${USERS.users['${provider1}'].broker}: Можливість подати цінову пропозицію
  ...      provider1
  ...      ${USERS.users['${provider1}'].broker}
  ${bid}=  test bid data
  Log  ${bid}
  ${bidresponses}=  Create Dictionary
  Set To Dictionary  ${bidresponses}                 bid   ${bid}
  Set To Dictionary  ${USERS.users['${provider1}']}   bidresponses  ${bidresponses}
  ${resp}=  Викликати для учасника   ${provider1}   Подати цінову пропозицію   ${TENDER['TENDER_UAID']}   ${bid}
  Set To Dictionary  ${USERS.users['${provider1}'].bidresponses}   resp  ${resp}
  log  ${resp}

Можливість редагувати однопредметний тендер більше ніж за 7 днів до завершення періоду подання пропозицій
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Можливість оголосити тендер
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  Викликати для учасника   ${tender_owner}  Внести зміни в тендер  ${TENDER['TENDER_UAID']}   description     description

Перевірити на зміну статус пропозицій після редагування інформації про закупівлю
  [Tags]   ${USERS.users['${provider}'].broker}: Можливість змінити цінову пропозицію
  ...      provider  provider1
  ...      ${USERS.users['${provider}'].broker}  ${USERS.users['${provider1}'].broker}
  ${usernames}=  Create List  ${provider}  ${provider1}
  :FOR  ${username}  IN  @{usernames}
  \  Дочекатись синхронізації з майданчиком    ${username}
  \  Викликати для учасника   ${username}   Пошук тендера по ідентифікатору   ${TENDER['TENDER_UAID']}
  \  ${bid}=  Викликати для учасника  ${username}  Отримати пропозицію  ${TENDER['TENDER_UAID']}
  \  Should Be Equal  ${bid.data.status}  invalid
  \  Log  ${bid}


Оновити статус цінової пропозиції першого учасника
  [Tags]   ${USERS.users['${provider}'].broker}: Можливість змінити цінову пропозицію
  ...      provider
  ...      ${USERS.users['${provider}'].broker}
  ${activestatusresp}=  create_data_dict  data.status  active
  ${activestatusresp}=  Викликати для учасника   ${provider}   Змінити цінову пропозицію   ${TENDER['TENDER_UAID']}   ${activestatusresp}
  Set To Dictionary  ${USERS.users['${provider}'].bidresponses}   activestatusresp   ${activestatusresp}
  log  ${activestatusresp}

Cкасувати цінову пропозицію другого учасника
  [Tags]   ${USERS.users['${provider1}'].broker}: Можливість скасувати цінову пропозицію
  ...      provider1
  ...      ${USERS.users['${provider1}'].broker}
  ${bid}=  Get Variable Value  ${USERS.users['${provider1}'].bidresponses['resp']}
  ${bidresponses}=  Викликати для учасника   ${provider1}   Скасувати цінову пропозицію   ${TENDER['TENDER_UAID']}   ${bid}

Повторно подати цінову пропозицію другим учасником після першої зміни
  [Tags]   ${USERS.users['${provider1}'].broker}: Можливість подати цінову пропозицію
  ...      provider1
  ...      ${USERS.users['${provider1}'].broker}
  ${bid}=  test bid data
  Log  ${bid}
  ${bidresponses}=  Create Dictionary
  Set To Dictionary  ${bidresponses}                 bid   ${bid}
  Set To Dictionary  ${USERS.users['${provider1}']}   bidresponses  ${bidresponses}
  ${resp}=  Викликати для учасника   ${provider1}   Подати цінову пропозицію   ${TENDER['TENDER_UAID']}   ${bid}
  Set To Dictionary  ${USERS.users['${provider1}'].bidresponses}   resp  ${resp}
  log  ${resp}

Неможливість редагувати однопредметний тендер менше ніж за 7 днів до завершення періоду подання пропозицій
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Можливість оголосити тендер
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ${no_edit_time}=  add_minutes_to_date  ${USERS.users['${tender_owner}'].tender_data.data.tenderPeriod.endDate}  -6
  Дочекатись дати  ${no_edit_time}
  Викликати для учасника   ${tender_owner}  Внести зміни в тендер  shouldfail  ${TENDER['TENDER_UAID']}   description     description

Неможливість подати вимогу на умови менше ніж за 10 днів до завершення періоду подання пропозицій
  [Tags]   ${USERS.users['${provider}'].broker}: Можливість подати вимогу на умови
  ...      provider
  ...      ${USERS.users['${provider}'].broker}
  [Documentation]    Користувач  ${USERS.users['${provider}'].broker}  намагається подати скаргу на умови оголошеної  закупівлі
  ${claim}=  Get From List  ${COMPLAINTS}  0
  Set To Dictionary  ${claim.data}   status   claim
  Викликати для учасника   ${provider}   Подати скаргу   shouldfail   ${TENDER['TENDER_UAID']}   ${claim}


Продовжити період редагування подання пропозиції на 7 днів
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Можливість оголосити тендер
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ${endDate}=  add_minutes_to_date   ${USERS.users['${tender_owner}'].tender_data.data.tenderPeriod.endDate}  7
  Викликати для учасника   ${tender_owner}  Внести зміни в тендер  ${TENDER['TENDER_UAID']}   tenderPeriod.endDate     ${endDate}


Можливість подати скаргу на умови більше ніж за 4 дні до завершення періоду подання пропозицій
  [Tags]   ${USERS.users['${provider}'].broker}: Можливість подати скаргу на умови
  ...      provider
  ...      ${USERS.users['${provider}'].broker}
  [Documentation]    Користувач  ${USERS.users['${provider}'].broker}  намагається подати скаргу на умови оголошеної  закупівлі
  Дочекатись синхронізації з майданчиком    ${provider}
  ${complaint}=  Get From List  ${COMPLAINTS}  0
  Set To Dictionary  ${complaint.data}   status   pending
  Викликати для учасника   ${provider}   Подати скаргу   ${TENDER['TENDER_UAID']}   ${complaint}
  Set To Dictionary  ${USERS.users['${provider}'].complaints}  complaint  ${complaint}


Можливість скасувати скаргу на умови
  [Tags]   ${USERS.users['${provider}'].broker}: Можливість скасувати скаргу на умови
  ...      provider
  ...      ${USERS.users['${provider}'].broker}
  ${complaint}=  Get From Dictionary  ${USERS.users['${provider}'].complaints}  complaint
  Set To Dictionary  ${complaint.data}   status   cancelled
  Set To Dictionary  ${complaint.data}   cancellationReason   test_draft_cancellation
  Викликати для учасника   ${provider}     Обробити скаргу    ${TENDER['TENDER_UAID']}  1  ${complaint}



Можливість редагувати однопредметний тендер після продовження періоду подання пропозицій
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Можливість оголосити тендер
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  Викликати для учасника   ${tender_owner}  Внести зміни в тендер  ${TENDER['TENDER_UAID']}   description     description


Перевірити на зміну статус пропозицій після редагування інформації про закупівлю після другої зміни
  [Tags]   ${USERS.users['${provider}'].broker}: Можливість змінити цінову пропозицію
  ...      provider  provider1
  ...      ${USERS.users['${provider}'].broker}  ${USERS.users['${provider1}'].broker}
  ${usernames}=  Create List  ${provider}  ${provider1}
  :FOR  ${username}  IN  @{usernames}
  \  Дочекатись синхронізації з майданчиком    ${username}
  \  Викликати для учасника   ${username}   Пошук тендера по ідентифікатору   ${TENDER['TENDER_UAID']}
  \  ${bid}=  Викликати для учасника  ${username}  Отримати пропозицію  ${TENDER['TENDER_UAID']}
  \  Should Be Equal  ${bid.data.status}  invalid
  \  Log  ${bid}


Можливість оновити статус цінової пропозиції першого учасника після другої зміни
  [Tags]   ${USERS.users['${provider}'].broker}: Можливість змінити цінову пропозицію
  ...      provider
  ...      ${USERS.users['${provider}'].broker}
  ${activestatusresp}=  create_data_dict  data.status  active
  Log   ${USERS.users['${provider}'].bidresponses['resp'].data.status}
  ${activestatusresp}=  Викликати для учасника   ${provider}   Змінити цінову пропозицію   ${TENDER['TENDER_UAID']}   ${activestatusresp}
  Set To Dictionary  ${USERS.users['${provider}'].bidresponses}   activestatusresp   ${activestatusresp}
  log  ${activestatusresp}


Повторно подати цінову пропозицію другим учасником після другої зміни
  [Tags]   ${USERS.users['${provider1}'].broker}: Можливість подати цінову пропозицію
  ...      provider1
  ...      ${USERS.users['${provider1}'].broker}
  ${bid}=  test bid data
  Log  ${bid}
  ${bidresponses}=  Create Dictionary
  Set To Dictionary  ${bidresponses}                 bid   ${bid}
  Set To Dictionary  ${USERS.users['${provider1}']}   bidresponses  ${bidresponses}
  ${resp}=  Викликати для учасника   ${provider1}   Подати цінову пропозицію   ${TENDER['TENDER_UAID']}   ${bid}
  Set To Dictionary  ${USERS.users['${provider1}'].bidresponses}   resp  ${resp}
  log  ${resp}


Неможливість подати скаргу на умови менше ніж за 4 дні до завершення періоду подання пропозицій
  [Tags]   ${USERS.users['${provider}'].broker}: Можливість подати скаргу на умови
  ...      provider
  ...      ${USERS.users['${provider}'].broker}
  [Documentation]    Користувач  ${USERS.users['${provider}'].broker}  намагається подати скаргу на умови оголошеної  закупівлі
  Log  ${USERS.users['${provider}'].tender_data.data.complaintPeriod.endDate}
  Дочекатись Дати   ${USERS.users['${provider}'].tender_data.data.complaintPeriod.endDate}
  Дочекатись синхронізації з майданчиком    ${provider}
  ${complaint}=  Get From List  ${COMPLAINTS}  0
  Set To Dictionary  ${complaint.data}   status   pending
  Викликати для учасника   ${provider}   Подати скаргу   shouldfail   ${TENDER['TENDER_UAID']}   ${COMPLAINTS[0]}
