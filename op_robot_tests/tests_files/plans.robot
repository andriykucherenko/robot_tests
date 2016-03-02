*** Settings ***
Library         op_robot_tests.tests_files.service_keywords
Library         String
Library         Collections
Library         Selenium2Library
Library         DebugLibrary
Resource        keywords.robot
Resource        keywords_plans.robot
Resource        resource.robot
Suite Setup     TestSuiteSetup
Suite Teardown  Close all browsers

*** Variables ***
${mode}         single

${role}         viewer
${broker}       Quinta

${question_id}  0

*** Test Cases ***
Можливість створити план
  [Tags]   ${USERS.users['${tender_owner}'].broker}: Можливість створити план
  ...      tender_owner
  ...      ${USERS.users['${tender_owner}'].broker}
  ...      minimal
  [Documentation]   Створення плану
  ${plan_data}=  Підготовка початкових даних плану
  ${PLAN_UAID}=  Викликати для учасника  ${tender_owner}  Створити план  ${plan_data}
  ${LAST_MODIFICATION_DATE}=  Get Current TZdate
  Set To Dictionary  ${USERS.users['${tender_owner}']}  initial_data  ${plan_data}
  Set To Dictionary  ${TENDER}   PLAN_UAID             ${PLAN_UAID}
  Set To Dictionary  ${TENDER}   LAST_MODIFICATION_DATE  ${LAST_MODIFICATION_DATE}
  Log  ${TENDER}


